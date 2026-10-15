//
//  FacilityDoctorsView.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//


import SwiftUI
import CoreLocation

struct FacilityDoctorsView: View {
    let place: NearbyPlace
    let onBookingConfirmed: () -> Void

    private let searchRadius: CLLocationDistance = 1000

    private var nearbyDoctors: [Doctor] {
        MockDoctorData.doctors
            .map { doctor -> (doctor: Doctor, distance: CLLocationDistance) in
                let doctorLocation = CLLocation(
                    latitude: doctor.latitude,
                    longitude: doctor.longitude
                )

                let facilityLocation = CLLocation(
                    latitude: place.coordinate.latitude,
                    longitude: place.coordinate.longitude
                )

                return (
                    doctor: doctor,
                    distance: doctorLocation.distance(
                        from: facilityLocation
                    )
                )
            }
            .filter { $0.distance <= searchRadius }
            .sorted { $0.distance < $1.distance }
            .map(\.doctor)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if nearbyDoctors.isEmpty {
                    EmptyStateView(
                        icon: "stethoscope",
                        title: "No Nearby Doctors",
                        message: "No doctors were found within 1 km of this location."
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                } else {
                    Text("Doctors Nearby")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)

                    VStack(spacing: 12) {
                        ForEach(nearbyDoctors) { doctor in
                            NavigationLink {
                                DoctorDetailView(
                                    doctor: doctor,
                                    onBookingConfirmed: onBookingConfirmed
                                )
                            } label: {
                                DoctorCard(doctor: doctor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppColors.background)
        .navigationTitle("Doctors")
        .navigationBarTitleDisplayMode(.inline)
    }
}
