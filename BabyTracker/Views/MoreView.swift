import SwiftUI

struct MoreView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @EnvironmentObject var vaccinationDataManager: VaccinationDataManager
    @State private var animateCards = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Animated Header with gradient
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.lavenderMist.opacity(0.3), .babyPrimary.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.babyPrimary, .mintGreen],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolEffect(.pulse.byLayer, options: .repeating)
                        }
                        .shadow(color: .babyPrimary.opacity(0.2), radius: 20, x: 0, y: 10)
                        .scaleEffect(animateCards ? 1.0 : 0.8)
                        .opacity(animateCards ? 1.0 : 0)
                        
                        Text("Daha Fazla")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.charcoal, .charcoal.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(animateCards ? 1.0 : 0)
                            .offset(y: animateCards ? 0 : 20)
                        
                        Text("Tüm özellikler ve ayarlar")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(animateCards ? 1.0 : 0)
                            .offset(y: animateCards ? 0 : 20)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    
                    // Feature Cards Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        // Vaccinations
                        NavigationLink(destination: VaccinationView()
                            .environmentObject(babyDataManager)
                            .environmentObject(vaccinationDataManager)) {
                            FeatureCard(
                                icon: "syringe.fill",
                                title: "Aşılar",
                                subtitle: "Takvim & Takip",
                                gradient: [.roseGold, .lightPeach],
                                delay: 0.1
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Nearby Services
                        NavigationLink(destination: NearbyServicesView()) {
                            FeatureCard(
                                icon: "map.fill",
                                title: "Yakın Hizmetler",
                                subtitle: "Doktor & Eczane",
                                gradient: [.mintGreen, .oceanBlue],
                                delay: 0.2
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Growth Tracking
                        NavigationLink(destination: GrowthTrackingView()) {
                            FeatureCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Büyüme",
                                subtitle: "Boy & Kilo",
                                gradient: [.oceanBlue, .babySecondary],
                                delay: 0.3
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Settings (placeholder)
                        Button(action: { HapticFeedback.lightImpact() }) {
                            FeatureCard(
                                icon: "gearshape.fill",
                                title: "Ayarlar",
                                subtitle: "Uygulama",
                                gradient: [.coolGray, .charcoal],
                                delay: 0.4
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Hızlı Erişim")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.charcoal)
                            
                            Spacer()
                            
                            Image(systemName: "bolt.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.warningOrange, .roseGold],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            QuickActionRow(
                                icon: "bell.fill",
                                title: "Bildirimler",
                                description: "Hatırlatıcılar ve uyarılar",
                                color: .warningOrange
                            )
                            
                            Divider()
                                .padding(.leading, 70)
                            
                            QuickActionRow(
                                icon: "shield.fill",
                                title: "Gizlilik",
                                description: "Veri güvenliği ve izinler",
                                color: .infoBlue
                            )
                            
                            Divider()
                                .padding(.leading, 70)
                            
                            QuickActionRow(
                                icon: "questionmark.circle.fill",
                                title: "Yardım",
                                description: "Sıkça sorulan sorular",
                                color: .successGreen
                            )
                            
                            Divider()
                                .padding(.leading, 70)
                            
                            QuickActionRow(
                                icon: "heart.fill",
                                title: "Bizi Değerlendirin",
                                description: "App Store'da puan verin",
                                color: .roseGold
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                    }
                    .opacity(animateCards ? 1.0 : 0)
                    .offset(y: animateCards ? 0 : 30)
                    
                    // App Info
                    VStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.roseGold, .lightPeach],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("BabyTracker")
                            .font(.headline)
                            .foregroundColor(.charcoal)
                        
                        Text("Versiyon 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Made with ❤️ for parents")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .opacity(animateCards ? 1.0 : 0)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.lavenderMist.opacity(0.15), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
    }
}

// Modern Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let delay: Double
    
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce, value: appeared)
            }
            
            Spacer()
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(20)
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: gradient[0].opacity(0.3), radius: 15, x: 0, y: 8)
        )
        .opacity(appeared ? 1.0 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: appeared)
        .onAppear {
            appeared = true
        }
    }
}

// Quick Action Row Component
struct QuickActionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticFeedback.lightImpact()
        }) {
            HStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoal)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

#Preview {
    MoreView()
        .environmentObject(BabyDataManager())
        .environmentObject(VaccinationDataManager())
}
