//
//  AuthResponseDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import Foundation

struct AuthResponseDTO: Decodable {
    let message: String
    let token: String
    let user: AuthUserDTO
}
