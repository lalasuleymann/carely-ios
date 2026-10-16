//
//  NetworkError.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError
    case encodingError
    case unauthorized
    case noInternetConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "API URL düzgün deyil."
        case .invalidResponse:
            return "Serverdən düzgün cavab alınmadı."
        case .serverError(let statusCode):
            return "Server xətası: \(statusCode)"
        case .decodingError:
            return "Server məlumatlarını oxumaq mümkün olmadı."
        case .encodingError:
            return "Sorğu məlumatlarını hazırlamaq mümkün olmadı."
        case .unauthorized:
            return "Sessiya bitib. Yenidən daxil ol."
        case .noInternetConnection:
            return "İnternet bağlantısını yoxla."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
