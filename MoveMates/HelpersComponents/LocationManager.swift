//
//  LocationManager.swift
//  SpotMe
//
//  Created by Mazen Younis on 16/05/2025.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentCountry: String = ""
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        
        manager.startUpdatingLocation()
    }

    
    // Called when permission status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied")
        case .notDetermined:
            print("Waiting for location access decision")
        @unknown default:
            break
        }
    }
    
    // Called when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations called with: \(locations.count) location(s)")
        
        guard let location = locations.last else {
            print("No location data available.")
            return
        }

        print("Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            if let country = placemarks?.first?.country {
                DispatchQueue.main.async {
                    self?.currentCountry = country
                    print("Resolved country: \(country)")
                }
            } else {
                print("Could not resolve country from location.")
            }
        }
    }
}
