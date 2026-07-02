//
//  PuntoAccesoRepository.swift
//  ProntoCheck
//
//  Created by usuario on 30/06/26.
//

import Foundation
import CoreLocation

final class PuntoAccesoRepository {
    
    private let network = NetworkService()
    
    func obtenerPuntoMasCercano(
        puntoDeAcceso: PuntoAcceso
    ) async throws -> PuntoAcceso {
        
        let puntos = try await obtenerPuntos()
        
        guard !puntos.isEmpty else {
            throw NSError(
                domain: "PuntoAccesoRepository",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "No hay puntos de acceso registrados."]
            )
        }
        
        let ubicacionActual = CLLocation(latitude: puntoDeAcceso.latitud, longitude: puntoDeAcceso.longitud)
        
        guard let puntoMasCercano = puntos.min(by: { punto1, punto2 in
            let distancia1 = CLLocation(
                latitude: punto1.latitud,
                longitude: punto1.longitud
            ).distance(from: ubicacionActual)
            
            let distancia2 = CLLocation(
                latitude: punto2.latitud,
                longitude: punto2.longitud
            ).distance(from: ubicacionActual)
            
            return distancia1 < distancia2
        }) else {
            throw NSError(
                domain: "PuntoAccesoRepository",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "No se pudo calcular el punto más cercano."]
            )
        }
        
        return puntoMasCercano
    }
    
    func obtenerPuntos() async throws -> [PuntoAcceso] {

        try await network.request(endpoint: EmpleadosEndpoint.puntoAcceso)
    }
}
