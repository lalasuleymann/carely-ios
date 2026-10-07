//
//  RatingView.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    let reviewCount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.warning)

            Text(String(format: "%.1f", rating))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primaryText)

            Text("(\(reviewCount))")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}

#Preview {
    RatingView(rating: 4.9,reviewCount: 312)
}
