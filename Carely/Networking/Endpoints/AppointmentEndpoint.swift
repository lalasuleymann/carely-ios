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
    case submitReview(id: Int, rating: Int)

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

        case .submitReview(let id, _):
            return "/api/appointments/\(id)/review"
        }
    }

    var method: HttpMethod {
        switch self {
        case .getAppointments, .getAppointment:
            return .get

        case .cancelAppointment:
            return .patch

        case .submitReview:
            return .post
        }
    }

    var requiresAuthentication: Bool {
        true
    }

    var body: Data? {
        switch self {
        case .submitReview(_, let rating):
            return try? JSONEncoder().encode(
                SubmitReviewRequest(rating: rating)
            )

        default:
            return nil
        }
    }
}

private struct SubmitReviewRequest: Encodable {
    let rating: Int
}
