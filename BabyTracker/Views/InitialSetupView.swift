import SwiftUI

struct InitialSetupView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @EnvironmentObject var growthDataManager: GrowthDataManager
    @State private var showingBabySetup = false
    @State private var animateContent = false
    @State private var animateFeatures = false
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            // Beautiful animated background
            AnimatedBackgroundView()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Section with stunning animations
                VStack(spacing: 32) {
                    // App icon with glow effect
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .scaleEffect(animateContent ? 1.0 : 0.8)
                            .opacity(animateContent ? 1.0 : 0)
                        
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                            .scaleEffect(animateContent ? 1.0 : 0.5)
                            .rotationEffect(.degrees(animateContent ? 0 : -10))
                    }
                    .animation(.spring(response: 1.2, dampingFraction: 0.6).delay(0.3), value: animateContent)
                    
                    // Welcome text with beautiful typography
                    VStack(spacing: 16) {
                        Text("Baby Tracker")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 30)
                        
                        Text("Hoş Geldiniz! 👋")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.95))
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        Text("Bebeğinizin gelişimini takip etmek ve önemli anları kaydetmek için buradayız.")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, 20)
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 15)
                    }
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateContent)
                }
                
                Spacer()
                
                // Features Section with stunning cards
                VStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        ModernFeatureRow(
                            icon: feature.icon,
                            title: feature.title,
                            description: feature.description,
                            color: feature.color,
                            gradient: feature.gradient
                        )
                        .opacity(animateFeatures ? 1.0 : 0)
                        .offset(x: animateFeatures ? 0 : -50)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.7)
                            .delay(1.0 + Double(index) * 0.2),
                            value: animateFeatures
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // CTA Button with amazing design
                Button(action: {
                    HapticFeedback.lightImpact()
                    showingBabySetup = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Başlayalım")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.babyPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white, Color.white.opacity(0.95)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
                            .shadow(color: .white.opacity(0.8), radius: 2, x: 0, y: 1)
                    )
                }
                .padding(.horizontal, 40)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 40)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(1.5), value: animateContent)
                
                Spacer(minLength: 50)
            }
            
            // Floating particles effect
            if showParticles {
                ForEach(0..<15, id: \.self) { index in
                    FloatingParticle(delay: Double(index) * 0.3)
                }
            }
        }
        .sheet(isPresented: $showingBabySetup) {
            BabySetupView(baby: $babyDataManager.currentBaby)
                .onDisappear {
                    // Setup completion logic
                    if !babyDataManager.currentBaby.name.isEmpty && 
                       babyDataManager.currentBaby.name != "Bebeğim" {
                        
                        // Add birth record to growth data
                        if let birthWeight = babyDataManager.currentBaby.birthWeight,
                           let birthHeight = babyDataManager.currentBaby.birthHeight {
                            
                            growthDataManager.addBirthRecord(
                                for: babyDataManager.currentBaby, 
                                weightKg: birthWeight / 1000, // gram to kg
                                heightCm: birthHeight
                            )
                        }
                        
                        babyDataManager.completeSetup()
                    }
                }
        }
        .onAppear {
            // Staggered animations for amazing entrance
            animateContent = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateFeatures = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showParticles = true
            }
        }
    }
    
    // Feature data
    private var features: [Feature] {
        [
            Feature(
                icon: "chart.line.uptrend.xyaxis",
                title: "Gelişim Takibi",
                description: "Boy, kilo ve önemli gelişim aşamalarını kaydedin",
                color: .babyPrimary,
                gradient: Color.babyGradient
            ),
            Feature(
                icon: "syringe.fill",
                title: "Aşı Takvimi",
                description: "Aşı planını takip edin ve hatırlatmalar alın",
                color: .roseGold,
                gradient: Color.vaccinationGradient
            ),
            Feature(
                icon: "gamecontroller.fill",
                title: "Yaşa Uygun Aktiviteler",
                description: "Bebeğinizin gelişimi için özel aktivite önerileri",
                color: .coralPink,
                gradient: Color.activityGradient
            )
        ]
    }
}

// Feature data model
struct Feature {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let gradient: LinearGradient
}

// Animated Background Component
struct AnimatedBackgroundView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base gradient
            Color.heroGradient
                .ignoresSafeArea()
            
            // Animated overlay gradients
            LinearGradient(
                colors: [
                    Color.pregnancyPrimary.opacity(animateGradient ? 0.3 : 0.6),
                    Color.babyPrimary.opacity(animateGradient ? 0.6 : 0.3),
                    Color.mintGreen.opacity(animateGradient ? 0.4 : 0.7)
                ],
                startPoint: animateGradient ? .topTrailing : .bottomLeading,
                endPoint: animateGradient ? .bottomLeading : .topTrailing
            )
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 8.0).repeatForever(autoreverses: true),
                value: animateGradient
            )
            
            // Subtle pattern overlay
            RadialGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
        .onAppear {
            animateGradient = true
        }
    }
}

// Modern Feature Row Component
struct ModernFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let gradient: LinearGradient
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(gradient)
                        .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 5)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.4), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
    }
}

// Floating Particle Effect
struct FloatingParticle: View {
    let delay: Double
    
    @State private var animate = false
    @State private var opacity: Double = 0
    
    private let size = CGFloat.random(in: 3...8)
    private let startX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
    private let endX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
    private let duration = Double.random(in: 8...15)
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .position(
                x: animate ? endX : startX,
                y: animate ? -50 : UIScreen.main.bounds.height + 50
            )
            .opacity(opacity)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: false)
                .delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
                withAnimation(.easeIn(duration: 2.0).delay(delay)) {
                    opacity = 1.0
                }
                
                // Fade out before reaching the top
                DispatchQueue.main.asyncAfter(deadline: .now() + delay + duration - 2.0) {
                    withAnimation(.easeOut(duration: 2.0)) {
                        opacity = 0
                    }
                }
            }
    }
}

#Preview {
    InitialSetupView()
        .environmentObject(BabyDataManager())
        .environmentObject(GrowthDataManager())
}
