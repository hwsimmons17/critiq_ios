//
//  MapView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/9/23.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI

struct MapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.7608, longitude: -111.8910), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    @EnvironmentObject var locationManager: LocationManager
    
    
    var body: some View {
        NavigationView {
        ZStack {
            Map(coordinateRegion: $region,showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        LocationButton(.currentLocation) {
                            setLocation()
                        }
                        .symbolVariant(.fill)
                        .labelStyle(.iconOnly)
                        .foregroundColor(Color("Purple Heart"))
                        .tint(Color("Green White"))
                        .cornerRadius(40)
                        .font(.system(size:20))
                    }
                    .padding(30)
                    HStack(alignment: .bottom) {
                        Spacer()
                        VStack {
                            Button {
                                print("left button was tapped")
                            } label: {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("Purple Heart"))
                            }
                            .padding(2)
                            Text("Saved")
                                .font(.custom("Ubuntu", size: 10))
                                .foregroundColor(Color("Purple Heart"))
                        }
                        Spacer()
                        NavigationLink {
                            SearchView()
                        } label: {
                            VStack {
                                Image(systemName: "plus")
                                    .padding(15)
                                    .font(.system(size: 20, weight: .bold))
                                    .background(Color("Goldenrod"))
                                    .foregroundColor(Color("Purple Heart"))
                                    .cornerRadius(40)
                                Text("Add Restaurant")
                                    .font(.custom("Ubuntu", size: 10))
                                    .foregroundColor(Color("Purple Heart"))
                            }
                        }
                        Spacer()
                        VStack {
                            NavigationLink {
                                TestView()
                            } label: {
                                Image(systemName: "menucard.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("Purple Heart"))
                            }
                            .padding(2)
                            Text("For You")
                                .font(.custom("Ubuntu", size: 10))
                                .foregroundColor(Color("Purple Heart"))
                        }
                        Spacer()
                    }.edgesIgnoringSafeArea(.all)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color("Green White"))
                }
            }
        }
        .onAppear {
            setLocation()
        }
    }
    
    func setLocation() {
        locationManager.requestLocation()
        let location = locationManager.location
        if let location = location {
            self.region.center = location
            self.region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
