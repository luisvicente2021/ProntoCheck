
import Foundation
import CoreLocation
import UIKit

@MainActor
final class RelojViewModel: ObservableObject {

    private let empleadosRepository = EmpleadosRepository()
    private let asistenciaRepository = AsistenciaRepository()
    private let puntoRepository = PuntoAccesoRepository()
    private let faceService = FaceRecognitionService()
    private let locationManager = LocationManager()

    @Published var empleados: [Empleado] = []
    @Published var puntosAcceso: [PuntoAcceso] = []

    @Published var empleadoDetectado: Empleado?
    @Published var tipoDisponible: String = "entrada"

    @Published var estadoEscaner = "ESPERANDO"
    @Published var mensaje = "Coloca tu rostro frente a la cámara"

    @Published var faceOK = false
    @Published var gpsOK = false

    private let umbralReconocimiento: Float = 11.0
    
    @Published var horaActual = ""
    @Published var fechaActual = ""

    private var relojTask: Task<Void, Never>?

    func iniciar() async {
        
        iniciarReloj()
        locationManager.start()

        do {
            empleados = try await empleadosRepository.obtenerEmpleados(
                pagina: 0,
                limite: 100
            )
            puntosAcceso = try await puntoRepository.obtenerPuntos()
        } catch {
            mensaje = "Error cargando datos iniciales"
            print(error)
        }
    }
    
    private func iniciarReloj() {

        relojTask?.cancel()

        relojTask = Task {

            while !Task.isCancelled {

                actualizarFechaHora()

                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
    
    private func actualizarFechaHora() {

        let ahora = Date()

        let horaFormatter = DateFormatter()
        horaFormatter.locale = Locale(identifier: "es_MX")
        horaFormatter.dateFormat = "hh:mm:ss a"

        horaActual = horaFormatter.string(from: ahora)

        let fechaFormatter = DateFormatter()
        fechaFormatter.locale = Locale(identifier: "es_MX")
        fechaFormatter.dateFormat = "EEEE d 'de' MMMM yyyy"

        fechaActual = fechaFormatter.string(from: ahora)
            .capitalized
    }

    func detenerReloj() {

        relojTask?.cancel()
        relojTask = nil

        locationManager.stop()
    }

    func validarRostro(_ image: UIImage) async {
        do {
            estadoEscaner = "ESCANEANDO..."
            mensaje = "Analizando rostro..."

            guard let rostro = try await faceService.detectarRostro(in: image) else {
                limpiarReconocimiento(mensaje: "No se detectó ningún rostro")
                estadoEscaner = "NO DETECTADO"
                return
            }

            let nuevoEmbedding = try faceService.generarEmbedding(desde: rostro)

            guard let empleado = buscarEmpleadoPorRostro(nuevoEmbedding) else {
                limpiarReconocimiento(mensaje: "Rostro no reconocido")
                estadoEscaner = "NO AUTORIZADO"
                return
            }

            empleadoDetectado = empleado
            faceOK = true
            tipoDisponible = await obtenerSiguienteTipoParaEmpleado(empleado.id)

            mensaje = "Rostro reconocido correctamente"
            estadoEscaner = "ROSTRO OK"
            
            
            print("Empleados cargados:", empleados.count)
            print("Embedding nuevo:", nuevoEmbedding.count)
            
            if let punto = validarPuntoActual() {
                gpsOK = true
                mensaje = "Rostro reconocido en \(punto.nombrePunto)"
            } else {
                gpsOK = false
                mensaje = "Rostro reconocido, pero fuera del punto autorizado"
            }

        } catch {
            limpiarReconocimiento(mensaje: "Error al validar rostro")
            estadoEscaner = "ERROR"
            print(error)
        }
    }

    private func buscarEmpleadoPorRostro(_ nuevoEmbedding: [Float]) -> Empleado? {
        var mejorEmpleado: Empleado?
        var mejorDistancia: Float = .greatestFiniteMagnitude

        for empleado in empleados {
            guard let guardado = empleado.faceEmbedding,
                  guardado.count == nuevoEmbedding.count else {
                continue
            }

            let distancia = distanciaEuclidiana(nuevoEmbedding, guardado)

            print("Empleado:", empleado.nombreCompleto, "Distancia:", distancia)
     
                print("Embedding guardado:", empleado.faceEmbedding?.count ?? 0)

            if distancia < mejorDistancia {
                mejorDistancia = distancia
                mejorEmpleado = empleado
            }
        }

        print("Mejor distancia:", mejorDistancia)

        return mejorDistancia < umbralReconocimiento ? mejorEmpleado : nil
    }

    private func distanciaEuclidiana(_ a: [Float], _ b: [Float]) -> Float {
        sqrt(zip(a, b).map { pow($0 - $1, 2) }.reduce(0, +))
    }

    func registrarAsistencia() async {
        guard let empleado = empleadoDetectado else {
            mensaje = "No hay empleado detectado"
            return
        }

        guard let punto = validarPuntoActual() else {
            gpsOK = false
            mensaje = "No estás dentro de un punto autorizado"
            return
        }

        do {
            _ = try await asistenciaRepository.registrarAsistencia(
                empleadoId: empleado.id,
                puntoAccesoId: punto.id,
                tipo: tipoDisponible
            )

            mensaje = "\(tipoDisponible.capitalized) registrada correctamente"
            estadoEscaner = "\(tipoDisponible.uppercased()) REGISTRADA"

            limpiarDespuesDeRegistro()

        } catch {
            mensaje = "Error al registrar asistencia"
            print("ERROR al enviar asistencia:", error)
        }
    }

    private func validarPuntoActual() -> PuntoAcceso? {
        guard let location = locationManager.location else {
            print("❌ No se pudo obtener la ubicación")
            return nil
        }

        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy <= 50 else {
            print("⏳ Esperando mejor precisión GPS...")
            return nil
        }

        let ubicacionActual = CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        for punto in puntosAcceso {
            let distancia = ubicacionActual.distance(from: punto.coordenada)

            print("""
            Punto: \(punto.nombrePunto)
            Distancia: \(Int(distancia)) metros
            Radio permitido: \(Int(punto.radioMetros)) metros
            """)

            if distancia <= punto.radioMetros {
                gpsOK = true
                return punto
            }
        }

        return nil
    }

    private func obtenerSiguienteTipoParaEmpleado(_ empleadoId: UUID) async -> String {
        do {
            let ultima = try await asistenciaRepository.obtenerUltimaAsistencia(
                empleadoId: empleadoId
            )

            guard let ultima else {
                return "entrada"
            }

            return ultima.tipo == "entrada" ? "salida" : "entrada"

        } catch {
            print("Error obteniendo última asistencia:", error)
            return "entrada"
        }
    }

    private func limpiarReconocimiento(mensaje: String) {
        self.mensaje = mensaje
        faceOK = false
        gpsOK = false
        empleadoDetectado = nil
    }

    private func limpiarDespuesDeRegistro() {
        faceOK = false
        gpsOK = false
        empleadoDetectado = nil
        tipoDisponible = tipoDisponible == "entrada" ? "salida" : "entrada"
    }
}
