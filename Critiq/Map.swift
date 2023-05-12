//
//  Map.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/9/23.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate {
    

    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var location: CLLocationCoordinate2D?
    @Published var searchResults = [Place]()
    
    var searchCompleter = MKLocalSearchCompleter()
    var locationManager = CLLocationManager()
    var searchTask: Task<Void, Never>?
    var network: Network = Network()
    
    

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        searchCompleter.delegate = self
    }

    func requestLocation() {
        self.locationManager.delegate = self
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            return
        }
        locationManager.requestLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                manager.stopUpdatingLocation()
                self.location = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 40.7608, longitude: locationManager.location?.coordinate.longitude ?? -111.8910)
            
        }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
    }
    
    func searchForRestaruant(searchString: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchString
        if let location = self.location {
            searchRequest.region.center = location
            searchRequest.region.span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        }
        guard let loc = self.location else {
            return
        }
        Task {
            let (places, err) =  await self.network.searchForPlaces(location: loc, searchString: searchString)
            if err != nil {
                return
            }
            self.searchResults = places
        }
    }
}

public extension Array where Element: MKMapItem {
    func uniqued() -> [MKMapItem] {
        var seen = Set<String>()
        return self.filter { mapItem in
            if let url = mapItem.url {
                if let host = url.host() {
                    let (inserted, _) = seen.insert(host)
                    return inserted
                }
            }
            return false
        }
    }
}



