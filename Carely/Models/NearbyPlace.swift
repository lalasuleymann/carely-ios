//
//  NearbyPlace.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import Foundation
import MapKit

struct NearbyPlace: Identifiable {
    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let phoneNumber: String?
    let website: URL?
    let imageURL: URL?
    let type: String

    init(dto: MedicalFacilityDTO) {
        self.id = dto.id
        self.name = dto.name
        self.coordinate = dto.coordinate
        self.address = dto.address
        self.phoneNumber = dto.phoneNumber
        self.website = dto.website.flatMap(URL.init(string:))
        self.imageURL = dto.imageUrl.flatMap(URL.init(string:))
        self.type = String(dto.type)
    }

    var mapItem: MKMapItem {
        let placemark = MKPlacemark(
            coordinate: coordinate
        )
        let item = MKMapItem(placemark: placemark)
        item.name = name
        item.phoneNumber = phoneNumber
        item.url = website
        return item
    }
}
