//
//  CreateAppointmentEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum CreateAppointmentEndpoint: Endpoint {
    case create(CreateAppointmentRequestDTO)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        "/api/appointments"
    }

    var method: HttpMethod {
        .post
    }

    var body: Data? {
        guard case .create(let request) = self else {
            return nil
        }

        return try? JSONEncoder().encode(request)
    }

    var requiresAuthentication: Bool {
        true
    }
}
