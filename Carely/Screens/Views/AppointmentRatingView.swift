//
//  AppointmentRatingView.swift
//  Carely
//
//  Created by Lala Suleymanova on 19.10.26.
//

import SwiftUI

struct AppointmentRatingView: View {
    let appointment: Appointment
    let viewModel: AppointmentViewModel

    @Environment(\.locale) private var locale
    

    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var rating: Int

    init(
        appointment: Appointment,
        viewModel: AppointmentViewModel
    ) {
        self.appointment = appointment
        self.viewModel = viewModel
        _rating = State(
            initialValue: Int(appointment.myRating ?? 0)
        )
    }
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }
    
    @MainActor
    private func submit(_ value: Int) async {
        guard rating == 0, !isSubmitting else { return }

        isSubmitting = true
        errorMessage = nil
        successMessage = nil

        do {
            try await viewModel.submitReview(
                appointment: appointment,
                rating: value
            )

            appointment.myRating = Double(value)
            appointment.hasReview = true
            rating = value
            successMessage = localize("Thank you for your rating!")
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(localize("Rate your appointment"))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 14) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        Task {
                            await submit(star)
                        }
                    } label: {
                        Image(
                            systemName: star <= rating
                                ? "star.fill"
                                : "star"
                        )
                        .font(.system(size: 28))
                        .foregroundStyle(
                            star <= rating ? .yellow : .gray
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isSubmitting || rating > 0)
                }
            }

            if isSubmitting {
                ProgressView()
                    .controlSize(.small)
            }

            if let successMessage {
                Text(successMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.success)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.error)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

}
