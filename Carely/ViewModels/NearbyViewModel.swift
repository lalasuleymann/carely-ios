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
    
    var searchText = ""
    var selectedDoctor: Doctor?
    
    private let locationManager = CLLocationManager()

    var selectedCategory: NearbyPlaceCategory = .all
    var nearbyPlaces: [NearbyPlace] = []
    var placesViewState: NearbyPlacesViewState = .idle
    var selectedPlace: NearbyPlace?

    var placesSearchRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 40.4093,
            longitude: 49.8671
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.04,
            longitudeDelta: 0.04
        )
    )
    
    private let placesService = NearbyPlacesService()
    
    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Map
    var cameraPosition: MapCameraPosition = .region(
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
    )

    // MARK: - Search
    var searchResults: [Doctor] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return []
        }

        return MockDoctorData.doctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(query)
                || doctor.specialty.localizedCaseInsensitiveContains(query)
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

            if results.isEmpty {
                placesViewState = .empty
            } else {
                placesViewState = .loaded
            }
        } catch {
            nearbyPlaces = []
            placesViewState = .error(
                "Yaxınlıqdakı məkanları yükləmək mümkün olmadı."
            )

            print("Nearby places error: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Location
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
        selectedDoctor = nil
    }

    // MARK: - User Location
    func showUserLocation() {
        guard let location else {
            requestLocation()
            return
        }

        selectedDoctor = nil

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
}
