import SwiftUI
import CoreLocation

struct PharmaciesListView: View {
    @ObservedObject var pharmacyService: PharmacyService
    @ObservedObject var locationService: LocationService
    let searchText: String
    
    @State private var animateCards = false
    @State private var selectedDistrictFilter: String = "Tümü"
    @State private var showRefreshButton = false
    
    private var districts: [String] {
        let allDistricts = Set(pharmacyService.pharmacies.map { $0.district })
        return ["Tümü"] + Array(allDistricts).sorted()
    }
    
    private var filteredPharmacies: [Pharmacy] {
        var filtered = pharmacyService.pharmacies
        
        if selectedDistrictFilter != "Tümü" {
            filtered = filtered.filter { $0.district == selectedDistrictFilter }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with refresh info
            if !pharmacyService.pharmacies.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nöbetçi Eczaneler")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                        
                        Text("24 saat açık eczaneler")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(filteredPharmacies.count) eczane")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.roseGold)
                        
                        Button(action: refreshPharmacies) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                                
                                Text("Yenile")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.roseGold)
                        }
                        .disabled(pharmacyService.isLoading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            
            // District Filter
            if districts.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(districts, id: \.self) { district in
                            DistrictFilterChip(
                                title: district,
                                isSelected: selectedDistrictFilter == district
                            ) {
                                selectedDistrictFilter = district
                                HapticFeedback.selection()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            
            // Pharmacies List
            if pharmacyService.isLoading {
                LoadingPharmaciesView()
            } else if filteredPharmacies.isEmpty {
                EmptyPharmaciesView(searchText: searchText)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(filteredPharmacies.enumerated()), id: \.offset) { index, pharmacy in
                            PharmacyCard(
                                pharmacy: pharmacy,
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
            await refreshPharmaciesAsync()
        }
    }
    
    private func refreshPharmacies() {
        Task {
            await refreshPharmaciesAsync()
        }
    }
    
    private func refreshPharmaciesAsync() async {
        if let location = locationService.currentLocation {
            await pharmacyService.fetchNearbyPharmacies(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } else {
            // Konum yoksa İstanbul merkez için eczaneleri getir
            await pharmacyService.fetchPharmaciesByCity(city: "İstanbul", district: "Şişli")
        }
    }
}

// District Filter Chip
struct DistrictFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .roseGold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [.roseGold, .roseGold.opacity(0.8)],
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
                                .stroke(Color.roseGold.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                        )
                        .shadow(
                            color: isSelected ? Color.roseGold.opacity(0.3) : Color.clear,
                            radius: isSelected ? 4 : 0,
                            x: 0,
                            y: isSelected ? 2 : 0
                        )
                )
        }
    }
}

// Pharmacy Card
struct PharmacyCard: View {
    let pharmacy: Pharmacy
    let locationService: LocationService
    
    @State private var isPressed = false
    @State private var showingActionSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(pharmacy.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .lineLimit(2)
                    
                    Text("\(pharmacy.district) / \(pharmacy.province)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.roseGold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // On Duty Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.successGreen)
                            .frame(width: 8, height: 8)
                        
                        Text("Nöbetçi")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.successGreen)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.successGreen.opacity(0.1))
                    )
                    
                    if let distance = pharmacy.distance {
                        Text(String(format: "%.1f km", distance))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.roseGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.roseGold.opacity(0.1))
                            )
                    }
                }
            }
            
            // Address
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(pharmacy.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Duty Hours
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.successGreen)
                
                Text("24 Saat Açık")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.successGreen)
                
                Spacer()
                
                Text("Nöbetçi Eczane")
                    .font(.caption)
                    .foregroundColor(.roseGold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.roseGold.opacity(0.1))
                    )
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Call Button
                Button(action: {
                    if let url = URL(string: "tel:\(pharmacy.phone)") {
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
                            .fill(Color.roseGold)
                            .shadow(color: Color.roseGold.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                Spacer()
                
                // Phone number
                Text(pharmacy.phone)
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
                                colors: [Color.roseGold.opacity(0.3), Color.roseGold.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.roseGold.opacity(0.1),
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
                    latitude: pharmacy.location.latitude,
                    longitude: pharmacy.location.longitude,
                    name: pharmacy.name
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Google Maps") {
                if let url = locationService.createGoogleMapsURL(
                    latitude: pharmacy.location.latitude,
                    longitude: pharmacy.location.longitude,
                    name: pharmacy.name
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Yandex Maps") {
                if let url = locationService.createYandexMapsURL(
                    latitude: pharmacy.location.latitude,
                    longitude: pharmacy.location.longitude
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Yol Tarifi - Apple Maps") {
                if let url = locationService.createAppleMapsDirectionURL(
                    latitude: pharmacy.location.latitude,
                    longitude: pharmacy.location.longitude,
                    name: pharmacy.name
                ) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("İptal", role: .cancel) { }
        }
    }
}

// Loading Pharmacies View
struct LoadingPharmaciesView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.roseGold)
            
            Text("Nöbetçi eczaneler yükleniyor...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

// Empty Pharmacies View
struct EmptyPharmaciesView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cross.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(.roseGold.opacity(0.6))
            
            VStack(spacing: 12) {
                Text(searchText.isEmpty ? "Nöbetçi Eczane Bulunamadı" : "Arama Sonucu Bulunamadı")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(searchText.isEmpty ? 
                     "Bu bölgede nöbetçi eczane bulunamadı. Lütfen farklı bir konum deneyin." :
                     "'\(searchText)' için sonuç bulunamadı. Farklı arama terimi deneyin."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
            }
            
            Button("Tekrar Dene") {
                // Refresh action
            }
            .buttonStyle(PrimaryButtonStyle(
                backgroundColor: .roseGold,
                shadowColor: .roseGold
            ))
            .frame(maxWidth: 200)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PharmaciesListView(
        pharmacyService: PharmacyService(),
        locationService: LocationService(),
        searchText: ""
    )
}
