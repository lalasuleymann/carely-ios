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
                appointment: Appointment
            )? in
                guard let doctor = doctorsByID[appointment.doctorID] else {
                    return nil
                }
                
                let latitude =
                (doctor.latitude * 100_000).rounded() / 100_000
                
                let longitude =
                (doctor.longitude * 100_000).rounded() / 100_000
                
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
    
    private var isSearching: Bool {
        !viewModel.searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
    
    // MARK: - Doctor Location Group
    private func locationGroup(for doctor: Doctor) -> NearbyLocationGroup? {
        locationGroups.first { group in
            group.appointments.contains {
                $0.doctorID == doctor.id
            }
        }
    }
    
    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.secondaryText)
            
            TextField(
                "Search doctors or specialties",
                text: $viewModel.searchText
            )
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.search)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.secondaryText)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: .black.opacity(0.06),
            radius: 8,
            y: 3
        )
    }
    
    private func clearSearch() {
        viewModel.clearSearch()
        selectedLocationID = nil
        fitAllLocations()
    }
    
    private func selectDoctor(_ doctor: Doctor) {
        viewModel.selectDoctor(doctor)
        
        let coordinate = CLLocationCoordinate2D(
            latitude: doctor.latitude,
            longitude: doctor.longitude
        )
        
        viewModel.cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        )
        
        selectedLocationID = locationGroup(for: doctor)?.id
    }
    
    private var searchResultsList: some View {
        Group {
            if isSearching && viewModel.selectedDoctor == nil {
                if viewModel.searchResults.isEmpty {
                    Text("No doctors found")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.searchResults) { doctor in
                                Button {
                                    selectDoctor(doctor)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: SpecialtyIconProvider.icon(for: doctor.specialty))
                                            .font(.title3)
                                            .foregroundStyle(AppColors.primary)
                                            .frame(width: 42,height: 42)
                                            .background(
                                                AppColors.primary.opacity(0.10)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        VStack(alignment: .leading,spacing: 4) {
                                            Text(doctor.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(
                                                    AppColors.primaryText
                                                )
                                            
                                            Text(doctor.specialty)
                                                .font(.caption)
                                                .foregroundStyle(
                                                    AppColors.secondaryText
                                                )
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.up.left")
                                            .font(.caption)
                                            .foregroundStyle(
                                                AppColors.secondaryText
                                            )
                                    }
                                    .padding(12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                
                                if doctor.id != viewModel.searchResults.last?.id {
                                    Divider()
                                        .padding(.leading, 66)
                                }
                            }
                        }
                    }
                    .frame(height: min(CGFloat(viewModel.searchResults.count) * 68,220))
                    .background(AppColors.surface)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .shadow(
                        color: .black.opacity(0.06),
                        radius: 8,
                        y: 3
                    )
                }
            }
        }
    }
    
    // MARK: - Fit All Locations
    private func fitAllLocations() {
        let coordinates = locationGroups.map(\.coordinate) + (viewModel.location.map { [$0.coordinate] } ?? [])
        
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
        
        viewModel.cameraPosition = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: latitudeDelta,
                    longitudeDelta: longitudeDelta
                )
            )
        )
    }
    
    private func resetMap() {
        selectedLocationID = nil
        didFitAllLocations = true

        viewModel.searchText = ""
        viewModel.selectedDoctor = nil
        viewModel.selectedPlace = nil

        viewModel.nearbyPlaces = []
        viewModel.placesViewState = .idle
        viewModel.selectedCategory = .all

        fitAllLocations()
    }

    private func fitAllLocationsIfNeeded() {
        guard !didFitAllLocations else { return }
        guard !locationGroups.isEmpty else { return }
        
        didFitAllLocations = true
        fitAllLocations()
    }
    
    private var fitAllLocationsButton: some View {
        Button {
            resetMap()
        } label: {
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 44, height: 44)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset map")
    }

    // MARK: - Nearby Place Detail Card
    private func nearbyPlaceDetailCard(_ place: NearbyPlace) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: viewModel.selectedCategory.icon)
                    .font(.title2)
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        AppColors.primary.opacity(0.10)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    Text(place.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)

                    Text(viewModel.selectedCategory.rawValue)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Button {
                    viewModel.selectedPlace = nil
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(
                            AppColors.primary.opacity(0.08),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close place details")
            }

            if !place.address.isEmpty {
                Label(place.address, systemImage: "mappin.and.ellipse")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            if let phone = place.phoneNumber,
               !phone.isEmpty {
                Label(phone, systemImage: "phone")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            HStack(spacing: 10) {
                Button {
                    let mapItem = place.mapItem
                    mapItem.name = place.name

                    mapItem.openInMaps(
                        launchOptions: [
                            MKLaunchOptionsDirectionsModeKey:
                                MKLaunchOptionsDirectionsModeDriving
                        ]
                    )
                } label: {
                    Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(AppTypography.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(AppColors.primary)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)

                if let website = place.website {
                    Link(destination: website) {
                        Image(systemName: "globe")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 48, height: 46)
                            .background(
                                AppColors.primary.opacity(0.10)
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                    }
                    .accessibilityLabel("Open website")
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(
            color: .black.opacity(0.10),
            radius: 12,
            y: 4
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .transition(
            .move(edge: .bottom)
                .combined(with: .opacity)
        )
    }
    
    // MARK: - Map
    private var map: some View {
        Map(
            position: $viewModel.cameraPosition,
            interactionModes: [.pan, .zoom, .rotate, .pitch] ) {
     
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

            if let doctor = viewModel.selectedDoctor {
                Annotation(
                    doctor.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: doctor.latitude,
                        longitude: doctor.longitude
                    ),
                    anchor: .bottom
                ) {
                    Button {
                        selectDoctor(doctor)
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 27))
                            .foregroundStyle(.red)
                            .background(.white, in: Circle())
                            .shadow(
                                color: .black.opacity(0.18),
                                radius: 3,
                                y: 2
                            )
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        "Show \(doctor.name) appointments"
                    )
                }
            }

            if !isSearching {
                ForEach(locationGroups) { group in
                    Annotation(
                        "Appointments nearby",
                        coordinate: group.coordinate,
                        anchor: .bottom
                    ) {
                        Button {
                            viewModel.selectedPlace = nil
                            viewModel.selectedDoctor = nil
                            viewModel.searchText = ""
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
                                        .font(.system(size: 10,weight: .bold))
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
            ForEach(viewModel.nearbyPlaces) { place in
                Annotation(
                    place.name,
                    coordinate: place.coordinate,
                    anchor: .bottom
                ) {
                    Button {
                        selectedLocationID = nil
                        viewModel.selectedDoctor = nil
                        viewModel.searchText = ""
                        viewModel.selectedPlace = place
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.red)
                            .background(.white, in: Circle())
                            .shadow(
                                color: .black.opacity(0.18),
                                radius: 3,
                                y: 2
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(place.name)
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
    
    // MARK: - Appointment Panel
    @ViewBuilder
    private var appointmentPanel: some View {
        if let doctor = viewModel.selectedDoctor {
            let doctorAppointments = appointmentViewModel.upcomingAppointments
                .filter { $0.doctorID == doctor.id }
                .sorted {
                    if $0.date == $1.date {
                        return $0.time < $1.time
                    }
                    return $0.date < $1.date
                }
            
            if !doctorAppointments.isEmpty {
                NearbyAppointmentPanel(
                    group: NearbyLocationGroup(
                        id: String(
                            format: "%.5f,%.5f",
                            doctor.latitude,
                            doctor.longitude
                        ),
                        coordinate: CLLocationCoordinate2D(
                            latitude: doctor.latitude,
                            longitude: doctor.longitude
                        ),
                        appointments: doctorAppointments
                    ),
                    appointmentViewModel: appointmentViewModel,
                    onClose: {
                        selectedLocationID = nil
                        viewModel.clearSearch()
                        fitAllLocations()
                    }
                )
                .padding(.bottom, 12)
                .transition(
                    .move(edge: .bottom)
                    .combined(with: .opacity)
                )
            }
        } else if !isSearching,
                  let group = selectedLocationGroup {
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
    
    // MARK: - Nearby Places State
    @ViewBuilder
    private var nearbyPlacesContent: some View {
        switch viewModel.placesViewState {
        case .idle, .loaded:
            EmptyView()
            
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                    .controlSize(.small)
                    .tint(AppColors.primary)

                Text("Searching nearby places...")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(AppColors.surface.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
        case .empty:
            EmptyStateView(
                icon: "mappin.slash",
                title: "No Places Found",
                message: "No places matching this category were found nearby."
            )
            
        case .error(let message):
            ErrorStateView(
                title: "Something Went Wrong",
                message: message,
                retryAction: {
                    Task {
                        await viewModel.searchNearbyPlaces(
                            in: viewModel.placesSearchRegion
                        )
                    }
                }
            )
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            map
            
            VStack(spacing: 12) {
                searchBar
                
                searchResultsList
                
                nearbyPlacesContent
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(NearbyPlaceCategory.allCases) { category in
                            Button {
                                viewModel.selectedPlace = nil
                                viewModel.selectedDoctor = nil
                                viewModel.searchText = ""
                                viewModel.selectedCategory = category
                                selectedLocationID = nil

                                Task {
                                    await viewModel.searchNearbyPlaces(
                                        in: viewModel.placesSearchRegion
                                    )
                                }
                            } label: {
                                Label(
                                    category.rawValue,
                                    systemImage: category.icon
                                )
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(
                                    viewModel.selectedCategory == category ? .white : AppColors.primaryText
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    viewModel.selectedCategory == category ? AppColors.primary : AppColors.surface
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if let error = viewModel.locationError {
                    Text(error)
                        .font(AppTypography.body)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(maxWidth: .infinity,alignment: .leading)
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
                .padding(.bottom,selectedLocationGroup == nil ? 100 : 320)
            }
            
            VStack {
                Spacer()
                
                if let place = viewModel.selectedPlace {
                    nearbyPlaceDetailCard(place)
                } else {
                    appointmentPanel
                }
            }
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.selectedPlace?.id
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
        .onDisappear {
            viewModel.selectedPlace = nil
            selectedLocationID = nil
        }
        .onChange(
            of: appointmentViewModel.upcomingAppointments.map(\.id)) { _, _ in
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
