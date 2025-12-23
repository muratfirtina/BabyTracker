import Foundation
import CoreLocation

// MARK: - Cache Models
struct CachedResult {
    let doctors: [Doctor]
    let timestamp: Date
    let nextPageToken: String?
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > 300 // 5 dakika cache
    }
}

struct CacheKey: Hashable {
    let type: String // "doctors" veya "hospitals"
    let latitude: Double
    let longitude: Double
    let radius: Double
    let query: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(String(format: "%.4f", latitude))
        hasher.combine(String(format: "%.4f", longitude))
        hasher.combine(String(format: "%.1f", radius))
        hasher.combine(query ?? "")
    }
}

/// Google Places API (New) - Yeni versiyon servisi
class GooglePlacesNewService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let session: URLSession
    private let apiKey: String
    
    // Task cancellation için
    private var currentTask: Task<Void, Never>?
    
    // Cache için
    private var cache: [CacheKey: CachedResult] = [:]
    private let cacheQueue = DispatchQueue(label: "com.babytracker.placescache")
    
    // Yeni API base URL
    private let baseURL = "https://places.googleapis.com/v1"
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 30 saniye timeout
        configuration.timeoutIntervalForResource = 60 // 60 saniye resource timeout
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Network proxy ayarlarını devre dışı bırak (simulator için)
        configuration.connectionProxyDictionary = [:]
        
        // HTTP pipelining'i kapat (simulator için)
        configuration.httpShouldUsePipelining = false
        
        self.session = URLSession(configuration: configuration)
        
        self.apiKey = APIConfig.getSecureAPIKey(for: "google_places") ?? ""
    }
    
    // MARK: - Public Methods with Pagination
    
    /// Konum bazlı yakındaki çocuk doktorlarını ara (Pagination destekli)
    func searchNearbyPediatricDoctors(
        latitude: Double,
        longitude: Double,
        radius: Double = 3000.0, // 3km
        pageToken: String? = nil
    ) async throws -> (doctors: [Doctor], nextPageToken: String?) {
        
        guard !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" else {
            throw GooglePlacesError.missingAPIKey
        }
        
        // Cache kontrolu (sadece ilk sayfa için)
        if pageToken == nil {
            let cacheKey = CacheKey(type: "doctors", latitude: latitude, longitude: longitude, radius: radius, query: nil)
            if let cached = getCachedResult(for: cacheKey), !cached.isExpired {
                print("📋 Cache'den doktor verisi alındı")
                return (cached.doctors, cached.nextPageToken)
            }
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // ÇOCUK DOKTORU ARAM ASI İÇİN TEXT-BASED SEARCH KULLAN
        // Bu sayede sadece çocuk doktorları gelecek, veteriner/dişçi vs. karışmayacak
        let result = try await performTextSearch(
            query: "çocuk doktoru pediatri", // Spesifik arama
            latitude: latitude,
            longitude: longitude,
            includedTypes: ["doctor"],
            pageToken: pageToken,
            maxRadius: radius
        )
        
        // İlk sayfayı cache'le
        if pageToken == nil {
            let cacheKey = CacheKey(type: "doctors", latitude: latitude, longitude: longitude, radius: radius, query: nil)
            setCachedResult(result, for: cacheKey)
        }
        
        return result
    }
    
    /// Konum bazlı yakındaki hastaneleri ara (Pagination destekli)
    func searchNearbyHospitals(
        latitude: Double,
        longitude: Double,
        radius: Double = 6000.0, // 6km
        pageToken: String? = nil
    ) async throws -> (doctors: [Doctor], nextPageToken: String?) {
        
        guard !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" else {
            throw GooglePlacesError.missingAPIKey
        }
        
        // Cache kontrolu (sadece ilk sayfa için)
        if pageToken == nil {
            let cacheKey = CacheKey(type: "hospitals", latitude: latitude, longitude: longitude, radius: radius, query: nil)
            if let cached = getCachedResult(for: cacheKey), !cached.isExpired {
                print("📋 Cache'den hastane verisi alındı")
                return (cached.doctors, cached.nextPageToken)
            }
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        let result = try await performSearchNearby(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            includedTypes: ["hospital"], // Sadece hastaneler
            pageToken: pageToken
        )
        
        // İlk sayfayı cache'le
        if pageToken == nil {
            let cacheKey = CacheKey(type: "hospitals", latitude: latitude, longitude: longitude, radius: radius, query: nil)
            setCachedResult(result, for: cacheKey)
        }
        
        return result
    }
    
    /// Text bazlı doktor arama (Pagination destekli)
    func searchDoctorsByText(
        query: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        pageToken: String? = nil
    ) async throws -> (doctors: [Doctor], nextPageToken: String?) {
        
        guard !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" else {
            throw GooglePlacesError.missingAPIKey
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        // Kullanıcı zaten "çocuk" veya "pediatri" yazmamışsa ekle
        let enhancedQuery: String
        let lowercasedQuery = query.lowercased()
        if lowercasedQuery.contains("çocuk") || lowercasedQuery.contains("pediatr") ||
           lowercasedQuery.contains("bebek") {
            enhancedQuery = query
        } else {
            enhancedQuery = "çocuk doktoru \(query)"
        }
        
        return try await performTextSearch(
            query: enhancedQuery,
            latitude: latitude,
            longitude: longitude,
            includedTypes: ["doctor"],
            pageToken: pageToken
        )
    }
    
    /// Text bazlı hastane arama (Pagination destekli)
    func searchHospitalsByText(
        query: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        pageToken: String? = nil
    ) async throws -> (doctors: [Doctor], nextPageToken: String?) {
        
        guard !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" else {
            throw GooglePlacesError.missingAPIKey
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        return try await performTextSearch(
            query: query,
            latitude: latitude,
            longitude: longitude,
            includedTypes: ["hospital"],
            pageToken: pageToken
        )
    }
    
    // MARK: - Cache Methods
    
    private func getCachedResult(for key: CacheKey) -> CachedResult? {
        return cacheQueue.sync {
            return cache[key]
        }
    }
    
    private func setCachedResult(_ result: (doctors: [Doctor], nextPageToken: String?), for key: CacheKey) {
        cacheQueue.async {
            self.cache[key] = CachedResult(
                doctors: result.doctors,
                timestamp: Date(),
                nextPageToken: result.nextPageToken
            )
        }
    }
    
    func clearCache() {
        cacheQueue.async {
            self.cache.removeAll()
            print("🗑️ Cache temizlendi")
        }
    }
    
    // MARK: - Private Methods (Yeni API Format)
    
    private func performSearchNearby(
        latitude: Double,
        longitude: Double,
        radius: Double
    ) async throws -> [Doctor] {
        
        // Task iptal edilmiş mi kontrol et
        try Task.checkCancellation()
        
        let url = URL(string: "\(baseURL)/places:searchNearby")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.internationalPhoneNumber,places.types", forHTTPHeaderField: "X-Goog-FieldMask")
        
        // Yeni API JSON body formatı
        let requestBody: [String: Any] = [
            "includedTypes": ["doctor", "hospital"],
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": radius
                ]
            ],
            "languageCode": "tr"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Hata mesajını parse et
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GooglePlacesError.apiError(message)
            }
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        // Yeni API response'u parse et
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(NewPlacesSearchResponse.self, from: data)
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Doctor modeline dönüştür
        let doctors = searchResponse.places.compactMap { place in
            convertNewPlaceToDoctor(place, userLocation: userLocation)
        }
        
        return doctors.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
    }
    
    private func performTextSearch(
        query: String,
        latitude: Double?,
        longitude: Double?,
        maxRadius: Double? = nil
    ) async throws -> [Doctor] {
        
        // Task iptal edilmiş mi kontrol et
        try Task.checkCancellation()
        
        let url = URL(string: "\(baseURL)/places:searchText")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.internationalPhoneNumber,places.types", forHTTPHeaderField: "X-Goog-FieldMask")
        
        var requestBody: [String: Any] = [
            "textQuery": query,
            "languageCode": "tr",
            "maxResultCount": 20
        ]
        
        // Eğer konum verilmişse ekle
        if let latitude = latitude, let longitude = longitude {
            let radiusToUse = maxRadius ?? 50000.0 // Varsayılan 50km
            requestBody["locationBias"] = [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": radiusToUse
                ]
            ]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GooglePlacesError.apiError(message)
            }
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(NewPlacesSearchResponse.self, from: data)
        
        // Debug log
        print("📋 Text Search: \(searchResponse.places.count) sonuç, nextPageToken: \(searchResponse.nextPageToken != nil ? "Var" : "Yok")")
        
        var userLocation: CLLocation?
        if let latitude = latitude, let longitude = longitude {
            userLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        let doctors = searchResponse.places.compactMap { place in
            convertNewPlaceToDoctor(place, userLocation: userLocation)
        }
        
        if userLocation != nil {
            return doctors.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
        } else {
            return doctors.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }
    }
    
    // MARK: - Conversion Helper
    
    private func convertNewPlaceToDoctor(_ place: NewPlace, userLocation: CLLocation?) -> Doctor? {
        guard let location = place.location else { return nil }
        
        let doctorLocation = Doctor.LocationCoordinate(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        var distance: Double?
        if let userLocation = userLocation {
            let placeLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            distance = userLocation.distance(from: placeLocation) / 1000.0
        }
        
        // Çalışma saatlerini parse et
        let workingHours = parseNewAPIWorkingHours(place.regularOpeningHours)
        
        // İsmi al
        let placeName = place.displayName?.text ?? "Doktor"
        
        // Doktor adını ve hastane adını ayır
        let (doctorName, hospitalName) = parseDoctorAndHospitalName(placeName, types: place.types)
        
        // Uzmanlık belirle
        let specialization = determineSpecialization(from: placeName, types: place.types)
        
        // Title belirle - Eğer doctorName "generic" ise, title ekleme
        let title: String
        if doctorName == "Çocuk Doktoru" || doctorName == "Genel Pratisyen" {
            title = "" // Generic isimler için title yok
        } else {
            title = determineTitle(from: placeName)
        }
        
        return Doctor(
            name: doctorName,
            title: title,
            specialization: specialization,
            hospital: hospitalName,
            address: place.formattedAddress ?? "Adres bilgisi yok",
            phone: place.internationalPhoneNumber ?? "Detay için arayın",
            location: doctorLocation,
            rating: place.rating,
            reviewCount: place.userRatingCount,
            workingHours: workingHours,
            acceptsAppointments: true,
            distance: distance
        )
    }
    
    // Doktor adını ve hastane adını ayırmak için
    private func parseDoctorAndHospitalName(_ fullName: String, types: [String]?) -> (doctorName: String, hospitalName: String) {
        let name = fullName
        let lowercasedName = name.lowercased()
        
        // 1. Önce hastane/klinik/tıp merkezi olup olmadığını kontrol et
        let hospitalKeywords = [
            "hastane", "hastanesi", "hospital",
            "tıp merkezi", "tıp merkez", "medical center",
            "sağlık merkezi", "health center",
            "üniversite", "university",
            "devlet hastanesi", "state hospital"
        ]
        
        let clinicKeywords = [
            "klinik", "kliniği", "clinic",
            "poliklinik", "polyclinic"
        ]
        
        let isHospital = hospitalKeywords.contains { lowercasedName.contains($0) }
        let isClinic = clinicKeywords.contains { lowercasedName.contains($0) }
        
        // 2. Eğer hastane/klinik ise
        if isHospital || isClinic {
            // "Dr." ile başlıyor ama aslında hastane adı
            // Örnek: "Dr. ÖZEL İLGİ ÇOCUK TIP MERKEZİ"
            if name.hasPrefix("Dr.") || name.hasPrefix("Dr ") {
                // Tüm ismi hastane olarak kullan, doktor adı generic
                return ("Çocuk Doktoru", name)
            }
            
            // "-" ile ayrılmışsa
            // Örnek: "Dr. Ayşe Yılmaz - Acıbadem Hastanesi"
            if name.contains("-") {
                let components = name.components(separatedBy: "-")
                if components.count >= 2 {
                    let doctorPart = components[0].trimmingCharacters(in: .whitespaces)
                    let hospitalPart = components[1].trimmingCharacters(in: .whitespaces)
                    
                    // Doktor kısmında hastane kelimesi varsa, doktor değil
                    let doctorLowercased = doctorPart.lowercased()
                    let isDoctorPartHospital = hospitalKeywords.contains { doctorLowercased.contains($0) } ||
                                               clinicKeywords.contains { doctorLowercased.contains($0) }
                    
                    if isDoctorPartHospital {
                        // Her iki kısım da hastane
                        return ("Çocuk Doktoru", name)
                    }
                    
                    // Doktor adını temizle
                    let cleanDoctorName = cleanDoctorTitle(doctorPart)
                    
                    // Doktor adı çok kısa veya sadece unvan varsa
                    if cleanDoctorName.count < 3 || cleanDoctorName == doctorPart {
                        return ("Çocuk Doktoru", hospitalPart)
                    }
                    
                    return (cleanDoctorName, hospitalPart)
                }
            }
            
            // Hastane/klinik ama doktor ayrımı yok
            return ("Çocuk Doktoru", name)
        }
        
        // 3. Muayenehane/Özel Muayenehane kontrolü
        let privateClinicKeywords = [
            "muayenehane", "muayenehanesi",
            "özel muayenehane", "private clinic"
        ]
        
        let isPrivateClinic = privateClinicKeywords.contains { lowercasedName.contains($0) }
        
        if isPrivateClinic {
            // "Dr. Mehmet Kaya Muayenehanesi" → "Dr. Mehmet Kaya" + "Muayenehane"
            var doctorName = name
            for keyword in privateClinicKeywords {
                doctorName = doctorName.replacingOccurrences(of: keyword, with: "", options: .caseInsensitive)
            }
            doctorName = doctorName.trimmingCharacters(in: .whitespaces)
            doctorName = cleanDoctorTitle(doctorName)
            
            if doctorName.isEmpty || doctorName.count < 3 {
                return ("Çocuk Doktoru", name)
            }
            
            return (doctorName, name)
        }
        
        // 4. Sadece doktor adı ("Dr." ile başlıyor, hastane/klinik kelimesi yok)
        if name.hasPrefix("Dr.") || name.hasPrefix("Dr ") ||
           lowercasedName.contains("doktor") || lowercasedName.contains("doctor") {
            
            // "-" ile ayrılmışsa
            if name.contains("-") {
                let components = name.components(separatedBy: "-")
                if components.count >= 2 {
                    let doctorPart = components[0].trimmingCharacters(in: .whitespaces)
                    let secondPart = components[1].trimmingCharacters(in: .whitespaces)
                    
                    let cleanDoctorName = cleanDoctorTitle(doctorPart)
                    
                    if cleanDoctorName.count >= 3 {
                        return (cleanDoctorName, secondPart)
                    }
                }
            }
            
            // Tek parça doktor adı
            let cleanName = cleanDoctorTitle(name)
            if cleanName.count >= 3 {
                return (cleanName, name)
            }
        }
        
        // 5. Diğer durumlar - varsayılan
        return ("Çocuk Doktoru", name)
    }
    
    // Doktor adından "Dr.", "Doktor" gibi unvanları temizle
    private func cleanDoctorTitle(_ name: String) -> String {
        var cleanName = name
        let titlesToRemove = ["Dr. ", "Dr.", "Doktor ", "doktor ", "Prof. Dr. ", "Prof.Dr.", "Doç. Dr. ", "Doç.Dr.", "Uzm. Dr. ", "Uzm.Dr."]
        
        for title in titlesToRemove {
            cleanName = cleanName.replacingOccurrences(of: title, with: "", options: .caseInsensitive)
        }
        
        return cleanName.trimmingCharacters(in: .whitespaces)
    }
    
    // Uzmanlık belirleme
    private func determineSpecialization(from name: String, types: [String]?) -> String {
        let lowercasedName = name.lowercased()
        
        // Alt uzmanlıklar
        if lowercasedName.contains("göz") || lowercasedName.contains("oftalmoloj") {
            return "Çocuk Göz Hastalıkları"
        }
        if lowercasedName.contains("kalp") || lowercasedName.contains("kardiyoloj") {
            return "Çocuk Kardiyolojisi"
        }
        if lowercasedName.contains("endokrin") {
            return "Çocuk Endokrinolojisi"
        }
        if lowercasedName.contains("nöroloj") || lowercasedName.contains("sinir") {
            return "Çocuk Nörolojisi"
        }
        if lowercasedName.contains("gastro") || lowercasedName.contains("sindirim") {
            return "Çocuk Gastroenterolojisi"
        }
        if lowercasedName.contains("hematoloj") || lowercasedName.contains("kan") {
            return "Çocuk Hematolojisi"
        }
        if lowercasedName.contains("cerrahi") {
            return "Çocuk Cerrahisi"
        }
        if lowercasedName.contains("allerj") || lowercasedName.contains("alerji") {
            return "Çocuk Alerji ve İmmünoloji"
        }
        
        // Genel çocuk veya pediatri
        if lowercasedName.contains("çocuk") || lowercasedName.contains("pediatr") ||
           lowercasedName.contains("bebek") || lowercasedName.contains("pediatric") {
            return "Çocuk Sağlığı ve Hastalıkları"
        }
        
        // Varsayılan - Genel Pratisyen DEĞİL, Çocuk Sağlığı
        return "Çocuk Sağlığı ve Hastalıkları"
    }
    
    // Title belirleme
    private func determineTitle(from name: String) -> String {
        if name.contains("Prof.") || name.contains("Profesör") {
            return "Prof. Dr."
        } else if name.contains("Doç.") {
            return "Doç. Dr."
        } else if name.contains("Uzm.") || name.contains("Uzman") {
            return "Uzm. Dr."
        } else if name.contains("Dr.") {
            return "Dr."
        }
        return "Dr."
    }
    
    private func parseNewAPIWorkingHours(_ openingHours: NewOpeningHours?) -> [Doctor.WorkingHour] {
        guard let weekdayDescriptions = openingHours?.weekdayDescriptions else {
            return createDefaultWorkingHours()
        }
        
        let dayNames = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
        
        return weekdayDescriptions.enumerated().map { index, text in
            let dayName = index < dayNames.count ? dayNames[index] : "Bilinmiyor"
            
            if text.lowercased().contains("closed") || text.lowercased().contains("kapalı") {
                return Doctor.WorkingHour(
                    day: dayName,
                    startTime: "",
                    endTime: "",
                    isAvailable: false
                )
            }
            
            // Parse time range
            let components = text.components(separatedBy: ": ")
            if components.count > 1 {
                let timeString = components[1]
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
    
    // MARK: - Hospital Search Methods
    
    private func performHospitalSearchNearby(
        latitude: Double,
        longitude: Double,
        radius: Double
    ) async throws -> [Doctor] {
        
        // Task iptal edilmiş mi kontrol et
        try Task.checkCancellation()
        
        let url = URL(string: "\(baseURL)/places:searchNearby")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.internationalPhoneNumber,places.types", forHTTPHeaderField: "X-Goog-FieldMask")
        
        // Hastane araması için includedTypes
        let requestBody: [String: Any] = [
            "includedTypes": ["hospital"],
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": radius
                ]
            ],
            "languageCode": "tr"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GooglePlacesError.apiError(message)
            }
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(NewPlacesSearchResponse.self, from: data)
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Doctor modeline dönüştür (hastaneler için)
        let hospitals = searchResponse.places.compactMap { place in
            convertNewPlaceToHospital(place, userLocation: userLocation)
        }
        
        return hospitals.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
    }
    
    private func performHospitalTextSearch(
        query: String,
        latitude: Double?,
        longitude: Double?,
        maxRadius: Double? = nil
    ) async throws -> [Doctor] {
        
        // Task iptal edilmiş mi kontrol et
        try Task.checkCancellation()
        
        let url = URL(string: "\(baseURL)/places:searchText")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.internationalPhoneNumber,places.types", forHTTPHeaderField: "X-Goog-FieldMask")
        
        var requestBody: [String: Any] = [
            "textQuery": query,
            "languageCode": "tr",
            "maxResultCount": 20
        ]
        
        // Eğer konum verilmişse ekle
        if let latitude = latitude, let longitude = longitude {
            let radiusToUse = maxRadius ?? 50000.0 // Varsayılan 50km
            requestBody["locationBias"] = [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": radiusToUse
                ]
            ]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GooglePlacesError.apiError(message)
            }
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(NewPlacesSearchResponse.self, from: data)
        
        var userLocation: CLLocation?
        if let latitude = latitude, let longitude = longitude {
            userLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        let hospitals = searchResponse.places.compactMap { place in
            convertNewPlaceToHospital(place, userLocation: userLocation)
        }
        
        if userLocation != nil {
            return hospitals.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
        } else {
            return hospitals.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }
    }
    
    // Hastane için özel converter
    private func convertNewPlaceToHospital(_ place: NewPlace, userLocation: CLLocation?) -> Doctor? {
        guard let location = place.location else { return nil }
        
        let hospitalLocation = Doctor.LocationCoordinate(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        var distance: Double?
        if let userLocation = userLocation {
            let placeLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            distance = userLocation.distance(from: placeLocation) / 1000.0
        }
        
        // Çalışma saatlerini parse et
        let workingHours = parseNewAPIWorkingHours(place.regularOpeningHours)
        
        // Hastane adını al
        let hospitalName = place.displayName?.text ?? "Hastane"
        
        // Hastane türünü belirle
        let specialization = determineHospitalType(from: hospitalName)
        
        return Doctor(
            name: hospitalName,
            title: "",
            specialization: specialization,
            hospital: hospitalName,
            address: place.formattedAddress ?? "Adres bilgisi yok",
            phone: place.internationalPhoneNumber ?? "Detay için arayın",
            location: hospitalLocation,
            rating: place.rating,
            reviewCount: place.userRatingCount,
            workingHours: workingHours,
            acceptsAppointments: true,
            distance: distance
        )
    }
    
    // Hastane türünü belirleme
    private func determineHospitalType(from name: String) -> String {
        let lowercasedName = name.lowercased()
        
        if lowercasedName.contains("üniversite") || lowercasedName.contains("university") {
            return "Genel & Araştırma Hastanesi"
        }
        if lowercasedName.contains("devlet") || lowercasedName.contains("state") {
            return "Devlet Hastanesi"
        }
        if lowercasedName.contains("özel") || lowercasedName.contains("private") {
            return "Özel Hastane"
        }
        if lowercasedName.contains("eğitim") || lowercasedName.contains("training") ||
           lowercasedName.contains("araştırma") || lowercasedName.contains("research") {
            return "Eğitim ve Araştırma Hastanesi"
        }
        
        return "Genel Hastane"
    }
    
    // MARK: - Private Pagination Methods
    
    /// Pagination destekli searchNearby
    private func performSearchNearby(
        latitude: Double,
        longitude: Double,
        radius: Double,
        includedTypes: [String],
        pageToken: String? = nil
    ) async throws -> (doctors: [Doctor], nextPageToken: String?) {
        
        try Task.checkCancellation()
        
        let url = URL(string: "\(baseURL)/places:searchNearby")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.internationalPhoneNumber,places.types", forHTTPHeaderField: "X-Goog-FieldMask")
        
        var requestBody: [String: Any] = [
            "includedTypes": includedTypes,
            "maxResultCount": 20,
            "locationRestriction": [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": radius
                ]
            ],
            "languageCode": "tr"
        ]
        
        // PageToken varsa ekle
        if let pageToken = pageToken {
            requestBody["pageToken"] = pageToken
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GooglePlacesError.apiError(message)
            }
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(NewPlacesSearchResponse.self, from: data)
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Doctor modeline dönüştür
        let doctors = searchResponse.places.compactMap { place in
            if includedTypes.contains("hospital") {
                return convertNewPlaceToHospital(place, userLocation: userLocation)
            } else {
                return convertNewPlaceToDoctor(place, userLocation: userLocation)
            }
        }
        
        // Rating'e göre sırala (yüksekten düşüğe)
        let sortedDoctors = doctors.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        
        return (sortedDoctors, searchResponse.nextPageToken)
    }
    
    /// Pagination destekli textSearch
    private func performTextSearch(
        query: String,
        latitude: Double?,
        longitude: Double?,
        includedTypes: [String],
        pageToken: String? = nil,
        maxRadius: Double? = nil
    ) async throws -> (doctors: [Doctor], nextPageToken: String?) {
        
        try Task.checkCancellation()
        
        let url = URL(string: "\(baseURL)/places:searchText")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.regularOpeningHours,places.internationalPhoneNumber,places.types", forHTTPHeaderField: "X-Goog-FieldMask")
        
        var requestBody: [String: Any] = [
            "textQuery": query,
            "languageCode": "tr",
            "maxResultCount": 20,
            "includedType": includedTypes.first ?? "doctor" // Text search tek type alıyor
        ]
        
        // PageToken varsa ekle
        if let pageToken = pageToken {
            requestBody["pageToken"] = pageToken
        }
        
        // Eğer konum verilmişse ekle
        if let latitude = latitude, let longitude = longitude {
            let radiusToUse = maxRadius ?? 50000.0 // Varsayılan 50km
            requestBody["locationBias"] = [
                "circle": [
                    "center": [
                        "latitude": latitude,
                        "longitude": longitude
                    ],
                    "radius": radiusToUse
                ]
            ]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJSON["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw GooglePlacesError.apiError(message)
            }
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(NewPlacesSearchResponse.self, from: data)
        
        var userLocation: CLLocation?
        if let latitude = latitude, let longitude = longitude {
            userLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        let doctors = searchResponse.places.compactMap { place in
            if includedTypes.contains("hospital") {
                return convertNewPlaceToHospital(place, userLocation: userLocation)
            } else {
                return convertNewPlaceToDoctor(place, userLocation: userLocation)
            }
        }
        
        // Rating'e göre sırala (yüksekten düşüğe)
        let sortedDoctors = doctors.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        
        return (sortedDoctors, searchResponse.nextPageToken)
    }
    
    var hasValidAPIKey: Bool {
        return !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE"
    }
    
    func getUserFriendlyError(_ error: Error) -> String {
        if let placesError = error as? GooglePlacesError {
            return placesError.errorDescription ?? "Bilinmeyen hata"
        }
        return error.localizedDescription
    }
}

// MARK: - New API Response Models

struct NewPlacesSearchResponse: Codable {
    let places: [NewPlace]
    let nextPageToken: String?
}

struct NewPlace: Codable {
    let displayName: NewDisplayName?
    let formattedAddress: String?
    let location: NewLocation?
    let rating: Double?
    let userRatingCount: Int?
    let regularOpeningHours: NewOpeningHours?
    let internationalPhoneNumber: String?
    let types: [String]?
}

struct NewDisplayName: Codable {
    let text: String
    let languageCode: String?
}

struct NewLocation: Codable {
    let latitude: Double
    let longitude: Double
}

struct NewOpeningHours: Codable {
    let openNow: Bool?
    let weekdayDescriptions: [String]?
}
