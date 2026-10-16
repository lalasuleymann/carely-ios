//
//  NetworkService.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

protocol NetworkService {
    func request<T: Decodable>(_ type: T.Type,from endpoint: Endpoint) async throws -> T
}
