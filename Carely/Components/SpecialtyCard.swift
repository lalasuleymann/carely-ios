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
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(AppColors.primary)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)
        }
        .frame(width: 88, height: 88)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider, lineWidth: 1)
        }
    }
}

#Preview {
    SpecialtyCard(title: "Cardiology",icon: "heart.text.square")
}
