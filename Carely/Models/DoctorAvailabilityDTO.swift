//
//  DoctorAvailabilityDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

struct DoctorAvailabilityDTO: Decodable {
    let doctorId: Int
    let date: String
    let timeZone: String
    let availableSlots: [String]
}
