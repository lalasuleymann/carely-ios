//
//  AppointmentCard.swift
//  Carely
//
//  Created by Lala Suleymanova on 12.10.26.
//

import SwiftUI

struct AppointmentCard: View {

    let appointment: Appointment
    let viewModel: AppointmentViewModel
    var onCancel: (() -> Void)? = nil

    // MARK: - Doctor Information
    private var doctorSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundStyle(AppColors.primary)

            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.doctorName)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)

                Text(appointment.specialty)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer(minLength: 8)

            statusBadge
        }
    }

    // MARK: - Status Badge
    private var statusBadge: some View {
        let color = viewModel.statusColor(for: appointment)

        return Text(viewModel.statusTitle(for: appointment))
            .font(AppTypography.caption)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Date and Time
    private var dateTimeSection: some View {
        HStack(spacing: 8) {
            Label {
                Text(viewModel.formattedDate(for: appointment))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            } icon: {
                Image(systemName: "calendar")
            }

            Spacer(minLength: 8)

            Label {
                Text(appointment.time)
                    .lineLimit(1)
                    .fixedSize()
            } icon: {
                Image(systemName: "clock")
            }
            .fixedSize()
        }
        .font(AppTypography.caption)
        .foregroundStyle(AppColors.secondaryText)
    }

    // MARK: - Fee and Actions
    private var footerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Consultation Fee")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Text(viewModel.formattedFee(for: appointment))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
            }

            Spacer()

            if viewModel.canCancel(appointment),
               let onCancel {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.error)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay {
                            Capsule()
                                .stroke(
                                    AppColors.error,
                                    lineWidth: 1
                                )
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            doctorSection

            Divider()
                .overlay(AppColors.divider)

            dateTimeSection

            footerSection
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    AppColors.divider,
                    lineWidth: 1
                )
        }
    }
}

#Preview {
    let viewModel = AppointmentViewModel()

    let appointment = Appointment(
        doctorID: 1,
        doctorName: "Dr. Sarah Mitchell",
        specialty: "Cardiology",
        date: Calendar.current.date(
            from: DateComponents(
                year: 2026,
                month: 10,
                day: 15
            )
        ) ?? .now,
        time: "10:00 AM",
        consultationFee: 120,
        status: .upcoming
    )

    AppointmentCard(
        appointment: appointment,
        viewModel: viewModel,
        onCancel: {
            print("Cancel appointment tapped")
        }
    )
    .padding()
    .background(AppColors.background)
}
