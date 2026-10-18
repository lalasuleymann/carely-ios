//
//  CompleteAppointmentResponseDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct CompleteAppointmentResponseDTO: Decodable {
    let message: String
    let id: Int
    let status: String
}
