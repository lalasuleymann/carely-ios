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
        }
    }

    var method: HttpMethod {
        .post
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
        }
    }
}
