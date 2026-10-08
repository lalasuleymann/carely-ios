//
//  SearchViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import Foundation
import Observation

@Observable
final class SearchViewModel {
    var searchText = ""
    var searchResults: [Doctor] = []
    var hasSearched = false

    func search() {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchResults = []
            hasSearched = false
            return
        }

        hasSearched = true

        searchResults = MockDoctorData.doctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(query) ||
            doctor.specialty.localizedCaseInsensitiveContains(query)
        }
    }
}
