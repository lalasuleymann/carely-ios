//
//  NearbyPlace.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import Foundation
import MapKit

struct NearbyPlace: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem

    var name: String {
        mapItem.name ?? "Unknown Place"
    }

    var coordinate: CLLocationCoordinate2D {
        mapItem.placemark.coordinate
    }

    var address: String {
        let placemark = mapItem.placemark

        return [
            placemark.thoroughfare,
            placemark.subThoroughfare,
            placemark.locality
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    var phoneNumber: String? {
        mapItem.phoneNumber
    }

    var website: URL? {
        mapItem.url
    }
}
