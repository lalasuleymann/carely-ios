//
//  SetPasswordEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum SetPasswordEndpoint: Endpoint {
    case setPassword(SetPasswordRequestDTO)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        "/api/auth/set-password"
    }

    var method: HttpMethod {
        .post
    }

    var body: Data? {
        guard case .setPassword(let request) = self else {
            return nil
        }

        return try? JSONEncoder().encode(request)
    }

    var requiresAuthentication: Bool {
        true
    }
}
