//
//  RegisterRequestDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import Foundation

struct RegisterRequestDTO: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}
