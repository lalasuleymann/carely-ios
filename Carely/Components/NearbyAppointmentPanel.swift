//
//  NearbyAppointmentPanel.swift
//  Carely
//
//  Created by Lala Suleymanova on 14.10.26.
//

import SwiftUI

struct NearbyAppointmentPanel: View {
    let group: NearbyLocationGroup
    let appointmentViewModel: AppointmentViewModel
    let onClose: () -> Void

    private var doctorIDs: [Int] {
        Array(Set(group.appointments.map(\.doctorID))).sorted()
    }

    private func appointments(for doctorID: Int) -> [Appointment] {
        group.appointments
            .filter { $0.doctorID == doctorID }
            .sorted {
                if $0.date == $1.date {
                    return $0.time < $1.time
                }

                return $0.date < $1.date
            }
    }

    private var contentHeight: CGFloat {
        let doctorCount = doctorIDs.count
        let appointmentCount = group.appointments.count
        let headerHeight: CGFloat = 42
        let rowHeight: CGFloat = 80
        let spacing: CGFloat = 12

        let totalHeight = CGFloat(doctorCount) * headerHeight + CGFloat(appointmentCount) * rowHeight + CGFloat(max(0, doctorCount + appointmentCount - 1)) * spacing

        return min(totalHeight, 300)
    }

    @ViewBuilder
    private func doctorSection(doctor: Doctor,doctorID: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(doctor.name)
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Text(doctor.specialty)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                if doctorID == doctorIDs.first {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close appointments")
                }
            }
            .padding(.horizontal, 4)

            ForEach(appointments(for: doctorID)) { appointment in
                NearbyAppointmentRow(
                    appointment: appointment,
                    appointmentViewModel: appointmentViewModel
                )
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(doctorIDs, id: \.self) { doctorID in
                    if let doctor = MockDoctorData.doctors.first(
                        where: { $0.id == doctorID }
                    ) {
                        doctorSection(doctor: doctor, doctorID: doctorID)
                    }
                }
            }
            .padding(14)
        }
        .frame(height: contentHeight)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: .black.opacity(0.12),
            radius: 10,
            y: 4
        )
        .padding(.horizontal, 20)
    }
}
