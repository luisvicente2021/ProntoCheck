//
//  Asistencia.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation

struct Asistencia: Codable, Identifiable {
    let id: UUID?
    let empleadoId: UUID
    let tipo: String
    let idPuntoAcceso: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case empleadoId = "empleado_id"
        case tipo
        case idPuntoAcceso = "id_punto_acceso"
    }
}

