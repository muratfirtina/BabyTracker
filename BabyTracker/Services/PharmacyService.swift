import Foundation
import CoreLocation

class PharmacyService: ObservableObject {
    @Published var pharmacies: [Pharmacy] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = APIConfig.NosyAPI.baseURL
    private let apiKey = APIConfig.getSecureAPIKey(for: "nosy") ?? "DEMO_KEY"
    
    private var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }
    
    // GPS bazlı nöbetçi eczane arama (1 kredi)
    func fetchNearbyPharmacies(latitude: Double, longitude: Double) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            guard let url = URL(string: "\(baseURL)/pharmacies-on-duty/locations?lat=\(latitude)&lng=\(longitude)") else {
                throw PharmacyServiceError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PharmacyServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw PharmacyServiceError.serverError(httpResponse.statusCode)
            }
            
            let nosyResponse = try JSONDecoder().decode(NosyAPIResponse.self, from: data)
            
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            let pharmaciesWithDistance = nosyResponse.data.map { pharmacyData in
                let pharmacy = pharmacyData.toPharmacy()
                let distance = userLocation.distance(from: pharmacy.location.clLocation) / 1000.0
                return Pharmacy(
                    name: pharmacy.name,
                    address: pharmacy.address,
                    phone: pharmacy.phone,
                    location: pharmacy.location,
                    isOnDuty: pharmacy.isOnDuty,
                    dutyStartTime: pharmacy.dutyStartTime,
                    dutyEndTime: pharmacy.dutyEndTime,
                    district: pharmacy.district,
                    province: pharmacy.province,
                    distance: distance
                )
            }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
            
            await MainActor.run {
                self.pharmacies = pharmaciesWithDistance
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                if error is PharmacyServiceError {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = "Nöbetçi eczaneler yüklenemedi: \(error.localizedDescription)"
                }
                // Mock data'yı yedek olarak göster
                self.loadMockPharmacies(userLatitude: latitude, userLongitude: longitude)
            }
        }
    }
    
    // İl/İlçe bazlı arama (1 kredi)
    func fetchPharmaciesByCity(city: String, district: String? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            var urlString = "\(baseURL)/pharmacies-on-duty?city=\(city)"
            if let district = district {
                urlString += "&district=\(district)"
            }
            
            guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
                throw PharmacyServiceError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PharmacyServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw PharmacyServiceError.serverError(httpResponse.statusCode)
            }
            
            let nosyResponse = try JSONDecoder().decode(NosyAPIResponse.self, from: data)
            
            let pharmacies = nosyResponse.data.map { $0.toPharmacy() }
            
            await MainActor.run {
                self.pharmacies = pharmacies
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.isLoading = false
                if error is PharmacyServiceError {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.errorMessage = "Nöbetçi eczaneler yüklenemedi: \(error.localizedDescription)"
                }
                // Mock data'yı yedek olarak göster
                self.pharmacies = Pharmacy.mockPharmacies
            }
        }
    }
    
    // Mock data yükleme (API hatası durumunda)
    private func loadMockPharmacies(userLatitude: Double, userLongitude: Double) {
        let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        let pharmaciesWithDistance = Pharmacy.mockPharmacies.map { pharmacy in
            let distance = userLocation.distance(from: pharmacy.location.clLocation) / 1000.0
            return Pharmacy(
                name: pharmacy.name,
                address: pharmacy.address,
                phone: pharmacy.phone,
                location: pharmacy.location,
                isOnDuty: pharmacy.isOnDuty,
                dutyStartTime: pharmacy.dutyStartTime,
                dutyEndTime: pharmacy.dutyEndTime,
                district: pharmacy.district,
                province: pharmacy.province,
                distance: distance
            )
        }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        
        self.pharmacies = pharmaciesWithDistance
    }
    
    // Test için mock data yükleme
    func loadMockData() {
        pharmacies = Pharmacy.mockPharmacies
    }
    
    // Eczane arama
    func searchPharmacies(query: String) {
        if query.isEmpty {
            return
        }
        
        let filtered = pharmacies.filter { pharmacy in
            pharmacy.name.localizedCaseInsensitiveContains(query) ||
            pharmacy.address.localizedCaseInsensitiveContains(query) ||
            pharmacy.district.localizedCaseInsensitiveContains(query)
        }
        
        pharmacies = filtered
    }
    
    // Filtreleri temizle
    func clearFilters() {
        // Bu method'u search yapıldıktan sonra orijinal listeye dönmek için kullanabilirsiniz
    }
}

// MARK: - Errors
enum PharmacyServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case noData
    case decodingError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL."
        case .invalidResponse:
            return "Geçersiz yanıt."
        case .serverError(let code):
            return "Sunucu hatası: \(code)"
        case .noData:
            return "Veri bulunamadı."
        case .decodingError:
            return "Veri işleme hatası."
        case .networkError:
            return "Ağ bağlantı hatası."
        }
    }
}
