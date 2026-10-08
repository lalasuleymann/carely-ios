//
//  UpcomingAppointmentCard.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import SwiftUI

struct UpcomingAppointmentCard: View {
    let doctorName: String
    let specialty: String
    let date: String
    let time: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Appointment")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.onPrimary.opacity(0.8))

                Spacer()

                Image(systemName: "calendar")
                    .foregroundStyle(AppColors.onPrimary)
            }

            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(AppColors.onPrimary.opacity(0.8))
                    .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(doctorName)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.onPrimary)

                    Text(specialty)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.onPrimary.opacity(0.8))
                }

                Spacer()
            }

            HStack(spacing: 16) {
                Label(date, systemImage: "calendar")
                Label(time, systemImage: "clock")
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.onPrimary)

            Button {
                action()
            } label: {
                Text("View Appointment")
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColors.onPrimary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .padding(20)
        .background(AppColors.primary)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}

#Preview {
    UpcomingAppointmentCard(
        doctorName: "Dr. Sarah Mitchell",
        specialty: "Cardiologist",
        date: "Today",
        time: "14:30"
    ) {
        print("Appointment tapped")
    }
}
