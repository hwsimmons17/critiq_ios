//
//  Primatives.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/4/23.
//

import SwiftUI

struct StandardBackground: View {
    var body: some View {
        Color("Green White")
            .ignoresSafeArea()
    }
}

struct RandomRectangle: View {
    @State var width: CGFloat
    @State var height: CGFloat
    @State var angle: Double
    @State var xPos: CGFloat
    @State var yPos: CGFloat
    var body: some View {
        Rectangle()
            .fill(Color("Goldenrod"))
            .frame(width: width, height: height)
            .rotationEffect(Angle(degrees: angle))
            .position(x: xPos, y: yPos)
    }
}

struct StandardImage: View {
    init(_ name: String, width: CGFloat, height: CGFloat) {
        self.name = name
        self.width = width
        self.height = height
    }
    @State var name: String
    @State var width: CGFloat
    @State var height: CGFloat
    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width:width, height: height)
    }
}

struct TitleText: View {
    init(_ text: String) {
        self.text = text
    }
    @State var text: String
    var body: some View {
        Text(text)
            .font(.custom("Poppins", size: 48))
            .foregroundColor(Color("Flamenco"))
    }
}

struct BodyTextCentered: View {
    init(_ text: String, width: CGFloat) {
        self.text = text
        self.width = width
    }
    @State var text: String
    @State var width: CGFloat
    var body: some View {
        Text(text)
            .font(.custom("Ubuntu", size: 20))
            .foregroundColor(Color("Flamenco"))
            .frame(width: width)
    }
}

struct BodyText: View {
    init(_ text: String) {
        self.text = text
    }
    @State var text: String
    var body: some View {
        Text(text)
            .font(.custom("Ubuntu", size: 20))
            .foregroundColor(Color("Flamenco"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ErrorText: View {
    @State var text: String
    var body: some View {
        Text(text)
            .font(.custom("Ubuntu", size: 20))
            .foregroundColor(Color(.red))
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct ActionButton: ButtonStyle {
    @State var width: CGFloat
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(18)
            .frame(maxWidth: width)
            .background(Color("Purple Heart"))
            .foregroundColor(Color("Green White"))
            .font(.custom("Poppins", size: 20))
            .clipShape(Capsule())
    }
}

struct StandardTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color("Green White"))
            .foregroundColor(Color("Purple Heart"))
            .font(.custom("Poppins", size: 20))
            .clipShape(Capsule())
            .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color("Purple Heart"), style: StrokeStyle(lineWidth: 1.0)))
            .padding(5)
    }
}

struct PhoneNumber: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color("Green White"))
            .foregroundColor(Color("Purple Heart"))
            .font(.custom("Poppins", size: 20))
            .clipShape(Capsule())
            .overlay(RoundedRectangle(cornerRadius: 30).strokeBorder(Color("Purple Heart"), style: StrokeStyle(lineWidth: 1.0)))
            .padding(5)
            .keyboardType(.phonePad)
    }
}

extension String {
    func formatPhoneNumber() -> String {
        // Remove any character that is not a number
        var validChars = self.filter { "0123456789()-".contains("\($0)") }
        let length = validChars.count
        
        guard length < 13 else {
            return String(validChars.prefix(13))
            }
        
        guard length > 0 else {
            return "("
        }
        if validChars.first != "(" {
            validChars = "(" + validChars
        }
        
        guard length > 4 else {
            return validChars
        }
        if validChars[validChars.index(validChars.startIndex, offsetBy: 4)] != ")" {
            validChars = validChars.addStringAt(other: ")", index: 3)
        }
        
        guard length > 8 else {
            return validChars
        }
        if validChars[validChars.index(validChars.startIndex, offsetBy: 8)] != "-" {
            validChars = validChars.addStringAt(other: "-", index: 7)
        }
        
        return validChars
    }
    
    func addStringAt(other: String, index: Int) -> String {
        guard self.count > index else {
            return self
        }
        let before = self[...self.index(self.startIndex, offsetBy: index)]
        let after = self[self.index(self.startIndex, offsetBy: index+1)...]
        return before+other+after
    }
    
    func neverEmpty() -> String {
        if self == "" {
            return " "
        }
        return self
    }
}

struct Primatives_Previews: PreviewProvider {
    static var previews: some View {
        StandardBackground()
        RandomRectangle(width: 338, height: 655, angle: 135, xPos: 100, yPos: 300)
        StandardImage("Ramen", width: 400, height: 100)
    }
}
