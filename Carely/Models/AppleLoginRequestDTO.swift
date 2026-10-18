//
//  AppleLoginRequestDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct AppleLoginRequestDTO: Encodable {
    let identityToken: String
    let firstName: String?
    let lastName: String?
    let email: String?
}
