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
    let appointmentType: String
    let action: () -> Void

    // MARK: - Doctor Section
    private var doctorSection: some View {
        HStack(spacing: 12) {
            doctorImage

            VStack(alignment: .leading, spacing: 5) {
                Text(doctorName)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.onPrimary)
                    .lineLimit(1)

                Text(specialty)
                    .font(AppTypography.caption)
                    .foregroundStyle(
                        AppColors.onPrimary.opacity(0.8)
                    )
            }

            Spacer()

            Text(appointmentType)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    AppColors.onPrimary.opacity(0.9)
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Appointment Info Section
    private var appointmentInfoSection: some View {
        HStack(spacing: 12) {
            dateView

            Spacer()

            Rectangle()
                .fill(
                    AppColors.onPrimary.opacity(0.35)
                )
                .frame(width: 1, height: 28)

            Spacer()

            timeView

            Image(systemName: "chevron.right")
                .font(
                    .system(size: 13, weight: .semibold)
                )
                .foregroundStyle(AppColors.onPrimary)
        }
    }

    // MARK: - Date
    private var dateView: some View {
        Label(date, systemImage: "calendar")
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.onPrimary)
            .lineLimit(1)
    }

    // MARK: - Time
    private var timeView: some View {
        Label(time, systemImage: "clock")
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.onPrimary)
    }

    // MARK: - Doctor Image
    private var doctorImage: some View {
        Image(systemName: "person.fill")
            .font(.system(size: 24))
            .foregroundStyle(AppColors.primary)
            .frame(width: 56, height: 56)
            .background(
                AppColors.onPrimary.opacity(0.9)
            )
            .clipShape(Circle())
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 18) {
                doctorSection

                Rectangle()
                    .fill(
                        AppColors.onPrimary.opacity(0.25)
                    )
                    .frame(height: 1)

                appointmentInfoSection
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(AppColors.primary)
            .clipShape(
                RoundedRectangle(cornerRadius: 22)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UpcomingAppointmentCard(
        doctorName: "Dr. Sarah Mitchell",
        specialty: "Cardiologist",
        date: "Thu, Sep 25, 2026",
        time: "10:00 AM",
        appointmentType: "In-Person"
    ) {
        print("Appointment tapped")
    }
}
