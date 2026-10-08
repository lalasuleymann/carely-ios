//
//  SpecialtyCard.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import SwiftUI

struct SpecialtyCard: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(AppColors.primary)
                .frame(width: 42, height: 42)
                .background(
                    AppColors.primary.opacity(0.10)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 96, height: 100)
        .background(AppColors.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    AppColors.divider,
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    SpecialtyCard(title: "Cardiology",icon: "heart.text.square")
}
