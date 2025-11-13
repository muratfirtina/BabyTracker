import SwiftUI

// Shared color scheme structure for gender-based theming
struct GenderColorScheme {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let gradient: LinearGradient
}

// Extension to create gender-based color schemes
extension GenderColorScheme {
    static func forGender(_ gender: Gender?) -> GenderColorScheme {
        switch gender {
        case .female:
            return GenderColorScheme(
                primary: .roseGold,
                secondary: .babyPink,
                accent: .coralPink,
                background: .lightPeach,
                gradient: LinearGradient(
                    colors: [Color.babyPink.opacity(0.4), Color.lightPeach.opacity(0.2), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .male:
            return GenderColorScheme(
                primary: .babyPrimary,
                secondary: .babySecondary,
                accent: .oceanBlue,
                background: .babyBlue,
                gradient: LinearGradient(
                    colors: [Color.babySecondary.opacity(0.4), Color.babyBlue.opacity(0.2), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .unknown, .none:
            return GenderColorScheme(
                primary: .mintGreen,
                secondary: .softMint,
                accent: .charcoal,
                background: .buttercream,
                gradient: LinearGradient(
                    colors: [Color.softMint.opacity(0.3), Color.buttercream.opacity(0.2), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}
