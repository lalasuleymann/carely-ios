//
//  HealthStatCard.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI


struct HealthStatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.12))
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

            Text(value)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
}

#Preview {
    LazyVGrid(
        columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ],
        spacing: 12
    ) {
        HealthStatCard(
            title: "Appointments",
            value: "12",
            icon: "calendar",
            iconColor: AppColors.primary
        )

        HealthStatCard(
            title: "Doctors Seen",
            value: "5",
            icon: "stethoscope",
            iconColor: .blue
        )

        HealthStatCard(
            title: "Next Visit",
            value: "Sep 25",
            icon: "clock",
            iconColor: AppColors.warning
        )

        HealthStatCard(
            title: "Prescriptions",
            value: "2",
            icon: "pills",
            iconColor: AppColors.success
        )
    }
}
