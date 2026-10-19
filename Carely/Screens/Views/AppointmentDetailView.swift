//
//  AppointmentDetailView.swift
//  Carely
//
//  Created by Lala Suleymanova on 12.10.26.
//

import SwiftUI

struct AppointmentDetailView: View {
    let appointment: Appointment
    let viewModel: AppointmentViewModel

    @Environment(\.dismiss) private var dismiss

    @Environment(\.locale)
    private var locale
    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }
    
    // MARK: - Doctor Section
    private var doctorSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(AppColors.primary)

            Text(appointment.doctorName)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)

            Text(appointment.specialty)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)

            Text(
                LocalizationManager.localized(
                    viewModel.statusTitle(for: appointment),
                    locale: locale
                )
            )
            .font(AppTypography.caption)
            .foregroundStyle(viewModel.statusColor(for: appointment))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                viewModel.statusColor(for: appointment).opacity(0.12)
            )
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Appointments Info Section
    private var appointmentInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appointment Information")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)

            infoRow(
                icon: "calendar",
                title: localize("Date"),
                value: viewModel.formattedDate(for: appointment, locale: locale)
            )

            infoRow(
                icon: "clock",
                title: localize("Time"),
                value: appointment.time
            )

            infoRow(
                icon: "number",
                title: localize("Appointment ID"),
                value: String(appointment.id.uuidString.prefix(8))
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Consultation Fee Section
    private var consultationFeeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Consultation Fee")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)

                Text(viewModel.formattedFee(for: appointment))
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)
            }

            Spacer()

            Image(systemName: "creditcard")
                .font(.title2)
                .foregroundStyle(AppColors.primary)
        }
        .padding(20)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Info Row
    private func infoRow(icon: String,title: String,value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Text(value)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
            }

            Spacer()
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                doctorSection
                appointmentInfoSection
                consultationFeeSection

                if viewModel.canCancel(appointment) {
                    VStack(spacing: 12) {
                        Button {
                            viewModel.completeAppointment(id: appointment.id)
                            dismiss()
                        } label: {
                            Text("Mark as Completed")
                                .font(AppTypography.bodyMedium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.success)

                        Button(role: .destructive) {
                            viewModel.cancelAppointment(id: appointment.id)
                            dismiss()
                        } label: {
                            Text("Cancel Appointment")
                                .font(AppTypography.bodyMedium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppColors.error)
                    }
                }
            }
            .padding(20)
        }
        .background(AppColors.background)
        .navigationTitle("Appointment Details")
        .navigationBarTitleDisplayMode(.inline)
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

    NavigationStack {
        AppointmentDetailView(
            appointment: appointment,
            viewModel: viewModel
        )
    }
}
