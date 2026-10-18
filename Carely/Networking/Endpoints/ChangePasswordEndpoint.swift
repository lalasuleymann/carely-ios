//
//  ChangePasswordEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum ChangePasswordEndpoint: Endpoint {
    case changePassword(ChangePasswordRequestDTO)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        "/api/auth/change-password"
    }

    var method: HttpMethod {
        .post
    }

    var body: Data? {
        guard case .changePassword(let request) = self else {
            return nil
        }

        return try? JSONEncoder().encode(request)
    }

    var requiresAuthentication: Bool {
        true
    }
}
