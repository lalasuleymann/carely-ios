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
    let doctor: Doctor?

    @Environment(\.dismiss) private var dismiss
    var shouldScrollToRating = false
    @Environment(\.locale)
    private var locale
    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }
    
    // MARK: - Doctor Section
    private var doctorSection: some View {
        VStack(spacing: 12) {
            Group {
                if let doctor,
                   let url = URL(string: doctor.imageURL),
                   !doctor.imageURL.isEmpty {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            doctorImagePlaceholder
                        }
                    }
                } else {
                    doctorImagePlaceholder
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())

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
    
    private var doctorImagePlaceholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(AppColors.primary)
            .frame(width: 100, height: 100)
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
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    doctorSection
                    appointmentInfoSection
                    consultationFeeSection

                    if appointment.status == .completed {
                        AppointmentRatingView(
                            appointment: appointment,
                            viewModel: viewModel
                        )
                        .frame(maxWidth: .infinity)
                        .id("appointment-rating")
                    }

                    if viewModel.canCancel(appointment) {
                        VStack(spacing: 12) {
                            Button {
                                viewModel.completeAppointment(
                                    id: appointment.id
                                )
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
                                viewModel.cancelAppointment(
                                    id: appointment.id
                                )
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
            .onAppear {
                if shouldScrollToRating {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo(
                                "appointment-rating",
                                anchor: .center
                            )
                        }
                    }
                }
            }
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
    let doctor = Doctor(
        id: 1,
        name: "Dr. Sarah Mitchell",
        specialty: "Cardiology",
        imageURL: "https://example.com/doctor.jpg",
        rating: 4.8,
        reviewCount: 120,
        experience: 10,
        location: "Baku",
        latitude: 40.4093,
        longitude: 49.8671,
        consultationFee: 120,
        isAvailable: true
    )

    NavigationStack {
        AppointmentDetailView(
            appointment: appointment,
            viewModel: viewModel, doctor: doctor
        )
    }
}
