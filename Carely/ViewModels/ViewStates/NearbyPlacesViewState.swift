//
//  NearbyPlacesViewState.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import Foundation

enum NearbyPlacesViewState {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
