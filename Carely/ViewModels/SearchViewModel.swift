//
//  SearchViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class SearchViewModel {
    var searchText = ""
    var searchResults: [Doctor] = []
    var state: SearchViewState = .idle
    var errorMessage: String?

    var selectedSpecialty = "All"
    var selectedRating = "Any"
    var minimumPrice = 0.0
    var onlyAvailable = false

    private(set) var doctors: [Doctor] = []

    private let networkService: NetworkService
    private var hasLoadedDoctors = false
    private var isLoading = false
    private var hasAttemptedSearch = false

    private(set) var specialtyList: [SpecialtyDTO] = []

    var specialties: [String] {
        ["All"] + specialtyList.map(\.name)
    }

    private let specialtyService: SpecialtyService

    let ratings = [
        "Any",
        "4.0+",
        "4.5+",
        "4.8+"
    ]

    init(
        networkService: NetworkService = DefaultNetworkService(),
        specialtyService: SpecialtyService? = nil
    ) {
        self.networkService = networkService
        self.specialtyService = specialtyService
            ?? DefaultSpecialtyService(networkService: networkService)
    }

    // MARK: - Load Specialities
    func loadSpecialties() async {
        do {
            specialtyList = try await specialtyService.fetchSpecialties()
        } catch {
            print("Failed to load specialties: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Doctors
    func loadDoctors() async {
        guard !hasLoadedDoctors, !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        state = .loading

        defer {
            isLoading = false
        }

        do {
            let response: [DoctorDTO] = try await networkService.request(
                DoctorEndpoint.all(),
                token: nil
            )

            doctors = response.map(\.toDoctor)
            hasLoadedDoctors = true

            if hasAttemptedSearch {
                updateSearchResults()
            } else {
                searchResults = []
                state = .idle
            }
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Search
    func search() {
        hasAttemptedSearch = true

        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty || hasActiveFilters else {
            searchResults = []
            errorMessage = nil
            state = .idle
            return
        }

        if hasLoadedDoctors {
            updateSearchResults()
        } else {
            Task {
                await loadDoctors()

                if hasLoadedDoctors {
                    updateSearchResults()
                }
            }
        }
    }

    // MARK: - Filters
    func applyFilters() {
        hasAttemptedSearch = true

        if hasLoadedDoctors {
            updateSearchResults()
        } else {
            Task {
                await loadDoctors()

                if hasLoadedDoctors {
                    updateSearchResults()
                }
            }
        }
    }

    private var hasActiveFilters: Bool {
        selectedSpecialty != "All" ||
        selectedRating != "Any" ||
        minimumPrice > 0 ||
        onlyAvailable
    }

    // MARK: - Filter Results
    private func updateSearchResults() {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty || hasActiveFilters else {
            searchResults = []
            state = .idle
            return
        }
        searchResults = filterDoctors(doctors, query: query)

        state = searchResults.isEmpty ? .empty : .loaded
    }

    private func filterDoctors(_ doctors: [Doctor],query: String) -> [Doctor] {
        doctors.filter { doctor in

            let matchesSearch =
                query.isEmpty ||
                doctor.name.localizedCaseInsensitiveContains(query) ||
                doctor.specialty.localizedCaseInsensitiveContains(query)

            let matchesSpecialty =
                selectedSpecialty == "All" ||
                doctor.specialty.localizedCaseInsensitiveCompare(
                    selectedSpecialty
                ) == .orderedSame

            let matchesRating =
                selectedRating == "Any" ||
                doctor.rating >= ratingValue

            let matchesPrice =
                doctor.consultationFee >= minimumPrice

            let matchesAvailability =
                !onlyAvailable || doctor.isAvailable

            return matchesSearch &&
                matchesSpecialty &&
                matchesRating &&
                matchesPrice &&
                matchesAvailability
        }
    }

    private var ratingValue: Double {
        switch selectedRating {
        case "4.0+":
            return 4.0
        case "4.5+":
            return 4.5
        case "4.8+":
            return 4.8
        default:
            return 0
        }
    }
}
