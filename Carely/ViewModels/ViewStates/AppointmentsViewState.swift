//
//  AppointmentsViewState.swift
//  Carely
//
//  Created by Lala Suleymanova on 12.10.26.
//

import Foundation

enum AppointmentsViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
