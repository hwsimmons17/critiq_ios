//
//  LoginView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/4/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var network: Network
    enum FocusedField {
        case firstName, lastName, phoneNumber
    }
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        ZStack {
            StandardBackground()
            RandomRectangle(width: 420, height: 655, angle: 45, xPos: 350, yPos: 450)
            VStack {
                TitleText("Welcome!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                BodyText("Sign in to continue")
                TextField("First Name", text: $firstName)
                    .modifier(StandardTextField())
                    .focused($focusedField, equals: .firstName)
                TextField("Last Name", text: $lastName)
                    .modifier(StandardTextField())
                    .focused($focusedField, equals: .lastName)
                TextField("Phone Number", text: $phoneNumber)
                    .modifier(PhoneNumber())
                    .onChange(of: phoneNumber) {
                        newValue in
                        phoneNumber = newValue.formatPhoneNumber()
                    }
                    .focused($focusedField, equals: .phoneNumber)
                Text(network.errorText.neverEmpty())
                    .font(.custom("Ubuntu", size: 20))
                    .foregroundColor(Color(.red))
                    .frame(maxWidth: .infinity, alignment: .center)
                Button("Submit") {
                    self.network.authenticate(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
                }
                .buttonStyle(ActionButton(width: .infinity))
                Spacer()
            }
            .padding(30)
        }
        .onAppear {
            focusedField = .firstName
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(Network())
    }
}
