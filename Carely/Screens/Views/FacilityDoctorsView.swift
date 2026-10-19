//
//  FacilityDoctorsView.swift
//  Carely
//
//  Created by Lala Suleymanova on 15.10.26.
//

import SwiftUI

@MainActor
struct FacilityDoctorsView: View {
    let place: NearbyPlace
    let onBookingConfirmed: () -> Void

    @State private var doctors: [Doctor] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let networkService: NetworkService

    init(
        place: NearbyPlace,
        onBookingConfirmed: @escaping () -> Void,
        networkService: NetworkService = DefaultNetworkService()
    ) {
        self.place = place
        self.onBookingConfirmed = onBookingConfirmed
        self.networkService = networkService
    }

    private func loadDoctors() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let facility: MedicalFacilityDetailDTO =
                try await networkService.request(
                    MedicalFacilityEndpoint.getById(id: place.id),
                    token: nil
                )

            doctors = facility.doctors.map {
                $0.toDoctor(facility: facility)
            }
        } catch {
                error.localizedDescription
            errorMessage = "Could not load doctors for this facility. Please try again."
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    ProgressView("Loading doctors...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 30)

                } else if let errorMessage {
                    ErrorStateView(
                        title: "Unable to Load Doctors",
                        message: errorMessage,
                        retryAction: {
                            Task {
                                await loadDoctors()
                            }
                        }
                    )

                } else if doctors.isEmpty {
                    EmptyStateView(
                        icon: "stethoscope",
                        title: "No Doctors at This Facility",
                        message: "No doctors are currently associated with this facility."
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)

                } else {
                    Text("Doctors at \(place.name)")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)

                    VStack(spacing: 12) {
                        ForEach(doctors) { doctor in
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
        .task {
            await loadDoctors()
        }
    }
}
