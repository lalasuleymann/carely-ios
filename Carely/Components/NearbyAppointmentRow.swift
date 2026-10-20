//
//  NearbyAppointmentRow.swift
//  Carely
//
//  Created by Lala Suleymanova on 14.10.26.
//


import SwiftUI

struct NearbyAppointmentRow: View {
    let appointment: Appointment
    let appointmentViewModel: AppointmentViewModel

    var body: some View {
        NavigationLink {
            AppointmentDetailView(
                appointment: appointment,
                viewModel: appointmentViewModel,
                doctor: appointmentViewModel.doctors.first {
                    $0.id == appointment.doctorID
                }
            )
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label(
                        appointment.date.formatted(
                            .dateTime
                                .month(.abbreviated)
                                .day()
                                .year()
                        ),
                        systemImage: "calendar"
                    )

                    Spacer()

                    Text(appointment.time)
                        .lineLimit(1)
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.primaryText)

                HStack {
                    Text("Consultation Fee")
                        .foregroundStyle(AppColors.secondaryText)

                    Spacer()

                    Text("$\(Int(appointment.consultationFee))")
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.primaryText)
                }
                .font(.subheadline)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        AppColors.secondaryText.opacity(0.15),
                        lineWidth: 1
                    )
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
