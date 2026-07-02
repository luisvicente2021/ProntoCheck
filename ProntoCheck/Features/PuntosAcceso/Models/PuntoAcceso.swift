//
//  PuntoAcceso.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation
import CoreLocation

struct PuntoAcceso: Decodable, Identifiable {

    let id: UUID
    let nombrePunto: String
    let nombreResidencial: String?
    let latitud: Double
    let longitud: Double
    let radioMetros: Double
    let activo: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case nombrePunto = "nombre_punto"
        case nombreResidencial = "nombre_residencial"
        case latitud
        case longitud
        case radioMetros = "radio_metros"
        case activo
    }
    
      var coordenada: CLLocation {
          CLLocation(
              latitude: latitud,
              longitude: longitud
          )
      }
}
