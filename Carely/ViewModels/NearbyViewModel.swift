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

    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()

        case .denied, .restricted:
            locationError = "Location access is disabled. Please enable it in Settings."

        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        authorizationStatus = manager.authorizationStatus

        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied ||
                    manager.authorizationStatus == .restricted {
            locationError = "Location access is disabled. Please enable it in Settings."
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let currentLocation = locations.last else { return }

        location = currentLocation
        locationError = nil

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

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        locationError = error.localizedDescription
        print("Location error: \(error.localizedDescription)")
    }

    func showUserLocation() {
        guard let location else {
            requestLocation()
            return
        }

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
