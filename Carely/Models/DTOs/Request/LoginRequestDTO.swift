//
//  LoginRequestDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}
