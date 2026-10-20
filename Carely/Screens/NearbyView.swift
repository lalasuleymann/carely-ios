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
    
    @Environment(\.selectedTab) private var selectedTab
    @Environment(\.locale) private var locale
    
    @State private var viewModel: NearbyViewModel
    @State private var selectedLocationID: String?
    @State private var didFitAllLocations = false
    @State private var showingDoctorsFor: NearbyPlace?
    @State private var isDoctorCardVisible = true
    @State private var isClinicCardVisible = true
    @State private var showDirectionsOptions = false
    @State private var showNearbyPlacePins = false
    
    init(networkService: any NetworkService = DefaultNetworkService()) {
        _viewModel = State(
            initialValue: NearbyViewModel(
                networkService: networkService
            )
        )
    }
    
    // MARK: - Localization
    private func localize(_ key: String) -> String {
        LocalizationManager.localized(key, locale: locale)
    }
    
    // MARK: - Location Groups
    private var locationGroups: [NearbyLocationGroup] {
        let doctorsByID = Dictionary(
            uniqueKeysWithValues: viewModel.doctors.map {
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

                let coordinate = CLLocationCoordinate2D(
                    latitude: doctor.latitude,
                    longitude: doctor.longitude
                )

                let key = "\(doctor.latitude),\(doctor.longitude)"

                return (
                    key: key,
                    coordinate: coordinate,
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
                    .sorted { $0.date < $1.date }
            )
        }
        .sorted { $0.id < $1.id }
    }

    private func appointments(for place: NearbyPlace) -> [Appointment] {
        appointmentViewModel.upcomingAppointments
            .filter { appointment in
                let appointmentFacility = appointment.facilityName
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                return !appointmentFacility.isEmpty &&
                    appointmentFacility.localizedCaseInsensitiveCompare(
                        place.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    ) == .orderedSame
            }
            .sorted {
                if $0.date == $1.date {
                    return $0.time < $1.time
                }

                return $0.date < $1.date
            }
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
        viewModel.hasSearched &&
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
            .onSubmit {
                Task {
                    await viewModel.search()
                }
            }
            
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

                if viewModel.isSearching {
                    ProgressView("Searching doctors...")
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                } else if let error = viewModel.searchError {
                    Text(error)
                        .font(AppTypography.body)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                } else if viewModel.searchResults.isEmpty {
                    Text("No doctors found")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.searchResults) { doctor in
                                Button {
                                    selectDoctor(doctor)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(
                                            systemName: SpecialtyIconProvider.icon(
                                                for: doctor.specialty
                                            )
                                        )
                                        .font(.title3)
                                        .foregroundStyle(AppColors.primary)
                                        .frame(width: 42, height: 42)
                                        .background(
                                            AppColors.primary.opacity(0.10)
                                        )
                                        .clipShape(
                                            RoundedRectangle(cornerRadius: 12)
                                        )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(doctor.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(AppColors.primaryText)

                                            Text(doctor.specialty)
                                                .font(.caption)
                                                .foregroundStyle(AppColors.secondaryText)
                                        }

                                        Spacer()

                                        Image(systemName: "arrow.up.left")
                                            .font(.caption)
                                            .foregroundStyle(AppColors.secondaryText)
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
                    .frame(
                        height: min(
                            CGFloat(viewModel.searchResults.count) * 68,
                            220
                        )
                    )
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    // MARK: - Fit All Locations
    private func fitAllLocations() {
        let coordinates =
            locationGroups.map(\.coordinate)
            + (viewModel.location.map { [$0.coordinate] } ?? [])

        guard !coordinates.isEmpty else {
            viewModel.showUserLocation()
            return
        }

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

        viewModel.cameraPosition = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(
                    latitudeDelta: max((maxLatitude - minLatitude) * 1.5, 0.01),
                    longitudeDelta: max((maxLongitude - minLongitude) * 1.5, 0.01)
                )
            )
        )
    }
    
    private func openGoogleMapsDirections(for place: NearbyPlace) {
        let coordinate = place.coordinate

        let appURL = URL(
            string: "comgooglemaps://?daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving"
        )

        if let appURL,
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }

        let webURL = URL(
            string: "https://www.google.com/maps/dir/?api=1&destination=\(coordinate.latitude),\(coordinate.longitude)"
        )

        if let webURL {
            UIApplication.shared.open(webURL)
        }
    }

    private func resetMap() {
        selectedLocationID = nil

        viewModel.searchText = ""
        viewModel.selectedDoctor = nil
        viewModel.selectedPlace = nil
        viewModel.clearSearch()

        isDoctorCardVisible = true
        isClinicCardVisible = true
        showDirectionsOptions = false

        viewModel.selectedCategory = .all
        viewModel.nearbyPlaces = []
        viewModel.placesViewState = .idle
        showNearbyPlacePins = false

        Task {
            await viewModel.searchNearbyPlaces(
                in: viewModel.placesSearchRegion
            )

            fitAllLocations()
            didFitAllLocations = true
        }
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
                    .background(AppColors.primary.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text(place.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)

                    Text(LocalizationManager.localized(viewModel.selectedCategory.rawValue,locale: locale))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Button {
                    selectedLocationID = nil
                    viewModel.selectedDoctor = nil
                    viewModel.searchText = ""
                    showingDoctorsFor = place
                } label: {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            AppColors.primary.opacity(0.10),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View doctors")

                Button {
                    isClinicCardVisible = false
                    showDirectionsOptions = false
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
                .accessibilityLabel("Close clinic card")
            }
            
            if !place.address.isEmpty {
                Label(
                    place.address,
                    systemImage: "mappin.and.ellipse"
                )
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
            }

            if let phone = place.phoneNumber, !phone.isEmpty {
                Label(phone, systemImage: "phone")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            HStack(spacing: 10) {
                Button {
                    showDirectionsOptions = true
                } label: {
                    Label(
                        "Get Directions",
                        systemImage: "arrow.triangle.turn.up.right.diamond.fill"
                    )
                    .font(AppTypography.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)

                if let website = place.website {
                    Link(destination: website) {
                        Image(systemName: "globe")
                            .font(.title3)
                            .foregroundStyle(AppColors.primary)
                            .frame(width: 48, height: 46)
                            .background(AppColors.primary.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
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
        .padding(.bottom, 8)
        .confirmationDialog(
            "Select an action",
            isPresented: $showDirectionsOptions,
            titleVisibility: .visible
        ) {
            Button("Open in Maps") {
                let mapItem = place.mapItem
                mapItem.name = place.name

                mapItem.openInMaps(
                    launchOptions: [
                        MKLaunchOptionsDirectionsModeKey:
                            MKLaunchOptionsDirectionsModeDriving
                    ]
                )
            }

            Button("Open in Google Maps") {
                openGoogleMapsDirections(for: place)
            }

            Button("Cancel", role: .cancel) {}
        }
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
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(.blue)
                        .background(.white, in: Circle())
                }
            }
            if !isSearching {
                ForEach(
                    locationGroups.filter { group in
                        viewModel.selectedCategory == .all ||
                        group.appointments.contains { appointment in
                            guard let doctor = viewModel.doctors.first(
                                where: { $0.id == appointment.doctorID }
                            ) else {
                                return false
                            }

                            return viewModel.selectedCategory.matches(
                                doctor.facilityType
                            )
                        }
                    }
                ) { group in
                    Annotation(
                        "Appointments nearby",
                        coordinate: group.coordinate,
                        anchor: .bottom
                    ) {
                        Button {
                            selectedLocationID = group.id
                            viewModel.selectedDoctor = nil
                            viewModel.searchText = ""

                            if let matchingPlace = viewModel.nearbyPlaces.first(
                                where: {
                                    $0.name.localizedCaseInsensitiveCompare(
                                        group.appointments.first?.facilityName ?? ""
                                    ) == .orderedSame
                                }
                            ) {
                                viewModel.selectedPlace = matchingPlace
                                isDoctorCardVisible = true
                                isClinicCardVisible = true
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 30))
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
                                        .background(.blue, in: Circle())
                                        .offset(x: 5, y: -5)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if showNearbyPlacePins && !isSearching {
                ForEach(viewModel.nearbyPlaces) { place in
                    Annotation(
                        place.name,
                        coordinate: place.coordinate,
                        anchor: .bottom
                    ) {
                        Button {
                            viewModel.selectedPlace = place
                            selectedLocationID = nil
                            viewModel.selectedDoctor = nil
                            isClinicCardVisible = true
                            isDoctorCardVisible = true
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
                        }
                        .buttonStyle(.plain)
                    }
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

                Text(localize("Searching nearby places..."))
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
                title: localize("No Places Found"),
                message: localize("No places matching this category were found nearby.")
            )
            
        case .error(let message):
            ErrorStateView(
                title: localize("Something Went Wrong"),
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
                                showNearbyPlacePins = true
                                selectedLocationID = nil

                                isDoctorCardVisible = true
                                isClinicCardVisible = true

                                Task {
                                    await viewModel.searchNearbyPlaces(
                                        in: viewModel.placesSearchRegion
                                    )
                                }
                            } label: {
                                Label(
                                    category.title(locale: locale),
                                    systemImage: category.icon
                                )
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(
                                    viewModel.selectedCategory == category
                                        ? .white
                                        : AppColors.primaryText
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(
                                    viewModel.selectedCategory == category
                                        ? AppColors.primary
                                        : AppColors.surface
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
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            VStack {
                Spacer()

                HStack {
                    Spacer()
                    fitAllLocationsButton
                }
                .padding(.horizontal, 20)
                .padding(
                    .bottom,
                    viewModel.selectedPlace != nil
                        ? 470
                        : (selectedLocationGroup != nil ? 320 : 100)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(true)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                if let place = viewModel.selectedPlace {
                    let placeAppointments = appointments(for: place)

                    VStack(spacing: 8) {
                        if isDoctorCardVisible && !placeAppointments.isEmpty {
                            NearbyAppointmentPanel(
                                group: NearbyLocationGroup(
                                    id: "facility-\(place.id)",
                                    coordinate: place.coordinate,
                                    appointments: placeAppointments
                                ),
                                appointmentViewModel: appointmentViewModel,
                                onClose: {
                                    isDoctorCardVisible = false
                                }
                            )
                            .frame(height: 220)
                            .clipped()
                            .transition(
                                .move(edge: .bottom)
                                    .combined(with: .opacity)
                            )
                        }
                        if isClinicCardVisible {
                            nearbyPlaceDetailCard(place)
                                .transition(
                                    .move(edge: .bottom)
                                        .combined(with: .opacity)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 8)
                    .frame(maxHeight: 450, alignment: .bottom)
                } else {
                    appointmentPanel
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(
                .easeInOut(duration: 0.2),
                value: viewModel.selectedPlace?.id
            )
            .animation(
                .easeInOut(duration: 0.2),
                value: isDoctorCardVisible
            )
            .animation(
                .easeInOut(duration: 0.2),
                value: isClinicCardVisible
            )
        }
        .navigationTitle("Nearby")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $showingDoctorsFor) { place in
            NavigationStack {
                FacilityDoctorsView(place: place) {
                    showingDoctorsFor = nil
                    viewModel.selectedPlace = nil
                    selectedLocationID = nil
                    viewModel.selectedDoctor = nil
                    viewModel.searchText = ""

                    selectedTab.wrappedValue = 2
                }
            }
        }
        .task {
            async let doctorsTask: Void = viewModel.loadDoctors()
            async let appointmentsTask: Void = appointmentViewModel.fetchAppointments()

            _ = await (doctorsTask, appointmentsTask)

            fitAllLocationsIfNeeded()
        }
        .onAppear {
            appointmentViewModel.configure(context: modelContext)
            appointmentViewModel.loadAppointments()

            if viewModel.location == nil {
                viewModel.requestLocation()
            }

            Task {
                await viewModel.searchNearbyPlaces(
                    in: viewModel.placesSearchRegion
                )
                fitAllLocationsIfNeeded()
            }
        }
        .onDisappear {
            viewModel.selectedPlace = nil
            selectedLocationID = nil
        }
        .onChange(of: appointmentViewModel.upcomingAppointments.map(\.id)) { _, _ in
            if !locationGroups.isEmpty {
                fitAllLocations()
                didFitAllLocations = true
            }
        }
    }
}
