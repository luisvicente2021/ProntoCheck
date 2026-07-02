//
//  AdminLoginViewModel.swift
//  ProntoCheck
//
//  Created by usuario on 01/07/26.
//

import Foundation
import CoreLocation
import UIKit

import Foundation

@MainActor
final class AdminLoginViewModel: ObservableObject {

    private let authRepository = AuthRepository()

    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoggedIn = false

    func login() async {
        errorMessage = nil

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Ingresa correo y contraseña"
            return
        }

        isLoading = true

        do {
            _ = try await authRepository.loginAdmin(
                email: email,
                password: password
            )

            isLoggedIn = true

        } catch {
            errorMessage = "Correo o contraseña incorrectos"
            print("Error login admin:", error)
        }

        isLoading = false
    }
}
