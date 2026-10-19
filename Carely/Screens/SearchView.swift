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

    @Environment(\.locale) private var locale

    // MARK: - Localization
    private func localized(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }

    // MARK: - Search
    private var searchSection: some View {
        HStack(spacing: 12) {
            SearchBar(
                text: $viewModel.searchText,
                placeholder: localized("Search doctors...")
            )
            .onSubmit {
                viewModel.search()
            }

            Button {
                showFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 52, height: 52)
                    .background(AppColors.surface)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                AppColors.divider,
                                lineWidth: 1
                            )
                    }
            }
            .accessibilityLabel(localized("Filters"))
        }
    }

    // MARK: - Results
    @ViewBuilder
    private var resultsSection: some View {
        switch viewModel.state {
        case .idle:
            emptySearchView

        case .loading:
            ProgressView(localized("Loading doctors..."))
                .tint(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, 50)

        case .loaded:
            if viewModel.searchResults.isEmpty {
                emptySearchView
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.searchResults) { doctor in
                        NavigationLink {
                            DoctorDetailView(doctor: doctor)
                        } label: {
                            DoctorCard(doctor: doctor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

        case .empty:
            noResultsView

        case .error(let message):
            VStack(spacing: 12) {
                ErrorStateView(
                    title: localized("Something went wrong"),
                    message: message
                )

                Button(localized("Try Again")) {
                    Task {
                        await viewModel.loadDoctors()
                    }
                }
                .foregroundStyle(AppColors.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Empty Search
    private var emptySearchView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: localized("Search for a doctor"),
            message: localized("Search by doctor name or specialty")
        )
    }

    // MARK: - No Results
    private var noResultsView: some View {
        EmptyStateView(
            icon: "person.crop.circle.badge.xmark",
            title: localized("No doctors found"),
            message: localized(
                "Try searching with another name or specialty."
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                searchSection
                resultsSection
            }
            .padding(16)
        }
        .background(AppColors.background)
        .navigationTitle(localized("Search"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) {
            FilterSheetView(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .task {
            async let doctorsTask: Void = viewModel.loadDoctors()
            async let specialtiesTask: Void = viewModel.loadSpecialties()

            _ = await (doctorsTask, specialtiesTask)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
