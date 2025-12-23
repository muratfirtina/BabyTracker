import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @State private var showingBabySetup = false
    @State private var animateCards = false
    
    var baby: Baby {
        babyDataManager.currentBaby
    }
    
    // Cinsiyet bazlı renk paleti
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(baby.gender)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cinsiyet bazlı güzel gradient arka plan
                genderColorScheme.gradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Baby Info Card
                        HeroBabyInfoCard(baby: baby, colorScheme: genderColorScheme)
                            .onTapGesture {
                                HapticFeedback.lightImpact()
                                showingBabySetup = true
                            }
                            .opacity(animateCards ? 1.0 : 0)
                            .offset(y: animateCards ? 0 : 30)
                            .animation(.easeOut(duration: 0.8).delay(0.1), value: animateCards)
                        
                        // Progress Section with beautiful animations
                        if baby.isPregnancy {
                            ModernPregnancyProgressCard(baby: baby)
                                .opacity(animateCards ? 1.0 : 0)
                                .offset(y: animateCards ? 0 : 40)
                                .animation(.easeOut(duration: 0.8).delay(0.3), value: animateCards)
                        } else {
                            ModernBabyProgressCard(baby: baby, colorScheme: genderColorScheme)
                                .opacity(animateCards ? 1.0 : 0)
                                .offset(y: animateCards ? 0 : 40)
                                .animation(.easeOut(duration: 0.8).delay(0.3), value: animateCards)
                        }
                        
                        // Enhanced Today's Recommendations
                        ModernTodayRecommendationsCard(baby: baby)
                            .opacity(animateCards ? 1.0 : 0)
                            .offset(y: animateCards ? 0 : 60)
                            .animation(.easeOut(duration: 0.8).delay(0.7), value: animateCards)
                        
                        // Additional spacing for better scroll experience
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingBabySetup) {
                BabySetupView(baby: $babyDataManager.currentBaby)
                    .onDisappear {
                        babyDataManager.saveBaby()
                    }
            }
            .onAppear {
                animateCards = true
            }
        }
    }
}

// 🎆 Hero Baby Info Card with stunning visual design and gender-based colors
struct HeroBabyInfoCard: View {
    let baby: Baby
    let colorScheme: GenderColorScheme
    
    @State private var animateContent = false
    @State private var showParticles = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    // Greeting based on time
                    Text(getGreeting())
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Baby name with beautiful animation
                    Text(baby.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .opacity(animateContent ? 1.0 : 0)
                    
                    // Age/pregnancy info
                    HStack(spacing: 8) {
                        Image(systemName: baby.isPregnancy ? "heart.fill" : "gift.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        if baby.isPregnancy {
                            Text("\(baby.pregnancyWeek). hamilelik haftası")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        } else {
                            Text("\(baby.ageInMonths) aylık \u{2022} \(baby.ageInDays) gün")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }
                
                Spacer()
                
                // Edit button with modern design
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        )
                }
            }
            
            // Progress indicator for pregnancy/growth
            if baby.isPregnancy {
                PregnancyProgressIndicator(week: baby.pregnancyWeek)
            } else {
                BabyGrowthIndicator(ageInMonths: baby.ageInMonths)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    baby.isPregnancy ? 
                    Color.pregnancyGradient : 
                    LinearGradient(
                        colors: [colorScheme.primary, colorScheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            // Subtle sparkle effect
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 50...300),
                        y: CGFloat.random(in: 20...80)
                    )
                    .opacity(showParticles ? 1.0 : 0)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: showParticles
                    )
            }
        )
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2)) {
                animateContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showParticles = true
            }
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Günaydın! 🌅"
        case 12..<17:
            return "İyi öğleden sonra! ☀️"
        case 17..<21:
            return "İyi akşamlar! 🌆"
        default:
            return "İyi geceler! 🌙"
        }
    }
}

// Local Progress Ring Component for Dashboard View
struct DashboardProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animateProgress ? progress : 0)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.5).delay(0.3), value: animateProgress)
            
            // Percentage text
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(width: size, height: size)
        .onAppear {
            animateProgress = true
        }
    }
}

// Pregnancy Progress Indicator
struct PregnancyProgressIndicator: View {
    let week: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Hamilelik İlerlemesi")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(week)/40 hafta")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            DashboardProgressRing(
                progress: Double(week) / 40.0,
                color: Color.white,
                lineWidth: 6,
                size: 50
            )
        }
    }
}

// Baby Growth Indicator
struct BabyGrowthIndicator: View {
    let ageInMonths: Int
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Text("\(ageInMonths)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("AY")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .background(.ultraThinMaterial)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(getGrowthStage(ageInMonths))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(getGrowthDescription(ageInMonths))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
    
    private func getGrowthStage(_ months: Int) -> String {
        switch months {
        case 0...3:
            return "Yenidoğan Dönemi"
        case 4...6:
            return "Erken Bebek Dönemi"
        case 7...12:
            return "Mobile Bebek Dönemi"
        case 13...24:
            return "Toddler Dönemi"
        case 25...36:
            return "Okul Öncesi"
        default:
            return "Çocuk Dönemi"
        }
    }
    
    private func getGrowthDescription(_ months: Int) -> String {
        switch months {
        case 0...3:
            return "Hızlı büyüme ve uyum dönemi"
        case 4...6:
            return "Sosyal gülümseme ve etkileşim"
        case 7...12:
            return "Emekleme ve ilk kelimeler"
        case 13...24:
            return "Yürüme ve dil gelişimi"
        case 25...36:
            return "Bağımsızlık ve oyun"
        default:
            return "Sosyal ve bildişsel gelişim"
        }
    }
}

// Modern Pregnancy Progress Card
struct ModernPregnancyProgressCard: View {
    let baby: Baby
    
    @State private var animateProgress = false
    
    var progressPercentage: Double {
        Double(baby.pregnancyWeek) / 40.0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🤰 Hamilelik Takibi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Bebeğinizin gelişimini takip edin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Week circle
                VStack {
                    Text("\(baby.pregnancyWeek)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.pregnancyPrimary)
                    
                    Text("HAFTA")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.pregnancyPrimary.opacity(0.7))
                }
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.pregnancySecondary)
                        .overlay(
                            Circle()
                                .stroke(Color.pregnancyPrimary.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            
            // Beautiful Progress Section
            VStack(spacing: 16) {
                HStack {
                    Text("İlerleme Durumu")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoal)
                    
                    Spacer()
                    
                    Text("%\(Int(progressPercentage * 100))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pregnancyPrimary)
                }
                
                // Custom animated progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pregnancySecondary.opacity(0.3))
                            .frame(height: 20)
                        
                        // Progress fill with gradient
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pregnancyGradient)
                            .frame(
                                width: animateProgress ? geometry.size.width * progressPercentage : 0,
                                height: 20
                            )
                            .overlay(
                                HStack {
                                    Spacer()
                                    Image(systemName: "heart.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .opacity(animateProgress ? 1.0 : 0)
                                    Spacer()
                                }
                            )
                            .animation(.easeInOut(duration: 1.5).delay(0.5), value: animateProgress)
                    }
                }
                .frame(height: 20)
                
                // Stats row
                HStack {
                    StatItem(
                        icon: "calendar",
                        title: "Kalan Süre",
                        value: "\(40 - baby.pregnancyWeek) hafta",
                        color: .pregnancyPrimary
                    )
                    
                    Spacer()
                    
                    StatItem(
                        icon: "clock",
                        title: "Trimester",
                        value: getTrimester(baby.pregnancyWeek),
                        color: .pregnancyAccent
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.pregnancyPrimary.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            animateProgress = true
        }
    }
    
    private func getTrimester(_ week: Int) -> String {
        switch week {
        case 1...12:
            return "1. Trimester"
        case 13...27:
            return "2. Trimester"
        case 28...40:
            return "3. Trimester"
        default:
            return "Doğum"
        }
    }
}

// Modern Baby Progress Card with gender-based colors
struct ModernBabyProgressCard: View {
    let baby: Baby
    let colorScheme: GenderColorScheme
    
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("👶 Bebek Gelişimi")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Yaşamının her anını kaydedin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Growth icon
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(colorScheme.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(colorScheme.secondary)
                    )
            }
            
            // Age display with beautiful design
            HStack(spacing: 24) {
                // Months
                VStack(spacing: 8) {
                    Text("\(baby.ageInMonths)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme.primary)
                        .scaleEffect(animateNumbers ? 1.0 : 0.5)
                        .opacity(animateNumbers ? 1.0 : 0)
                    
                    Text("AY")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme.primary.opacity(0.7))
                    
                    Text("Yaş")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme.secondary.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(colorScheme.primary.opacity(0.3), lineWidth: 1)
                        )
                )
                
                // Days
                VStack(spacing: 8) {
                    Text("\(baby.ageInDays)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme.accent)
                        .scaleEffect(animateNumbers ? 1.0 : 0.5)
                        .opacity(animateNumbers ? 1.0 : 0)
                    
                    Text("GÜN")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme.accent.opacity(0.7))
                    
                    Text("Toplam")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme.background.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(colorScheme.accent.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Milestone indicator
            HStack {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.coralPink)
                
                Text(getMilestone(baby.ageInMonths))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.charcoal)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.lightPeach.opacity(0.3))
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: colorScheme.primary.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.3)) {
                animateNumbers = true
            }
        }
    }
    
    private func getMilestone(_ months: Int) -> String {
        switch months {
        case 0...2:
            return "Gülümseme ve göz kontagı dönemi"
        case 3...5:
            return "Başını kaldırma ve tutma dönemi"
        case 6...8:
            return "Oturma ve ilk sözcükler"
        case 9...11:
            return "Emekleme ve ayakta durma"
        case 12...17:
            return "Yürüme ve kelime öğrenme"
        case 18...23:
            return "Koşma ve cümle kurma"
        case 24...35:
            return "Bağımsızlık ve sosyalleşme"
        default:
            return "Her gün yeni şeyler öğreniyor"
        }
    }
}

// Helper component for stats
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
    }
}



// Enhanced Today's Recommendations Card
struct ModernTodayRecommendationsCard: View {
    let baby: Baby
    
    @State private var animateRecommendations = false
    
    var recommendations: [Recommendation] {
        if baby.isPregnancy {
            return [
                Recommendation(
                    icon: "figure.walk",
                    title: "Günlük Yürüyüş",
                    description: "30 dakika hafif tempolu yürüyüş",
                    color: .pregnancyPrimary,
                    gradient: Color.pregnancyGradient
                ),
                Recommendation(
                    icon: "drop.fill",
                    title: "Su Tüketimi",
                    description: "Günde 8-10 bardak su için",
                    color: .oceanBlue,
                    gradient: Color.babyGradient
                ),
                Recommendation(
                    icon: "pills.circle.fill",
                    title: "Vitamin Desteği",
                    description: "Folik asit ve vitamin takviyesi",
                    color: .mintGreen,
                    gradient: Color.developmentGradient
                )
            ]
        } else {
            return [
                Recommendation(
                    icon: "gamecontroller.fill",
                    title: "Gelişim Oyunları",
                    description: "Yaşa uygun duyusal aktiviteler",
                    color: .coralPink,
                    gradient: Color.activityGradient
                ),
                Recommendation(
                    icon: "book.closed.fill",
                    title: "Okuma Zamanı",
                    description: "15 dakika hikaye okuma",
                    color: .babyPrimary,
                    gradient: Color.babyGradient
                ),
                Recommendation(
                    icon: "moon.zzz.fill",
                    title: "Uyku Düzeni",
                    description: "Düzenli uyku saatleri",
                    color: .lilacPurple,
                    gradient: Color.sleepGradient
                )
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with time-based greeting
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎆 Bugünün Önerileri")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text(getTimeBasedMessage())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Current time indicator
                VStack {
                    Text(getCurrentTime())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.buttercream)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.charcoal.opacity(0.8))
                        )
                }
            }
            
            // Recommendations list
            VStack(spacing: 12) {
                ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                    ModernRecommendationRow(recommendation: recommendation)
                        .opacity(animateRecommendations ? 1.0 : 0)
                        .offset(x: animateRecommendations ? 0 : 50)
                        .animation(
                            .easeOut(duration: 0.6).delay(Double(index) * 0.2),
                            value: animateRecommendations
                        )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.buttercream.opacity(0.6), Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.warningOrange.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            animateRecommendations = true
        }
    }
    
    private func getTimeBasedMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Sabah rutininize başlayın"
        case 12..<17:
            return "Öğlen aktiviteleriniz için hazır"
        case 17..<21:
            return "Akşam dinlenme zamanı"
        default:
            return "Rahat bir gece geçirin"
        }
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: Date())
    }
}

// Recommendation data model
struct Recommendation {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let gradient: LinearGradient
}

// Modern Recommendation Row
struct ModernRecommendationRow: View {
    let recommendation: Recommendation
    
    @State private var isCompleted = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            Image(systemName: recommendation.icon)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(recommendation.gradient)
                        .shadow(color: recommendation.color.opacity(0.3), radius: 6, x: 0, y: 3)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                    .strikethrough(isCompleted)
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isCompleted ? 0.6 : 1.0)
            }
            
            Spacer()
            
            // Completion toggle
            Button(action: {
                HapticFeedback.lightImpact()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    isCompleted.toggle()
                }
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .successGreen : .coolGray)
                    .scaleEffect(isCompleted ? 1.1 : 1.0)
            }
        }
        .padding(.vertical, 8)
        .opacity(isCompleted ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isCompleted)
    }
}

#Preview {
    DashboardView()
}
