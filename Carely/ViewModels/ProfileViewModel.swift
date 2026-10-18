//
//  ProfileViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    private let networkService: NetworkService

    private(set) var profile: ProfileDTO?
    private(set) var isLoading = false
    private(set) var isSaving = false

    var errorMessage: String?
    var successMessage: String?

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Load Profile
    func loadProfile() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                errorMessage = "Please log in again."
                return
            }

            let result: ProfileDTO = try await networkService.request(
                ProfileEndpoint.getProfile,
                token: token
            )

            profile = result
        } catch {
            errorMessage = error.localizedDescription
            print("Profile loading error: \(error)")
        }
    }

    // MARK: - Update Profile
    func updateProfile(firstName: String,lastName: String,phoneNumber: String?) async {
        guard !isSaving else { return }

        let trimmedFirstName = firstName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedLastName = lastName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedPhoneNumber = phoneNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedFirstName.count >= 2 else {
            errorMessage = "First name must contain at least 2 characters."
            return
        }

        guard trimmedLastName.count >= 2 else {
            errorMessage = "Last name must contain at least 2 characters."
            return
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        defer {
            isSaving = false
        }

        do {
            guard let token = try KeychainService.readToken(),
                  !token.isEmpty else {
                errorMessage = "Please log in again."
                return
            }

            let request = UpdateProfileRequestDTO(
                firstName: trimmedFirstName,
                lastName: trimmedLastName,
                phoneNumber: trimmedPhoneNumber?.isEmpty == true
                    ? nil
                    : trimmedPhoneNumber,
                profileImageUrl: profile?.profileImageUrl
            )

            let response: ProfileUpdateResponseDTO =
                try await networkService.request(
                    ProfileEndpoint.updateProfile(request),
                    token: token
                )

            profile = response.user

        } catch {
            errorMessage = error.localizedDescription
            print("Profile update error: \(error)")
        }
    }

    // MARK: - Clear Messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
