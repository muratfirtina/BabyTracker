import Foundation
import CoreLocation

/// Google Places API ile çocuk doktorları arama servisi
class GooglePlacesService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let session: URLSession
    private let apiKey: String
    
    init() {
        // URLSession yapılandırması
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.GooglePlacesAPI.requestTimeout
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
        
        // API Key'i al
        self.apiKey = APIConfig.getSecureAPIKey(for: "google_places") ?? ""
    }
    
    // MARK: - Public Methods
    
    /// Konum bazlı yakındaki çocuk doktorlarını ara
    func searchNearbyPediatricDoctors(
        latitude: Double,
        longitude: Double,
        radius: Double = APIConfig.GooglePlacesAPI.defaultRadius
    ) async throws -> [Doctor] {
        
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
        
        // İlk arama: "çocuk doktoru" keyword ile
        let doctors = try await performNearbySearch(
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            keyword: "çocuk doktoru pediatri"
        )
        
        return doctors
    }
    
    /// Metin bazlı doktor arama
    func searchDoctorsByText(
        query: String,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async throws -> [Doctor] {
        
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
        
        let doctors = try await performTextSearch(
            query: query,
            latitude: latitude,
            longitude: longitude
        )
        
        return doctors
    }
    
    /// Belirli bir place için detaylı bilgi al
    func fetchPlaceDetails(placeId: String, userLocation: CLLocation? = nil) async throws -> Doctor {
        guard !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE" else {
            throw GooglePlacesError.missingAPIKey
        }
        
        var components = URLComponents(string: APIConfig.GooglePlacesAPI.baseURL + APIConfig.GooglePlacesAPI.placeDetailsEndpoint)!
        
        components.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: "name,formatted_address,formatted_phone_number,international_phone_number,geometry,rating,user_ratings_total,opening_hours,website,types,business_status"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "language", value: "tr")
        ]
        
        guard let url = components.url else {
            throw GooglePlacesError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let placeDetailsResponse = try decoder.decode(GooglePlaceDetailsResponse.self, from: data)
        
        guard placeDetailsResponse.status == "OK" else {
            throw GooglePlacesError.apiError(placeDetailsResponse.errorMessage ?? "Unknown error")
        }
        
        return placeDetailsResponse.result.toDoctor(userLocation: userLocation)
    }
    
    // MARK: - Private Methods
    
    /// Nearby Search API çağrısı
    private func performNearbySearch(
        latitude: Double,
        longitude: Double,
        radius: Double,
        keyword: String
    ) async throws -> [Doctor] {
        
        var components = URLComponents(string: APIConfig.GooglePlacesAPI.baseURL + APIConfig.GooglePlacesAPI.nearbySearchEndpoint)!
        
        components.queryItems = [
            URLQueryItem(name: "location", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "radius", value: String(Int(radius))),
            URLQueryItem(name: "type", value: "doctor"),
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "language", value: "tr")
        ]
        
        guard let url = components.url else {
            throw GooglePlacesError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let placesResponse = try decoder.decode(GooglePlacesResponse.self, from: data)
        
        guard placesResponse.isSuccessful else {
            if placesResponse.status == "ZERO_RESULTS" {
                return [] // Sonuç bulunamadı, hata değil
            }
            throw GooglePlacesError.apiError(placesResponse.errorMessage ?? "Unknown error")
        }
        
        // Kullanıcı konumunu oluştur
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Google Place'leri Doctor modeline dönüştür
        let doctors = placesResponse.results.map { place in
            place.toDoctor(userLocation: userLocation)
        }
        
        // Mesafeye göre sırala
        return doctors.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
    }
    
    /// Text Search API çağrısı
    private func performTextSearch(
        query: String,
        latitude: Double?,
        longitude: Double?
    ) async throws -> [Doctor] {
        
        var components = URLComponents(string: APIConfig.GooglePlacesAPI.baseURL + APIConfig.GooglePlacesAPI.textSearchEndpoint)!
        
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "type", value: "doctor"),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "language", value: "tr")
        ]
        
        // Eğer konum verilmişse, o bölgeye öncelik ver
        if let latitude = latitude, let longitude = longitude {
            queryItems.append(URLQueryItem(name: "location", value: "\(latitude),\(longitude)"))
            queryItems.append(URLQueryItem(name: "radius", value: String(Int(APIConfig.GooglePlacesAPI.maxRadius))))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw GooglePlacesError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesError.serverError(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let placesResponse = try decoder.decode(GooglePlacesResponse.self, from: data)
        
        guard placesResponse.isSuccessful else {
            if placesResponse.status == "ZERO_RESULTS" {
                return []
            }
            throw GooglePlacesError.apiError(placesResponse.errorMessage ?? "Unknown error")
        }
        
        // Kullanıcı konumunu oluştur (varsa)
        var userLocation: CLLocation?
        if let latitude = latitude, let longitude = longitude {
            userLocation = CLLocation(latitude: latitude, longitude: longitude)
        }
        
        // Google Place'leri Doctor modeline dönüştür
        let doctors = placesResponse.results.map { place in
            place.toDoctor(userLocation: userLocation)
        }
        
        // Eğer konum varsa mesafeye göre, yoksa rating'e göre sırala
        if userLocation != nil {
            return doctors.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
        } else {
            return doctors.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        }
    }
}

// MARK: - Error Handling
enum GooglePlacesError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Google Places API anahtarı bulunamadı. Lütfen API anahtarınızı APIConfig.swift dosyasına ekleyin."
        case .invalidURL:
            return "Geçersiz URL"
        case .invalidResponse:
            return "Geçersiz yanıt"
        case .serverError(let code):
            return "Sunucu hatası: \(code)"
        case .apiError(let message):
            return "Google Places API Hatası: \(message)"
        case .decodingError:
            return "Veri işleme hatası"
        case .networkError(let error):
            return "Ağ hatası: \(error.localizedDescription)"
        }
    }
}

// MARK: - Helper Extensions
extension GooglePlacesService {
    
    /// API key'in geçerli olup olmadığını kontrol et
    var hasValidAPIKey: Bool {
        return !apiKey.isEmpty && apiKey != "YOUR_GOOGLE_PLACES_API_KEY_HERE"
    }
    
    /// Hata mesajını kullanıcı dostu formata dönüştür
    func getUserFriendlyError(_ error: Error) -> String {
        if let placesError = error as? GooglePlacesError {
            return placesError.errorDescription ?? "Bilinmeyen hata"
        }
        return error.localizedDescription
    }
}
