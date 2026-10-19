//
//  NearbyViewModel.swift
//  Carely
//
//  Created by Lala Suleymanova on 13.10.26.
//

import SwiftUI
import MapKit
import CoreLocation

@MainActor
@Observable
final class NearbyViewModel: NSObject, CLLocationManagerDelegate {
    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: String?
    private let networkService: any NetworkService
    
    var searchText = ""
    var searchResults: [Doctor] = []
    var selectedDoctor: Doctor?
    var hasSearched = false
    var isSearching = false
    var searchError: String?

    var selectedCategory: NearbyPlaceCategory = .all
    var nearbyPlaces: [NearbyPlace] = []
    var placesViewState: NearbyPlacesViewState = .idle
    var selectedPlace: NearbyPlace?
    var hasSetInitialLocation = false

    var doctors: [Doctor] = []
    var doctorsState: NearbyPlacesViewState = .idle
    
    private let placesService = NearbyPlacesService()
    private let locationManager = CLLocationManager()

    // MARK: - Default Map Region
    static var defaultMapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 40.4093,
                longitude: 49.8671
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.04,
                longitudeDelta: 0.04
            )
        )
    }

    var placesSearchRegion = NearbyViewModel.defaultMapRegion

    // MARK: - Map
    var cameraPosition: MapCameraPosition = .region(
        NearbyViewModel.defaultMapRegion
    )

    // MARK: - Initialization
    init(networkService: any NetworkService = DefaultNetworkService()) {
        self.networkService = networkService

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Doctor Search
    func search() async {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            searchResults = []
            hasSearched = false
            searchError = nil
            return
        }

        isSearching = true
        hasSearched = true
        searchError = nil

        defer {
            isSearching = false
        }

        do {
            let doctors: [DoctorDTO] = try await networkService.request(
                DoctorEndpoint.all(search: query),
                token: nil
            )

            searchResults = doctors.map(\.toDoctor)
        } catch {
            searchResults = []
            searchError = error.localizedDescription
        }
    }

    func loadDoctors() async {
        doctorsState = .loading

        do {
            let response: [DoctorDTO] = try await networkService.request(
                DoctorEndpoint.all(search: nil),
                token: nil
            )

            doctors = response
                .map(\.toDoctor)
                .filter {
                    CLLocationCoordinate2DIsValid(
                        CLLocationCoordinate2D(
                            latitude: $0.latitude,
                            longitude: $0.longitude
                        )
                    )
                    && $0.latitude != 0
                    && $0.longitude != 0
                }

            doctorsState = doctors.isEmpty ? .empty : .loaded
        } catch {
            doctors = []
            doctorsState = .error(
                "Həkimləri backend-dən yükləmək mümkün olmadı."
            )
            print("Doctor loading error:", error)
        }
    }
    

    // MARK: - Nearby Places Search
    func searchNearbyPlaces(in region: MKCoordinateRegion) async {
        placesSearchRegion = region
        placesViewState = .loading

        do {
            let results = try await placesService.search(
                category: selectedCategory,
                region: region
            )

            nearbyPlaces = results
            placesViewState = results.isEmpty ? .empty : .loaded

        } catch {
            nearbyPlaces = []
            placesViewState = .error(
                "Yaxınlıqdakı məkanları yükləmək mümkün olmadı."
            )
        }
    }

    // MARK: - Location Permissions
    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()

        case .denied, .restricted:
            locationError =
                "Location access is disabled. Please enable it in Settings."

        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        if manager.authorizationStatus == .authorizedWhenInUse
            || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()

        } else if manager.authorizationStatus == .denied
                    || manager.authorizationStatus == .restricted {
            locationError =
                "Location access is disabled. Please enable it in Settings."
        }
    }

    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            return
        }

        location = currentLocation
        locationError = nil

        guard selectedDoctor == nil else {
            return
        }

        cameraPosition = .region(
            MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.04,
                    longitudeDelta: 0.04
                )
            )
        )
    }

    func locationManager(_ manager: CLLocationManager,didFailWithError error: Error) {
        locationError = error.localizedDescription
        print("Location error: \(error.localizedDescription)")
    }

    // MARK: - Search Actions
    func selectDoctor(_ doctor: Doctor) {
        selectedDoctor = doctor
        searchText = doctor.name
        selectedPlace = nil

        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: doctor.latitude,
                longitude: doctor.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        )

        cameraPosition = .region(region)
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
        selectedDoctor = nil
        hasSearched = false
        searchError = nil
        isSearching = false
    }

    // MARK: - User Location
    func showUserLocation() {
        guard let location else {
            requestLocation()
            return
        }

        selectedDoctor = nil
        hasSetInitialLocation = true

        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.04,
                    longitudeDelta: 0.04
                )
            )
        )
    }

    // MARK: - Reset Map
    func resetMap() {
        clearSearch()

        selectedPlace = nil
        selectedCategory = .all

        placesSearchRegion = Self.defaultMapRegion
        cameraPosition = .region(Self.defaultMapRegion)
    }
}
