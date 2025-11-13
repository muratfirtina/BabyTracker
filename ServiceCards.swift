import SwiftUI

// MARK: - Pharmacy Card Component
struct PharmacyCard: View {
    let pharmacy: Pharmacy
    let userLocation: CLLocation?
    @State private var showingMapSelection = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with pharmacy info
            HStack(alignment: .top, spacing: 16) {
                // Pharmacy icon
                Image(systemName: "cross.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.successGreen, .successGreen.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .successGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                // Pharmacy details
                VStack(alignment: .leading, spacing: 6) {
                    Text(pharmacy.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .lineLimit(2)
                    
                    Text(MapUtility.formatAddress(pharmacy.address))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    // Distance and duty status
                    HStack(spacing: 12) {
                        if let distance = pharmacy.distance {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                    .foregroundColor(.infoBlue)
                                
                                Text(MapUtility.formatDistance(distance))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.infoBlue)
                            }
                        }
                        
                        if pharmacy.isOnDuty {
                            StatusBadgeView(
                                "Nöbetçi",
                                color: .successGreen,
                                style: .filled,
                                size: .small
                            )
                        }
                    }
                }
                
                Spacer()
            }
            
            // Action buttons
            HStack(spacing: 12) {
                // Call button
                Button(action: {
                    HapticFeedback.lightImpact()
                    MapUtility.callPhoneNumber(pharmacy.phone)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.caption)
                        
                        Text("Ara")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.infoBlue)
                            .shadow(color: .infoBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                // Directions button
                Button(action: {
                    HapticFeedback.lightImpact()
                    showingMapSelection = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        
                        Text("Yol Tarifi")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.successGreen)
                            .shadow(color: .successGreen.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                Spacer()
                
                // Phone number display
                Text(MapUtility.formatPhoneNumber(pharmacy.phone))
                    .font(.caption)
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
                                colors: [Color.successGreen.opacity(0.3), Color.successGreen.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.successGreen.opacity(0.1),
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
        .sheet(isPresented: $showingMapSelection) {
            MapSelectionSheet(
                latitude: pharmacy.latitude,
                longitude: pharmacy.longitude,
                name: pharmacy.name,
                forDirections: true,
                isPresented: $showingMapSelection
            )
        }
    }
}

// MARK: - Doctor Card Component
struct DoctorCard: View {
    let doctor: Doctor
    let userLocation: CLLocation?
    @State private var showingMapSelection = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with doctor info
            HStack(alignment: .top, spacing: 16) {
                // Doctor icon
                Image(systemName: "stethoscope.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.babyPrimary, .babyPrimary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .babyPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                // Doctor details
                VStack(alignment: .leading, spacing: 6) {
                    Text(doctor.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .lineLimit(2)
                    
                    Text(doctor.specialty.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.babyPrimary)
                    
                    Text(doctor.hospital)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Rating and availability
                    HStack(spacing: 12) {
                        if doctor.rating > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.warningOrange)
                                
                                Text(String(format: "%.1f", doctor.rating))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.charcoal)
                                
                                Text("(\(doctor.reviewCount))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let distance = doctor.distance {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                    .foregroundColor(.infoBlue)
                                
                                Text(MapUtility.formatDistance(distance))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.infoBlue)
                            }
                        }
                        
                        StatusBadgeView(
                            doctor.isAvailable ? "Müsait" : "Meşgul",
                            color: doctor.isAvailable ? .successGreen : .errorRed,
                            style: .filled,
                            size: .small
                        )
                    }
                }
                
                Spacer()
            }
            
            // Working hours
            if let workingHours = doctor.workingHours {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Çalışma Saatleri: \(workingHours)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.coolGray.opacity(0.1))
                )
            }
            
            // Action buttons
            HStack(spacing: 12) {
                // Call button
                Button(action: {
                    HapticFeedback.lightImpact()
                    MapUtility.callPhoneNumber(doctor.phone)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.caption)
                        
                        Text("Ara")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.infoBlue)
                            .shadow(color: .infoBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                // Directions button
                Button(action: {
                    HapticFeedback.lightImpact()
                    showingMapSelection = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        
                        Text("Yol Tarifi")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.babyPrimary)
                            .shadow(color: .babyPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                }
                
                Spacer()
                
                // Phone number display
                Text(MapUtility.formatPhoneNumber(doctor.phone))
                    .font(.caption)
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
                                colors: [Color.babyPrimary.opacity(0.3), Color.babyPrimary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.babyPrimary.opacity(0.1),
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
        .sheet(isPresented: $showingMapSelection) {
            MapSelectionSheet(
                latitude: doctor.latitude,
                longitude: doctor.longitude,
                name: doctor.hospital,
                forDirections: true,
                isPresented: $showingMapSelection
            )
        }
    }
}

// MARK: - Empty State Components
struct PharmacyEmptyState: View {
    let onRetry: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "cross.circle",
            title: "Nöbetçi Eczane Bulunamadı",
            description: "Konumunuz yakınında nöbetçi eczane bulunamadı. Lütfen daha sonra tekrar deneyin.",
            actionTitle: "Tekrar Dene",
            action: onRetry,
            color: .successGreen
        )
    }
}

struct DoctorEmptyState: View {
    let onRetry: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "stethoscope",
            title: "Çocuk Doktoru Bulunamadı",
            description: "Konumunuz yakınında çocuk doktoru bulunamadı. Farklı bir arama yapmayı deneyin.",
            actionTitle: "Tekrar Dene",
            action: onRetry,
            color: .babyPrimary
        )
    }
}

// MARK: - Loading State Components
struct LocationServiceLoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .babyPrimary))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Error State Components
struct LocationErrorView: View {
    let error: String
    let onRetry: () -> Void
    let onManualLocation: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.slash")
                .font(.system(size: 50))
                .foregroundColor(.errorRed)
            
            VStack(spacing: 12) {
                Text("Konum Hatası")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button("Tekrar Dene", action: onRetry)
                    .buttonStyle(PrimaryButtonStyle(backgroundColor: .babyPrimary))
                    .frame(maxWidth: 200)
                
                Button("Manuel Konum Seç", action: onManualLocation)
                    .buttonStyle(SecondaryButtonStyle(borderColor: .babyPrimary))
                    .frame(maxWidth: 200)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Section Header Component
struct ServiceSectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                if let count = count {
                    Text("\(count) sonuç bulundu")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 20) {
        PharmacyCard(
            pharmacy: Pharmacy(
                id: UUID(),
                name: "Eczane 24",
                address: "Kozyatağı Mahallesi, İnönü Caddesi No:4, 34742 Kadıköy/İstanbul",
                phone: "+90 216 571 29 00",
                latitude: 40.9782,
                longitude: 29.0742,
                distance: 1.2,
                city: "İstanbul",
                district: "Kadıköy",
                isOnDuty: true
            ),
            userLocation: nil
        )
        
        DoctorCard(
            doctor: Doctor(
                id: UUID(),
                name: "Dr. Ayşe Kırmızı",
                specialty: .pediatrics,
                hospital: "Acıbadem Kozyatağı Hastanesi",
                address: "Kozyatağı Mahallesi, İnönü Caddesi No:4, 34742 Kadıköy/İstanbul",
                phone: "+90 216 571 29 00",
                latitude: 40.9782,
                longitude: 29.0742,
                distance: 1.5,
                rating: 4.8,
                reviewCount: 127,
                isAvailable: true,
                workingHours: "08:00 - 18:00"
            ),
            userLocation: nil
        )
    }
    .padding()
    .background(Color.softGray)
}
