//
//  MockDoctorData.swift
//  Carely
//
//  Created by Lala Suleymanova on 07.10.26.
//

import Foundation

enum MockDoctorData {
    static let doctors: [Doctor] = [
        Doctor(
            id: 1,
            name: "Dr. Sarah Johnson",
            specialty: "Cardiologist",
            imageURL: "doctor1",
            rating: 4.9,
            reviewCount: 312,
            experience: 12,
            location: "Baku, Azerbaijan",
            consultationFee: 50,
            isAvailable: true
        ),
        Doctor(
            id: 2,
            name: "Dr. Michael Brown",
            specialty: "Neurologist",
            imageURL: "doctor2",
            rating: 4.8,
            reviewCount: 245,
            experience: 10,
            location: "Baku, Azerbaijan",
            consultationFee: 45,
            isAvailable: true
        ),
        Doctor(
            id: 3,
            name: "Dr. Emily Davis",
            specialty: "Dermatologist",
            imageURL: "doctor3",
            rating: 4.7,
            reviewCount: 189,
            experience: 8,
            location: "Baku, Azerbaijan",
            consultationFee: 40,
            isAvailable: false
        ),
        Doctor(
            id: 4,
            name: "Dr. James Wilson",
            specialty: "Dentist",
            imageURL: "doctor4",
            rating: 4.9,
            reviewCount: 278,
            experience: 15,
            location: "Baku, Azerbaijan",
            consultationFee: 35,
            isAvailable: true
        ),
        Doctor(
            id: 5,
            name: "Dr. Olivia Martinez",
            specialty: "Pediatrician",
            imageURL: "doctor5",
            rating: 4.8,
            reviewCount: 221,
            experience: 11,
            location: "Baku, Azerbaijan",
            consultationFee: 40,
            isAvailable: true
        )
    ]
}
