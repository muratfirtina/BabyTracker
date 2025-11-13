import Foundation
import CoreLocation

struct Pharmacy: Identifiable, Codable {
    let id: UUID
    let name: String
    let address: String
    let phone: String
    let location: LocationCoordinate
    let isOnDuty: Bool
    let dutyStartTime: String?
    let dutyEndTime: String?
    let district: String
    let province: String
    let distance: Double? // km cinsinden
    
    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        phone: String,
        location: LocationCoordinate,
        isOnDuty: Bool,
        dutyStartTime: String? = nil,
        dutyEndTime: String? = nil,
        district: String,
        province: String,
        distance: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.location = location
        self.isOnDuty = isOnDuty
        self.dutyStartTime = dutyStartTime
        self.dutyEndTime = dutyEndTime
        self.district = district
        self.province = province
        self.distance = distance
    }
    
    struct LocationCoordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        var clLocation: CLLocation {
            CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}

// NosyAPI Response Models
struct NosyAPIResponse: Codable {
    let status: Bool
    let data: [PharmacyData]
}

struct PharmacyData: Codable {
    let name: String
    let address: String
    let phone: String
    let location: NosyLocation
    let district: String
    let province: String
    
    struct NosyLocation: Codable {
        let latitude: String
        let longitude: String
    }
    
    // Convert to our Pharmacy model
    func toPharmacy(distance: Double? = nil) -> Pharmacy {
        return Pharmacy(
            name: name,
            address: address,
            phone: phone,
            location: Pharmacy.LocationCoordinate(
                latitude: Double(location.latitude) ?? 0.0,
                longitude: Double(location.longitude) ?? 0.0
            ),
            isOnDuty: true, // NosyAPI sadece nöbetçi eczaneleri döndürür
            dutyStartTime: "08:00",
            dutyEndTime: "08:00", // Nöbetçi eczaneler 24 saat açık
            district: district,
            province: province,
            distance: distance
        )
    }
}

extension Pharmacy {
    static let mockPharmacies: [Pharmacy] = [
        Pharmacy(
            name: "Yeni Eczane",
            address: "Cumhuriyet Cd. No:156/A, 34367 Şişli/İstanbul",
            phone: "+90 212 296 45 67",
            location: LocationCoordinate(latitude: 41.0603, longitude: 28.9846),
            isOnDuty: true,
            dutyStartTime: "08:00",
            dutyEndTime: "08:00",
            district: "Şişli",
            province: "İstanbul",
            distance: 0.8
        ),
        Pharmacy(
            name: "Sağlık Eczanesi",
            address: "İnönü Cd. No:23, 34373 Şişli/İstanbul",
            phone: "+90 212 231 78 90",
            location: LocationCoordinate(latitude: 41.0525, longitude: 28.9789),
            isOnDuty: true,
            dutyStartTime: "08:00",
            dutyEndTime: "08:00",
            district: "Şişli",
            province: "İstanbul",
            distance: 1.2
        ),
        Pharmacy(
            name: "Modern Eczane",
            address: "Büyükdere Cd. No:78, 34394 Şişli/İstanbul",
            phone: "+90 212 275 34 12",
            location: LocationCoordinate(latitude: 41.0682, longitude: 28.9903),
            isOnDuty: true,
            dutyStartTime: "08:00",
            dutyEndTime: "08:00",
            district: "Şişli",
            province: "İstanbul",
            distance: 1.5
        ),
        Pharmacy(
            name: "Aile Eczanesi",
            address: "Halaskargazi Cd. No:45, 34371 Şişli/İstanbul",
            phone: "+90 212 247 65 43",
            location: LocationCoordinate(latitude: 41.0564, longitude: 28.9823),
            isOnDuty: true,
            dutyStartTime: "08:00",
            dutyEndTime: "08:00",
            district: "Şişli",
            province: "İstanbul",
            distance: 0.9
        )
    ]
}
