//
//  Employe.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import Foundation

struct Empleado: Decodable, Identifiable, Equatable {
    let id: UUID
    let email: String
    let nombre: String
    let apellidoPaterno: String?
    let apellidoMaterno: String?
    let residencial: String?
    let direccion: String?
    let telefonoCasa: String?
    let telefonoEmpresa: String?
    let activo: Bool?
    let jornadaHoras: Int?
    let fotoRostro: String?
    let faceEmbedding: [Float]?
    
    init(
        id: UUID,
        email: String,
        nombre: String,
        apellidoPaterno: String? = nil,
        apellidoMaterno: String? = nil,
        residencial: String? = nil,
        direccion: String? = nil,
        telefonoCasa: String? = nil,
        telefonoEmpresa: String? = nil,
        activo: Bool? = true,
        jornadaHoras: Int? = 8,
        fotoRostro: String? = nil,
        faceEmbedding: [Float]?
    ) {
        self.id = id
        self.email = email
        self.nombre = nombre
        self.apellidoPaterno = apellidoPaterno
        self.apellidoMaterno = apellidoMaterno
        self.residencial = residencial
        self.direccion = direccion
        self.telefonoCasa = telefonoCasa
        self.telefonoEmpresa = telefonoEmpresa
        self.activo = activo
        self.jornadaHoras = jornadaHoras
        self.fotoRostro = fotoRostro
        self.faceEmbedding = faceEmbedding
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nombre
        case apellidoPaterno = "apellido_paterno"
        case apellidoMaterno = "apellido_materno"
        case residencial
        case direccion
        case telefonoCasa = "telefono_casa"
        case telefonoEmpresa = "telefono_empresa"
        case activo
        case jornadaHoras = "jornada_horas"
        case fotoRostro = "foto_rostro"
        case faceEmbedding = "face_embedding_ios"
        
    }
    
    var nombreCompleto: String {
        [nombre, apellidoPaterno, apellidoMaterno]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var iniciales: String {
        let primera = nombre.first.map { String($0) } ?? ""
        let segunda = apellidoPaterno?.first.map { String($0) } ?? ""
        return "\(primera)\(segunda)".uppercased()
    }
}
