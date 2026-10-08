//
//  HomeViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 08.10.26.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    var doctors: [Doctor] = MockDoctorData.doctors
    var searchText = ""

    var filteredDoctors: [Doctor] {
        guard !searchText.isEmpty else {
            return doctors
        }

        return doctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(searchText) ||
            doctor.specialty.localizedCaseInsensitiveContains(searchText)
        }
    }
}
