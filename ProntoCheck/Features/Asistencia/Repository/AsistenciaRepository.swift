//
//  AsistenciaRepository.swift
//  ProntoCheck
//
//  Created by usuario on 30/06/26.
//

import Foundation

final class AsistenciaRepository {
    private let networkService = NetworkService()

    func registrarAsistencia(
        empleadoId: UUID,
        puntoAccesoId: UUID,
        tipo: String
    ) async throws -> Asistencia {

        let request = RegistrarAsistenciaRequest(
            empleadoId: empleadoId,
            idPuntoAcceso: puntoAccesoId,
            tipo: tipo
        )

        let response: [Asistencia] = try await networkService.request(
            endpoint: PostEndpoint.createAttendances(request)
        )

        guard let asistencia = response.first else {
            throw NetworkError.invalidResponse
        }

        return asistencia
    }

    func obtenerUltimaAsistencia(empleadoId: UUID) async throws -> Asistencia? {
        let response: [Asistencia] = try await networkService.request(
            endpoint: PostEndpoint.ultimaAsistencia(empleadoId)
        )

        return response.first
    }
}
