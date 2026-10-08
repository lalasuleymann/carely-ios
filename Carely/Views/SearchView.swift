//
//  SearchView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var showFilters = false
    
    // MARK: - Search
    private var searchSection: some View {
        HStack(spacing: 12) {
            SearchBar(
                text: $viewModel.searchText,
                placeholder: "Search doctors..."
            )
            .onSubmit {
                viewModel.search()
            }

            Button {
                showFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        AppColors.primary
                    )
                    .frame(width: 52, height: 52)
                    .background(AppColors.surface)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                        .stroke(
                            AppColors.divider,
                            lineWidth: 1
                        )
                    }
            }
        }
    }
    
    // MARK: - Results
    private var resultsSection: some View {
        VStack(alignment: .leading,spacing: 12) {
            if !viewModel.searchResults.isEmpty {
                Text("Search Results")
                    .font(AppTypography.headline)
                    .foregroundStyle(
                        AppColors.primaryText
                    )

                ForEach(viewModel.searchResults) { doctor in
                    DoctorCard(doctor: doctor)
                }
            } else if viewModel.hasSearched {
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
            .sheet(isPresented: $showFilters) {
                FilterSheetView(viewModel: viewModel)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    SearchView()
}
