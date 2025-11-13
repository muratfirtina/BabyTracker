import Foundation
import CoreLocation

struct MapUtility {
    
    enum MapApp: String, CaseIterable {
        case appleMaps = "Apple Haritalar"
        case googleMaps = "Google Maps"
        case yandexMaps = "Yandex Maps"
        
        var iconName: String {
            switch self {
            case .appleMaps:
                return "map.fill"
            case .googleMaps:
                return "globe.europe.africa.fill"
            case .yandexMaps:
                return "location.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .appleMaps:
                return .blue
            case .googleMaps:
                return .green
            case .yandexMaps:
                return .red
            }
        }
    }
    
    // MARK: - Map Opening Functions
    
    static func openInAppleMaps(latitude: Double, longitude: Double, name: String? = nil) {
        var urlString = "http://maps.apple.com/?ll=\(latitude),\(longitude)&z=15"
        
        if let name = name {
            urlString += "&q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    static func openInAppleMapsForDirections(latitude: Double, longitude: Double, name: String? = nil) {
        let destination = "\(latitude),\(longitude)"
        var urlString = "http://maps.apple.com/?daddr=\(destination)&dirflg=d"
        
        if let name = name {
            urlString = "http://maps.apple.com/?daddr=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&dirflg=d"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    static func openInGoogleMaps(latitude: Double, longitude: Double, name: String? = nil) {
        let query = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(latitude),\(longitude)"
        let urlString = "https://www.google.com/maps/search/?api=1&query=\(query)"
        
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
    
    static func openInGoogleMapsForDirections(latitude: Double, longitude: Double, name: String? = nil) {
        let destination = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(latitude),\(longitude)"
        let urlString = "https://www.google.com/maps/dir/?api=1&destination=\(destination)"
        
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
    
    static func openInYandexMaps(latitude: Double, longitude: Double, name: String? = nil) {
        let urlString = "yandexmaps://maps.yandex.com/?ll=\(longitude),\(latitude)&z=15"
        
        guard let url = URL(string: urlString) else {
            // Fallback to web version
            let webUrlString = "https://yandex.com/maps/?ll=\(longitude),\(latitude)&z=15"
            guard let webUrl = URL(string: webUrlString) else { return }
            UIApplication.shared.open(webUrl)
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to web version
            let webUrlString = "https://yandex.com/maps/?ll=\(longitude),\(latitude)&z=15"
            guard let webUrl = URL(string: webUrlString) else { return }
            UIApplication.shared.open(webUrl)
        }
    }
    
    static func openInYandexMapsForDirections(latitude: Double, longitude: Double, name: String? = nil) {
        let urlString = "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            // Fallback to regular Yandex Maps
            openInYandexMaps(latitude: latitude, longitude: longitude, name: name)
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to regular Yandex Maps
            openInYandexMaps(latitude: latitude, longitude: longitude, name: name)
        }
    }
    
    // MARK: - Availability Check Functions
    
    static func isAppleMapsAvailable() -> Bool {
        return true // Apple Maps is always available on iOS
    }
    
    static func isGoogleMapsAvailable() -> Bool {
        return true // Google Maps web version is always available
    }
    
    static func isYandexMapsAvailable() -> Bool {
        guard let url = URL(string: "yandexmaps://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    static func getAvailableMapApps() -> [MapApp] {
        var availableApps: [MapApp] = []
        
        if isAppleMapsAvailable() {
            availableApps.append(.appleMaps)
        }
        
        if isGoogleMapsAvailable() {
            availableApps.append(.googleMaps)
        }
        
        if isYandexMapsAvailable() {
            availableApps.append(.yandexMaps)
        }
        
        return availableApps
    }
    
    // MARK: - Generic Map Opening Function
    
    static func openInMap(
        app: MapApp,
        latitude: Double,
        longitude: Double,
        name: String? = nil,
        forDirections: Bool = false
    ) {
        switch app {
        case .appleMaps:
            if forDirections {
                openInAppleMapsForDirections(latitude: latitude, longitude: longitude, name: name)
            } else {
                openInAppleMaps(latitude: latitude, longitude: longitude, name: name)
            }
            
        case .googleMaps:
            if forDirections {
                openInGoogleMapsForDirections(latitude: latitude, longitude: longitude, name: name)
            } else {
                openInGoogleMaps(latitude: latitude, longitude: longitude, name: name)
            }
            
        case .yandexMaps:
            if forDirections {
                openInYandexMapsForDirections(latitude: latitude, longitude: longitude, name: name)
            } else {
                openInYandexMaps(latitude: latitude, longitude: longitude, name: name)
            }
        }
    }
    
    // MARK: - Distance Calculation
    
    static func calculateDistance(
        from userLocation: CLLocation,
        to targetLatitude: Double,
        targetLongitude: Double
    ) -> Double {
        let targetLocation = CLLocation(latitude: targetLatitude, longitude: targetLongitude)
        return userLocation.distance(from: targetLocation) / 1000 // Convert to kilometers
    }
    
    static func formatDistance(_ distance: Double) -> String {
        if distance < 1 {
            return String(format: "%.0f m", distance * 1000)
        } else {
            return String(format: "%.1f km", distance)
        }
    }
    
    // MARK: - Address Formatting
    
    static func formatAddress(_ address: String) -> String {
        // Clean up common address formatting issues
        let cleanAddress = address
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleanAddress
    }
    
    // MARK: - Phone Number Formatting
    
    static func formatPhoneNumber(_ phone: String) -> String {
        let digits = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if digits.hasPrefix("90") && digits.count == 12 {
            // Turkish phone number format: +90 XXX XXX XX XX
            let formatted = "+90 \(digits.dropFirst(2).prefix(3)) \(digits.dropFirst(5).prefix(3)) \(digits.dropFirst(8).prefix(2)) \(digits.dropFirst(10))"
            return String(formatted)
        } else if digits.hasPrefix("0") && digits.count == 11 {
            // Turkish phone number format: 0XXX XXX XX XX
            let formatted = "\(digits.prefix(4)) \(digits.dropFirst(4).prefix(3)) \(digits.dropFirst(7).prefix(2)) \(digits.dropFirst(9))"
            return String(formatted)
        }
        
        return phone // Return original if format is not recognized
    }
    
    // MARK: - Call Phone Number
    
    static func callPhoneNumber(_ phoneNumber: String) {
        let cleanedPhoneNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        guard let url = URL(string: "tel://\(cleanedPhoneNumber)") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

struct MapSelectionSheet: View {
    let latitude: Double
    let longitude: Double
    let name: String?
    let forDirections: Bool
    @Binding var isPresented: Bool
    
    private let availableApps = MapUtility.getAvailableMapApps()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(forDirections ? "Yol Tarifi Al" : "Haritada Göster")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    if let name = name {
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top)
                
                VStack(spacing: 16) {
                    ForEach(availableApps, id: \.rawValue) { app in
                        MapAppButton(
                            app: app,
                            latitude: latitude,
                            longitude: longitude,
                            name: name,
                            forDirections: forDirections
                        ) {
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoal)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
    }
}

struct MapAppButton: View {
    let app: MapUtility.MapApp
    let latitude: Double
    let longitude: Double
    let name: String?
    let forDirections: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticFeedback.lightImpact()
            MapUtility.openInMap(
                app: app,
                latitude: latitude,
                longitude: longitude,
                name: name,
                forDirections: forDirections
            )
            onTap()
        }) {
            HStack(spacing: 16) {
                Image(systemName: app.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(app.color)
                            .shadow(color: app.color.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoal)
                    
                    Text(forDirections ? "Yol tarifi al" : "Haritada göster")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
