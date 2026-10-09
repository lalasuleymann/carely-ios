//
//  SearchViewState.swift
//  Carely
//
//  Created by Lala Suleymanova on 09.10.26.
//


import Foundation

enum SearchViewState {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}
