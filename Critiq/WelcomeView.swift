//
//  WelcomeView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/4/23.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var network: Network
    @State private var displayLogin: Bool = false
    var body: some View {
        ZStack {
            StandardBackground()
            RandomRectangle(width: 338, height: 655, angle: 135, xPos: 100, yPos: 300)
            GeometryReader{ geometry in
                VStack {
                    Spacer()
                    StandardImage("Ramen", width: geometry.size.width, height: 300)
                    TitleText("Hello!")
                    BodyTextCentered("Welcome to Critiq, the easiest way to find where you want to eat tonight", width: geometry.size.width*0.80)
                    Spacer()
                    Spacer()
                    Button("Begin") {
                        network.loginState = LoginState.notLoggedIn
                    }
                    .padding(30)
                    .buttonStyle(ActionButton(width:.infinity))
                    Spacer()
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
