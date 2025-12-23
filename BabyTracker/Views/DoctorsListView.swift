import SwiftUI
import CoreLocation

struct DoctorsListView: View {
    @ObservedObject var doctorService: DoctorService
    @ObservedObject var locationService: LocationService
    let searchText: String
    
    @State private var animateCards = false
    @State private var selectedSpecialization: String = "Tümü"
    @State private var showFilterSheet = false
    @State private var showLocationWarning = false
    
    // Uzmanlık alanları listesi - daha spesifik
    private var specializations: [String] {
        var specs = ["Tümü", "Çocuk Sağlığı ve Hastalıkları"]
        
        // Alt uzmanlık alanları
        let subSpecializations = [
            "Çocuk Kardiyolojisi",
            "Çocuk Göz",
            "Çocuk Endokrin",
            "Çocuk Nörolojisi",
            "Çocuk Gastroenterolojisi",
            "Çocuk Hematolojisi",
            "Çocuk Cerrahisi"
        ]
        
        specs.append(contentsOf: subSpecializations)
        return specs
    }
    
    private var filteredDoctors: [Doctor] {
        if selectedSpecialization == "Tümü" {
            return doctorService.doctors
        } else {
            return doctorService.doctors.filter { 
                $0.specialization.localizedCaseInsensitiveContains(selectedSpecialization) ||
                selectedSpecialization.localizedCaseInsensitiveContains($0.specialization)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Konum Uyarısı
            if !locationService.hasValidLocation && !doctorService.isLoading {
                LocationWarningBanner {
                    showLocationWarning = true
                }
            }
            
            // Filter Section
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(specializations, id: \.self) { specialization in
                        SpecializationFilterChip(
                            title: specialization,
                            isSelected: selectedSpecialization == specialization
                        ) {
                            selectedSpecialization = specialization
                            HapticFeedback.selection()
                            
                            // Uzmanlık seçildiğinde arama yap
                            if specialization != "Tümü" {
                                searchBySpecialization(specialization)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            
            // Doctors List
            if doctorService.isLoading {
                LoadingDoctorsView()
            } else if filteredDoctors.isEmpty {
                EmptyDoctorsView(searchText: searchText, hasLocation: locationService.hasValidLocation)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(filteredDoctors.enumerated()), id: \.offset) { index, doctor in
                            DoctorCard(
                                doctor: doctor,
                                locationService: locationService
                            )
                            .opacity(animateCards ? 1.0 : 0)
                            .offset(y: animateCards ? 0 : 30)
                            .animation(
                                .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                                value: animateCards
                            )
                            .onAppear {
                                // Infinite scroll trigger
                                if doctor.id == doctorService.doctors.last?.id,
                                   let location = locationService.currentLocation,
                                   doctorService.hasMoreDoctors {
                                    Task {
                                        await doctorService.loadMoreDoctors(
                                            latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Loading more indicator
                        if doctorService.isLoadingMore {
                            HStack {
                                ProgressView()
                                    .tint(.oceanBlue)
                                Text("Daha fazla doktor yükle niyor...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        
                        // End of list indicator
                        if !doctorService.hasMoreDoctors && !doctorService.doctors.isEmpty {
                            Text("✓ Tüm doktorlar yüklendi")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            animateCards = true
            // İlk açılışta otomatik yükleme yapma
            // Sadece konum geldiğinde yükle
        }
        .refreshable {
            loadDoctorsIfLocationAvailable()
        }
        .alert("Konum Gerekli", isPresented: $showLocationWarning) {
            Button("Konum İzni Ver") {
                locationService.requestLocationPermission()
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Yakındaki doktorları görebilmek için konum izni verin veya manuel olarak şehir seçin.")
        }
    }
    
    // Konum varsa doktor yükle
    private func loadDoctorsIfLocationAvailable() {
        guard locationService.hasValidLocation else {
            print("⚠️ Konum bilgisi yok, arama yapılmıyor")
            return
        }
        
        Task {
            if let location = locationService.currentLocation {
                await doctorService.fetchNearbyDoctors(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
    }
    
    // Uzmanlık alanına göre ara
    private func searchBySpecialization(_ specialization: String) {
        guard locationService.hasValidLocation else {
            showLocationWarning = true
            return
        }
        
        Task {
            var latitude: Double?
            var longitude: Double?
            
            if let location = locationService.currentLocation {
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
            }
            
            await doctorService.fetchDoctorsBySpecialization(
                specialization,
                latitude: latitude,
                longitude: longitude
            )
        }
    }
}

// Konum Uyarı Banner'ı
struct LocationWarningBanner: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "location.slash.fill")
                    .font(.title3)
                    .foregroundColor(.warningOrange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Konum Bilgisi Yok")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoal)
                    
                    Text("Yakındaki doktorları görmek için konum izni verin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.warningOrange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}

// Specialization Filter Chip
struct SpecializationFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .oceanBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [.oceanBlue, .oceanBlue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color.white, Color.white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.oceanBlue.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                        )
                        .shadow(
                            color: isSelected ? Color.oceanBlue.opacity(0.3) : Color.clear,
                            radius: isSelected ? 4 : 0,
                            x: 0,
                            y: isSelected ? 2 : 0
                        )
                )
        }
    }
}

// Doctor Card
struct DoctorCard: View {
    let doctor: Doctor
    let locationService: LocationService
    
    @State private var isPressed = false
    @State private var showingActionSheet = false
    
    // Hastane mi muayenehane mi?
    private var facilityType: String {
        let name = doctor.hospital.lowercased()
        if name.contains("hastane") || name.contains("hospital") || name.contains("tıp merkezi") || name.contains("medical center") {
            return "🏥 Hastane"
        } else if name.contains("klinik") || name.contains("clinic") || name.contains("poliklinik") {
            return "🏥 Klinik"
        } else {
            return "🏥 Muayenehane"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Title ve Name - title boşsa veya name generic ise sadece name göster
                    if doctor.title.isEmpty || doctor.name == "Çocuk Doktoru" {
                        // Generic isim veya title yok
                        if doctor.name == "Çocuk Doktoru" {
                            // Hastane/Klinik kartı - hastane adını büyük göster
                            Text(doctor.hospital)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                                .lineLimit(2)
                        } else {
                            Text(doctor.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                                .lineLimit(2)
                        }
                    } else {
                        Text("\(doctor.title) \(doctor.name)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                            .lineLimit(2)
                    }
                    
                    Text(doctor.specialization)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.oceanBlue)
                }
                
                Spacer()
                
                // Rating and distance
                VStack(alignment: .trailing, spacing: 4) {
                    if let rating = doctor.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.warningOrange)
                            
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoal)
                            
                            if let reviewCount = doctor.reviewCount {
                                Text("(\(reviewCount))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if let distance = doctor.distance {
                        Text(String(format: "%.1f km", distance))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.mintGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.mintGreen.opacity(0.1))
                            )
                    }
                }
            }
            
            // Hospital Name
            VStack(alignment: .leading, spacing: 8) {
                // Hastane adını sadece üstte gösterilmediyse göster
                if doctor.name != "Çocuk Doktoru" {
                    HStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(doctor.hospital)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.charcoal)
                            .lineLimit(2)
                    }
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(doctor.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            // Working Hours (Today's status)
            if let todayWorkingHour = getTodayWorkingHour() {
                HStack(spacing: 8) {
                    Image(systemName: todayWorkingHour.isAvailable ? "clock.fill" : "clock.badge.xmark.fill")
                        .font(.caption)
                        .foregroundColor(todayWorkingHour.isAvailable ? .successGreen : .errorRed)
                    
                    if todayWorkingHour.isAvailable {
                        Text("Bugün: \(todayWorkingHour.startTime) - \(todayWorkingHour.endTime)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.successGreen)
                    } else {
                        Text("Bugün kapalı")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.errorRed)
                    }
                    
                    Spacer()
                    
                    if doctor.acceptsAppointments {
                        Text("Randevu alınabilir")
                            .font(.caption2)
                            .foregroundColor(.infoBlue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.infoBlue.opacity(0.1))
                            )
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Call Button
                Button(action: {
                    if let url = URL(string: "tel:\(doctor.phone)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.caption)
                        
                        Text("Ara")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.successGreen)
                            .shadow(color: Color.successGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                // Maps Button
                Button(action: {
                    showingActionSheet = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.caption)
                        
                        Text("Harita")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.oceanBlue)
                            .shadow(color: Color.oceanBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                Spacer()
                
                // Phone number
                Text(doctor.phone)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.oceanBlue.opacity(0.3), Color.oceanBlue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.oceanBlue.opacity(0.1),
                    radius: isPressed ? 8 : 12,
                    x: 0,
                    y: isPressed ? 4 : 6
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
        .confirmationDialog("Harita Seçin", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Apple Maps") {
                if let url = locationService.createAppleMapsURL(
                    latitude: doctor.location.latitude,
                    longitude: doctor.location.longitude,
                    name: doctor.hospital
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Google Maps") {
                if let url = locationService.createGoogleMapsURL(
                    latitude: doctor.location.latitude,
                    longitude: doctor.location.longitude,
                    name: doctor.hospital
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Yandex Maps") {
                if let url = locationService.createYandexMapsURL(
                    latitude: doctor.location.latitude,
                    longitude: doctor.location.longitude
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Yol Tarifi - Apple Maps") {
                if let url = locationService.createAppleMapsDirectionURL(
                    latitude: doctor.location.latitude,
                    longitude: doctor.location.longitude,
                    name: doctor.hospital
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("İptal", role: .cancel) { }
        }
    }
    
    private func getTodayWorkingHour() -> Doctor.WorkingHour? {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayNames = ["", "Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
        
        if today >= 1 && today < dayNames.count {
            let todayName = dayNames[today]
            return doctor.workingHours.first { $0.day == todayName }
        }
        
        return nil
    }
}

// Loading Doctors View
struct LoadingDoctorsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.oceanBlue)
            
            Text("Doktorlar yükleniyor...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

// Empty Doctors View
struct EmptyDoctorsView: View {
    let searchText: String
    let hasLocation: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: hasLocation ? "stethoscope" : "location.slash")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(.oceanBlue.opacity(0.6))
            
            VStack(spacing: 12) {
                Text(hasLocation ? "Doktor Bulunamadı" : "Konum Bilgisi Gerekli")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(hasLocation ?
                     (searchText.isEmpty ? 
                      "Bu bölgede doktor bulunamadı. Lütfen farklı bir konum deneyin." :
                      "'\(searchText)' için sonuç bulunamadı. Farklı arama terimi deneyin.") :
                     "Yakındaki doktorları görebilmek için konum izni verin veya manuel olarak şehir seçin."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DoctorsListView(
        doctorService: DoctorService(),
        locationService: LocationService(),
        searchText: ""
    )
}
