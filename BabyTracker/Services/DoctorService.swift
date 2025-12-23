import Foundation
import CoreLocation

class DoctorService: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var hospitals: [Doctor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Pagination states
    @Published var isLoadingMore = false
    @Published var hasMoreDoctors = true
    @Published var hasMoreHospitals = true
    private var doctorsNextPageToken: String?
    private var hospitalsNextPageToken: String?
    
    // Yeni API servisini kullan
    private let googlePlacesService = GooglePlacesNewService()
    private let useRealAPI = APIConfig.FeatureFlags.enableRealDoctorAPI
    
    // Task cancellation için
    private var currentSearchTask: Task<Void, Never>?
    
    // MARK: - Public Methods
    
    /// Yakındaki doktorları getir (konum bazlı - ilk sayfa)
    func fetchNearbyDoctors(latitude: Double, longitude: Double, radius: Double = 3.0) async {
        // Önceki task'ı iptal et
        currentSearchTask?.cancel()
        
        // Pagination state'i sıfırla
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            doctors = []
            doctorsNextPageToken = nil
            hasMoreDoctors = true
        }
        
        do {
            if useRealAPI {
                print("🔍 Yeni Google Places API kullanılıyor...")
                let result = try await googlePlacesService.searchNearbyPediatricDoctors(
                    latitude: latitude,
                    longitude: longitude,
                    radius: radius * 1000 // km'yi metreye çevir
                )
                print("✅ \(result.doctors.count) doktor bulundu, nextPageToken: \(result.nextPageToken != nil ? "Var" : "Yok")")
                
                await MainActor.run {
                    self.doctors = result.doctors
                    self.doctorsNextPageToken = result.nextPageToken
                    self.hasMoreDoctors = result.nextPageToken != nil
                    self.isLoading = false
                }
            } else {
                print("🔍 Mock data kullanılıyor...")
                let fetchedDoctors = await fetchMockDoctors(latitude: latitude, longitude: longitude, radius: radius)
                
                await MainActor.run {
                    self.doctors = fetchedDoctors
                    self.hasMoreDoctors = false
                    self.isLoading = false
                }
            }
        } catch is CancellationError {
            print("ℹ️ Arama iptal edildi")
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = googlePlacesService.getUserFriendlyError(error)
                self.isLoading = false
                print("⚠️ API Hatası: \(error.localizedDescription)")
            }
        }
    }
    
    /// Daha fazla doktor yükle (pagination)
    func loadMoreDoctors(latitude: Double, longitude: Double, radius: Double = 3.0) async {
        guard !isLoadingMore, hasMoreDoctors, let pageToken = doctorsNextPageToken else {
            return
        }
        
        await MainActor.run {
            isLoadingMore = true
        }
        
        do {
            let result = try await googlePlacesService.searchNearbyPediatricDoctors(
                latitude: latitude,
                longitude: longitude,
                radius: radius * 1000,
                pageToken: pageToken
            )
            
            await MainActor.run {
                self.doctors.append(contentsOf: result.doctors)
                self.doctorsNextPageToken = result.nextPageToken
                self.hasMoreDoctors = result.nextPageToken != nil
                self.isLoadingMore = false
                print("📄 \(result.doctors.count) doktor daha yüklendi (Toplam: \(self.doctors.count)), hasMore: \(self.hasMoreDoctors)")
            }
        } catch {
            await MainActor.run {
                self.isLoadingMore = false
                print("⚠️ Daha fazla doktor yüklenemedi: \(error.localizedDescription)")
            }
        }
    }
    
    /// Uzmanlık alanına göre doktor arama
    func fetchDoctorsBySpecialization(_ specialization: String, latitude: Double? = nil, longitude: Double? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result: (doctors: [Doctor], nextPageToken: String?)
            
            if useRealAPI {
                // Google Places API ile arama yap
                let query = "\(specialization) doktor"
                result = try await googlePlacesService.searchDoctorsByText(
                    query: query,
                    latitude: latitude,
                    longitude: longitude
                )
            } else {
                // Mock data'dan filtrele
                let mockDoctors = await fetchMockDoctorsBySpecialization(
                    specialization: specialization,
                    latitude: latitude,
                    longitude: longitude
                )
                result = (doctors: mockDoctors, nextPageToken: nil)
            }
            
            await MainActor.run {
                self.doctors = result.doctors
                self.isLoading = false
            }
        } catch is CancellationError {
            // Task iptal edildi - sessizce devam et
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = googlePlacesService.getUserFriendlyError(error)
                self.isLoading = false
            }
        }
    }
    
    /// Hastane adına göre doktor arama
    func fetchDoctorsByHospital(_ hospital: String, latitude: Double? = nil, longitude: Double? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result: (doctors: [Doctor], nextPageToken: String?)
            
            if useRealAPI {
                // Google Places API ile arama yap
                let query = "\(hospital) çocuk doktoru"
                result = try await googlePlacesService.searchDoctorsByText(
                    query: query,
                    latitude: latitude,
                    longitude: longitude
                )
            } else {
                // Mock data'dan filtrele
                let mockDoctors = await fetchMockDoctorsByHospital(
                    hospital: hospital,
                    latitude: latitude,
                    longitude: longitude
                )
                result = (doctors: mockDoctors, nextPageToken: nil)
            }
            
            await MainActor.run {
                self.doctors = result.doctors
                self.isLoading = false
            }
        } catch is CancellationError {
            // Task iptal edildi - sessizce devam et
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = googlePlacesService.getUserFriendlyError(error)
                self.isLoading = false
            }
        }
    }
    
    /// Genel arama (isim, hastane, uzmanlık)
    func searchDoctors(query: String, latitude: Double? = nil, longitude: Double? = nil) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            await loadAllDoctors(latitude: latitude, longitude: longitude)
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result: (doctors: [Doctor], nextPageToken: String?)
            
            if useRealAPI {
                // Google Places API ile arama yap
                // Kullanıcı zaten "çocuk" veya "pediatri" yazmamışsa ekle
                let lowercasedQuery = query.lowercased()
                let searchQuery: String
                if lowercasedQuery.contains("çocuk") || lowercasedQuery.contains("pediatr") ||
                   lowercasedQuery.contains("bebek") {
                    searchQuery = query
                } else {
                    searchQuery = "çocuk doktoru \(query)"
                }
                
                result = try await googlePlacesService.searchDoctorsByText(
                    query: searchQuery,
                    latitude: latitude,
                    longitude: longitude
                )
            } else {
                // Mock data'da ara
                let mockDoctors = await searchMockDoctors(
                    query: query,
                    latitude: latitude,
                    longitude: longitude
                )
                result = (doctors: mockDoctors, nextPageToken: nil)
            }
            
            await MainActor.run {
                self.doctors = result.doctors
                self.isLoading = false
            }
        } catch is CancellationError {
            // Task iptal edildi - sessizce devam et
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = googlePlacesService.getUserFriendlyError(error)
                self.isLoading = false
            }
        }
    }
    
    /// Tüm doktorları yükle
    func loadAllDoctors(latitude: Double? = nil, longitude: Double? = nil) async {
        if let latitude = latitude, let longitude = longitude {
            await fetchNearbyDoctors(latitude: latitude, longitude: longitude, radius: 5.0) // 5km
        } else {
            await MainActor.run {
                self.doctors = Doctor.mockDoctors
                self.isLoading = false
            }
        }
    }
    
    /// Mock data yükleme (test için)
    func loadMockData() {
        doctors = Doctor.mockDoctors
    }
    
    // MARK: - Mock Data Methods (Real API çalışmazsa fallback)
    
    private func fetchMockDoctors(latitude: Double, longitude: Double, radius: Double) async -> [Doctor] {
        // Simüle edilmiş ağ gecikmesi
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Mock data'dan mesafe hesaplayarak filtrele
        let doctorsWithDistance = Doctor.mockDoctors.compactMap { doctor in
            let distance = userLocation.distance(from: doctor.location.clLocation) / 1000.0
            
            if distance <= radius {
                return Doctor(
                    name: doctor.name,
                    title: doctor.title,
                    specialization: doctor.specialization,
                    hospital: doctor.hospital,
                    address: doctor.address,
                    phone: doctor.phone,
                    location: doctor.location,
                    rating: doctor.rating,
                    reviewCount: doctor.reviewCount,
                    workingHours: doctor.workingHours,
                    acceptsAppointments: doctor.acceptsAppointments,
                    distance: distance
                )
            }
            return nil
        }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        
        return doctorsWithDistance
    }
    
    private func fetchMockDoctorsBySpecialization(specialization: String, latitude: Double?, longitude: Double?) async -> [Doctor] {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye
        
        var filteredDoctors = Doctor.mockDoctors.filter { doctor in
            doctor.specialization.localizedCaseInsensitiveContains(specialization)
        }
        
        if let latitude = latitude, let longitude = longitude {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            filteredDoctors = filteredDoctors.map { doctor in
                let distance = userLocation.distance(from: doctor.location.clLocation) / 1000.0
                return Doctor(
                    name: doctor.name,
                    title: doctor.title,
                    specialization: doctor.specialization,
                    hospital: doctor.hospital,
                    address: doctor.address,
                    phone: doctor.phone,
                    location: doctor.location,
                    rating: doctor.rating,
                    reviewCount: doctor.reviewCount,
                    workingHours: doctor.workingHours,
                    acceptsAppointments: doctor.acceptsAppointments,
                    distance: distance
                )
            }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        }
        
        return filteredDoctors
    }
    
    private func fetchMockDoctorsByHospital(hospital: String, latitude: Double?, longitude: Double?) async -> [Doctor] {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye
        
        var filteredDoctors = Doctor.mockDoctors.filter { doctor in
            doctor.hospital.localizedCaseInsensitiveContains(hospital)
        }
        
        if let latitude = latitude, let longitude = longitude {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            filteredDoctors = filteredDoctors.map { doctor in
                let distance = userLocation.distance(from: doctor.location.clLocation) / 1000.0
                return Doctor(
                    name: doctor.name,
                    title: doctor.title,
                    specialization: doctor.specialization,
                    hospital: doctor.hospital,
                    address: doctor.address,
                    phone: doctor.phone,
                    location: doctor.location,
                    rating: doctor.rating,
                    reviewCount: doctor.reviewCount,
                    workingHours: doctor.workingHours,
                    acceptsAppointments: doctor.acceptsAppointments,
                    distance: distance
                )
            }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        }
        
        return filteredDoctors
    }
    
    private func searchMockDoctors(query: String, latitude: Double?, longitude: Double?) async -> [Doctor] {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye
        
        var filteredDoctors = Doctor.mockDoctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(query) ||
            doctor.hospital.localizedCaseInsensitiveContains(query) ||
            doctor.specialization.localizedCaseInsensitiveContains(query) ||
            doctor.address.localizedCaseInsensitiveContains(query)
        }
        
        if let latitude = latitude, let longitude = longitude {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            filteredDoctors = filteredDoctors.map { doctor in
                let distance = userLocation.distance(from: doctor.location.clLocation) / 1000.0
                return Doctor(
                    name: doctor.name,
                    title: doctor.title,
                    specialization: doctor.specialization,
                    hospital: doctor.hospital,
                    address: doctor.address,
                    phone: doctor.phone,
                    location: doctor.location,
                    rating: doctor.rating,
                    reviewCount: doctor.reviewCount,
                    workingHours: doctor.workingHours,
                    acceptsAppointments: doctor.acceptsAppointments,
                    distance: distance
                )
            }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        }
        
        return filteredDoctors
    }
    
    // MARK: - Utility Properties
    
    /// Doktor uzmanlık alanları listesi
    var availableSpecializations: [String] {
        let specializations = Set(Doctor.mockDoctors.map { $0.specialization })
        return Array(specializations).sorted()
    }
    
    /// Hastane listesi
    var availableHospitals: [String] {
        let hospitals = Set(Doctor.mockDoctors.map { $0.hospital })
        return Array(hospitals).sorted()
    }
    
    /// API durumu
    var isUsingRealAPI: Bool {
        return useRealAPI && googlePlacesService.hasValidAPIKey
    }
}

// MARK: - Extensions for Future API Integration
extension DoctorService {
    
    /// Gelecekte e-Nabız API entegrasyonu için
    func fetchDoctorsFromENabiz(latitude: Double, longitude: Double) async {
        // e-Nabız API entegrasyonu burada yapılacak
        // Şu anda mevcut fonksiyonu kullanıyor
        await fetchNearbyDoctors(latitude: latitude, longitude: longitude)
    }
    
    /// Gelecekte MHRS API entegrasyonu için
    func fetchDoctorsFromMHRS(specialization: String) async {
        // MHRS API entegrasyonu burada yapılacak
        // Şu anda mevcut fonksiyonu kullanıyor
        await fetchDoctorsBySpecialization(specialization)
    }
}

// MARK: - Hospital Methods
extension DoctorService {
    
    /// Yakındaki hastaneleri getir (konum bazlı - ilk sayfa)
    func fetchNearbyHospitals(latitude: Double, longitude: Double, radius: Double = 6.0) async {
        // Pagination state'i sıfırla
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            hospitals = []
            hospitalsNextPageToken = nil
            hasMoreHospitals = true
        }
        
        do {
            if useRealAPI {
                print("🏥 Hastaneler için Yeni Google Places API kullanılıyor...")
                let result = try await googlePlacesService.searchNearbyHospitals(
                    latitude: latitude,
                    longitude: longitude,
                    radius: radius * 1000 // km'yi metreye çevir
                )
                print("✅ \(result.doctors.count) hastane bulundu, nextPageToken: \(result.nextPageToken != nil ? "Var" : "Yok")")
                
                await MainActor.run {
                    self.hospitals = result.doctors
                    self.hospitalsNextPageToken = result.nextPageToken
                    self.hasMoreHospitals = result.nextPageToken != nil
                    self.isLoading = false
                }
            } else {
                print("🏥 Hastaneler için Mock data kullanılıyor...")
                let fetchedHospitals = await fetchMockHospitals(latitude: latitude, longitude: longitude, radius: radius)
                
                await MainActor.run {
                    self.hospitals = fetchedHospitals
                    self.hasMoreHospitals = false
                    self.isLoading = false
                }
            }
        } catch is CancellationError {
            print("ℹ️ Hastane araması iptal edildi")
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = googlePlacesService.getUserFriendlyError(error)
                self.isLoading = false
                print("⚠️ Hastane API Hatası: \(error.localizedDescription)")
            }
        }
    }
    
    /// Daha fazla hastane yükle (pagination)
    func loadMoreHospitals(latitude: Double, longitude: Double, radius: Double = 6.0) async {
        guard !isLoadingMore, hasMoreHospitals, let pageToken = hospitalsNextPageToken else {
            return
        }
        
        await MainActor.run {
            isLoadingMore = true
        }
        
        do {
            let result = try await googlePlacesService.searchNearbyHospitals(
                latitude: latitude,
                longitude: longitude,
                radius: radius * 1000,
                pageToken: pageToken
            )
            
            await MainActor.run {
                self.hospitals.append(contentsOf: result.doctors)
                self.hospitalsNextPageToken = result.nextPageToken
                self.hasMoreHospitals = result.nextPageToken != nil
                self.isLoadingMore = false
                print("🏥 \(result.doctors.count) hastane daha yüklendi (Toplam: \(self.hospitals.count)), hasMore: \(self.hasMoreHospitals)")
            }
        } catch {
            await MainActor.run {
                self.isLoadingMore = false
                print("⚠️ Daha fazla hastane yüklenemedi: \(error.localizedDescription)")
            }
        }
    }
    
    /// Hastane arama (query bazlı)
    func searchHospitals(query: String, latitude: Double? = nil, longitude: Double? = nil) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            if let latitude = latitude, let longitude = longitude {
                await fetchNearbyHospitals(latitude: latitude, longitude: longitude)
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            hospitals = []
        }
        
        do {
            if useRealAPI {
                let searchQuery = query.contains("hastane") || query.contains("hospital") ? query : "\(query) hastanesi"
                let result = try await googlePlacesService.searchHospitalsByText(
                    query: searchQuery,
                    latitude: latitude,
                    longitude: longitude
                )
                
                await MainActor.run {
                    self.hospitals = result.doctors
                    self.isLoading = false
                }
            } else {
                let fetchedHospitals = await searchMockHospitals(
                    query: query,
                    latitude: latitude,
                    longitude: longitude
                )
                
                await MainActor.run {
                    self.hospitals = fetchedHospitals
                    self.isLoading = false
                }
            }
        } catch is CancellationError {
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = googlePlacesService.getUserFriendlyError(error)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Hospital Mock Data Methods
    
    private func fetchMockHospitals(latitude: Double, longitude: Double, radius: Double) async -> [Doctor] {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Mock hastane datası
        let mockHospitals = Doctor.mockHospitals.compactMap { hospital in
            let distance = userLocation.distance(from: hospital.location.clLocation) / 1000.0
            
            if distance <= radius {
                return Doctor(
                    name: hospital.name,
                    title: hospital.title,
                    specialization: hospital.specialization,
                    hospital: hospital.hospital,
                    address: hospital.address,
                    phone: hospital.phone,
                    location: hospital.location,
                    rating: hospital.rating,
                    reviewCount: hospital.reviewCount,
                    workingHours: hospital.workingHours,
                    acceptsAppointments: hospital.acceptsAppointments,
                    distance: distance
                )
            }
            return nil
        }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        
        return mockHospitals
    }
    
    private func searchMockHospitals(query: String, latitude: Double?, longitude: Double?) async -> [Doctor] {
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye
        
        var filteredHospitals = Doctor.mockHospitals.filter { hospital in
            hospital.name.localizedCaseInsensitiveContains(query) ||
            hospital.address.localizedCaseInsensitiveContains(query)
        }
        
        if let latitude = latitude, let longitude = longitude {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            filteredHospitals = filteredHospitals.map { hospital in
                let distance = userLocation.distance(from: hospital.location.clLocation) / 1000.0
                return Doctor(
                    name: hospital.name,
                    title: hospital.title,
                    specialization: hospital.specialization,
                    hospital: hospital.hospital,
                    address: hospital.address,
                    phone: hospital.phone,
                    location: hospital.location,
                    rating: hospital.rating,
                    reviewCount: hospital.reviewCount,
                    workingHours: hospital.workingHours,
                    acceptsAppointments: hospital.acceptsAppointments,
                    distance: distance
                )
            }.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
        }
        
        return filteredHospitals
    }
}
