import SwiftUI
import CoreLocation

struct NearbyServicesView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var pharmacyService = PharmacyService()
    @StateObject private var doctorService = DoctorService()
    
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var animateContent = false
    @State private var showLocationPermissionAlert = false
    
    private let tabTitles = ["Doktorlar", "Nöbetçi Eczaneler"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [Color.softMint.opacity(0.3), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    ModernNearbyServicesHeader(
                        locationService: locationService,
                        onLocationTap: handleLocationPermission
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -30)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                    
                    // Search Bar
                    ModernSearchBar(text: $searchText, onSearchChanged: handleSearch)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Tab Selector
                    ModernServiceTabSelector(
                        selectedTab: $selectedTab,
                        tabTitles: tabTitles
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -10)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        // Doctors Tab
                        DoctorsListView(
                            doctorService: doctorService,
                            locationService: locationService,
                            searchText: searchText
                        )
                        .tag(0)
                        
                        // Pharmacies Tab
                        PharmaciesListView(
                            pharmacyService: pharmacyService,
                            locationService: locationService,
                            searchText: searchText
                        )
                        .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .opacity(animateContent ? 1.0 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Konum İzni Gerekli", isPresented: $showLocationPermissionAlert) {
                Button("Ayarlara Git") {
                    locationService.requestLocationPermission()
                }
                Button("İptal", role: .cancel) { }
            } message: {
                Text("Size en yakın doktor ve eczaneleri gösterebilmek için konum izni gerekiyor.")
            }
        }
        .onAppear {
            animateContent = true
            loadInitialData()
        }
        .onChange(of: locationService.location) { location in
            if let location = location {
                loadLocationBasedData(location: location)
            }
        }
        .onChange(of: selectedTab) { _ in
            HapticFeedback.selection()
        }
    }
    
    private func handleLocationPermission() {
        switch locationService.authorizationStatus {
        case .notDetermined:
            locationService.requestLocationPermission()
        case .denied, .restricted:
            showLocationPermissionAlert = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationService.getCurrentLocation()
        @unknown default:
            break
        }
    }
    
    private func handleSearch() {
        // Arama işlemi 0.5 saniye gecikmeyle yapılır (debouncing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let location = locationService.location {
                Task {
                    if selectedTab == 0 {
                        await doctorService.searchDoctors(
                            query: searchText,
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    } else {
                        // Eczane arama local olarak yapılır
                        pharmacyService.searchPharmacies(query: searchText)
                    }
                }
            } else {
                Task {
                    if selectedTab == 0 {
                        await doctorService.searchDoctors(query: searchText)
                    } else {
                        pharmacyService.searchPharmacies(query: searchText)
                    }
                }
            }
        }
    }
    
    private func loadInitialData() {
        // İlk açılışta mock data yükle
        Task {
            await doctorService.loadAllDoctors()
        }
        pharmacyService.loadMockData()
    }
    
    private func loadLocationBasedData(location: CLLocation) {
        Task {
            // Paralel olarak hem doktor hem eczane verilerini yükle
            async let doctorsTask = doctorService.fetchNearbyDoctors(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            async let pharmaciesTask = pharmacyService.fetchNearbyPharmacies(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            // Her iki task'in tamamlanmasını bekle
            await doctorsTask
            await pharmaciesTask
        }
    }
}

// Modern Nearby Services Header
struct ModernNearbyServicesHeader: View {
    let locationService: LocationService
    let onLocationTap: () -> Void
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏥 Yakın Hizmetler")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("Size en yakın doktor ve eczaneler")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Location button with animation
                Button(action: onLocationTap) {
                    Image(systemName: locationService.isLoading ? "location.fill" : "location.circle.fill")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                        .scaleEffect(animateIcon ? 1.1 : 1.0)
                        .rotationEffect(.degrees(locationService.isLoading ? 360 : 0))
                        .animation(
                            locationService.isLoading ? 
                                .linear(duration: 1.0).repeatForever(autoreverses: false) :
                                .spring(response: 0.6, dampingFraction: 0.6),
                            value: locationService.isLoading ? true : animateIcon
                        )
                }
            }
            
            // Location Status
            if let location = locationService.location {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.successGreen)
                    
                    Text("Konum alındı")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text("Lat: \(String(format: "%.4f", location.coordinate.latitude)), Lng: \(String(format: "%.4f", location.coordinate.longitude))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            } else if let errorMessage = locationService.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.errorRed)
                    
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                    
                    Spacer()
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.mintGreen, Color.mintGreen.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.top, 60) // Space for navigation
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5)) {
                animateIcon = true
            }
        }
    }
}

// Modern Search Bar
struct ModernSearchBar: View {
    @Binding var text: String
    let onSearchChanged: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundColor(isFocused ? .mintGreen : .secondary)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField("Doktor, hastane veya eczane ara...", text: $text)
                .font(.subheadline)
                .foregroundColor(.charcoal)
                .focused($isFocused)
                .onSubmit {
                    onSearchChanged()
                }
                .onChange(of: text) { _ in
                    onSearchChanged()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearchChanged()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isFocused ? Color.mintGreen : Color.coolGray.opacity(0.3),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// Modern Service Tab Selector
struct ModernServiceTabSelector: View {
    @Binding var selectedTab: Int
    let tabTitles: [String]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in
                ModernServiceTabButton(
                    title: title,
                    isSelected: selectedTab == index,
                    color: index == 0 ? .oceanBlue : .roseGold
                ) {
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.mintGreen.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernServiceTabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: title == "Doktorlar" ? "stethoscope" : "cross.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: isSelected ? color.opacity(0.3) : Color.clear,
                        radius: isSelected ? 8 : 0,
                        x: 0,
                        y: isSelected ? 4 : 0
                    )
            )
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

#Preview {
    NearbyServicesView()
}
