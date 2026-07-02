//
//  LoginRequest.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation


struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable {
    let accessToken: String
    let tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case user
    }
}

struct AuthUser: Decodable {
    let id: UUID
    let email: String?
}
