//
//  HttpHeader.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

enum HttpHeader {
    static let contentType = "Content-Type"
    static let authorization = "Authorization"
    static let accept = "Accept"
}

enum ContentType: String {
    case json = "application/json"
}
