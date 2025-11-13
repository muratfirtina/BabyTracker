import SwiftUI

struct VaccinationView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @EnvironmentObject var vaccinationDataManager: VaccinationDataManager
    @State private var animateContent = false
    @State private var showNotification = false
    @State private var notificationMessage = ""
    
    private var baby: Baby {
        babyDataManager.currentBaby
    }
    
    private var vaccines: [Vaccination] {
        vaccinationDataManager.vaccines
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful background
                LinearGradient(
                    colors: [
                        Color.lightPeach.opacity(0.3),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    if baby.isPregnancy {
                        PregnancyVaccineInfoView()
                            .opacity(animateContent ? 1.0 : 0)
                            .offset(y: animateContent ? 0 : 30)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateContent)
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Enhanced Progress Section
                                ModernVaccinationProgressSection(baby: baby, vaccines: vaccines)
                                    .opacity(animateContent ? 1.0 : 0)
                                    .offset(y: animateContent ? 0 : 30)
                                    .animation(.easeOut(duration: 0.8).delay(0.1), value: animateContent)
                                
                                // Vaccine Cards with stunning design
                                LazyVStack(spacing: 16) {
                                    ForEach(Array(vaccines.enumerated()), id: \.offset) { index, vaccine in
                                        ModernVaccinationCard(
                                            vaccine: vaccine,
                                            baby: baby,
                                            onToggle: {
                                                toggleVaccination(vaccine)
                                            }
                                        )
                                        .opacity(animateContent ? 1.0 : 0)
                                        .offset(y: animateContent ? 0 : 20)
                                        .animation(
                                            .easeOut(duration: 0.6).delay(0.2 + Double(index) * 0.1),
                                            value: animateContent
                                        )
                                    }
                                }
                                
                                // Bottom spacing
                                Spacer(minLength: 80)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                    }
                }
                
                // Notification banner
                if showNotification {
                    VStack {
                        VaccinationNotificationBanner(
                            message: notificationMessage,
                            type: .success,
                            action: {
                                showNotification = false
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Aşı Takvimi")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            animateContent = true
        }
    }
    
    private func toggleVaccination(_ vaccine: Vaccination) {
        HapticFeedback.lightImpact()
        vaccinationDataManager.toggleVaccination(vaccine)
        
        // Show success notification
        if vaccine.isCompleted {
            notificationMessage = "\(vaccine.name) aşısı tamamlandı olarak işaretlendi! 🎉"
        } else {
            notificationMessage = "\(vaccine.name) aşısı tamamlanmadı olarak işaretlendi."
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showNotification = true
        }
        
        // Auto-hide notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showNotification = false
            }
        }
    }
}

// Enhanced Progress Section with beautiful design
struct ModernVaccinationProgressSection: View {
    let baby: Baby
    let vaccines: [Vaccination]
    
    @State private var animateProgress = false
    
    private var completedVaccines: Int {
        vaccines.filter { $0.isCompleted }.count
    }
    
    private var overdueVaccines: [Vaccination] {
        vaccines.filter { vaccine in
            !vaccine.isCompleted && vaccine.ageInMonths <= baby.ageInMonths
        }
    }
    
    private var upcomingVaccines: [Vaccination] {
        vaccines.filter { vaccine in
            !vaccine.isCompleted && vaccine.ageInMonths > baby.ageInMonths && vaccine.ageInMonths <= baby.ageInMonths + 2
        }
    }
    
    private var completionPercentage: Double {
        Double(completedVaccines) / Double(vaccines.count)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with beautiful typography
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💉 Aşı Durumu")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                    
                    Text("Bebeğinizin aşı programını takip edin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Completion ring
                VaccinationProgressRing(
                    progress: animateProgress ? completionPercentage : 0,
                    color: Color.roseGold,
                    lineWidth: 6,
                    size: 60
                )
            }
            
            // Stats row with beautiful cards
            HStack(spacing: 16) {
                VaccinationStatCard(
                    title: "Tamamlanan",
                    value: "\(completedVaccines)",
                    subtitle: "/\(vaccines.count) aşı",
                    color: .successGreen,
                    icon: "checkmark.circle.fill"
                )
                
                VaccinationStatCard(
                    title: "Geciken",
                    value: "\(overdueVaccines.count)",
                    subtitle: "aşı var",
                    color: .errorRed,
                    icon: "exclamationmark.triangle.fill"
                )
                
                VaccinationStatCard(
                    title: "Yaklaşan",
                    value: "\(upcomingVaccines.count)",
                    subtitle: "aşı var",
                    color: .warningOrange,
                    icon: "clock.fill"
                )
            }
            
            // Alert cards for overdue and upcoming vaccines
            if !overdueVaccines.isEmpty {
                ModernAlertCard(
                    title: "Geciken Aşılar",
                    message: "\(overdueVaccines.count) adet aşınız gecikmiş durumda. Lütfen doktorunuzla iletişime geçin.",
                    color: .errorRed,
                    icon: "exclamationmark.triangle.fill"
                )
                .opacity(animateProgress ? 1.0 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.5), value: animateProgress)
            }
            
            if !upcomingVaccines.isEmpty {
                ModernAlertCard(
                    title: "Yaklaşan Aşılar",
                    message: "\(upcomingVaccines.count) adet aşınızın zamanı yaklaşıyor. Randevu almayı unutmayın.",
                    color: .warningOrange,
                    icon: "clock.fill"
                )
                .opacity(animateProgress ? 1.0 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.7), value: animateProgress)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.roseGold.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateProgress = true
            }
        }
    }
}

// Vaccination Stat Card
struct VaccinationStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.charcoal)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
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

// Modern Alert Card
struct ModernAlertCard: View {
    let title: String
    let message: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.1), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Modern Vaccination Card
struct ModernVaccinationCard: View {
    let vaccine: Vaccination
    let baby: Baby
    let onToggle: () -> Void
    
    @State private var isExpanded = false
    @State private var isPressed = false
    
    private var vaccinationStatus: VaccinationStatus {
        if vaccine.isCompleted {
            return .completed
        } else if vaccine.ageInMonths <= baby.ageInMonths {
            return .overdue
        } else if vaccine.ageInMonths <= baby.ageInMonths + 1 {
            return .upcoming
        } else {
            return .future
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(vaccine.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                        
                        Text(getAgeText())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        ModernStatusBadge(status: vaccinationStatus)
                        
                        if vaccine.isCompleted, let date = vaccine.completionDate {
                            Text(DateFormatter.short.string(from: date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Description
                Text(vaccine.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
                
                // Expand button
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(isExpanded ? "Daha az göster" : "Detayları göster")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.roseGold)
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundColor(Color.roseGold)
                    }
                }
                
                // Action button
                if !vaccine.isCompleted && vaccinationStatus != .future {
                    Button(action: {
                        HapticFeedback.success()
                        onToggle()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            
                            Text("Tamamlandı Olarak İşaretle")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.successGreen, .successGreen.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .successGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                }
            }
            .padding(20)
            
            // Expanded details
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .background(Color.coolGray.opacity(0.3))
                    
                    VaccinationDetailSection(title: "Önem", content: vaccine.importance)
                    
                    if !vaccine.sideEffects.isEmpty {
                        VaccinationDetailSection(
                            title: "Olası Yan Etkiler",
                            content: vaccine.sideEffects.joined(separator: "\n• ")
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: -10)),
                    removal: .opacity.combined(with: .offset(y: -10))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(getBorderGradient(), lineWidth: 2)
                )
                .shadow(
                    color: vaccinationStatus.color.opacity(0.15),
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
    }
    
    private func getAgeText() -> String {
        if vaccine.ageInMonths == 0 {
            return "Doğumda"
        } else {
            return "\(vaccine.ageInMonths). ay"
        }
    }
    
    private func getBorderGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                vaccinationStatus.color.opacity(0.6),
                vaccinationStatus.color.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Modern Status Badge
struct ModernStatusBadge: View {
    let status: VaccinationStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: status.icon)
                .font(.caption2)
                .fontWeight(.semibold)
            
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [status.color, status.color.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: status.color.opacity(0.4), radius: 4, x: 0, y: 2)
        )
    }
}

// Vaccination Detail Section
struct VaccinationDetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.charcoal)
            
            Text(content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
    }
}

// Enhanced Pregnancy Vaccine Info View
struct PregnancyVaccineInfoView: View {
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Hero section
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.pregnancyPrimary.opacity(0.2), Color.pregnancyPrimary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateContent ? 1.0 : 0.8)
                        .opacity(animateContent ? 1.0 : 0)
                    
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(.pregnancyPrimary)
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                }
                .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateContent)
                
                VStack(spacing: 12) {
                    Text("Hamilelik Döneminde Aşılar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.charcoal)
                        .multilineTextAlignment(.center)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text("Bebeğiniz doğduktan sonra aşı takvimi burada görünecek. Şu anda hamilelik döneminde anneler için önemli bilgiler:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .padding(.horizontal, 20)
                        .opacity(animateContent ? 1.0 : 0)
                        .offset(y: animateContent ? 0 : 15)
                }
                .animation(.easeOut(duration: 0.8).delay(0.4), value: animateContent)
            }
            
            // Pregnancy vaccines info cards
            VStack(spacing: 16) {
                ForEach(Array(pregnancyVaccines.enumerated()), id: \.offset) { index, vaccine in
                    PregnancyVaccineCard(
                        vaccine: vaccine.vaccine,
                        timing: vaccine.timing,
                        importance: vaccine.importance,
                        color: vaccine.color,
                        icon: vaccine.icon
                    )
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    .animation(
                        .easeOut(duration: 0.8).delay(0.6 + Double(index) * 0.2),
                        value: animateContent
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            animateContent = true
        }
    }
    
    private var pregnancyVaccines: [(vaccine: String, timing: String, importance: String, color: Color, icon: String)] {
        [
            (
                vaccine: "Tetanos-Difteri",
                timing: "20. hafta sonrası",
                importance: "Bebeği tetanos ve difteriden korur",
                color: .roseGold,
                icon: "shield.fill"
            ),
            (
                vaccine: "Boğmaca (Tdap)",
                timing: "27-36. hafta arası",
                importance: "Bebeği doğumdan sonraki ilk aylarda boğmacadan korur",
                color: .coralPink,
                icon: "heart.circle.fill"
            ),
            (
                vaccine: "Grip Aşısı",
                timing: "Grip sezonu boyunca",
                importance: "Anne ve bebeği grip komplikasyonlarından korur",
                color: .oceanBlue,
                icon: "thermometer"
            )
        ]
    }
}

// Pregnancy Vaccine Card
struct PregnancyVaccineCard: View {
    let vaccine: String
    let timing: String
    let importance: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(vaccine)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                
                Text("Zamanı: \(timing)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                
                Text(importance)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// Enhanced Vaccination Status enum
enum VaccinationStatus: String {
    case completed = "Tamamlandı"
    case overdue = "Gecikmiş"
    case upcoming = "Yaklaşıyor"
    case future = "Gelecek"
    
    var color: Color {
        switch self {
        case .completed:
            return .successGreen
        case .overdue:
            return .errorRed
        case .upcoming:
            return .warningOrange
        case .future:
            return .coolGray
        }
    }
    
    var icon: String {
        switch self {
        case .completed:
            return "checkmark.circle.fill"
        case .overdue:
            return "exclamationmark.triangle.fill"
        case .upcoming:
            return "clock.fill"
        case .future:
            return "calendar"
        }
    }
}

// Enhanced DateFormatter
extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
}

// Local Progress Ring Component for Vaccination View
struct VaccinationProgressRing: View {
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
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.5).delay(0.3), value: animateProgress)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
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

// Local Notification Banner Component for Vaccination View
struct VaccinationNotificationBanner: View {
    let message: String
    let type: VaccinationBannerType
    let showCloseButton: Bool
    let action: (() -> Void)?
    
    @State private var animateIn = false
    @State private var isVisible = true
    
    enum VaccinationBannerType {
        case success
        case warning
        case error
        case info
        
        var color: Color {
            switch self {
            case .success: return .successGreen
            case .warning: return .warningOrange
            case .error: return .errorRed
            case .info: return .infoBlue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    init(
        message: String,
        type: VaccinationBannerType,
        showCloseButton: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.type = type
        self.showCloseButton = showCloseButton
        self.action = action
    }
    
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                if showCloseButton {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            action?()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [type.color, type.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: type.color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .offset(y: animateIn ? 0 : -100)
            .opacity(animateIn ? 1.0 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateIn)
            .onAppear {
                animateIn = true
                
                // Auto dismiss after 5 seconds for non-error types
                if type != .error {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            isVisible = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            action?()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VaccinationView()
}
