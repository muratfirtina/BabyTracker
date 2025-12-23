import SwiftUI

struct DevelopmentView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @State private var selectedTab = 0
    @State private var animateContent = false
    @State private var showGrowthTracking = false
    
    var baby: Baby {
        babyDataManager.currentBaby
    }
    
    // Gender-based color scheme
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(baby.gender)
    }
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                genderColorScheme.gradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    ModernDevelopmentHeader(baby: baby, colorScheme: genderColorScheme)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : -30)
                        .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                    
                    // Modern Tab Selector
                    ModernTabSelector(
                        selectedTab: $selectedTab,
                        showGrowthTracking: $showGrowthTracking,
                        colorScheme: genderColorScheme
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : -20)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Content
                    ModernDevelopmentStagesView(baby: baby, colorScheme: genderColorScheme)
                        .opacity(animateContent ? 1.0 : 0)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: animateContent)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showGrowthTracking) {
                GrowthTrackingView()
                    .environmentObject(babyDataManager)
            }
        }
        .onAppear {
            animateContent = true
        }
    }
}

// Modern Development Header
struct ModernDevelopmentHeader: View {
    let baby: Baby
    let colorScheme: GenderColorScheme
    
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📊 Gelişim Takibi")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Text(baby.isPregnancy ? "Hamilelik döneminde gelişim" : "Bebeğinizin büyüme yolculuğu")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Development icon with animation
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .rotationEffect(.degrees(animateIcon ? 0 : -15))
                    .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.5), value: animateIcon)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [colorScheme.primary, colorScheme.accent],
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
}

// Modern Tab Selector
struct ModernTabSelector: View {
    @Binding var selectedTab: Int
    @Binding var showGrowthTracking: Bool
    let colorScheme: GenderColorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            ModernTabButton(
                title: "Gelişim Aşamaları",
                icon: "figure.child",
                isSelected: selectedTab == 0,
                color: colorScheme.primary
            ) {
                HapticFeedback.selection()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedTab = 0
                }
            }
            
            ModernTabButton(
                title: "Büyüme Grafiği",
                icon: "chart.xyaxis.line",
                isSelected: false,
                color: colorScheme.accent
            ) {
                HapticFeedback.selection()
                showGrowthTracking = true
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: colorScheme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct ModernTabButton: View {
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

// Modern Development Stages View
struct ModernDevelopmentStagesView: View {
    let baby: Baby
    let colorScheme: GenderColorScheme
    
    @State private var animateCards = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if baby.isPregnancy {
                    ModernPregnancyDevelopmentSection(
                        pregnancyWeek: baby.pregnancyWeek,
                        colorScheme: colorScheme
                    )
                } else {
                    ModernBabyDevelopmentSection(
                        ageInMonths: baby.ageInMonths,
                        colorScheme: colorScheme
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .opacity(animateCards ? 1.0 : 0)
        .animation(.easeOut(duration: 0.8).delay(0.2), value: animateCards)
        .onAppear {
            animateCards = true
        }
    }
}

// Modern Pregnancy Development Section
struct ModernPregnancyDevelopmentSection: View {
    let pregnancyWeek: Int
    let colorScheme: GenderColorScheme
    
    @State private var animateProgress = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Week Progress Card
            ModernWeekProgressCard(
                week: pregnancyWeek,
                colorScheme: colorScheme
            )
            
            // Development Cards
            VStack(spacing: 16) {
                ModernDevelopmentCard(
                    title: "Bu Haftaki Gelişmeler",
                    icon: "figure.child",
                    items: getDevelopments(for: pregnancyWeek),
                    color: .pregnancyPrimary,
                    iconColor: .successGreen
                )
                
                ModernDevelopmentCard(
                    title: "Annenin Değişimleri",
                    icon: "heart.fill",
                    items: getMotherChanges(for: pregnancyWeek),
                    color: .pregnancyAccent,
                    iconColor: .coralPink
                )
                
                ModernDevelopmentCard(
                    title: "Bu Hafta İçin Öneriler",
                    icon: "lightbulb.fill",
                    items: getRecommendations(for: pregnancyWeek),
                    color: .pregnancySecondary,
                    iconColor: .warningOrange
                )
            }
        }
    }
    
    private func getBabySize(for week: Int) -> String {
        let sizes = [
            4: "Haşhaş tanesi",
            8: "Böğürtlen",
            12: "Kayısı",
            16: "Elma",
            20: "Muz",
            24: "Mısır koçanı",
            28: "Patlıcan",
            32: "Hindistan cevizi",
            36: "Kavun",
            40: "Karpuz"
        ]
        
        let closestWeek = sizes.keys.sorted().last { $0 <= week } ?? 4
        return sizes[closestWeek] ?? "Karpuz"
    }
    
    private func getDevelopments(for week: Int) -> [String] {
        switch week {
        case 4...8:
            return [
                "Kalp atışları başladı",
                "Temel organ gelişimi",
                "Sinir sistemi oluşuyor"
            ]
        case 9...12:
            return [
                "Parmaklar belirginleşti",
                "Yüz hatları oluşuyor",
                "Refleksler gelişiyor"
            ]
        case 13...16:
            return [
                "Cinsiyet belirginleşiyor",
                "Kemikler sertleşiyor",
                "Dış kulak oluşuyor"
            ]
        case 17...20:
            return [
                "Bebek hareketleri hissediliyor",
                "Saçlar çıkıyor",
                "Yutkunma başladı"
            ]
        case 21...24:
            return [
                "Duyu organları aktif",
                "Akciğer gelişimi",
                "Düzenli uyku-uyanıklık döngüsü"
            ]
        case 25...28:
            return [
                "Gözler açılıyor",
                "Beyin hızla gelişiyor",
                "Yaşam şansı artıyor"
            ]
        case 29...32:
            return [
                "Kemikler sertleşiyor",
                "Yağ tabakası oluşuyor",
                "Doğum pozisyonu alıyor"
            ]
        case 33...36:
            return [
                "Akciğerler olgunlaşıyor",
                "Kilo alımı hızlanıyor",
                "Bağışıklık sistemi güçleniyor"
            ]
        default:
            return [
                "Doğuma tam hazır",
                "Tüm organlar olgun",
                "Doğum pozisyonunda"
            ]
        }
    }
    
    private func getMotherChanges(for week: Int) -> [String] {
        switch week {
        case 4...8:
            return [
                "Mide bulantısı başlayabilir",
                "Göğüslerde hassasiyet",
                "Yorgunluk hissi"
            ]
        case 9...12:
            return [
                "Kilo artışı başlıyor",
                "Bulantı azalmaya başlıyor",
                "Enerji artışı"
            ]
        case 13...16:
            return [
                "Karın belirginleşiyor",
                "Cilt değişiklikleri",
                "İştah artışı"
            ]
        case 17...20:
            return [
                "Bebek hareketleri hissediliyor",
                "Kilo alımı hızlanıyor",
                "Saçlarda değişim"
            ]
        case 21...24:
            return [
                "Karın büyüyor",
                "Sırt ağrıları başlayabilir",
                "Uykusuzluk problemi"
            ]
        case 25...28:
            return [
                "Nefes darlığı",
                "Ayaklarda şişlik",
                "Sık idrara çıkma"
            ]
        case 29...32:
            return [
                "Karın sertleşmeleri",
                "Mide yanması",
                "Yorgunluk artışı"
            ]
        case 33...36:
            return [
                "Doğum belirtileri yaklaşıyor",
                "Pelvis bölgesinde basınç",
                "Uyku problemleri"
            ]
        default:
            return [
                "Doğum yaklaşıyor",
                "Düzenli kasılmalar",
                "Su gelmesi mümkün"
            ]
        }
    }
    
    private func getRecommendations(for week: Int) -> [String] {
        switch week {
        case 4...8:
            return [
                "Folik asit takviyesi alın",
                "Sigarayı bırakın",
                "Bol dinlenin"
            ]
        case 9...12:
            return [
                "Düzenli egzersiz yapın",
                "Sağlıklı beslenin",
                "Doktor kontrolünü aksatmayın"
            ]
        case 13...16:
            return [
                "Kalsiyum alımını artırın",
                "Rahat giysiler giyin",
                "Stres yönetimi yapın"
            ]
        case 17...20:
            return [
                "Bebek hareketlerini takip edin",
                "Yeterli protein alın",
                "Düzenli yürüyüş yapın"
            ]
        case 21...24:
            return [
                "Şeker testini yaptırın",
                "Doğum kursuna katılın",
                "Kilo kontrolü yapın"
            ]
        case 25...28:
            return [
                "Demir eksikliği kontrolü",
                "Ayaklarınızı yükseltin",
                "Bol su için"
            ]
        case 29...32:
            return [
                "Doğum planını hazırlayın",
                "Hastane çantasını hazırlayın",
                "Strep B testi yaptırın"
            ]
        case 33...36:
            return [
                "Doğum belirtilerini öğrenin",
                "Doktor ile iletişimi artırın",
                "Bebeğin odasını hazırlayın"
            ]
        default:
            return [
                "Doğuma hazır olun",
                "Acil durum planını bilin",
                "Rahat nefes alma egzersizleri"
            ]
        }
    }
}

// Modern Baby Development Section
struct ModernBabyDevelopmentSection: View {
    let ageInMonths: Int
    let colorScheme: GenderColorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            // Age Progress Card
            ModernAgeProgressCard(
                ageInMonths: ageInMonths,
                colorScheme: colorScheme
            )
            
            // Development Cards
            VStack(spacing: 16) {
                ModernDevelopmentCard(
                    title: "Fiziksel Gelişim",
                    icon: "figure.walk",
                    items: getPhysicalDevelopment(for: ageInMonths),
                    color: colorScheme.primary,
                    iconColor: .oceanBlue
                )
                
                ModernDevelopmentCard(
                    title: "Bilişsel Beceriler",
                    icon: "brain.head.profile",
                    items: getCognitiveSkills(for: ageInMonths),
                    color: colorScheme.accent,
                    iconColor: .lilacPurple
                )
                
                ModernDevelopmentCard(
                    title: "Sosyal Beceriler",
                    icon: "person.2.fill",
                    items: getSocialSkills(for: ageInMonths),
                    color: colorScheme.secondary,
                    iconColor: .coralPink
                )
                
                ModernDevelopmentCard(
                    title: "Bu Ay İçin Öneriler",
                    icon: "lightbulb.fill",
                    items: getMonthlyRecommendations(for: ageInMonths),
                    color: .mintGreen,
                    iconColor: .warningOrange
                )
            }
        }
    }
    
    private func getPhysicalDevelopment(for months: Int) -> [String] {
        switch months {
        case 0:
            return [
                "Doğum kilosu ve boyu kaydedilir",
                "Başını kaldıramaz",
                "Refleksler aktif"
            ]
        case 1:
            return [
                "Baş kontrolü gelişmeye başlar",
                "Göz kontakı kurar",
                "Kilo alımı hızlanır"
            ]
        case 2:
            return [
                "Gülümser",
                "Başını daha iyi kaldırır",
                "Ellerini ağzına götürür"
            ]
        case 3:
            return [
                "Başını 45 derece kaldırır",
                "Seslere tepki verir",
                "Elleriyle oyuncak tutar"
            ]
        case 4:
            return [
                "Destekle oturur",
                "Çifte sesler çıkarır",
                "Objeleri yakalar"
            ]
        case 5:
            return [
                "Desteksiz oturmaya başlar",
                "Katı gıdalara geçiş",
                "Transfer hareketleri"
            ]
        case 6:
            return [
                "Oturur",
                "Katı gıda yer",
                "İki elli oyuncak kullanır"
            ]
        case 7...8:
            return [
                "Emeklemeye başlar",
                "Ayakta durur (destekle)",
                "Parmakla beslenme"
            ]
        case 9...11:
            return [
                "Ayakta durur",
                "İlk adımlar",
                "Kaba motor beceriler gelişir"
            ]
        case 12...18:
            return [
                "Bağımsız yürür",
                "Koşmaya başlar",
                "Merdiven çıkar"
            ]
        case 19...24:
            return [
                "Güvenle koşar",
                "Zıplayabilir",
                "Top atar ve yakalar"
            ]
        case 25...36:
            return [
                "Üç tekerlekli bisiklet sürer",
                "Merdivenler güvenle çıkar",
                "İnce motor beceriler gelişir"
            ]
        case 37...48:
            return [
                "Tek ayak üzerinde durur",
                "Makasla keser",
                "Çizgi çizer"
            ]
        case 49...60:
            return [
                "Bisiklet sürer",
                "Yazı yazmaya başlar",
                "Karmaşık hareketler yapar"
            ]
        default:
            return [
                "Tam gelişmiş motor beceriler",
                "Spor aktiviteleri yapabilir",
                "Koordinasyon mükemmel"
            ]
        }
    }
    
    private func getCognitiveSkills(for months: Int) -> [String] {
        switch months {
        case 0...3:
            return [
                "Yüzleri tanır",
                "Sesleri takip eder",
                "Temel refleksler"
            ]
        case 4...6:
            return [
                "Nedeni sonucu anlama başlar",
                "Obje kalıcılığı gelişir",
                "Taklit etmeye başlar"
            ]
        case 7...12:
            return [
                "Problem çözme becerileri",
                "Kelime anlama",
                "İlk kelimeler"
            ]
        case 13...18:
            return [
                "50-100 kelime söyler",
                "İki kelimeli cümleler",
                "Basit talimatları anlar"
            ]
        case 19...24:
            return [
                "200+ kelime söyler",
                "Karmaşık talimatları anlar",
                "Hayal gücü gelişir"
            ]
        case 25...36:
            return [
                "1000+ kelime söyler",
                "Karmaşık cümleler kurar",
                "Sayıları öğrenir"
            ]
        case 37...48:
            return [
                "Hikaye anlatır",
                "Soyut kavramları anlar",
                "Okuma hazırlığı"
            ]
        case 49...60:
            return [
                "Okumaya başlar",
                "Matematik becerileri",
                "Mantıksal düşünme"
            ]
        default:
            return [
                "İleri düzey düşünme",
                "Analitik beceriler",
                "Yaratıcı problem çözme"
            ]
        }
    }
    
    private func getSocialSkills(for months: Int) -> [String] {
        switch months {
        case 0...3:
            return [
                "Göz kontakı kurar",
                "Sosyal gülümseme",
                "Anne-baba tanıma"
            ]
        case 4...6:
            return [
                "Diğer bebeklerle ilgilenme",
                "Yabancı kaygısı",
                "Basit sosyal oyunlar"
            ]
        case 7...12:
            return [
                "Taklit oyunları",
                "Sosyal sinyalleri anlama",
                "Oyuncak paylaşımı"
            ]
        case 13...18:
            return [
                "Bağımsızlık isteği",
                "Diğer çocuklarla oynama",
                "Empati gösterme"
            ]
        case 19...24:
            return [
                "Paralel oyun",
                "Paylaşım öğrenme",
                "Duygusal ifade"
            ]
        case 25...36:
            return [
                "Birlikte oyun oynama",
                "Arkadaşlık kurma",
                "Sosyal kuralları öğrenme"
            ]
        case 37...48:
            return [
                "Grup oyunları",
                "İşbirliği yapma",
                "Çatışma çözme"
            ]
        case 49...60:
            return [
                "Karmaşık sosyal ilişkiler",
                "Liderlik becerileri",
                "Team çalışması"
            ]
        default:
            return [
                "Olgun sosyal beceriler",
                "Empati ve anlayış",
                "Sosyal sorumluluk"
            ]
        }
    }
    
    private func getMonthlyRecommendations(for months: Int) -> [String] {
        switch months {
        case 0...3:
            return [
                "Düzenli uyku programı oluşturun",
                "Bol bol konuşun ve okuyun",
                "Tummy time uygulayın"
            ]
        case 4...6:
            return [
                "Emzirmeye devam edin",
                "Güvenli oyuncaklar verin",
                "Sesli oyunlar oynayın"
            ]
        case 7...12:
            return [
                "Güvenli keşif ortamı sağlayın",
                "Parmak yemekleri verin",
                "Okuma alışkanlığı oluşturun"
            ]
        case 13...18:
            return [
                "Açık hava aktiviteleri",
                "Konuşma gelişimini destekleyin",
                "Yaratıcı oyunlara yönlendirin"
            ]
        case 19...24:
            return [
                "Sosyal aktivitelere katılın",
                "Sanat ve zanaat aktiviteleri",
                "Müzik ve dans"
            ]
        case 25...36:
            return [
                "Okul öncesi hazırlık",
                "Bağımsızlık becerilerini destekleyin",
                "Tuvalet eğitimi başlatın"
            ]
        case 37...48:
            return [
                "Eğitim oyunları oynayın",
                "Arkadaşlık ilişkilerini destekleyin",
                "Hobiler geliştirin"
            ]
        case 49...60:
            return [
                "Okul hazırlığı yapın",
                "Sorumluluk verin",
                "Spor aktivitelerine katılın"
            ]
        default:
            return [
                "Yeteneklerini keşfetmesine yardım edin",
                "Değer eğitimi verin",
                "Özgüven geliştirin"
            ]
        }
    }
}

// Modern Week Progress Card
struct ModernWeekProgressCard: View {
    let week: Int
    let colorScheme: GenderColorScheme
    
    @State private var animateProgress = false
    
    var progressPercentage: Double {
        Double(week) / 40.0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(week). Hamilelik Haftası")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Bebeğinizin boyutu: \(getBabySize(for: week))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(week)")
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
            
            // Progress Bar
            VStack(spacing: 12) {
                HStack {
                    Text("Hamilelik İlerlemesi")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.charcoal)
                    
                    Spacer()
                    
                    Text("%\(Int(progressPercentage * 100))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.pregnancyPrimary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.pregnancySecondary.opacity(0.3))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.pregnancyGradient)
                            .frame(
                                width: animateProgress ? geometry.size.width * progressPercentage : 0,
                                height: 16
                            )
                            .animation(.easeInOut(duration: 1.5).delay(0.5), value: animateProgress)
                    }
                }
                .frame(height: 16)
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
    
    private func getBabySize(for week: Int) -> String {
        let sizes = [
            4: "Haşhaş tanesi",
            8: "Böğürtlen",
            12: "Kayısı",
            16: "Elma",
            20: "Muz",
            24: "Mısır koçanı",
            28: "Patlıcan",
            32: "Hindistan cevizi",
            36: "Kavun",
            40: "Karpuz"
        ]
        
        let closestWeek = sizes.keys.sorted().last { $0 <= week } ?? 4
        return sizes[closestWeek] ?? "Karpuz"
    }
}

// Modern Age Progress Card
struct ModernAgeProgressCard: View {
    let ageInMonths: Int
    let colorScheme: GenderColorScheme
    
    @State private var animateNumbers = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(ageInMonths). Ay Gelişimi")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text(getAgeDescription(ageInMonths))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(ageInMonths)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme.primary)
                        .scaleEffect(animateNumbers ? 1.0 : 0.8)
                        .opacity(animateNumbers ? 1.0 : 0)
                    
                    Text("AYLIK")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme.primary.opacity(0.7))
                }
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(colorScheme.secondary)
                        .overlay(
                            Circle()
                                .stroke(colorScheme.primary.opacity(0.3), lineWidth: 2)
                        )
                )
            }
            
            // Milestone indicator
            HStack {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.coralPink)
                
                Text(getMilestone(ageInMonths))
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
    
    private func getAgeDescription(_ months: Int) -> String {
        switch months {
        case 0...3:
            return "Yenidoğan dönemi - Hızlı büyüme"
        case 4...6:
            return "Erken bebek dönemi - Sosyal etkileşim"
        case 7...12:
            return "Mobile bebek dönemi - Hareket"
        case 13...24:
            return "Toddler dönemi - Bağımsızlık"
        case 25...36:
            return "Okul öncesi - Yaratıcılık"
        default:
            return "Çocuk dönemi - Sosyal gelişim"
        }
    }
    
    private func getMilestone(_ months: Int) -> String {
        switch months {
        case 0...2:
            return "Gülümseme ve göz kontağı dönemi"
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

// Modern Development Card
struct ModernDevelopmentCard: View {
    let title: String
    let icon: String
    let items: [String]
    let color: Color
    let iconColor: Color
    
    @State private var animateItems = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [iconColor, iconColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: iconColor.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("\(items.count) önemli gelişim")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Items
            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(iconColor.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.charcoal)
                            .lineLimit(nil)
                    }
                    .opacity(animateItems ? 1.0 : 0)
                    .offset(x: animateItems ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.6).delay(Double(index) * 0.1),
                        value: animateItems
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            animateItems = true
        }
    }
}

#Preview {
    DevelopmentView()
}
