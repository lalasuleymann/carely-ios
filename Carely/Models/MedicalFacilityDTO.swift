//
//  MedicalFacilityDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation
import CoreLocation

struct MedicalFacilityDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let type: Int
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let website: String?
    let imageUrl: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
