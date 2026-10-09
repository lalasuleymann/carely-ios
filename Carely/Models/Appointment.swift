//
//  Appointment.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//

import Foundation

struct Appointment: Identifiable, Codable {
    let id: UUID
    let doctorID: Int
    let doctorName: String
    let specialty: String
    let date: Date
    let time: String
    let consultationFee: Double
    var status: AppointmentStatus

    init(
        id: UUID = UUID(),
        doctorID: Int,
        doctorName: String,
        specialty: String,
        date: Date,
        time: String,
        consultationFee: Double,
        status: AppointmentStatus = .upcoming
    ) {
        self.id = id
        self.doctorID = doctorID
        self.doctorName = doctorName
        self.specialty = specialty
        self.date = date
        self.time = time
        self.consultationFee = consultationFee
        self.status = status
    }
}

enum AppointmentStatus: String, Codable {
    case upcoming
    case completed
    case cancelled
}
