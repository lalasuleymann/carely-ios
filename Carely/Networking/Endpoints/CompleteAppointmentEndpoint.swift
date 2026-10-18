//
//  CompleteAppointmentEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum CompleteAppointmentEndpoint: Endpoint {
    case completeAppointment(id: Int)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .completeAppointment(let id):
            return "/api/appointments/\(id)/complete"
        }
    }

    var method: HttpMethod {
        .patch
    }

    var requiresAuthentication: Bool {
        true
    }
}
