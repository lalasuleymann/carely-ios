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
    var state: SearchViewState = .idle
    
    var selectedSpecialty = "All"
    var selectedRating = "Any"
    var minimumPrice = 0.0
    var onlyAvailable = false
    
    let specialties = [
        "All",
        "Cardiology",
        "Neurology",
        "Dermatology",
        "Dentistry",
        "Pediatrics"
    ]
    
    let ratings = [
        "Any",
        "4.0+",
        "4.5+",
        "4.8+"
    ]
    
    func search() {
        updateSearchResults()
    }
    
    func applyFilters() {
        updateSearchResults()
    }
    
    private func updateSearchResults() {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let hasActiveFilters =
        selectedSpecialty != "All" ||
        selectedRating != "Any" ||
        minimumPrice > 0 ||
        onlyAvailable
        
        guard !query.isEmpty || hasActiveFilters else {
            searchResults = []
            state = .idle
            return
        }
        
        searchResults = filterDoctors(
            MockDoctorData.doctors,
            query: query
        )
        
        state = searchResults.isEmpty ? .empty : .loaded
    }
    
    private func filterDoctors(_ doctors: [Doctor], query: String) -> [Doctor] {
        doctors.filter { doctor in
            let matchesSearch = query.isEmpty || doctor.name.localizedCaseInsensitiveContains(query) || doctor.specialty.localizedCaseInsensitiveContains(query)
            
            let matchesSpecialty: Bool
            
            switch selectedSpecialty {
            case "All":
                matchesSpecialty = true
            case "Cardiology":
                matchesSpecialty = doctor.specialty == "Cardiologist"
            case "Neurology":
                matchesSpecialty = doctor.specialty == "Neurologist"
            case "Dermatology":
                matchesSpecialty = doctor.specialty == "Dermatologist"
            case "Dentistry":
                matchesSpecialty = doctor.specialty == "Dentist"
            case "Pediatrics":
                matchesSpecialty = doctor.specialty == "Pediatrician"
            default:
                matchesSpecialty = false
            }
            
            let matchesRating = selectedRating == "Any" || doctor.rating >= ratingValue
            
            let matchesPrice = doctor.consultationFee >= minimumPrice
            
            let matchesAvailability = !onlyAvailable || doctor.isAvailable
            
            return matchesSearch && matchesSpecialty && matchesRating && matchesPrice && matchesAvailability
        }
    }
    
    private var ratingValue: Double {
        switch selectedRating {
        case "4.0+":
            return 4.0
        case "4.5+":
            return 4.5
        case "4.8+":
            return 4.8
        default:
            return 0
        }
    }
}
