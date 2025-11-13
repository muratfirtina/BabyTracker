import SwiftUI
import CoreLocation

struct DoctorsListView: View {
    @ObservedObject var doctorService: DoctorService
    @ObservedObject var locationService: LocationService
    let searchText: String
    
    @State private var animateCards = false
    @State private var selectedSpecialization: String = "Tümü"
    @State private var showFilterSheet = false
    
    private var specializations: [String] {
        ["Tümü"] + doctorService.availableSpecializations
    }
    
    private var filteredDoctors: [Doctor] {
        if selectedSpecialization == "Tümü" {
            return doctorService.doctors
        } else {
            return doctorService.doctors.filter { $0.specialization == selectedSpecialization }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                EmptyDoctorsView(searchText: searchText)
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
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            animateCards = true
        }
        .refreshable {
            if let location = locationService.location {
                await doctorService.fetchNearbyDoctors(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            } else {
                await doctorService.loadAllDoctors()
            }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(doctor.title) \(doctor.name)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .lineLimit(2)
                    
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
            
            // Hospital and Address
            VStack(alignment: .leading, spacing: 8) {
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
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "stethoscope")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(.oceanBlue.opacity(0.6))
            
            VStack(spacing: 12) {
                Text(searchText.isEmpty ? "Doktor Bulunamadı" : "Arama Sonucu Bulunamadı")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(searchText.isEmpty ? 
                     "Bu bölgede doktor bulunamadı. Lütfen farklı bir konum deneyin." :
                     "'\(searchText)' için sonuç bulunamadı. Farklı arama terimi deneyin."
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
