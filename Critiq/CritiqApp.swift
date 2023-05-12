//
//  CritiqApp.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/3/23.
//

import SwiftUI

@main
struct CritiqApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Network())
                .environmentObject(LocationManager())
        }
    }
}
