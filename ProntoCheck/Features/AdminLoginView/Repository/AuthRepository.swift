//
//  AuthRepository.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation

final class AuthRepository {
    private let networkService = NetworkService()

    func loginAdmin(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)

        let response: AuthResponse = try await networkService.request(
            endpoint: AuthEndpoint.login(request)
        )

        return response
    }
}
