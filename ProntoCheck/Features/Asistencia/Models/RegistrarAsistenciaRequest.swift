//
//  RegistrarAsistenciaRequest.swift
//  ProntoCheck
//
//  Created by usuario on 30/06/26.
//

import Foundation

struct RegistrarAsistenciaRequest: Encodable {
    let empleadoId: UUID
    let idPuntoAcceso: UUID
    let tipo: String

    enum CodingKeys: String, CodingKey {
        case empleadoId = "empleado_id"
        case idPuntoAcceso = "id_punto_acceso"
        case tipo
    }
}

extension RegistrarAsistenciaRequest {
    
    func toDomain() -> Asistencia {
        
        return  Asistencia(id: nil, empleadoId: empleadoId, tipo: tipo, idPuntoAcceso: idPuntoAcceso)
    }
}

