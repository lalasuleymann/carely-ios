//
//  Endpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var requiresAuthentication: Bool { get }
}

extension Endpoint {
    var method: HttpMethod { .get }
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
    var body: Data? { nil }
    var requiresAuthentication: Bool { false }

    func makeRequest(token: String? = nil) throws -> URLRequest {
        guard var components = URLComponents(
            string: baseURL + path
        ) else {
            throw NetworkError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        request.setValue(
            ContentType.json.rawValue,
            forHTTPHeaderField: HttpHeader.accept
        )

        if body != nil {
            request.setValue(
                ContentType.json.rawValue,
                forHTTPHeaderField: HttpHeader.contentType
            )
        }

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        if requiresAuthentication {
            guard let token, !token.isEmpty else {
                throw NetworkError.unauthorized
            }

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: HttpHeader.authorization
            )
        }

        return request
    }
}
