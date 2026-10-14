//
//  Doctor.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import Foundation

struct Doctor: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let specialty: String
    let imageURL: String
    let rating: Double
    let reviewCount: Int
    let experience: Int
    let location: String
    let latitude: Double
    let longitude: Double
    let consultationFee: Double
    let isAvailable: Bool
}
