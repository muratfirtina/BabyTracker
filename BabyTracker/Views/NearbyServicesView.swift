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
    @State private var locationLoadTask: Task<Void, Never>?
    
    private let tabTitles = ["Doktorlar", "Hastaneler", "Eczaneler"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [Color.softMint.opacity(0.2), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Compact Modern Header
                    CompactNearbyServicesHeader(
                        locationService: locationService,
                        onLocationTap: handleLocationPermission
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -20)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: animateContent)
                    
                    // Search Bar
                    ModernSearchBar(text: $searchText, onSearchChanged: handleSearch)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -10)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    
                    // Modern Pill-Style Tab Selector
                    ModernPillTabSelector(
                        selectedTab: $selectedTab,
                        tabTitles: tabTitles
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3), value: animateContent)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        // Doctors Tab
                        DoctorsListView(
                            doctorService: doctorService,
                            locationService: locationService,
                            searchText: searchText
                        )
                        .tag(0)
                        
                        // Hospitals Tab
                        HospitalsListView(
                            doctorService: doctorService,
                            locationService: locationService,
                            searchText: searchText
                        )
                        .tag(1)
                        
                        // Pharmacies Tab
                        PharmaciesListView(
                            pharmacyService: pharmacyService,
                            locationService: locationService,
                            searchText: searchText
                        )
                        .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .opacity(animateContent ? 1.0 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4), value: animateContent)
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
            withAnimation {
                animateContent = true
            }
        }
        .onChange(of: locationService.currentLocation) { oldValue, newValue in
            // Debouncing: Önceki task'ı iptal et
            locationLoadTask?.cancel()
            
            // Yeni task oluştur
            locationLoadTask = Task {
                // 2 saniye bekle (debouncing)
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                guard !Task.isCancelled else { 
                    print("ℹ️ Konum task iptal edildi (normal)")
                    return 
                }
                
                if let location = newValue {
                    print("📍 Konum değişti, arama başlatılıyor...")
                    await loadLocationBasedData(location: location)
                }
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let location = locationService.currentLocation {
                Task {
                    switch selectedTab {
                    case 0: // Doctors
                        await doctorService.searchDoctors(
                            query: searchText,
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    case 1: // Hospitals
                        await doctorService.searchHospitals(
                            query: searchText,
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    case 2: // Pharmacies
                        await pharmacyService.fetchNearbyPharmacies(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    default:
                        break
                    }
                }
            } else {
                Task {
                    switch selectedTab {
                    case 0:
                        await doctorService.searchDoctors(query: searchText)
                    case 1:
                        await doctorService.searchHospitals(query: searchText)
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func loadLocationBasedData(location: CLLocation) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.doctorService.fetchNearbyDoctors(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            
            group.addTask {
                await self.doctorService.fetchNearbyHospitals(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            
            group.addTask {
                await self.pharmacyService.fetchNearbyPharmacies(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
    }
}

// Compact Modern Header - Reduced spacing
struct CompactNearbyServicesHeader: View {
    @ObservedObject var locationService: LocationService
    let onLocationTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("🏥 Yakın Hizmetler")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Compact Location Button
                    Button(action: onLocationTap) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.25))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: locationService.isLoading ? "location.fill" : "location.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(locationService.isLoading ? 360 : 0))
                                .animation(
                                    locationService.isLoading ? 
                                        .linear(duration: 1.0).repeatForever(autoreverses: false) :
                                        .spring(response: 0.6, dampingFraction: 0.6),
                                    value: locationService.isLoading
                                )
                        }
                    }
                }
                
                // Compact Location Status
                HStack(spacing: 6) {
                    Image(systemName: getStatusIcon())
                        .font(.caption2)
                        .foregroundColor(getStatusColor())
                    
                    Text(getStatusText())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.mintGreen, Color.mintGreen.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .mintGreen.opacity(0.3), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private func getStatusIcon() -> String {
        if locationService.currentLocation != nil {
            return "checkmark.circle.fill"
        } else if locationService.isLoading {
            return "location.fill"
        } else {
            return "location.slash"
        }
    }
    
    private func getStatusColor() -> Color {
        if locationService.currentLocation != nil {
            return .white
        } else if locationService.isLoading {
            return .white.opacity(0.8)
        } else {
            return .white.opacity(0.7)
        }
    }
    
    private func getStatusText() -> String {
        if let locationName = locationService.currentLocationName {
            return locationName
        } else if locationService.currentLocation != nil {
            return "Konum alındı"
        } else if locationService.isLoading {
            return "Konum alınıyor..."
        } else if let error = locationService.errorMessage {
            return error
        } else {
            return "Konumunuzu paylaşın"
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
                .font(.body)
                .foregroundColor(isFocused ? .mintGreen : .secondary)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            TextField("Ara...", text: $text)
                .font(.body)
                .foregroundColor(.charcoal)
                .focused($isFocused)
                .onSubmit {
                    onSearchChanged()
                }
                .onChange(of: text) { oldValue, newValue in
                    onSearchChanged()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    onSearchChanged()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isFocused ? Color.mintGreen : Color.coolGray.opacity(0.2),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.04), radius: 8, x: 0, y: 4)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isFocused)
    }
}

// Modern Pill-Style Tab Selector - More Tappable
struct ModernPillTabSelector: View {
    @Binding var selectedTab: Int
    let tabTitles: [String]
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in
                PillTabButton(
                    title: title,
                    icon: index == 0 ? "stethoscope" : (index == 1 ? "building.2.fill" : "cross.case.fill"),
                    isSelected: selectedTab == index,
                    namespace: animation
                ) {
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.mintGreen.opacity(0.15), radius: 12, x: 0, y: 4)
        )
    }
}

struct PillTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : nil)
            .foregroundStyle(
                !isSelected ? 
                    LinearGradient(
                        colors: [.mintGreen, .oceanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [.white, .white],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.mintGreen, .oceanBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "tab", in: namespace)
                        .shadow(color: .mintGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                }
            }
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

// Hospitals List View
struct HospitalsListView: View {
    @ObservedObject var doctorService: DoctorService
    @ObservedObject var locationService: LocationService
    let searchText: String
    
    var body: some View {
        ScrollView {
            if doctorService.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 80)
                    
                    Text("Hastaneler yüklüyor...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if let error = doctorService.errorMessage {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                        .padding(.top, 60)
                    
                    Text("Bir Hata Oluştu")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Tekrar Dene") {
                        Task {
                            if let location = locationService.currentLocation {
                                await doctorService.fetchNearbyHospitals(
                                    latitude: location.coordinate.latitude,
                                    longitude: location.coordinate.longitude
                                )
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.mintGreen)
                }
                .frame(maxWidth: .infinity)
            } else if doctorService.hospitals.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "building.2")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding(.top, 60)
                    
                    Text("Hastane Bulunamadı")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(searchText.isEmpty ? "Yakınınızda hastane bulunamadı" : "Arama sonuçlarında hastane bulunamadı")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(doctorService.hospitals) { hospital in
                        HospitalCard(hospital: hospital)
                            .onAppear {
                                // Infinite scroll trigger
                                if hospital.id == doctorService.hospitals.last?.id,
                                   let location = locationService.currentLocation,
                                   doctorService.hasMoreHospitals {
                                    Task {
                                        await doctorService.loadMoreHospitals(
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
                            Text("Daha fazla hastane yükle niyor...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    
                    // End of list indicator
                    if !doctorService.hasMoreHospitals && !doctorService.hospitals.isEmpty {
                        Text("✓ Tüm hastaneler yüklendi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }
}

// Hospital Card
struct HospitalCard: View {
    let hospital: Doctor // Using Doctor model for hospitals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Icon
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.oceanBlue, .oceanBlue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .oceanBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hospital.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .lineLimit(2)
                    
                    if !hospital.specialization.isEmpty {
                        Text(hospital.specialization)
                            .font(.caption)
                            .foregroundColor(.oceanBlue)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
            
            // Info
            VStack(spacing: 12) {
                if !hospital.address.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(hospital.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                if !hospital.phone.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(hospital.phone)
                            .font(.subheadline)
                            .foregroundColor(.oceanBlue)
                    }
                }
                
                if let distance = hospital.distance {
                    HStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f km uzaklıkta", distance / 1000))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Actions
            HStack(spacing: 12) {
                if !hospital.phone.isEmpty {
                    Button(action: {
                        if let url = URL(string: "tel://\(hospital.phone)") {
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.successGreen, .successGreen.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
                
                if hospital.location.latitude != 0, hospital.location.longitude != 0 {
                    Button(action: {
                        let coordinate = "\(hospital.location.latitude),\(hospital.location.longitude)"
                        let url = URL(string: "maps://?q=\(coordinate)")
                        if let url = url {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "map.fill")
                                .font(.caption)
                            Text("Yol Tarifi")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.oceanBlue, .oceanBlue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .oceanBlue.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    NearbyServicesView()
}
