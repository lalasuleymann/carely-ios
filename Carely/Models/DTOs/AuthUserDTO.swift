//
//  AuthUserDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import Foundation

struct AuthUserDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let profileImageUrl: String?
}
