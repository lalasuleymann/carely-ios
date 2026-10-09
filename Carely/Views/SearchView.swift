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
    @ViewBuilder
    private var resultsSection: some View {
        switch viewModel.state {
        case .idle:
            emptySearchView
        case .loading:
            ProgressView("Loading doctors...")
                .tint(AppColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
        case .loaded:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.searchResults) { doctor in
                    DoctorCard(doctor: doctor)
                }
            }
        case .empty:
            noResultsView
        case .error(let message):
            ErrorStateView(
                title: "Something went wrong",
                message: message
            )
        }
    }

    // MARK: - Empty Search
    private var emptySearchView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Search for a doctor",
            message: "Search by doctor name or specialty"
        )
    }

    // MARK: - No Results
    private var noResultsView: some View {
        EmptyStateView(
            icon: "person.crop.circle.badge.xmark",
            title: "No doctors found",
            message: "Try searching with another name or specialty."
        )
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
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
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
