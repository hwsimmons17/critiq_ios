//
//  Server.swift
//  Critiq
//
//  Created by Hunter Simmons on 5/4/23.
//

import Foundation
import CoreLocation


enum LoginState {
    case welcome, notLoggedIn, phoneNumberVerification, loggedIn
}

struct Place: Codable, Hashable, Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
    
    var id: UInt64
    var name: String
    var address: Address
    var  photos: [String]?
    var website: String?
    var foursquareId: String?
}

struct Address: Codable {
    var  address: String
    var   full_address: String?
    var   country: String?
    var   region: String?
    var   postcode: String?
    var   place: String?
    var   street: String?
}

@MainActor
class Network: ObservableObject {
    @Published var errorText: String = ""
    @Published var loginState: LoginState = LoginState.welcome
    
    private var phoneNumber: String = ""
    private var firstName: String = ""
    private var lastName: String = ""
    private var accessToken: String?
    private var refreshToken: String?
    
    struct AuthenticateRequestBody: Codable {
        var firstName: String
        var lastName: String
        var phoneNumber: String
    }
    
    struct OTPRequestBody: Codable {
        var phoneNumber: String
        var code: Int
    }
    
    struct TokenResponseBody: Decodable {
        var accessToken: String
        var refreshToken: String
    }
    
    struct RefreshTokenRequestBody: Codable {
        var refreshToken: String
    }
    
    struct SearchForPlaceRequestBody: Codable {
        var placeName: String
        var location: Coordinates
    }
    
    struct Coordinates: Codable {
        var latitude: Float64
        var longitude: Float64
    }
    
    struct SearchForPlaceResponseBody: Codable {
        var places: [Place]
    }
    
    func determineLoginStatus() {
        let refreshTokenOptional = KeyChain.load(key: "refreshToken")
        guard let refreshToken = refreshTokenOptional else {
            if self.loginState == .loggedIn {
                self.loginState = .welcome
            }
            return
        }
        self.refreshToken = String(decoding: refreshToken, as: UTF8.self)
        self.loginState = .loggedIn
    }
    
    func authenticate(firstName: String, lastName: String, phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self.firstName = firstName
        self.lastName = lastName
        
        let requestBody = AuthenticateRequestBody(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(requestBody)
        guard let url = URL(string: "http://localhost:8080/authenticate") else { fatalError("Missing URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.errorText = "Error connecting to server"
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.errorText = ""
                    self.loginState = LoginState.phoneNumberVerification
                }
            } else {
                DispatchQueue.main.async {
                    guard let data = data else {
                        self.errorText = "Error"
                        return
                    }
                    let err = String(decoding: data, as: UTF8.self)
                    self.errorText = err
                }
            }
        }
        
        dataTask.resume()
    }
    
    func submitOTP(code: String) {
        let requestBody = OTPRequestBody(phoneNumber: self.phoneNumber, code: Int(code) ?? 0)
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(requestBody)
        guard let url = URL(string: "http://localhost:8080/verify-phone") else { fatalError("Missing URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.errorText = "Error connecting to server"
                    self.loginState = LoginState.notLoggedIn
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    guard let data = data else {
                        self.errorText = "Bad response from server"
                        self.loginState = LoginState.notLoggedIn
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let res = try decoder.decode(TokenResponseBody.self, from: data)
                        self.accessToken = res.accessToken
                        self.refreshToken = res.refreshToken
                        if errSecSuccess !=  KeyChain.save(key:"refreshToken", data: Data(res.refreshToken.utf8)) {
                        }
                        self.loginState = .loggedIn
                        return
                    } catch {
                        self.errorText = "Bad response from server"
                        self.loginState = LoginState.notLoggedIn
                    }
                }
            } else {
                DispatchQueue.main.async {
                    guard let data = data else {
                        self.errorText = "Error"
                        self.loginState = LoginState.notLoggedIn
                        
                        return
                    }
                    let err = String(decoding: data, as: UTF8.self)
                    self.errorText = err
                    if err == "" {
                        self.errorText = "Invalid code"
                    }
                    self.loginState = LoginState.notLoggedIn
                }
            }
        }
        dataTask.resume()
    }
    
    func searchForPlaces(location: CLLocationCoordinate2D, searchString: String) async -> ([Place], String?) {
        let token = await self.refreshAccessToken()
        guard let token = token else {
            return ([], "No access token")
        }
        let requestBody = SearchForPlaceRequestBody(placeName: searchString, location: Coordinates(latitude: location.latitude, longitude: location.longitude))
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(requestBody)
        guard let url = URL(string: "http://localhost:8080/search-places") else { fatalError("Missing URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else { return ([], "Error with request") }
            
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let res = try decoder.decode(SearchForPlaceResponseBody.self, from: data)
                    return (res.places, nil)
                } catch {
                    return ([], "Error decoding JSON")
                }
            } else {
                return ([], "Response not ok")
            }
        } catch {
            return ([], "Error with request")
        }
    }
    
    func refreshAccessToken() async -> String? {
        let refreshTokenOptional = KeyChain.load(key: "refreshToken")
        guard let refreshToken = refreshTokenOptional else {
            return nil
        }
        let token = String(decoding: refreshToken, as: UTF8.self)
        let requestBody = RefreshTokenRequestBody(refreshToken: token)
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(requestBody)
        guard let url = URL(string: "http://localhost:8080/refresh-token") else { fatalError("Missing URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else { return nil }
            if response.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let res = try decoder.decode(TokenResponseBody.self, from: data)
                    self.accessToken = res.accessToken
                    self.refreshToken = res.refreshToken
                    return res.accessToken
                } catch {}
            } else {}
        } catch {}
        return nil
    }
}



class KeyChain {
    
    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    
    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
}

