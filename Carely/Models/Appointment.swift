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
    // Local identifier used by the existing SwiftUI views.
    var id: UUID

    // Backend appointment identifier.
    var serverID: Int?

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
        serverID: Int? = nil,
        doctorID: Int,
        doctorName: String,
        specialty: String,
        date: Date,
        time: String,
        consultationFee: Double,
        status: AppointmentStatus = .upcoming
    ) {
        self.id = id
        self.serverID = serverID
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
