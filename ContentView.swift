import SwiftUI

struct ContentView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @EnvironmentObject var vaccinationDataManager: VaccinationDataManager
    @EnvironmentObject var growthDataManager: GrowthDataManager
    @State private var selectedTab = 0
    @State private var animateTabChange = false
    
    var body: some View {
        ZStack {
            // Beautiful background gradient that changes based on selected tab
            getBackgroundGradient(for: selectedTab)
                .ignoresSafeArea(.all, edges: .bottom)
                .animation(.easeInOut(duration: 0.5), value: selectedTab)
            
            TabView(selection: $selectedTab) {
                // 🏠 Dashboard
                DashboardView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        TabItemView(
                            icon: "house.fill",
                            title: "Ana Sayfa",
                            isSelected: selectedTab == 0
                        )
                    }
                    .tag(0)
                
                // 📈 Development
                DevelopmentView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        TabItemView(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Gelişim",
                            isSelected: selectedTab == 1
                        )
                    }
                    .tag(1)
                
                // 💉 Vaccinations
                VaccinationView()
                    .environmentObject(babyDataManager)
                    .environmentObject(vaccinationDataManager)
                    .tabItem {
                        TabItemView(
                            icon: "cross.fill",
                            title: "Aşılar",
                            isSelected: selectedTab == 2
                        )
                    }
                    .tag(2)
                
                // 🎮 Activities
                ActivitiesView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        TabItemView(
                            icon: "gamecontroller.fill",
                            title: "Aktiviteler",
                            isSelected: selectedTab == 3
                        )
                    }
                    .tag(3)
                
                // 🏥 Nearby Services
                NearbyServicesView()
                    .tabItem {
                        TabItemView(
                            icon: "cross.circle.fill",
                            title: "Yakındaki",
                            isSelected: selectedTab == 4
                        )
                    }
                    .tag(4)
                
                // 🌙 Sleep Sounds
                SleepSoundsView()
                    .tabItem {
                        TabItemView(
                            icon: "moon.fill",
                            title: "Uyku",
                            isSelected: selectedTab == 5
                        )
                    }
                    .tag(5)
            }
            .onChange(of: selectedTab) { newValue in
                // Haptic feedback when tab changes
                HapticFeedback.selection()
                
                // Animate tab change
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    animateTabChange.toggle()
                }
            }
        }
        .preferredColorScheme(.light) // Force light mode for consistent colors
    }
    
    // Dynamic background based on selected tab
    private func getBackgroundGradient(for tab: Int) -> LinearGradient {
        switch tab {
        case 0: // Dashboard
            return LinearGradient(
                colors: [Color.softGray, Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 1: // Development
            return LinearGradient(
                colors: [Color.babySecondary.opacity(0.3), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2: // Vaccinations
            return LinearGradient(
                colors: [Color.lightPeach.opacity(0.4), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3: // Activities
            return LinearGradient(
                colors: [Color.buttercream.opacity(0.5), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 4: // Nearby Services
            return LinearGradient(
                colors: [Color.babySecondary.opacity(0.3), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 5: // Sleep
            return LinearGradient(
                colors: [Color.lavenderMist.opacity(0.4), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.softGray, Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Enhanced Tab Item View
struct TabItemView: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? getTabColor() : .secondary)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
            
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? getTabColor() : .secondary)
        }
        .opacity(isSelected ? 1.0 : 0.7)
    }
    
    private func getTabColor() -> Color {
        switch title {
        case "Ana Sayfa":
            return .babyPrimary
        case "Gelişim":
            return .mintGreen
        case "Aşılar":
            return .roseGold
        case "Aktiviteler":
            return .coralPink
        case "Yakındaki":
            return .infoBlue
        case "Uyku":
            return .lilacPurple
        default:
            return .babyPrimary
        }
    }
}

#Preview {
    ContentView()
}
