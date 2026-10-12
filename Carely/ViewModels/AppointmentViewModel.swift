//
//  AppointmentViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class AppointmentViewModel {
    private(set) var appointments: [Appointment] = []

    func statusTitle(for appointment: Appointment) -> String {
        switch appointment.status {
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }

    func statusColor(for appointment: Appointment) -> Color {
        switch appointment.status {
        case .upcoming:
            return AppColors.primary
        case .completed:
            return AppColors.success
        case .cancelled:
            return AppColors.error
        }
    }

    func formattedDate(for appointment: Appointment) -> String {
        appointment.date.formatted(
            .dateTime
                .month(.abbreviated)
                .day()
                .year()
        )
    }

    func formattedFee(for appointment: Appointment) -> String {
        "$\(Int(appointment.consultationFee))"
    }

    func canCancel(_ appointment: Appointment) -> Bool {
        appointment.status == .upcoming
    }

    func bookAppointment(doctor: Doctor,date: Date,time: String) {
        let appointment = Appointment(
            doctorID: doctor.id,
            doctorName: doctor.name,
            specialty: doctor.specialty,
            date: date,
            time: time,
            consultationFee: doctor.consultationFee
        )

        appointments.append(appointment)
    }

    func cancelAppointment(id: UUID) {
        guard let index = appointments.firstIndex(
            where: { $0.id == id }
        ) else {
            return
        }

        appointments[index].status = .cancelled
    }
}
