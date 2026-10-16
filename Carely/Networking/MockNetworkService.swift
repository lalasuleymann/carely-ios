//
//  MockNetworkService.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

final class MockNetworkService: NetworkService {
    private let resultData: Data
    private let shouldFail: Bool

    init<T: Encodable>(response: T,shouldFail: Bool = false) throws {
        self.resultData = try JSONEncoder().encode(response)
        self.shouldFail = shouldFail
    }

    func request<T: Decodable>(_ endpoint: Endpoint,token: String? = nil) async throws -> T {
        if shouldFail {
            throw NetworkError.serverError(statusCode: 500)
        }

        do {
            return try JSONDecoder().decode(T.self, from: resultData)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
