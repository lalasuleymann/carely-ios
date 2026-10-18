//
//  MedicalFacilityDetailDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct MedicalFacilityDetailDTO: Decodable {
    let id: Int
    let name: String
    let type: Int
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let website: String?
    let imageUrl: String?
    let doctors: [FacilityDoctorDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, type, address, latitude, longitude
        case phoneNumber, website
        case imageUrl
        case doctors
    }
}
