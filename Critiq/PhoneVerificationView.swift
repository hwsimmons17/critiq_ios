//
//  PhoneVerificationView.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/5/23.
//

import SwiftUI

struct PhoneVerificationView: View {
    @EnvironmentObject var network: Network
    @State var submitNumber: [String] = ["","","","",""]
    @FocusState private var focusedField: Int?
    var body: some View {
        ZStack {
            StandardBackground()
            RandomRectangle(width: 520, height: 275, angle: 159, xPos: 200, yPos: 350)
            VStack {
                TitleText("Verify Your Phone Number")
                BodyText("We want to ensure you are a real person! Enter your OTP below")
                HStack {
                    ForEach(0..<submitNumber.count, id: \.self) { i in
                        Circle()
                            .fill((submitNumber[i] == "") ? Color("Green White") : Color("Purple Heart"), strokeBorder: Color("Purple Heart"))
                            .frame(width: 60, height: 60)
                            .overlay(TextField("", text: $submitNumber[i])
                                .font(.custom("Ubuntu", size: 20).weight(.heavy))
                                .onChange(of: submitNumber[i]) { _ in
                                    handleTextChange()
                                }
                                .foregroundColor((submitNumber[i] == "") ? Color("Purple Heart") : Color("Green White"))
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: i)
                                     )
                                }
                }
                HStack {
                    Text("Didn't get a password?")
                        .font(.custom("Ubuntu", size: 20))
                        .foregroundColor(Color("Flamenco"))
                    Text("Resend OTP")
                        .foregroundColor(.blue)
                        .font(.custom("Ubuntu", size: 20))
                        .onTapGesture {
                            print("resending code...")
                        }
                    Spacer()
                }
                Spacer()
            }
            .padding(15)
        }
        .onAppear {
            focusedField = 0
        }
    }
    
    func handleTextChange() {
        var password = ""
        for (i, num) in submitNumber.enumerated() {
            if num == "" {
                self.focusedField = i
                return
            }
            password = password + num
        }
        print("submitted")
        network.submitOTP(code: password)
    }
}

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}


struct PhoneVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneVerificationView()
    }
}
