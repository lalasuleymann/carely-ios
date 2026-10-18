//
//  ProfileDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct ProfileDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let profileImageUrl: String?
    let createdAt: String?
    let hasPassword: Bool
}
