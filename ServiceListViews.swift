import SwiftUI
import CoreLocation

// MARK: - Doctors List View
struct DoctorsListView: View {
    @ObservedObject var doctorService: DoctorService
    @ObservedObject var locationService: LocationService
    let searchText: String
    
    @State private var animateCards = false
    @State private var hasSearched = false
    
    private var filteredDoctors: [Doctor] {
        if searchText.isEmpty {
            return doctorService.nearbyDoctors
        } else {
            return doctorService.nearbyDoctors.filter { doctor in
                doctor.name.localizedCaseInsensitiveContains(searchText) ||
                doctor.hospital.localizedCaseInsensitiveContains(searchText) ||
                doctor.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if doctorService.isLoading {
                    LocationServiceLoadingView(message: "Çocuk doktorları aranıyor...")
                        .frame(height: 200)
                } else if let error = doctorService.errorMessage {
                    LocationErrorView(
                        error: error,
                        onRetry: {
                            searchDoctors()
                        },
                        onManualLocation: {
                            // Handle manual location selection
                        }
                    )
                    .padding()
                } else if filteredDoctors.isEmpty && hasSearched {
                    DoctorEmptyState {
                        searchDoctors()
                    }
                    .padding()
                } else if !filteredDoctors.isEmpty {
                    ServiceSectionHeader(
                        title: "Çocuk Doktorları",
                        icon: "stethoscope",
                        color: .babyPrimary,
                        count: filteredDoctors.count
                    )
                    
                    ForEach(Array(filteredDoctors.enumerated()), id: \.offset) { index, doctor in
                        DoctorCard(
                            doctor: doctor,
                            userLocation: locationService.currentLocation
                        )
                        .opacity(animateCards ? 1.0 : 0)
                        .offset(y: animateCards ? 0 : 30)
                        .animation(
                            .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                            value: animateCards
                        )
                    }
                } else {
                    // Initial state - show instruction
                    InitialSearchStateView(
                        icon: "stethoscope",
                        title: "Çocuk Doktorları",
                        description: "Konumunuza göre yakınınızdaki çocuk doktorlarını bulun",
                        color: .babyPrimary
                    ) {
                        searchDoctors()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .refreshable {
            await refreshDoctors()
        }
        .onAppear {
            if !hasSearched && locationService.hasLocationPermission {
                searchDoctors()
            }
        }
        .onChange(of: locationService.currentLocation) { _ in
            if locationService.hasLocationPermission && !hasSearched {
                searchDoctors()
            }
        }
        .onAppear {
            animateCards = true
        }
    }
    
    private func searchDoctors() {
        hasSearched = true
        
        if let location = locationService.currentLocation {
            Task {
                await doctorService.fetchNearbyDoctors(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        } else if let manualLocation = locationService.manualLocation {
            Task {
                await doctorService.fetchDoctorsByCity(
                    city: manualLocation.city,
                    district: manualLocation.district
                )
            }
        }
    }
    
    private func refreshDoctors() async {
        if let location = locationService.currentLocation {
            await doctorService.fetchNearbyDoctors(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } else if let manualLocation = locationService.manualLocation {
            await doctorService.fetchDoctorsByCity(
                city: manualLocation.city,
                district: manualLocation.district
            )
        }
    }
}

// MARK: - Pharmacies List View
struct PharmaciesListView: View {
    @ObservedObject var pharmacyService: PharmacyService
    @ObservedObject var locationService: LocationService
    let searchText: String
    
    @State private var animateCards = false
    @State private var hasSearched = false
    
    private var filteredPharmacies: [Pharmacy] {
        if searchText.isEmpty {
            return pharmacyService.nearbyPharmacies
        } else {
            return pharmacyService.nearbyPharmacies.filter { pharmacy in
                pharmacy.name.localizedCaseInsensitiveContains(searchText) ||
                pharmacy.address.localizedCaseInsensitiveContains(searchText) ||
                pharmacy.district.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if pharmacyService.isLoading {
                    LocationServiceLoadingView(message: "Nöbetçi eczaneler aranıyor...")
                        .frame(height: 200)
                } else if let error = pharmacyService.errorMessage {
                    LocationErrorView(
                        error: error,
                        onRetry: {
                            searchPharmacies()
                        },
                        onManualLocation: {
                            // Handle manual location selection
                        }
                    )
                    .padding()
                } else if filteredPharmacies.isEmpty && hasSearched {
                    PharmacyEmptyState {
                        searchPharmacies()
                    }
                    .padding()
                } else if !filteredPharmacies.isEmpty {
                    ServiceSectionHeader(
                        title: "Nöbetçi Eczaneler",
                        icon: "cross.fill",
                        color: .successGreen,
                        count: filteredPharmacies.count
                    )
                    
                    ForEach(Array(filteredPharmacies.enumerated()), id: \.offset) { index, pharmacy in
                        PharmacyCard(
                            pharmacy: pharmacy,
                            userLocation: locationService.currentLocation
                        )
                        .opacity(animateCards ? 1.0 : 0)
                        .offset(y: animateCards ? 0 : 30)
                        .animation(
                            .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                            value: animateCards
                        )
                    }
                } else {
                    // Initial state - show instruction
                    InitialSearchStateView(
                        icon: "cross.fill",
                        title: "Nöbetçi Eczaneler",
                        description: "Konumunuza göre yakınınızdaki nöbetçi eczaneleri bulun",
                        color: .successGreen
                    ) {
                        searchPharmacies()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .refreshable {
            await refreshPharmacies()
        }
        .onAppear {
            if !hasSearched && locationService.hasLocationPermission {
                searchPharmacies()
            }
        }
        .onChange(of: locationService.currentLocation) { _ in
            if locationService.hasLocationPermission && !hasSearched {
                searchPharmacies()
            }
        }
        .onAppear {
            animateCards = true
        }
    }
    
    private func searchPharmacies() {
        hasSearched = true
        
        if let location = locationService.currentLocation {
            Task {
                await pharmacyService.fetchNearbyPharmacies(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        } else if let manualLocation = locationService.manualLocation {
            Task {
                await pharmacyService.fetchPharmaciesByCity(
                    city: manualLocation.city,
                    district: manualLocation.district
                )
            }
        }
    }
    
    private func refreshPharmacies() async {
        if let location = locationService.currentLocation {
            await pharmacyService.fetchNearbyPharmacies(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } else if let manualLocation = locationService.manualLocation {
            await pharmacyService.fetchPharmaciesByCity(
                city: manualLocation.city,
                district: manualLocation.district
            )
        }
    }
}

// MARK: - Initial Search State View
struct InitialSearchStateView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let onSearch: () -> Void
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1.0 : 0.6)
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(color)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .rotationEffect(.degrees(animateIcon ? 0 : -10))
            }
            .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateIcon)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                Button("Ara") {
                    HapticFeedback.lightImpact()
                    onSearch()
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: color))
                .frame(maxWidth: 200)
            }
            .opacity(animateIcon ? 1.0 : 0)
            .offset(y: animateIcon ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: animateIcon)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
        .onAppear {
            animateIcon = true
        }
    }
}

// MARK: - Permission Request View
struct PermissionRequestView: View {
    let onRequestPermission: () -> Void
    let onManualLocation: () -> Void
    
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Image(systemName: "location.circle")
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(.babyPrimary)
                    .scaleEffect(animateContent ? 1.0 : 0.8)
                    .opacity(animateContent ? 1.0 : 0)
                
                VStack(spacing: 12) {
                    Text("Konum İzni Gerekli")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("Yakınınızdaki doktor ve eczaneleri bulabilmek için konum izni vermeniz gerekiyor.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                }
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 20)
            }
            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
            
            VStack(spacing: 16) {
                Button("Konum İzni Ver") {
                    HapticFeedback.lightImpact()
                    onRequestPermission()
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .babyPrimary))
                
                Button("Manuel Konum Seç") {
                    HapticFeedback.lightImpact()
                    onManualLocation()
                }
                .buttonStyle(SecondaryButtonStyle(borderColor: .babyPrimary))
            }
            .opacity(animateContent ? 1.0 : 0)
            .offset(y: animateContent ? 0 : 30)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: animateContent)
        }
        .padding(.horizontal, 40)
        .onAppear {
            animateContent = true
        }
    }
}

// MARK: - Quick Stats View
struct ServiceStatsView: View {
    let doctorCount: Int
    let pharmacyCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Doktor",
                count: doctorCount,
                icon: "stethoscope",
                color: .babyPrimary
            )
            
            StatCard(
                title: "Eczane",
                count: pharmacyCount,
                icon: "cross.fill",
                color: .successGreen
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.charcoal)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack {
        DoctorsListView(
            doctorService: DoctorService(),
            locationService: LocationService(),
            searchText: ""
        )
    }
}
