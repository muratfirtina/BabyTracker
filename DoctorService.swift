import Foundation
import CoreLocation

class DoctorService: ObservableObject {
    @Published var nearbyDoctors: [Doctor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let session = URLSession.shared
    
    func fetchNearbyDoctors(latitude: Double, longitude: Double, specialty: DoctorSpecialty = .pediatrics) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let doctors = try await performAPIRequest(latitude: latitude, longitude: longitude, specialty: specialty)
            await MainActor.run {
                self.nearbyDoctors = doctors
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func fetchDoctorsByCity(city: String, district: String? = nil, specialty: DoctorSpecialty = .pediatrics) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let doctors = try await performCityAPIRequest(city: city, district: district, specialty: specialty)
            await MainActor.run {
                self.nearbyDoctors = doctors
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func performAPIRequest(latitude: Double, longitude: Double, specialty: DoctorSpecialty) async throws -> [Doctor] {
        // Note: Bu örnek implementation'da mock data kullanıyoruz
        // Gerçek uygulamada e-Nabız API veya DoktorTakvimi API kullanılacak
        
        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        return generateMockDoctors(latitude: latitude, longitude: longitude, specialty: specialty)
    }
    
    private func performCityAPIRequest(city: String, district: String?, specialty: DoctorSpecialty) async throws -> [Doctor] {
        // Note: Bu örnek implementation'da mock data kullanıyoruz
        // Gerçek uygulamada e-Nabız API veya DoktorTakvimi API kullanılacak
        
        // Simulate API delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        return generateMockDoctorsForCity(city: city, district: district, specialty: specialty)
    }
    
    // MARK: - Mock Data Generation (Gerçek API entegrasyonu için kaldırılacak)
    private func generateMockDoctors(latitude: Double, longitude: Double, specialty: DoctorSpecialty) -> [Doctor] {
        let mockDoctors = [
            Doctor(
                id: UUID(),
                name: "Dr. Ayşe Kırmızı",
                specialty: .pediatrics,
                hospital: "Acıbadem Kozyatağı Hastanesi",
                address: "Kozyatağı Mahallesi, İnönü Caddesi No:4, 34742 Kadıköy/İstanbul",
                phone: "+90 216 571 29 00",
                latitude: latitude + Double.random(in: -0.01...0.01),
                longitude: longitude + Double.random(in: -0.01...0.01),
                distance: Double.random(in: 0.5...5.0),
                rating: 4.8,
                reviewCount: 127,
                isAvailable: true,
                workingHours: "08:00 - 18:00"
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Mehmet Yılmaz",
                specialty: .pediatrics,
                hospital: "Memorial Şişli Hastanesi",
                address: "Piyalepaşa Bulvarı, Okmeydanı No:4, 34384 Şişli/İstanbul",
                phone: "+90 212 314 66 66",
                latitude: latitude + Double.random(in: -0.01...0.01),
                longitude: longitude + Double.random(in: -0.01...0.01),
                distance: Double.random(in: 0.5...5.0),
                rating: 4.6,
                reviewCount: 89,
                isAvailable: true,
                workingHours: "09:00 - 17:00"
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Fatma Demir",
                specialty: .pediatrics,
                hospital: "Koç Üniversitesi Hastanesi",
                address: "Davutpaşa Caddesi No:4, 34010 Topkapı/İstanbul",
                phone: "+90 212 338 10 00",
                latitude: latitude + Double.random(in: -0.01...0.01),
                longitude: longitude + Double.random(in: -0.01...0.01),
                distance: Double.random(in: 0.5...5.0),
                rating: 4.9,
                reviewCount: 203,
                isAvailable: false,
                workingHours: "08:30 - 16:30"
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Can Özkan",
                specialty: .pediatrics,
                hospital: "Medipol Mega Hastanesi",
                address: "TEM Avrupa Otoyolu Göztepe Çıkışı No:1, 34214 Bağcılar/İstanbul",
                phone: "+90 212 468 40 00",
                latitude: latitude + Double.random(in: -0.01...0.01),
                longitude: longitude + Double.random(in: -0.01...0.01),
                distance: Double.random(in: 0.5...5.0),
                rating: 4.7,
                reviewCount: 156,
                isAvailable: true,
                workingHours: "07:30 - 19:00"
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Zeynep Aktaş",
                specialty: .pediatrics,
                hospital: "Anadolu Sağlık Merkezi",
                address: "Anadolu Caddesi No:1, 34662 Kocaeli/Gebze",
                phone: "+90 262 678 50 00",
                latitude: latitude + Double.random(in: -0.01...0.01),
                longitude: longitude + Double.random(in: -0.01...0.01),
                distance: Double.random(in: 0.5...5.0),
                rating: 4.5,
                reviewCount: 74,
                isAvailable: true,
                workingHours: "08:00 - 17:30"
            )
        ]
        
        return Array(mockDoctors.shuffled().prefix(Int.random(in: 3...5)))
    }
    
    private func generateMockDoctorsForCity(city: String, district: String?, specialty: DoctorSpecialty) -> [Doctor] {
        let mockDoctors = [
            Doctor(
                id: UUID(),
                name: "Dr. Ahmet Çelik",
                specialty: .pediatrics,
                hospital: "\(city) Devlet Hastanesi",
                address: "\(district ?? "Merkez"), \(city)",
                phone: "+90 212 555 00 00",
                latitude: 41.0082 + Double.random(in: -0.05...0.05),
                longitude: 28.9784 + Double.random(in: -0.05...0.05),
                distance: Double.random(in: 1.0...10.0),
                rating: 4.4,
                reviewCount: 67,
                isAvailable: true,
                workingHours: "08:00 - 17:00"
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Selin Yıldırım",
                specialty: .pediatrics,
                hospital: "\(city) Üniversitesi Hastanesi",
                address: "\(district ?? "Merkez"), \(city)",
                phone: "+90 212 555 11 11",
                latitude: 41.0082 + Double.random(in: -0.05...0.05),
                longitude: 28.9784 + Double.random(in: -0.05...0.05),
                distance: Double.random(in: 1.0...10.0),
                rating: 4.8,
                reviewCount: 142,
                isAvailable: false,
                workingHours: "09:00 - 16:00"
            ),
            Doctor(
                id: UUID(),
                name: "Dr. Emre Bozkurt",
                specialty: .pediatrics,
                hospital: "\(city) Özel Hastanesi",
                address: "\(district ?? "Merkez"), \(city)",
                phone: "+90 212 555 22 22",
                latitude: 41.0082 + Double.random(in: -0.05...0.05),
                longitude: 28.9784 + Double.random(in: -0.05...0.05),
                distance: Double.random(in: 1.0...10.0),
                rating: 4.6,
                reviewCount: 98,
                isAvailable: true,
                workingHours: "08:30 - 18:30"
            )
        ]
        
        return Array(mockDoctors.shuffled().prefix(Int.random(in: 2...3)))
    }
}

// MARK: - Error Handling
enum DoctorServiceError: LocalizedError {
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
