import Foundation
import CoreLocation

// MARK: - Google Places API Response Models

/// Google Places API ana response modeli
struct GooglePlacesResponse: Codable {
    let results: [GooglePlace]
    let status: String
    let errorMessage: String?
    let nextPageToken: String?
    
    enum CodingKeys: String, CodingKey {
        case results
        case status
        case errorMessage = "error_message"
        case nextPageToken = "next_page_token"
    }
    
    var isSuccessful: Bool {
        return status == "OK" || status == "ZERO_RESULTS"
    }
}

/// Google Place detay modeli
struct GooglePlace: Codable {
    let placeId: String
    let name: String
    let vicinity: String?
    let formattedAddress: String?
    let geometry: GoogleGeometry
    let types: [String]
    let rating: Double?
    let userRatingsTotal: Int?
    let businessStatus: String?
    let openingHours: GoogleOpeningHours?
    let photos: [GooglePhoto]?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case vicinity
        case formattedAddress = "formatted_address"
        case geometry
        case types
        case rating
        case userRatingsTotal = "user_ratings_total"
        case businessStatus = "business_status"
        case openingHours = "opening_hours"
        case photos
    }
}

/// Google Place geometri bilgisi
struct GoogleGeometry: Codable {
    let location: GoogleLocation
}

/// Google konum bilgisi
struct GoogleLocation: Codable {
    let lat: Double
    let lng: Double
}

/// Google açılış saatleri
struct GoogleOpeningHours: Codable {
    let openNow: Bool?
    let weekdayText: [String]?
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
    }
}

/// Google fotoğraf bilgisi
struct GooglePhoto: Codable {
    let photoReference: String
    let height: Int
    let width: Int
    let htmlAttributions: [String]
    
    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
        case height
        case width
        case htmlAttributions = "html_attributions"
    }
    
    /// Fotoğraf URL'ini oluştur
    func getPhotoURL(maxWidth: Int = 400, apiKey: String) -> URL? {
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photo_reference=\(photoReference)&key=\(apiKey)"
        return URL(string: urlString)
    }
}

// MARK: - Place Details Response
struct GooglePlaceDetailsResponse: Codable {
    let result: GooglePlaceDetails
    let status: String
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case result
        case status
        case errorMessage = "error_message"
    }
}

struct GooglePlaceDetails: Codable {
    let placeId: String
    let name: String
    let formattedAddress: String
    let formattedPhoneNumber: String?
    let internationalPhoneNumber: String?
    let geometry: GoogleGeometry
    let rating: Double?
    let userRatingsTotal: Int?
    let openingHours: GooglePlaceOpeningHours?
    let website: String?
    let types: [String]
    let businessStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case name
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case internationalPhoneNumber = "international_phone_number"
        case geometry
        case rating
        case userRatingsTotal = "user_ratings_total"
        case openingHours = "opening_hours"
        case website
        case types
        case businessStatus = "business_status"
    }
}

struct GooglePlaceOpeningHours: Codable {
    let openNow: Bool?
    let periods: [GooglePeriod]?
    let weekdayText: [String]?
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case periods
        case weekdayText = "weekday_text"
    }
}

struct GooglePeriod: Codable {
    let open: GoogleTimeDetail
    let close: GoogleTimeDetail?
}

struct GoogleTimeDetail: Codable {
    let day: Int // 0 = Sunday, 1 = Monday, etc.
    let time: String // HHMM format
}

// MARK: - Conversion to Doctor Model
extension GooglePlace {
    /// Google Place'i Doctor modeline dönüştür
    func toDoctor(userLocation: CLLocation? = nil) -> Doctor {
        let location = Doctor.LocationCoordinate(
            latitude: geometry.location.lat,
            longitude: geometry.location.lng
        )
        
        // Mesafe hesaplama
        var distance: Double?
        if let userLocation = userLocation {
            let placeLocation = CLLocation(latitude: geometry.location.lat, longitude: geometry.location.lng)
            distance = userLocation.distance(from: placeLocation) / 1000.0 // km cinsinden
        }
        
        // Uzmanlık belirleme
        let specialization = determineSpecialization(from: types, name: name)
        
        // Çalışma saatlerini parse et
        let workingHours = parseWorkingHours(from: openingHours)
        
        // Adres bilgisi
        let address = formattedAddress ?? vicinity ?? "Adres bilgisi yok"
        
        // Telefon - Google Places Nearby Search'de telefon bilgisi yok, 
        // bu yüzden Place Details çağrısı yapılması gerekir
        let phone = "Detay için arayın"
        
        return Doctor(
            name: name,
            title: "Dr.",
            specialization: specialization,
            hospital: name, // Google Places'de hastane bilgisi doğrudan yok
            address: address,
            phone: phone,
            location: location,
            rating: rating,
            reviewCount: userRatingsTotal,
            workingHours: workingHours,
            acceptsAppointments: true, // Varsayılan olarak true
            distance: distance
        )
    }
    
    /// Place type'larından uzmanlık belirle
    private func determineSpecialization(from types: [String], name: String) -> String {
        let nameLower = name.lowercased()
        
        if nameLower.contains("çocuk") || nameLower.contains("pediatri") || 
           nameLower.contains("pediatrist") || nameLower.contains("bebek") {
            return "Çocuk Sağlığı ve Hastalıkları"
        }
        
        // Type'lara göre belirleme
        if types.contains("doctor") {
            return "Genel Pratisyen"
        }
        
        return "Sağlık Hizmeti"
    }
    
    /// Açılış saatlerini parse et
    private func parseWorkingHours(from openingHours: GoogleOpeningHours?) -> [Doctor.WorkingHour] {
        guard let weekdayText = openingHours?.weekdayText else {
            return createDefaultWorkingHours()
        }
        
        let dayNames = ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
        
        return weekdayText.enumerated().map { index, text in
            // Örnek format: "Monday: 9:00 AM – 5:00 PM"
            let components = text.components(separatedBy: ": ")
            let dayName = dayNames[index]
            
            if components.count > 1 {
                let timeString = components[1]
                
                if timeString.lowercased().contains("closed") || timeString.lowercased().contains("kapalı") {
                    return Doctor.WorkingHour(
                        day: dayName,
                        startTime: "",
                        endTime: "",
                        isAvailable: false
                    )
                }
                
                // Zaman aralığını parse et
                let times = timeString.components(separatedBy: "–").map { $0.trimmingCharacters(in: .whitespaces) }
                if times.count == 2 {
                    return Doctor.WorkingHour(
                        day: dayName,
                        startTime: times[0],
                        endTime: times[1],
                        isAvailable: true
                    )
                }
            }
            
            // Varsayılan
            return Doctor.WorkingHour(
                day: dayName,
                startTime: "09:00",
                endTime: "17:00",
                isAvailable: true
            )
        }
    }
    
    /// Varsayılan çalışma saatleri
    private func createDefaultWorkingHours() -> [Doctor.WorkingHour] {
        let weekdays = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"]
        let weekend = ["Cumartesi", "Pazar"]
        
        var hours: [Doctor.WorkingHour] = []
        
        // Hafta içi
        for day in weekdays {
            hours.append(Doctor.WorkingHour(
                day: day,
                startTime: "09:00",
                endTime: "17:00",
                isAvailable: true
            ))
        }
        
        // Hafta sonu
        for day in weekend {
            hours.append(Doctor.WorkingHour(
                day: day,
                startTime: "",
                endTime: "",
                isAvailable: false
            ))
        }
        
        return hours
    }
}

// MARK: - Place Details Conversion
extension GooglePlaceDetails {
    /// Place Details'i Doctor modeline dönüştür (daha detaylı bilgi ile)
    func toDoctor(userLocation: CLLocation? = nil) -> Doctor {
        let location = Doctor.LocationCoordinate(
            latitude: geometry.location.lat,
            longitude: geometry.location.lng
        )
        
        // Mesafe hesaplama
        var distance: Double?
        if let userLocation = userLocation {
            let placeLocation = CLLocation(latitude: geometry.location.lat, longitude: geometry.location.lng)
            distance = userLocation.distance(from: placeLocation) / 1000.0
        }
        
        // Uzmanlık belirleme
        let specialization = determineSpecialization(from: types, name: name)
        
        // Çalışma saatlerini parse et
        let workingHours = parseWorkingHours(from: openingHours)
        
        // Telefon bilgisi (Details API'de var)
        let phone = formattedPhoneNumber ?? internationalPhoneNumber ?? "Telefon bilgisi yok"
        
        return Doctor(
            name: name,
            title: "Dr.",
            specialization: specialization,
            hospital: name,
            address: formattedAddress,
            phone: phone,
            location: location,
            rating: rating,
            reviewCount: userRatingsTotal,
            workingHours: workingHours,
            acceptsAppointments: true,
            distance: distance
        )
    }
    
    private func determineSpecialization(from types: [String], name: String) -> String {
        let nameLower = name.lowercased()
        
        if nameLower.contains("çocuk") || nameLower.contains("pediatri") || 
           nameLower.contains("pediatrist") || nameLower.contains("bebek") {
            return "Çocuk Sağlığı ve Hastalıkları"
        }
        
        if types.contains("doctor") {
            return "Genel Pratisyen"
        }
        
        return "Sağlık Hizmeti"
    }
    
    private func parseWorkingHours(from openingHours: GooglePlaceOpeningHours?) -> [Doctor.WorkingHour] {
        guard let weekdayText = openingHours?.weekdayText else {
            return createDefaultWorkingHours()
        }
        
        let dayNames = ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
        
        return weekdayText.enumerated().map { index, text in
            let components = text.components(separatedBy: ": ")
            let dayName = dayNames[index]
            
            if components.count > 1 {
                let timeString = components[1]
                
                if timeString.lowercased().contains("closed") || timeString.lowercased().contains("kapalı") {
                    return Doctor.WorkingHour(
                        day: dayName,
                        startTime: "",
                        endTime: "",
                        isAvailable: false
                    )
                }
                
                let times = timeString.components(separatedBy: "–").map { $0.trimmingCharacters(in: .whitespaces) }
                if times.count == 2 {
                    return Doctor.WorkingHour(
                        day: dayName,
                        startTime: times[0],
                        endTime: times[1],
                        isAvailable: true
                    )
                }
            }
            
            return Doctor.WorkingHour(
                day: dayName,
                startTime: "09:00",
                endTime: "17:00",
                isAvailable: true
            )
        }
    }
    
    private func createDefaultWorkingHours() -> [Doctor.WorkingHour] {
        let weekdays = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma"]
        let weekend = ["Cumartesi", "Pazar"]
        
        var hours: [Doctor.WorkingHour] = []
        
        for day in weekdays {
            hours.append(Doctor.WorkingHour(
                day: day,
                startTime: "09:00",
                endTime: "17:00",
                isAvailable: true
            ))
        }
        
        for day in weekend {
            hours.append(Doctor.WorkingHour(
                day: day,
                startTime: "",
                endTime: "",
                isAvailable: false
            ))
        }
        
        return hours
    }
}
