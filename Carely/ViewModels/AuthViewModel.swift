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
    
    func updateCurrentUser(from profile: ProfileDTO) {
        currentUser = AuthUserDTO(
            id: profile.id,
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            phoneNumber: profile.phoneNumber,
            profileImageUrl: profile.profileImageUrl
        )
    }
    
    func restoreCurrentUser() async {
        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                currentUser = nil
                isAuthenticated = false
                return
            }

            let profile: ProfileDTO = try await networkService.request(
                ProfileEndpoint.getProfile,
                token: token
            )
            currentUser = AuthUserDTO(
                id: profile.id,
                firstName: profile.firstName,
                lastName: profile.lastName,
                email: profile.email,
                phoneNumber: profile.phoneNumber,
                profileImageUrl: profile.profileImageUrl
            )

            isAuthenticated = true
        } catch {
            error.localizedDescription
        }
    }

    // MARK: - Email Login
    func login(email: String, password: String, locale: Locale) async -> Bool {
        guard validateEmail(email), !password.isEmpty else {
            errorMessage = LocalizationManager.localized("Please enter a valid email and password.", locale: locale)
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
    
    func updateCurrentUser(firstName: String,lastName: String,phoneNumber: String?) {
        guard let currentUser else { return }

        self.currentUser = AuthUserDTO(
            id: currentUser.id,
            firstName: firstName,
            lastName: lastName,
            email: currentUser.email,
            phoneNumber: phoneNumber,
            profileImageUrl: currentUser.profileImageUrl
        )
    }
    
    // MARK: - Change Password
    func changePassword(currentPassword: String,newPassword: String,confirmPassword: String,locale: Locale) async -> Bool {
        guard !currentPassword.isEmpty else {
            errorMessage = LocalizationManager.localized("Please enter your current password.", locale: locale)
            return false
        }

        guard newPassword.count >= 8 else {
            errorMessage = LocalizationManager.localized("New password must contain at least 8 characters.", locale: locale)
            return false
        }

        guard newPassword.count <= 100 else {
            errorMessage = LocalizationManager.localized("New password cannot exceed 100 characters.", locale: locale)
            return false
        }

        guard newPassword == confirmPassword else {
            errorMessage = LocalizationManager.localized("New passwords do not match.", locale: locale)
            return false
        }

        guard currentPassword != newPassword else {
            errorMessage = LocalizationManager.localized("New password must be different from the current password.", locale: locale)
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                errorMessage = "Please log in again."
                return false
            }

            let request = ChangePasswordRequestDTO(
                currentPassword: currentPassword,
                newPassword: newPassword
            )

            let _: ChangePasswordResponseDTO =
                try await networkService.request(
                    ChangePasswordEndpoint.changePassword(request),
                    token: token
                )

            return true
        } catch {
            errorMessage = error.localizedDescription
            error.localizedDescription
            return false
        }
    }

    // MARK: - Set Password
    func setPassword(newPassword: String, confirmPassword: String) async -> Bool {
        guard newPassword.count >= 8 else {
            errorMessage = "Password must contain at least 8 characters."
            return false
        }

        guard newPassword.count <= 100 else {
            errorMessage = "Password cannot exceed 100 characters."
            return false
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                errorMessage = "Please log in again."
                return false
            }

            let request = SetPasswordRequestDTO(
                newPassword: newPassword
            )

            let _: SetPasswordResponseDTO =
                try await networkService.request(
                    SetPasswordEndpoint.setPassword(request),
                    token: token
                )

            return true
        } catch {
            errorMessage = error.localizedDescription
            error.localizedDescription
            return false
        }
    }

    // MARK: - Delete Account
    func deleteAccount() async -> Bool {
        guard let token = try? KeychainService.readToken(),
              !token.isEmpty else {
            errorMessage = "Token tapılmadı. Yenidən login et."
            return false
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let _: DeleteAccountResponseDTO = try await networkService.request(
                AuthEndpoint.deleteAccount,
                token: token
            )

            try KeychainService.deleteToken()

            currentUser = nil
            isAuthenticated = false
            errorMessage = nil

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Logout
    func logout() {
        do {
            try KeychainService.deleteToken()
            currentUser = nil
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
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
