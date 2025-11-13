import SwiftUI
import CoreLocation

struct NearbyServicesView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var pharmacyService = PharmacyService()
    @StateObject private var doctorService = DoctorService()
    
    @State private var selectedTab = 0
    @State private var animateContent = false
    @State private var showingLocationPicker = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: [Color.babySecondary.opacity(0.3), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    ModernServicesHeader(
                        locationService: locationService,
                        onLocationTap: {
                            showingLocationPicker = true
                        }
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -30)
                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                    
                    // Search bar
                    ModernSearchBar(text: $searchText)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // Tab Selector
                    ModernServiceTabSelector(selectedTab: $selectedTab)
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
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    locationService: locationService,
                    isPresented: $showingLocationPicker
                )
            }
        }
        .onAppear {
            animateContent = true
            locationService.requestLocationPermission()
        }
    }
}

// MARK: - Modern Services Header
struct ModernServicesHeader: View {
    @ObservedObject var locationService: LocationService
    let onLocationTap: () -> Void
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏥 Yakındaki Hizmetler")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text("Çocuk doktorları ve nöbetçi eczaneler")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Location icon with animation
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .rotationEffect(.degrees(animateIcon ? 0 : -15))
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5), value: animateIcon)
            }
            
            // Location info
            Button(action: onLocationTap) {
                HStack(spacing: 12) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(getLocationText())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    if locationService.authorizationStatus != .authorizedWhenInUse &&
                       locationService.authorizationStatus != .authorizedAlways {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                        .background(.ultraThinMaterial)
                )
            }
            .disabled(locationService.authorizationStatus == .authorizedWhenInUse ||
                     locationService.authorizationStatus == .authorizedAlways)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.babyPrimary, Color.babyPrimary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .onAppear {
            animateIcon = true
        }
    }
    
    private func getLocationText() -> String {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationService.currentLocation {
                return locationService.currentLocationName ?? "Konum alınıyor..."
            } else {
                return "Konum alınıyor..."
            }
        case .denied:
            return "Konum izni reddedildi - Ayarlardan açın"
        case .restricted:
            return "Konum hizmetleri kısıtlı"
        case .notDetermined:
            return "Konum izni gerekli - Dokunarak açın"
        @unknown default:
            return "Konum durumu bilinmiyor"
        }
    }
}

// MARK: - Modern Search Bar
struct ModernSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundColor(.secondary)
            
            TextField("Doktor veya eczane ara...", text: $text)
                .font(.subheadline)
                .focused($isFocused)
                .submitLabel(.search)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = false
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
                            isFocused ? Color.babyPrimary : Color.coolGray.opacity(0.3),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Service Tab Selector
struct ModernServiceTabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 12) {
            ServiceTabButton(
                title: "Çocuk Doktorları",
                icon: "stethoscope",
                isSelected: selectedTab == 0,
                color: .babyPrimary
            ) {
                HapticFeedback.selection()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedTab = 0
                }
            }
            
            ServiceTabButton(
                title: "Nöbetçi Eczaneler",
                icon: "cross.fill",
                isSelected: selectedTab == 1,
                color: .successGreen
            ) {
                HapticFeedback.selection()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedTab = 1
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.babyPrimary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ServiceTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
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

// MARK: - Location Picker View
struct LocationPickerView: View {
    @ObservedObject var locationService: LocationService
    @Binding var isPresented: Bool
    
    @State private var selectedCity = ""
    @State private var selectedDistrict = ""
    @State private var cities: [String] = []
    @State private var districts: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Konum Seçimi")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Konum izni verilmediği için manuel olarak şehir ve ilçe seçin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                VStack(spacing: 16) {
                    // City Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Şehir")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.charcoal)
                        
                        Picker("Şehir Seçin", selection: $selectedCity) {
                            Text("Şehir Seçin").tag("")
                            ForEach(cities, id: \.self) { city in
                                Text(city).tag(city)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.coolGray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.babyPrimary.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    // District Picker
                    if !selectedCity.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("İlçe")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoal)
                            
                            Picker("İlçe Seçin", selection: $selectedDistrict) {
                                Text("İlçe Seçin").tag("")
                                ForEach(districts, id: \.self) { district in
                                    Text(district).tag(district)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.coolGray.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.babyPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Konumu Ayarla") {
                        // Set manual location
                        locationService.setManualLocation(city: selectedCity, district: selectedDistrict)
                        isPresented = false
                    }
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: .babyPrimary))
                    .disabled(selectedCity.isEmpty)
                    
                    Button("Konum İzni Ver") {
                        locationService.requestLocationPermission()
                    }
                    .buttonStyle(SecondaryButtonStyle(borderColor: .babyPrimary))
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoal)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
        .onAppear {
            loadCities()
        }
        .onChange(of: selectedCity) { city in
            if !city.isEmpty {
                loadDistricts(for: city)
            }
        }
    }
    
    private func loadCities() {
        // Mock cities data - replace with actual API call
        cities = [
            "İstanbul", "Ankara", "İzmir", "Bursa", "Antalya",
            "Adana", "Konya", "Şanlıurfa", "Gaziantep", "Kocaeli"
        ]
    }
    
    private func loadDistricts(for city: String) {
        // Mock districts data - replace with actual API call
        switch city {
        case "İstanbul":
            districts = ["Kadıköy", "Beşiktaş", "Şişli", "Bakırköy", "Üsküdar", "Fatih", "Beyoğlu"]
        case "Ankara":
            districts = ["Çankaya", "Keçiören", "Yenimahalle", "Mamak", "Etimesgut", "Sincan"]
        case "İzmir":
            districts = ["Konak", "Bornova", "Karşıyaka", "Buca", "Alsancak", "Bayraklı"]
        default:
            districts = ["Merkez", "Kale", "Çamlık", "Yeni Mahalle"]
        }
        selectedDistrict = ""
    }
}

#Preview {
    NearbyServicesView()
}
