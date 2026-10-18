//
//  DefaultNetworkService.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

nonisolated final class DefaultNetworkService: NetworkService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: Endpoint,token: String? = nil) async throws -> T {
        let request = try endpoint.makeRequest(token: token)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                }

                throw NetworkError.serverError(
                    statusCode: httpResponse.statusCode
                )
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            if error.code == .notConnectedToInternet ||
                error.code == .networkConnectionLost {
                throw NetworkError.noInternetConnection
            }

            throw NetworkError.unknown(error)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
