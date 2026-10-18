//
//  UpdateProfileRequestDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct UpdateProfileRequestDTO: Encodable {
    let firstName: String
    let lastName: String
    let phoneNumber: String?
    let profileImageUrl: String?
}
