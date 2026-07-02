//
//  CrearEmpleadoRequest.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation

struct CrearEmpleadoRequest: Encodable {
    let email: String
    let nombre: String
    let apellidoPaterno: String?
    let apellidoMaterno: String?
    let residencial: String?
    let direccion: String?
    let telefonoCasa: String?
    let telefonoEmpresa: String?
    let fotoRostro: String?
    let faceEmbedding: [Float]?
    
    enum CodingKeys: String, CodingKey {
        case email
        case nombre
        case apellidoPaterno = "apellido_paterno"
        case apellidoMaterno = "apellido_materno"
        case residencial
        case direccion
        case telefonoCasa = "telefono_casa"
        case telefonoEmpresa = "telefono_empresa"
        case fotoRostro = "foto_rostro"
        case faceEmbedding = "face_embedding_ios"
    }
}
