//
//  ErrorStateView.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.error)

            Text(title)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)

            Text(message)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)

            if let retryAction {
                Button(action: retryAction) {
                    Text("Try Again")
                        .font(AppTypography.button)
                        .foregroundStyle(AppColors.primary)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }
}
