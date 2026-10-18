//
//  AuthService.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import Foundation

protocol AuthService {
    func login(email: String, password: String) async throws -> AuthResponseDTO
    func register(firstName: String,lastName: String,email: String,password: String) async throws -> AuthResponseDTO
}

nonisolated final class DefaultAuthService: AuthService {
    private let networkService: NetworkService

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    func login(email: String,password: String) async throws -> AuthResponseDTO {
        let request = LoginRequestDTO(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        return try await networkService.request(
            AuthEndpoint.login(request),
            token: nil
        )
    }

    func register(firstName: String,lastName: String,email: String,password: String) async throws -> AuthResponseDTO {
        let request = RegisterRequestDTO(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )

        return try await networkService.request(
            AuthEndpoint.register(request),
            token: nil
        )
    }
}
