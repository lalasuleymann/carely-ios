//
//  PrimaryButton.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        title: String,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(AppColors.onPrimary)
                } else {
                    Text(title)
                        .font(AppTypography.button)
                }
            }
            .foregroundStyle(AppColors.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isDisabled
                    ? AppColors.secondaryText.opacity(0.4)
                    : AppColors.primary
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Book Appointment") {
            print("Book tapped")
        }

        PrimaryButton(
            title: "Continue",
            isLoading: true
        ) {
            print("Continue tapped")
        }

        PrimaryButton(
            title: "Disabled",
            isDisabled: true
        ) {
            print("Disabled tapped")
        }
    }
    .padding(16)
}
