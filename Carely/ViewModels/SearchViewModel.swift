
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
    private(set) var specialtyList: [SpecialtyDTO] = []

    private let networkService: NetworkService
    private let specialtyService: SpecialtyService

    private var hasLoadedDoctors = false
    private var isLoading = false
    private var hasAttemptedSearch = false

    var specialties: [String] {
        ["All"] + specialtyList.map(\.name)
    }

    let ratings = [
        "Any",
        "1.0+",
        "2.0+",
        "3.0+",
        "4.0+"
    ]

    init(
        networkService: NetworkService = DefaultNetworkService(),
        specialtyService: SpecialtyService? = nil
    ) {
        self.networkService = networkService
        self.specialtyService = specialtyService
            ?? DefaultSpecialtyService(
                networkService: networkService
            )
    }

    // MARK: - Load Specialties
    func loadSpecialties() async {
        do {
            specialtyList = try await specialtyService.fetchSpecialties()
        } catch {
            errorMessage = error.localizedDescription
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
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard query.count >= 3 || hasActiveFilters else {
            hasAttemptedSearch = false
            searchResults = []
            errorMessage = nil
            state = .idle
            return
        }

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

    // MARK: - Apply Filters
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
    // MARK: - Reset Search Results
    func clearSearchResults() {
        searchResults = []
        hasAttemptedSearch = false
        errorMessage = nil
        state = .idle
    }

    // MARK: - Active Filters
    private var hasActiveFilters: Bool {
        selectedSpecialty != "All"
            || selectedRating != "Any"
            || minimumPrice > 0
            || onlyAvailable
    }

    // MARK: - Update Search Results
    private func updateSearchResults() {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !query.isEmpty || hasActiveFilters || hasAttemptedSearch else {
            searchResults = []
            state = .idle
            return
        }

        searchResults = filterDoctors(
            doctors,
            query: query
        )

        state = searchResults.isEmpty ? .empty : .loaded
    }

    // MARK: - Filter Doctors
    private func filterDoctors(_ doctors: [Doctor],query: String) -> [Doctor] {
        doctors.filter { doctor in

            let matchesSearch =
                query.isEmpty
                || doctor.name.localizedCaseInsensitiveContains(query)
                || doctor.specialty.localizedCaseInsensitiveContains(query)

            let matchesSpecialty =
                selectedSpecialty == "All"
                || doctor.specialty.localizedCaseInsensitiveCompare(
                    selectedSpecialty
                ) == .orderedSame

            let matchesRating =
                selectedRating == "Any"
                || doctor.rating >= ratingValue

            let matchesPrice =
                doctor.consultationFee >= minimumPrice

            let matchesAvailability =
                !onlyAvailable || doctor.isAvailable

            return matchesSearch
                && matchesSpecialty
                && matchesRating
                && matchesPrice
                && matchesAvailability
        }
    }

    // MARK: - Rating Value
    private var ratingValue: Double {
        guard selectedRating != "Any" else {
            return 0
        }

        let value = selectedRating.replacingOccurrences(
            of: "+",
            with: ""
        )

        return Double(value) ?? 0
    }
}

