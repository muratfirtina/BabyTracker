import Foundation
import CoreLocation

class PharmacyService: ObservableObject {
    @Published var nearbyPharmacies: [Pharmacy] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let session = URLSession.shared
    
    func fetchNearbyPharmacies(latitude: Double, longitude: Double) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let pharmacies = try await performAPIRequest(latitude: latitude, longitude: longitude)
            await MainActor.run {
                self.nearbyPharmacies = pharmacies
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func fetchPharmaciesByCity(city: String, district: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let pharmacies = try await performCityAPIRequest(city: city, district: district)
            await MainActor.run {
                self.nearbyPharmacies = pharmacies
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func performAPIRequest(latitude: Double, longitude: Double) async throws -> [Pharmacy] {
        guard let apiKey = APIConfig.NosyAPI.apiKey else {
            throw PharmacyServiceError.missingAPIKey
        }
        
        var components = URLComponents(string: APIConfig.NosyAPI.baseURL + APIConfig.NosyAPI.Endpoints.gpsPharmacies)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "limit", value: "20")
        ]
        
        guard let url = components.url else {
            throw PharmacyServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PharmacyServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PharmacyServiceError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(NosyAPIResponse.self, from: data)
        
        guard decodedResponse.success else {
            throw PharmacyServiceError.apiError(decodedResponse.message ?? "Unknown error")
        }
        
        return decodedResponse.data?.map { nosyPharmacy in
            Pharmacy(
                id: UUID(),
                name: nosyPharmacy.name,
                address: nosyPharmacy.address,
                phone: nosyPharmacy.phone,
                latitude: nosyPharmacy.latitude,
                longitude: nosyPharmacy.longitude,
                distance: nosyPharmacy.distance,
                city: nosyPharmacy.city,
                district: nosyPharmacy.district,
                isOnDuty: true
            )
        } ?? []
    }
    
    private func performCityAPIRequest(city: String, district: String?) async throws -> [Pharmacy] {
        guard let apiKey = APIConfig.NosyAPI.apiKey else {
            throw PharmacyServiceError.missingAPIKey
        }
        
        var components = URLComponents(string: APIConfig.NosyAPI.baseURL + APIConfig.NosyAPI.Endpoints.cityPharmacies)!
        var queryItems = [URLQueryItem(name: "city", value: city)]
        
        if let district = district {
            queryItems.append(URLQueryItem(name: "district", value: district))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw PharmacyServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PharmacyServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw PharmacyServiceError.serverError(httpResponse.statusCode)
        }
        
        let decodedResponse = try JSONDecoder().decode(NosyAPIResponse.self, from: data)
        
        guard decodedResponse.success else {
            throw PharmacyServiceError.apiError(decodedResponse.message ?? "Unknown error")
        }
        
        return decodedResponse.data?.map { nosyPharmacy in
            Pharmacy(
                id: UUID(),
                name: nosyPharmacy.name,
                address: nosyPharmacy.address,
                phone: nosyPharmacy.phone,
                latitude: nosyPharmacy.latitude,
                longitude: nosyPharmacy.longitude,
                distance: nosyPharmacy.distance,
                city: nosyPharmacy.city,
                district: nosyPharmacy.district,
                isOnDuty: true
            )
        } ?? []
    }
}

// MARK: - Error Handling
enum PharmacyServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API anahtarı bulunamadı"
        case .invalidURL:
            return "Geçersiz URL"
        case .invalidResponse:
            return "Geçersiz yanıt"
        case .serverError(let code):
            return "Sunucu hatası: \(code)"
        case .apiError(let message):
            return "API Hatası: \(message)"
        }
    }
}

// MARK: - API Response Models
struct NosyAPIResponse: Codable {
    let success: Bool
    let message: String?
    let data: [NosyPharmacyData]?
}

struct NosyPharmacyData: Codable {
    let name: String
    let address: String
    let phone: String
    let latitude: Double
    let longitude: Double
    let distance: Double?
    let city: String
    let district: String
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case address = "address"
        case phone = "phone"
        case latitude = "lat"
        case longitude = "lng"
        case distance = "distance"
        case city = "city"
        case district = "district"
    }
}
