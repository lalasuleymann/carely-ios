//
//  AppointmentEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum AppointmentEndpoint: Endpoint {
    case getAppointments
    case getAppointment(id: Int)
    case cancelAppointment(id: Int)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .getAppointments:
            return "/api/appointments"

        case .getAppointment(let id):
            return "/api/appointments/\(id)"

        case .cancelAppointment(let id):
            return "/api/appointments/\(id)/cancel"
        }
    }

    var method: HttpMethod {
        switch self {
        case .getAppointments, .getAppointment:
            return .get

        case .cancelAppointment:
            return .patch
        }
    }

    var requiresAuthentication: Bool {
        true
    }
}
