//
//  Appointment.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import Foundation
import SwiftData

@Model
final class Appointment {
    var id: UUID
    var doctorID: Int
    var doctorName: String
    var specialty: String
    var date: Date
    var time: String
    var consultationFee: Double
    var statusRawValue: String

    var status: AppointmentStatus {
        get {
            AppointmentStatus(rawValue: statusRawValue) ?? .upcoming
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }

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
        self.statusRawValue = status.rawValue
    }
}

enum AppointmentStatus: String, Codable {
    case upcoming
    case completed
    case cancelled
}
