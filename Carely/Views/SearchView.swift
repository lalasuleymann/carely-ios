//
//  SearchView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [Doctor] = []
    @State private var hasSearched = false
    
    // MARK: - Search
    private var searchSection: some View {
        SearchBar(text: $searchText,placeholder: "Search doctors...")
        .onSubmit {
            search()
        }
    }

    // MARK: - Results
    private var resultsSection: some View {
        VStack(alignment: .leading,spacing: 12) {
            if !searchResults.isEmpty {
                Text("Search Results")
                    .font(AppTypography.headline)
                    .foregroundStyle(
                        AppColors.primaryText
                    )

                ForEach(searchResults) { doctor in
                    DoctorCard(doctor: doctor)
                }
            } else if hasSearched {
                noResultsView
            } else {
                emptySearchView
            }
        }
    }

    // MARK: - Empty Search
    private var emptySearchView: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundStyle(
                    AppColors.primary
                )

            Text("Search for a doctor")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(
                    AppColors.primaryText
                )

            Text("Search by doctor name or specialty")
            .font(AppTypography.caption)
            .foregroundStyle(
                AppColors.secondaryText
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }

    // MARK: - No Results
    private var noResultsView: some View {
        VStack(spacing: 8) {
            Image(systemName:"person.crop.circle.badge.xmark")
            .font(.system(size: 32))
            .foregroundStyle(
                AppColors.secondaryText
            )

            Text("No doctors found")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(
                    AppColors.primaryText
                )

            Text("Try searching with another name or specialty.")
            .font(AppTypography.caption)
            .foregroundStyle(
                AppColors.secondaryText
            )
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }

    // MARK: - Search Logic
    private func search() {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchResults = []
            hasSearched = false
            return
        }
        hasSearched = true
        
        searchResults = MockDoctorData.doctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(query) ||
            doctor.specialty.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading,spacing: 20) {
                    searchSection
                    resultsSection
                }
                .padding(16)
            }
            .background(AppColors.background)
            .navigationTitle("Search Doctors")
        }
    }
}

#Preview {
    SearchView()
}
