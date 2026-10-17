//
//  DoctorAvailabilityEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

enum DoctorAvailabilityEndpoint: Endpoint {
    case availability(doctorId: Int, date: String)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .availability(let doctorId, _):
            return "/api/doctors/\(doctorId)/availability"
        }
    }

    var method: HttpMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .availability(_, let date):
            return [
                URLQueryItem(name: "date", value: date)
            ]
        }
    }
}
