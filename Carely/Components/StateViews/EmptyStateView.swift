//
//  EmptyStateView.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(AppColors.primary)

            Text(title)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)

            Text(message)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 50)
    }
}
