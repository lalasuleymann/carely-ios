//
//  NearbyView.swift
//  Carely
//
//  Created by Lala Suleymanova on 13.10.26.
//


import SwiftUI
import MapKit
import SwiftData

struct NearbyView: View {
    @Environment(AppointmentViewModel.self)
    private var appointmentViewModel

    @Environment(\.modelContext)
    private var modelContext

    @State private var viewModel = NearbyViewModel()
    @State private var selectedLocationID: String?
    @State private var didFitAllLocations = false

    // MARK: - Location Groups
    private var locationGroups: [NearbyLocationGroup] {
        let doctorsByID = Dictionary(
            uniqueKeysWithValues: MockDoctorData.doctors.map {
                ($0.id, $0)
            }
        )

        let mappedAppointments = appointmentViewModel.upcomingAppointments
            .compactMap { appointment -> (
                key: String,
                coordinate: CLLocationCoordinate2D,
                appointment: Appointment)? in
                guard let doctor = doctorsByID[appointment.doctorID] else {
                    return nil
                }

                let latitude = (doctor.latitude * 100_000).rounded() / 100_000
                let longitude = (doctor.longitude * 100_000).rounded() / 100_000

                let key = String(
                    format: "%.5f,%.5f",
                    latitude,
                    longitude
                )

                return (
                    key: key,
                    coordinate: CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    appointment: appointment
                )
            }

        let grouped = Dictionary(
            grouping: mappedAppointments,
            by: \.key
        )

        return grouped.map { key, items in
            NearbyLocationGroup(
                id: key,
                coordinate: items[0].coordinate,
                appointments: items
                    .map(\.appointment)
                    .sorted {
                        if $0.date == $1.date {
                            return $0.time < $1.time
                        }

                        return $0.date < $1.date
                    }
            )
        }
        .sorted { $0.id < $1.id }
    }

    private var selectedLocationGroup: NearbyLocationGroup? {
        guard let selectedLocationID else {
            return nil
        }

        return locationGroups.first {
            $0.id == selectedLocationID
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.secondaryText)

            Text("Search hospitals and clinics")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    // MARK: - Fit All Locations

    private func fitAllLocations() {
        let coordinates = locationGroups.map(\.coordinate)
            + (viewModel.location.map { [$0.coordinate] } ?? [])

        guard !coordinates.isEmpty else { return }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)

        guard
            let minLatitude = latitudes.min(),
            let maxLatitude = latitudes.max(),
            let minLongitude = longitudes.min(),
            let maxLongitude = longitudes.max()
        else {
            return
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )

        let latitudeDelta = max(
            (maxLatitude - minLatitude) * 1.5,
            0.01
        )

        let longitudeDelta = max(
            (maxLongitude - minLongitude) * 1.5,
            0.01
        )

        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(
                latitudeDelta: latitudeDelta,
                longitudeDelta: longitudeDelta
            )
        )

        viewModel.cameraPosition = .region(region)
    }
    
    private func fitAllLocationsIfNeeded() {
        guard !didFitAllLocations else { return }
        guard !locationGroups.isEmpty else { return }

        didFitAllLocations = true
        fitAllLocations()
    }
    
    private var fitAllLocationsButton: some View {
        Button {
            fitAllLocations()
        } label: {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 44, height: 44)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Show all locations")
    }
    
    // MARK: - Map
    private var map: some View {
        Map(
            position: $viewModel.cameraPosition,
            interactionModes: [.pan, .zoom, .rotate, .pitch]
        ) {
            if let location = viewModel.location {
                Annotation(
                    "Your location",
                    coordinate: location.coordinate,
                    anchor: .center
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.20))
                            .frame(width: 44, height: 44)

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                            .overlay {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                            }
                            .shadow(
                                color: .black.opacity(0.2),
                                radius: 3
                            )
                    }
                }
            }

            ForEach(locationGroups) { group in
                Annotation(
                    "Appointments nearby",
                    coordinate: group.coordinate,
                    anchor: .bottom
                ) {
                    Button {
                        selectedLocationID = group.id
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 27))
                                .foregroundStyle(.red)
                                .background(.white, in: Circle())
                                .shadow(
                                    color: .black.opacity(0.18),
                                    radius: 3,
                                    y: 2
                                )

                            if group.appointments.count > 1 {
                                Text("\(group.appointments.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 17, height: 17)
                                    .background(.black, in: Circle())
                                    .offset(x: 7, y: -5)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapScaleView()
        }
        .ignoresSafeArea(edges: .bottom)
    }

    var body: some View {
        ZStack(alignment: .top) {
            map

            VStack(spacing: 16) {
                searchBar

                HStack {
                    Label(
                        "Hospitals & Clinics",
                        systemImage: "cross.case"
                    )
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(16)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let error = viewModel.locationError {
                    Text(error)
                        .font(AppTypography.body)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    fitAllLocationsButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, selectedLocationGroup == nil ? 100 : 320)
            }
            .allowsHitTesting(true)

            VStack {
                Spacer()

                if let group = selectedLocationGroup {
                    NearbyAppointmentPanel(
                        group: group,
                        appointmentViewModel: appointmentViewModel,
                        onClose: {
                            selectedLocationID = nil
                        }
                    )
                    .padding(.bottom, 12)
                    .transition(
                        .move(edge: .bottom)
                            .combined(with: .opacity)
                    )
                }
            }
            .animation(
                .easeInOut(duration: 0.2),
                value: selectedLocationID
            )
        }
        .navigationTitle("Nearby")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            appointmentViewModel.configure(context: modelContext)
            appointmentViewModel.loadAppointments()

            if viewModel.location == nil {
                viewModel.requestLocation()
            }

            fitAllLocationsIfNeeded()
        }
        .onChange(
            of: appointmentViewModel.upcomingAppointments.map(\.id)
        ) { _, _ in
            guard let selectedLocationID else {
                return
            }

            if !locationGroups.contains(where: {
                $0.id == selectedLocationID
            }) {
                self.selectedLocationID = nil
                viewModel.showUserLocation()
            }
        }
    }
}

#Preview {
    NavigationStack {
        NearbyView()
    }
    .environment(AppointmentViewModel())
    .modelContainer(for: Appointment.self)
}
