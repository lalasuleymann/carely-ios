//
//  AppointmentViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import Foundation
import Observation

@Observable
final class AppointmentViewModel {
    
    private(set) var appointments: [Appointment] = []

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
