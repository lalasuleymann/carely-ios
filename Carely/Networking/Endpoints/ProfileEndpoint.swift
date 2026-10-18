//
//  ProfileEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

enum ProfileEndpoint: Endpoint {
    case getProfile
    case updateProfile(UpdateProfileRequestDTO)

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        "/api/profile"
    }

    var method: HttpMethod {
        switch self {
        case .getProfile:
            return .get
        case .updateProfile:
            return .put
        }
    }

    var body: Data? {
        guard case .updateProfile(let request) = self else {
            return nil
        }

        return try? JSONEncoder().encode(request)
    }

    var requiresAuthentication: Bool {
        true
    }
}
