//
//  SpecialtyIconProvider.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//


import Foundation

struct SpecialtyIconProvider {

    private static let iconsBySpecialty: [String: String] = [
        "cardiology": "heart.fill",
        "cardiologist": "heart.fill",

        "neurology": "brain.head.profile",
        "neurologist": "brain.head.profile",

        "dermatology": "hand.raised.fill",
        "dermatologist": "hand.raised.fill",

        "dentistry": "mouth.fill",
        "dentist": "mouth.fill",
        "dental": "mouth.fill",

        "pediatrics": "figure.child",
        "paediatrics": "figure.child",
        "pediatrician": "figure.child",
        "paediatrician": "figure.child",

        "ophthalmology": "eye.fill",
        "ophthalmologist": "eye.fill",

        "orthopedics": "figure.walk",
        "orthopaedics": "figure.walk",
        "orthopedic": "figure.walk",

        "psychiatry": "brain",
        "psychiatrist": "brain",
        "psychology": "brain",

        "gynecology": "cross.case.fill",
        "gynaecology": "cross.case.fill",
        "obstetrics": "cross.case.fill",

        "urology": "cross.vial.fill",
        "gastroenterology": "stomach.fill",

        "pulmonology": "lungs.fill",
        "respiratory": "lungs.fill",

        "endocrinology": "waveform.path.ecg",
        "oncology": "cross.case.fill",

        "general practice": "stethoscope",
        "general practitioner": "stethoscope"
    ]

    static func icon(for specialty: String) -> String {
        let normalizedSpecialty = specialty
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if let exactMatch = iconsBySpecialty[normalizedSpecialty] {
            return exactMatch
        }

        let matchingSpecialty = iconsBySpecialty.keys
            .sorted { $0.count > $1.count }
            .first { normalizedSpecialty.contains($0) }

        if let matchingSpecialty {
            return iconsBySpecialty[matchingSpecialty] ?? "stethoscope"
        }

        return "stethoscope"
    }
}
