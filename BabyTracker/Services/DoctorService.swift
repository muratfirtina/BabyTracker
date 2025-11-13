import Foundation
import CoreLocation

class DoctorService: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Doktor arama servisi
    func fetchNearbyDoctors(latitude: Double, longitude: Double, radius: Double = 10.0) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simüle edilmiş ağ gecikmesi
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 saniye
        
        let userLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        // Mock data'dan mesafe hesaplayarak filtrele
        let doctorsWithDistance = Doctor.mockDoctors.compactMap { doctor in
            let distance = userLocation.distance(from: doctor.location.clLocation) / 1000.0
            
            // Belirtilen radius içindeki doktorları filtrele
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
        
        await MainActor.run {
            self.doctors = doctorsWithDistance
            self.isLoading = false
        }
    }
    
    // Uzmanlık alanına göre doktor arama
    func fetchDoctorsBySpecialization(_ specialization: String, latitude: Double? = nil, longitude: Double? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simüle edilmiş ağ gecikmesi
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye
        
        var filteredDoctors = Doctor.mockDoctors.filter { doctor in
            doctor.specialization.localizedCaseInsensitiveContains(specialization)
        }
        
        // Eğer konum verilmişse mesafe hesapla
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
        
        await MainActor.run {
            self.doctors = filteredDoctors
            self.isLoading = false
        }
    }
    
    // Hastane adına göre doktor arama
    func fetchDoctorsByHospital(_ hospital: String, latitude: Double? = nil, longitude: Double? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simüle edilmiş ağ gecikmesi
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye
        
        var filteredDoctors = Doctor.mockDoctors.filter { doctor in
            doctor.hospital.localizedCaseInsensitiveContains(hospital)
        }
        
        // Eğer konum verilmişse mesafe hesapla
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
        
        await MainActor.run {
            self.doctors = filteredDoctors
            self.isLoading = false
        }
    }
    
    // Genel arama (isim, hastane, uzmanlık)
    func searchDoctors(query: String, latitude: Double? = nil, longitude: Double? = nil) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            await loadAllDoctors(latitude: latitude, longitude: longitude)
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simüle edilmiş ağ gecikmesi
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye
        
        var filteredDoctors = Doctor.mockDoctors.filter { doctor in
            doctor.name.localizedCaseInsensitiveContains(query) ||
            doctor.hospital.localizedCaseInsensitiveContains(query) ||
            doctor.specialization.localizedCaseInsensitiveContains(query) ||
            doctor.address.localizedCaseInsensitiveContains(query)
        }
        
        // Eğer konum verilmişse mesafe hesapla
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
        
        await MainActor.run {
            self.doctors = filteredDoctors
            self.isLoading = false
        }
    }
    
    // Tüm doktorları yükle
    func loadAllDoctors(latitude: Double? = nil, longitude: Double? = nil) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simüle edilmiş ağ gecikmesi
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye
        
        var allDoctors = Doctor.mockDoctors
        
        // Eğer konum verilmişse mesafe hesapla
        if let latitude = latitude, let longitude = longitude {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            allDoctors = allDoctors.map { doctor in
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
        
        await MainActor.run {
            self.doctors = allDoctors
            self.isLoading = false
        }
    }
    
    // Mock data yükleme (test için)
    func loadMockData() {
        doctors = Doctor.mockDoctors
    }
    
    // Doktor uzmanlık alanları listesi
    var availableSpecializations: [String] {
        let specializations = Set(Doctor.mockDoctors.map { $0.specialization })
        return Array(specializations).sorted()
    }
    
    // Hastane listesi
    var availableHospitals: [String] {
        let hospitals = Set(Doctor.mockDoctors.map { $0.hospital })
        return Array(hospitals).sorted()
    }
}

// MARK: - Extensions for Future API Integration
extension DoctorService {
    
    // Gelecekte e-Nabız API entegrasyonu için
    func fetchDoctorsFromENabiz(latitude: Double, longitude: Double) async {
        // e-Nabız API entegrasyonu burada yapılacak
        // Şu anda mock data döndürüyor
        await fetchNearbyDoctors(latitude: latitude, longitude: longitude)
    }
    
    // Gelecekte MHRS API entegrasyonu için
    func fetchDoctorsFromMHRS(specialization: String) async {
        // MHRS API entegrasyonu burada yapılacak
        // Şu anda mock data döndürüyor
        await fetchDoctorsBySpecialization(specialization)
    }
    
    // Gelecekte DoktorTakvimi API entegrasyonu için
    func fetchDoctorsFromDoktorTakvimi(query: String, latitude: Double, longitude: Double) async {
        // DoktorTakvimi API entegrasyonu burada yapılacak
        // Şu anda mock data döndürüyor
        await searchDoctors(query: query, latitude: latitude, longitude: longitude)
    }
}
