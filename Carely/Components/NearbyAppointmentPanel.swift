//
//  NearbyAppointmentPanel.swift
//  Carely
//
//  Created by Lala Suleymanova on 14.10.26.
//

import SwiftUI
import MapKit
import UIKit

struct NearbyAppointmentPanel: View {
    let group: NearbyLocationGroup
    let appointmentViewModel: AppointmentViewModel
    let onClose: () -> Void

    @State private var showDirectionsOptions = false

    // MARK: - Doctor IDs
    private var doctorIDs: [Int] {
        Array(Set(group.appointments.map(\.doctorID))).sorted()
    }

    // MARK: - Appointments
    private func appointments(for doctorID: Int) -> [Appointment] {
        group.appointments
            .filter { $0.doctorID == doctorID }
            .sorted {
                if $0.date == $1.date {
                    return $0.time < $1.time
                }

                return $0.date < $1.date
            }
    }

    // MARK: - Panel Height
    private var contentHeight: CGFloat {
        let doctorCount = doctorIDs.count
        let appointmentCount = group.appointments.count

        let headerHeight: CGFloat = 42
        let rowHeight: CGFloat = 80
        let spacing: CGFloat = 12

        let totalHeight =
            CGFloat(doctorCount) * headerHeight
            + CGFloat(appointmentCount) * rowHeight
            + CGFloat(max(0, doctorCount + appointmentCount - 1)) * spacing

        return min(totalHeight, 300)
    }

    // MARK: - Location Coordinate
    private var doctorCoordinate: CLLocationCoordinate2D {
        group.coordinate
    }

    // MARK: - Doctor Section
    private func doctorSection(doctorID: Int) -> some View {
        let doctorAppointments = appointments(for: doctorID)
        let firstAppointment = doctorAppointments.first

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(firstAppointment?.doctorName ?? "Doctor")
                        .font(.headline)
                        .foregroundStyle(AppColors.primaryText)

                    Text(firstAppointment?.specialty ?? "")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                if doctorID == doctorIDs.first {
                    HStack(spacing: 12) {
                        Button {
                            showDirectionsOptions = true
                        } label: {
                            Image(
                                systemName: "arrow.triangle.turn.up.right.diamond.fill"
                            )
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Get Directions")

                        Button(action: onClose) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Close appointments")
                    }
                }
            }
            .padding(.horizontal, 4)

            ForEach(doctorAppointments) { appointment in
                NearbyAppointmentRow(
                    appointment: appointment,
                    appointmentViewModel: appointmentViewModel
                )
            }
        }
    }

    // MARK: - Apple Maps
    private func openAppleMaps() {
        let coordinate = doctorCoordinate

        let source = MKMapItem.forCurrentLocation()
        source.name = "My Location"

        let destination = MKMapItem(
            placemark: MKPlacemark(coordinate: coordinate)
        )
        destination.name = "Appointment Location"

        MKMapItem.openMaps(
            with: [source, destination],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }

    // MARK: - Google Maps
    private func openGoogleMaps() {
        let coordinate = doctorCoordinate

        var components = URLComponents()
        components.scheme = "comgooglemaps"
        components.host = ""

        components.queryItems = [
            URLQueryItem(
                name: "daddr",
                value: "\(coordinate.latitude),\(coordinate.longitude)"
            ),
            URLQueryItem(
                name: "directionsmode",
                value: "driving"
            )
        ]

        if let appURL = components.url,
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            var webComponents = URLComponents(
                string: "https://www.google.com/maps/dir/"
            )

            webComponents?.queryItems = [
                URLQueryItem(name: "api", value: "1"),
                URLQueryItem(
                    name: "destination",
                    value: "\(coordinate.latitude),\(coordinate.longitude)"
                ),
                URLQueryItem(
                    name: "travelmode",
                    value: "driving"
                )
            ]

            if let webURL = webComponents?.url {
                UIApplication.shared.open(webURL)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(doctorIDs, id: \.self) { doctorID in
                    doctorSection(doctorID: doctorID)
                }
            }
            .padding(14)
        }
        .confirmationDialog(
            "Select an action",
            isPresented: $showDirectionsOptions,
            titleVisibility: .visible
        ) {
            Button("Open in Maps") {
                openAppleMaps()
            }

            Button("Open in Google Maps") {
                openGoogleMaps()
            }

            Button("Cancel", role: .cancel) {}
        }
        .frame(height: contentHeight)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: .black.opacity(0.12),
            radius: 10,
            y: 4
        )
        .padding(.horizontal, 20)
    }
}
