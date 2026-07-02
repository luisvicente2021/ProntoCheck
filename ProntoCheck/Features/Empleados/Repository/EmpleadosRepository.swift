//
//  EmpleadosRepository.swift
//  ProntoCheck
//
//  Created by usuario on 26/06/26.
//

import Foundation

final class EmpleadosRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func obtenerEmpleados(
        pagina: Int,
        limite: Int
    ) async throws -> [Empleado] {
        
        let offset = pagina * limite
        
        return try await networkService.request(
            endpoint: EmpleadosEndpoint.obtenerTodos(
                limit: limite,
                offset: offset
            )
        )
    }
    
    func registrarEmpleado(
        empleado: Empleado
    ) async throws -> Empleado {
        
        let request = CrearEmpleadoRequest(
            email: empleado.email,
            nombre: empleado.nombre,
            apellidoPaterno: empleado.apellidoPaterno,
            apellidoMaterno: empleado.apellidoMaterno,
            residencial: empleado.residencial,
            direccion: empleado.direccion,
            telefonoCasa: empleado.telefonoCasa,
            telefonoEmpresa: empleado.telefonoEmpresa, 
            fotoRostro: empleado.fotoRostro,
            faceEmbedding: empleado.faceEmbedding
        )
        
        let response: [Empleado] = try await networkService.request(
            endpoint: EmpleadosEndpoint.crear(request)
        )
        
        guard let empleadoCreado = response.first else {
            throw NetworkError.invalidResponse
        }
        
        return empleadoCreado
    }
    
    /*func actualizarEmpleado(id: String, empleado: Empleado) async throws -> Empleado {
        let endpoint = "empleados?id=eq.\(id)"
        
        let response: [Empleado] = try await networkService.patch(
            endpoint: endpoint,
            body: empleado
        )
        
        guard let empleadoActualizado = response.first else {
            throw URLError(.badServerResponse)
        }
        
        return empleadoActualizado
    }*/
}
