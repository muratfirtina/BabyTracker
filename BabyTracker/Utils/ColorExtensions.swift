import SwiftUI

extension Color {
    // 🎨 Modern Baby Theme Colors
    // Pastel Ana Renkler
    static let babyBlue = Color(red: 0.68, green: 0.85, blue: 0.98)      // #AED9F7
    static let babyPink = Color(red: 0.98, green: 0.76, blue: 0.86)      // #FAC2DB
    static let softMint = Color(red: 0.76, green: 0.95, blue: 0.87)      // #C2F2DE
    static let lightPeach = Color(red: 0.99, green: 0.89, blue: 0.82)    // #FDE3D1
    static let lavenderMist = Color(red: 0.93, green: 0.87, blue: 0.98)  // #EDDEF9
    static let buttercream = Color(red: 0.99, green: 0.97, blue: 0.86)   // #FDF7DC
    
    // Vibrant Ana Renkler  
    static let oceanBlue = Color(red: 0.25, green: 0.67, blue: 0.89)     // #40ABDF
    static let roseGold = Color(red: 0.89, green: 0.58, blue: 0.67)      // #E394AA
    static let mintGreen = Color(red: 0.32, green: 0.85, blue: 0.64)     // #52D9A3
    static let coralPink = Color(red: 0.95, green: 0.64, blue: 0.62)     // #F2A39E
    static let lilacPurple = Color(red: 0.71, green: 0.65, blue: 0.92)   // #B5A5EA
    
    // Hamilelik Teması
    static let pregnancyPrimary = Color(red: 0.85, green: 0.55, blue: 0.78)  // #D98BC7
    static let pregnancySecondary = Color(red: 0.92, green: 0.82, blue: 0.95) // #EBD1F2
    static let pregnancyAccent = Color(red: 0.68, green: 0.45, blue: 0.89)    // #AD72E3
    
    // Bebek Teması
    static let babyPrimary = Color(red: 0.45, green: 0.75, blue: 0.92)     // #73BFE8
    static let babySecondary = Color(red: 0.82, green: 0.92, blue: 0.98)   // #D1EAF9
    static let babyAccent = Color(red: 0.25, green: 0.62, blue: 0.85)      // #409ED9
    
    // Neutral Colors (Modern)
    static let softGray = Color(red: 0.96, green: 0.96, blue: 0.97)       // #F5F5F7
    static let warmGray = Color(red: 0.93, green: 0.92, blue: 0.94)       // #EDEBF0
    static let coolGray = Color(red: 0.89, green: 0.91, blue: 0.94)       // #E3E8F0
    static let charcoal = Color(red: 0.29, green: 0.33, blue: 0.38)       // #4A5461
    
    // Durum renkleri (Güncellenmiş)
    static let successGreen = Color(red: 0.29, green: 0.78, blue: 0.55)    // #4AC788
    static let warningOrange = Color(red: 1.0, green: 0.65, blue: 0.31)    // #FFA54F
    static let errorRed = Color(red: 0.95, green: 0.39, blue: 0.41)        // #F26367
    static let infoBlue = Color(red: 0.32, green: 0.68, blue: 0.93)        // #52ADED
    
    // 🌈 Beautiful Gradient Combinations
    static let pregnancyGradient = LinearGradient(
        colors: [pregnancyPrimary, pregnancyAccent.opacity(0.7), lavenderMist],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let babyGradient = LinearGradient(
        colors: [babyPrimary, oceanBlue.opacity(0.8), softMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let activityGradient = LinearGradient(
        colors: [lightPeach, coralPink.opacity(0.6), buttercream],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let developmentGradient = LinearGradient(
        colors: [mintGreen.opacity(0.8), softMint, babyBlue.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sleepGradient = LinearGradient(
        colors: [lilacPurple.opacity(0.7), lavenderMist, softGray],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let vaccinationGradient = LinearGradient(
        colors: [roseGold.opacity(0.6), babyPink, lightPeach.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Hero Gradients
    static let heroGradient = LinearGradient(
        colors: [
            pregnancyPrimary.opacity(0.9), 
            babyPrimary.opacity(0.8), 
            mintGreen.opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [softGray, Color.white.opacity(0.9)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Hex renk desteği
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Card stil modifikatörleri
// 🎨 Enhanced Card Styles
struct CardStyle: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let borderWidth: CGFloat
    let borderColor: Color
    
    init(
        backgroundColor: Color = Color.white,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.08,
        borderWidth: CGFloat = 0,
        borderColor: Color = Color.clear
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .shadow(
                color: Color.charcoal.opacity(shadowOpacity), 
                radius: shadowRadius, 
                x: 0, 
                y: shadowRadius / 2
            )
    }
}

// Modern Glass Effect Card
struct GlassCardStyle: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: Double
    
    init(cornerRadius: CGFloat = 20, opacity: Double = 0.15) {
        self.cornerRadius = cornerRadius
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(opacity))
                    .background(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.6), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// Floating Card with Glow
struct FloatingCardStyle: ViewModifier {
    let glowColor: Color
    let cornerRadius: CGFloat
    
    init(glowColor: Color = .babyBlue, cornerRadius: CGFloat = 18) {
        self.glowColor = glowColor
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .shadow(color: glowColor.opacity(0.3), radius: 15, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
    }
}

extension View {
    func cardStyle(
        backgroundColor: Color = Color.white,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.08,
        borderWidth: CGFloat = 0,
        borderColor: Color = Color.clear
    ) -> some View {
        modifier(CardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius,
            shadowOpacity: shadowOpacity,
            borderWidth: borderWidth,
            borderColor: borderColor
        ))
    }
    
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 0.15) -> some View {
        modifier(GlassCardStyle(cornerRadius: cornerRadius, opacity: opacity))
    }
    
    func floatingCard(glowColor: Color = .babyBlue, cornerRadius: CGFloat = 18) -> some View {
        modifier(FloatingCardStyle(glowColor: glowColor, cornerRadius: cornerRadius))
    }
    
    // Animated Scale Effect
    func animatedScale(pressed: Bool) -> some View {
        self.scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: pressed)
    }
    
    // Shimmer Effect
    func shimmer() -> some View {
        self.overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.6),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .offset(x: -200)
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: true
                )
        )
        .mask(self)
    }
}

// 🎯 Modern Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let shadowColor: Color
    
    init(
        backgroundColor: Color = .babyPrimary, 
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = 16,
        shadowColor: Color = .babyPrimary
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                backgroundColor,
                                backgroundColor.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(
                        color: shadowColor.opacity(0.3), 
                        radius: configuration.isPressed ? 5 : 10, 
                        x: 0, 
                        y: configuration.isPressed ? 2 : 5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    let borderColor: Color
    let foregroundColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    
    init(
        borderColor: Color = .babyPrimary, 
        foregroundColor: Color = .babyPrimary,
        backgroundColor: Color = .babySecondary,
        cornerRadius: CGFloat = 16
    ) {
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(foregroundColor)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Floating Action Button Style
struct FloatingActionButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let size: CGFloat
    
    init(backgroundColor: Color = .babyPrimary, size: CGFloat = 60) {
        self.backgroundColor = backgroundColor
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [backgroundColor, backgroundColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: backgroundColor.opacity(0.4), 
                        radius: configuration.isPressed ? 8 : 15, 
                        x: 0, 
                        y: configuration.isPressed ? 4 : 8
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Icon Button Style
struct IconButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color
    let size: CGFloat
    
    init(
        backgroundColor: Color = .softGray, 
        foregroundColor: Color = .charcoal,
        size: CGFloat = 44
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(foregroundColor)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .shadow(
                        color: Color.black.opacity(0.1), 
                        radius: configuration.isPressed ? 2 : 4, 
                        x: 0, 
                        y: configuration.isPressed ? 1 : 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
