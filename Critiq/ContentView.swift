//
//  ContentView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/3/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @EnvironmentObject var network: Network
    
        var body: some View {
            switch network.loginState {
            case LoginState.welcome:
                WelcomeView()
                    .onAppear {
                        network.determineLoginStatus()
                    }
            case LoginState.notLoggedIn:
                LoginView()
            case LoginState.phoneNumberVerification:
                PhoneVerificationView()
            case LoginState.loggedIn:
                MapView()
                    .onAppear {
                        network.determineLoginStatus()
                    }
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
