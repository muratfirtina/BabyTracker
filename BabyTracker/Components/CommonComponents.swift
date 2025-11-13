import SwiftUI

// 🎨 Modern UI Components for Baby Tracker

// Enhanced Progress Card with beautiful animations
struct ProgressCard: View {
    let title: String
    let current: Int
    let total: Int
    let color: Color
    let icon: String
    let gradient: LinearGradient?
    
    @State private var animateProgress = false
    
    var percentage: Double {
        guard total > 0 else { return 0 }

// 🌟 Premium Visual Components

// Glassmorphism Container
struct GlassmorphismContainer<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let opacity: Double
    
    init(
        cornerRadius: CGFloat = 20,
        opacity: Double = 0.1,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(opacity))
                    .background(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

// Animated Progress Ring
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animateProgress = false
    
    init(
        progress: Double,
        color: Color = .babyPrimary,
        lineWidth: CGFloat = 8,
        size: CGFloat = 60
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.size = size
    }
    
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

// Notification Banner
struct NotificationBanner: View {
    let message: String
    let type: BannerType
    let showCloseButton: Bool
    let action: (() -> Void)?
    
    @State private var animateIn = false
    @State private var isVisible = true
    
    enum BannerType {
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
        type: BannerType,
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
                        withAnimation(.easeInOut(duration: 0.3)) {
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
        return Double(current) / Double(total)
    }
    
    init(
        title: String, 
        current: Int, 
        total: Int, 
        color: Color, 
        icon: String,
        gradient: LinearGradient? = nil
    ) {
        self.title = title
        self.current = current
        self.total = total
        self.color = color
        self.icon = icon
        self.gradient = gradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and stats
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(
                                    gradient ?? LinearGradient(
                                        colors: [color, color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.charcoal)
                        
                        Text("\(current) / \(total) tamamlandı")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Percentage display
                VStack(alignment: .trailing, spacing: 2) {
                    Text("%\(Int(percentage * 100))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                    
                    Text("Tamamlanan")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Animated Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("İlerleme")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.charcoal)
                    
                    Spacer()
                    
                    Text("\(current)/\(total)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(color)
                }
                
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(height: 12)
                    
                    // Progress fill with animation
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            gradient ?? LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateProgress ? CGFloat(percentage) * UIScreen.main.bounds.width * 0.7 : 0, height: 12)
                        .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
                        .animation(.easeInOut(duration: 1.2).delay(0.3), value: animateProgress)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, color.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            animateProgress = true
        }
    }
}

// Enhanced Info Card with modern design
struct InfoCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    let gradient: LinearGradient?
    
    @State private var animateValue = false
    
    init(
        title: String, 
        value: String, 
        subtitle: String? = nil, 
        icon: String, 
        color: Color,
        gradient: LinearGradient? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.gradient = gradient
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with beautiful background
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                gradient ?? LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.charcoal)
                    .scaleEffect(animateValue ? 1.0 : 0.8)
                    .opacity(animateValue ? 1.0 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateValue)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.charcoal)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white, color.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: color.opacity(0.15), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            animateValue = true
        }
    }
}

// Modern Status Badge with enhanced styling
struct StatusBadgeView: View {
    let text: String
    let color: Color
    let style: BadgeStyle
    let size: BadgeSize
    
    enum BadgeStyle {
        case filled
        case outlined
        case glassmorphism
        case gradient
    }
    
    enum BadgeSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium:
                return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .large:
                return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }
        
        var font: Font {
            switch self {
            case .small:
                return .caption2
            case .medium:
                return .caption
            case .large:
                return .subheadline
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small:
                return 8
            case .medium:
                return 10
            case .large:
                return 12
            }
        }
    }
    
    init(
        _ text: String, 
        color: Color = .babyPrimary, 
        style: BadgeStyle = .filled,
        size: BadgeSize = .medium
    ) {
        self.text = text
        self.color = color
        self.style = style
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(size.padding)
            .background(backgroundView)
            .overlay(overlayView)
            .cornerRadius(size.cornerRadius)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .filled, .gradient:
            return .white
        case .outlined, .glassmorphism:
            return color
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
        case .outlined:
            Color.clear
            
        case .glassmorphism:
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(color.opacity(0.15))
                .background(.ultraThinMaterial)
            
        case .gradient:
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if style == .outlined {
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(color, lineWidth: 1.5)
        }
    }
}

// Beautiful Empty State with enhanced visual appeal
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    let color: Color
    
    @State private var animateIcon = false
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        color: Color = .babyPrimary
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Animated Icon with beautiful background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1.0 : 0.6)
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(color)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .rotationEffect(.degrees(animateIcon ? 0 : -10))
            }
            .animation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.2), value: animateIcon)
            
            // Content
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
            }
            .opacity(animateIcon ? 1.0 : 0)
            .offset(y: animateIcon ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.5), value: animateIcon)
            
            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle(
                        backgroundColor: color,
                        shadowColor: color
                    ))
                    .frame(maxWidth: 240)
                    .opacity(animateIcon ? 1.0 : 0)
                    .offset(y: animateIcon ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: animateIcon)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
        .onAppear {
            animateIcon = true
        }
    }
}

struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Yükleniyor...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    init(_ message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Bir Hata Oluştu")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                Button("Tekrar Dene", action: retryAction)
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: 200)
            }
        }
        .padding(.horizontal, 40)
    }
}

struct SectionHeaderView: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        _ title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let actionTitle = actionTitle, let action = action {
                    Button(actionTitle, action: action)
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
            }
        }
    }
}

// Enhanced Floating Action Button with multiple styles
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    let color: Color
    let size: CGFloat
    let style: FABStyle
    
    @State private var isPressed = false
    
    enum FABStyle {
        case standard
        case extended(String)
        case mini
    }
    
    init(
        icon: String, 
        color: Color = .babyPrimary, 
        size: CGFloat = 56,
        style: FABStyle = .standard,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(FloatingActionButtonStyle(
            backgroundColor: color,
            size: buttonSize
        ))
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {
            // Long press action if needed
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .standard, .mini:
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
            
        case .extended(let text):
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(text)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var buttonSize: CGFloat {
        switch style {
        case .mini:
            return 40
        case .standard:
            return size
        case .extended:
            return 0 // Extended buttons don't use fixed size
        }
    }
}

// 🎭 Enhanced Custom Modifiers and Effects
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

// Bouncy animation effect
struct BounceEffect: GeometryEffect {
    var bounceHeight: CGFloat
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let bounce = bounceHeight * sin(animatableData * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: 0, y: bounce))
    }
}

// Pulse effect for buttons and cards
struct PulseEffect: ViewModifier {
    let color: Color
    let intensity: Double
    
    @State private var animate = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(animate ? 0 : intensity), lineWidth: animate ? 10 : 2)
                    .scaleEffect(animate ? 1.5 : 1.0)
                    .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: animate)
            )
            .onAppear {
                animate = true
            }
    }
}

extension View {
    func shake(with amount: CGFloat = 10) -> some View {
        modifier(ShakeEffect(amount: amount, animatableData: amount))
    }
    
    func bounce(height: CGFloat = 10, duration: Double = 1.0) -> some View {
        modifier(BounceEffect(bounceHeight: height, animatableData: 1.0))
            .animation(.easeInOut(duration: duration).repeatForever(autoreverses: true), value: true)
    }
    
    func pulse(color: Color = .babyPrimary, intensity: Double = 0.3) -> some View {
        modifier(PulseEffect(color: color, intensity: intensity))
    }
    
    // Slide in animation
    func slideIn(from edge: Edge, delay: Double = 0) -> some View {
        let offset: CGSize = {
            switch edge {
            case .top: return CGSize(width: 0, height: -100)
            case .bottom: return CGSize(width: 0, height: 100)
            case .leading: return CGSize(width: -100, height: 0)
            case .trailing: return CGSize(width: 100, height: 0)
            }
        }()
        
        return self
            .offset(offset)
            .opacity(0)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay)) {
                    // Animation handled by state change
                }
            }
    }
    
    // Fade in with scale
    func fadeInScale(delay: Double = 0) -> some View {
        self
            .scaleEffect(0.8)
            .opacity(0)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay)) {
                    // Animation handled by state change
                }
            }
    }
}

// Enhanced Haptic feedback helper with better organization
struct HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // Convenience methods for common actions
    static func success() {
        notification(.success)
    }
    
    static func warning() {
        notification(.warning)
    }
    
    static func error() {
        notification(.error)
    }
    
    static func lightImpact() {
        impact(.light)
    }
    
    static func heavyImpact() {
        impact(.heavy)
    }
}

// 🎨 Beautiful Hero Card Component
struct HeroCard: View {
    let title: String
    let subtitle: String?
    let value: String
    let icon: String
    let gradient: LinearGradient
    let action: (() -> Void)?
    
    @State private var animateContent = false
    
    init(
        title: String,
        subtitle: String? = nil,
        value: String,
        icon: String,
        gradient: LinearGradient,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.icon = icon
        self.gradient = gradient
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(value)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .scaleEffect(animateContent ? 1.0 : 0.8)
                            .opacity(animateContent ? 1.0 : 0)
                    }
                    
                    Spacer()
                    
                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .rotationEffect(.degrees(animateContent ? 0 : -15))
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(gradient)
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
            )
        }
        .disabled(action == nil)
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6).delay(0.3)) {
                animateContent = true
            }
        }
    }
}

// 🎯 Quick Action Grid Component
struct QuickActionGrid: View {
    let actions: [QuickAction]
    let columns: Int
    
    struct QuickAction {
        let title: String
        let icon: String
        let color: Color
        let action: () -> Void
    }
    
    init(actions: [QuickAction], columns: Int = 2) {
        self.actions = actions
        self.columns = columns
    }
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: columns),
            spacing: 16
        ) {
            ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                QuickActionCard(
                    title: action.title,
                    icon: action.icon,
                    color: action.color,
                    action: action.action
                )
                .opacity(0)
                .offset(y: 30)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6).delay(Double(index) * 0.1)) {
                        // Animation will be handled by the card itself
                    }
                }
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var animateIn = false
    
    var body: some View {
        Button(action: {
            HapticFeedback.lightImpact()
            action()
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.charcoal)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(
                        color: color.opacity(0.1), 
                        radius: isPressed ? 5 : 10, 
                        x: 0, 
                        y: isPressed ? 2 : 5
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(animateIn ? 1.0 : 0)
        .offset(y: animateIn ? 0 : 30)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: animateIn)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {}
        .onAppear {
            animateIn = true
        }
    }
}
