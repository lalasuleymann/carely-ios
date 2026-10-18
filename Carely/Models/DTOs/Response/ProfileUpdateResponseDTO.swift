//
//  ProfileUpdateResponseDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct ProfileUpdateResponseDTO: Decodable {
    let message: String?
    let user: ProfileDTO
}
