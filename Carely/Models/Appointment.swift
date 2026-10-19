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
    var serverID: Int?

    var doctorID: Int
    var doctorName: String
    var specialty: String
    var facilityName: String

    var date: Date
    var time: String
    var consultationFee: Double
    var statusRawValue: String
    var hasReview: Bool
    var myRating: Double?
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
        facilityName: String = "",
        date: Date,
        time: String,
        consultationFee: Double,
        status: AppointmentStatus = .upcoming,
        hasReview: Bool = false,
        myRating: Double? = nil
    ) {
        self.id = id
        self.serverID = serverID
        self.doctorID = doctorID
        self.doctorName = doctorName
        self.specialty = specialty
        self.facilityName = facilityName
        self.date = date
        self.time = time
        self.consultationFee = consultationFee
        self.statusRawValue = status.rawValue
        self.hasReview = hasReview
        self.myRating = myRating
    }
}

enum AppointmentStatus: String, Codable {
    case upcoming
    case completed
    case cancelled
}
