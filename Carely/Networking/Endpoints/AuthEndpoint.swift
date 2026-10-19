//
//  AuthEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 17.10.26.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(LoginRequestDTO)
    case register(RegisterRequestDTO)
    case google(GoogleLoginRequestDTO)
    case apple(AppleLoginRequestDTO)
    case deleteAccount

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        switch self {
        case .login:
            return "/api/auth/login"
        case .register:
            return "/api/auth/register"
        case .google:
            return "/api/auth/google"
        case .apple:
            return "/api/auth/apple"
        case .deleteAccount:
            return "/api/auth/account"
        }
    }

    var method: HttpMethod {
        switch self {
        case .deleteAccount:
            return .delete
        default:
            return .post
        }
    }

    var body: Data? {
        let encoder = JSONEncoder()

        switch self {
        case .login(let request):
            return try? encoder.encode(request)
        case .register(let request):
            return try? encoder.encode(request)
        case .google(let request):
            return try? encoder.encode(request)
        case .apple(let request):
            return try? encoder.encode(request)
        case .deleteAccount:
            return nil
        }
    }
    
    var requiresAuthentication: Bool {
        switch self {
        case .deleteAccount:
            return true
        default:
            return false
        }
    }
}
