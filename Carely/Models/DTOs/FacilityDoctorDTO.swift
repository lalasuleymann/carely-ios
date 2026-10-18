//
//  FacilityDoctorDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 18.10.26.
//

import Foundation

struct FacilityDoctorDTO: Decodable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let imageUrl: String?
    let experienceYears: Int
    let consultationFee: Double
    let specialty: String
    let rating: Double
    let reviewCount: Int

    var name: String {
        "\(firstName) \(lastName)"
    }

    func toDoctor(facility: MedicalFacilityDetailDTO) -> Doctor {
        Doctor(
            id: id,
            name: name,
            specialty: specialty,
            imageURL: imageUrl ?? "",
            rating: rating,
            reviewCount: reviewCount,
            experience: experienceYears,
            location: facility.name,
            latitude: facility.latitude,
            longitude: facility.longitude,
            consultationFee: consultationFee,
            isAvailable: false,
            facilityIDs: [facility.id]
        )
    }
}
