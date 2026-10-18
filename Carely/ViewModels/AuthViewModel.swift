//
//  AuthViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//


import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    private let authService: AuthService
    private let networkService: NetworkService

    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var currentUser: AuthUserDTO?
    private(set) var isAuthenticated = false

    init(
        authService: AuthService = DefaultAuthService(),
        networkService: NetworkService = DefaultNetworkService()
    ) {
        self.authService = authService
        self.networkService = networkService
    }

    // MARK: - Email Login
    func login(email: String, password: String) async -> Bool {
        guard validateEmail(email), !password.isEmpty else {
            errorMessage = "Please enter a valid email and password."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await authService.login(
                email: email,
                password: password
            )

            try KeychainService.save(token: response.token)

            currentUser = response.user
            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Google Login
    func loginWithGoogle(idToken: String) async -> Bool {
        guard !idToken.isEmpty else {
            errorMessage = "Google authentication failed. Please try again."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: AuthResponseDTO = try await networkService.request(
                AuthEndpoint.google(
                    GoogleLoginRequestDTO(idToken: idToken)
                ),
                token: nil
            )

            try KeychainService.save(token: response.token)

            currentUser = response.user
            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Apple Login
    func loginWithApple(identityToken: String,firstName: String?,lastName: String?,email: String?) async -> Bool {
        guard !identityToken.isEmpty else {
            errorMessage = "Apple authentication failed. Please try again."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = AppleLoginRequestDTO(
                identityToken: identityToken,
                firstName: firstName,
                lastName: lastName,
                email: email
            )

            let response: AuthResponseDTO = try await networkService.request(
                AuthEndpoint.apple(request),
                token: nil
            )

            try KeychainService.save(token: response.token)

            currentUser = response.user
            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Register
    func register(firstName: String,lastName: String,email: String,password: String) async -> Bool {
        guard
            firstName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2,
            lastName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2,
            validateEmail(email),
            password.count >= 8
        else {
            errorMessage = "Check your details. Password must contain at least 8 characters."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await authService.register(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )

            try KeychainService.save(token: response.token)

            currentUser = response.user
            isAuthenticated = true
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Authentication State
    func checkAuthentication() {
        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                isAuthenticated = false
                currentUser = nil
                return
            }

            isAuthenticated = true
        } catch {
            isAuthenticated = false
            currentUser = nil
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Validation
    private func validateEmail(_ email: String) -> Bool {
        let value = email.trimmingCharacters(in: .whitespacesAndNewlines)

        return value.range(
            of: #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#,
            options: .regularExpression
        ) != nil
    }
}
