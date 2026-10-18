//
//  AppointmentDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct AppointmentDTO: Decodable, Identifiable {
    let id: Int
    let doctorId: Int
    let doctorName: String
    let specialty: String
    let facilityName: String
    let consultationFee: Double
    let startAt: String
    let endAt: String
    let status: String
    let notes: String?
    let createdAt: String
}
