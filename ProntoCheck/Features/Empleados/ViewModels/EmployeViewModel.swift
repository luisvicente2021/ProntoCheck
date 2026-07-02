//
//  EmployeViewModel.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import Foundation

@MainActor
final class EmpleadosViewModel: ObservableObject {
    
    @Published var empleados: [Empleado] = []
    @Published var listState: ViewState = .idle
    @Published var crudState: ViewState = .idle
    
    private let repository: EmpleadosRepository
    
    private var paginaActual = 0
    private let limite = 20
    private var puedeCargarMas = true
    
    init(repository: EmpleadosRepository = EmpleadosRepository()) {
        self.repository = repository
    }
    
    func cargarPagina(reiniciar: Bool = false) {
        guard !listState.isLoading else { return }
        
        if reiniciar {
            paginaActual = 0
            puedeCargarMas = true
            empleados.removeAll()
        }
        
        guard puedeCargarMas else { return }
        
        listState = .loading
        
        Task {
            do {
                let nuevosEmpleados = try await repository.obtenerEmpleados(
                    pagina: paginaActual,
                    limite: limite
                )
                
                if reiniciar {
                    empleados = nuevosEmpleados
                } else {
                    empleados.append(contentsOf: nuevosEmpleados)
                }
                
                puedeCargarMas = nuevosEmpleados.count == limite
                paginaActual += 1
                listState = .success
                
            } catch {
                listState = .failure(error.localizedDescription)
            }
        }
    }
    
    func registrarEmpleado(empleado: Empleado) {
        crudState = .loading
        
        Task {
            do {
                let nuevoEmpleado = try await repository.registrarEmpleado(empleado: empleado)
                
                empleados.insert(nuevoEmpleado, at: 0)
                crudState = .success
                
            } catch {
                crudState = .failure(error.localizedDescription)
                print("ERROR REGISTRANDO:", error)
                
            }
        }
    }
    /*
    func actualizarEmpleado(id: String, empleado: Empleado) {
        crudState = .loading
        
        Task {
            do {
                let empleadoActualizado = try await repository.actualizarEmpleado(
                    id: id,
                    empleado: empleado
                )
                
                if let index = empleados.firstIndex(where: { $0.id == id }) {
                    empleados[index] = empleadoActualizado
                }
                
                crudState = .success
                
            } catch {
                crudState = .failure(error.localizedDescription)
            }
        }
    }
     */
}
