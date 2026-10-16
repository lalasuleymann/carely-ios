//
//  Endpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

struct Endpoint {
    let path: String
    let method: HttpMethod
    let headers: [HttpHeader]
    let queryItems: [URLQueryItem]

    init(
        path: String,
        method: HttpMethod = .get,
        headers: [HttpHeader] = [],
        queryItems: [URLQueryItem] = []
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
    }
}
