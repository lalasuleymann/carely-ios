//
//  CreateAppointmentRequestDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct CreateAppointmentRequestDTO: Encodable {
    let doctorId: Int
    let startAt: String
    let notes: String?
}
