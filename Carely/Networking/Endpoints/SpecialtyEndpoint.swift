//
//  SpecialtyEndpoint.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

enum SpecialtyEndpoint: Endpoint {
    case all

    var baseURL: String {
        APIConfig.baseURL
    }

    var path: String {
        "/api/specialties"
    }

    var method: HttpMethod {
        .get
    }
}
