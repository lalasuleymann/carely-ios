//
//  FilterSheetView.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SearchViewModel

    // MARK: - Specialty
    private var specialtySection: some View {
        Section("Specialty") {
            Picker(
                "Specialty",
                selection: $viewModel.selectedSpecialty
            ) {
                ForEach(viewModel.specialties,id: \.self) { specialty in
                    Text(specialty)
                }
            }
        }
    }

    // MARK: - Rating
    private var ratingSection: some View {
        Section("Minimum Rating") {
            Picker(
                "Rating",
                selection: $viewModel.selectedRating
            ) {
                ForEach(viewModel.ratings,id: \.self) { rating in
                    Text(rating)
                }
            }
        }
    }

    // MARK: - Price
    private var priceSection: some View {
        Section("Consultation Fee") {
            VStack(spacing: 12) {
                HStack {
                    Text("$\(Int(viewModel.minimumPrice))")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(
                            AppColors.primaryText
                        )

                    Spacer()

                    Text("$100")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(
                            AppColors.secondaryText
                        )
                }

                Slider(
                    value: $viewModel.minimumPrice,
                    in: 0...100,
                    step: 5
                ) {
                    Text("Minimum price")
                }
                .tint(AppColors.primary)
            }
        }
    }
    
    // MARK: - Availability
    private var availabilitySection: some View {
        Section("Availability") {
            Toggle(
                "Available today",
                isOn: $viewModel.onlyAvailable
            )
        }
    }

    // MARK: - Actions
    private func resetFilters() {
        viewModel.selectedSpecialty = "All"
        viewModel.selectedRating = "Any"
        viewModel.minimumPrice = 0
        viewModel.onlyAvailable = false
    }

    private func applyFilters() {
        viewModel.applyFilters()
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                specialtySection
                ratingSection
                priceSection
                availabilitySection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Reset") {
                        resetFilters()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

}

#Preview {
    FilterSheetView(viewModel: SearchViewModel())
}
