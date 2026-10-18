//
//  DoctorDTO.swift
//  Carely
//
//  Created by Lala Suleymanova on 16.10.26.
//

import Foundation

struct DoctorDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let imageUrl: String?
    let bio: String?
    let experienceYears: Int
    let consultationFee: Double
    let specialty: SpecialtyDTO
    let medicalFacility: MedicalFacilityDTO
    let rating: Double
    let reviewCount: Int

    var toDoctor: Doctor {
        Doctor(
            id: id,
            name: "\(firstName) \(lastName)",
            specialty: specialty.name,
            imageURL: imageUrl ?? "",
            rating: rating,
            reviewCount: reviewCount,
            experience: experienceYears,
            location: medicalFacility.address,
            latitude: medicalFacility.latitude,
            longitude: medicalFacility.longitude,
            consultationFee: consultationFee,
            isAvailable: false,
            facilityIDs: [medicalFacility.id]
        )
    }
}
