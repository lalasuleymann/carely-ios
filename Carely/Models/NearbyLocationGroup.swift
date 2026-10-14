//
//  NearbyLocationGroup.swift
//  Carely
//
//  Created by Lala Suleymanova on 14.10.26.
//

import Foundation
import CoreLocation

struct NearbyLocationGroup: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let appointments: [Appointment]
}
