//
//  SpecialtyService.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

protocol SpecialtyService {
    func fetchSpecialties() async throws -> [SpecialtyDTO]
}

final class DefaultSpecialtyService: SpecialtyService {
    private let networkService: NetworkService

    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }

    func fetchSpecialties() async throws -> [SpecialtyDTO] {
        try await networkService.request(
            SpecialtyEndpoint.all,
            token: nil
        )
    }
}
