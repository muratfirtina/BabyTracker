import SwiftUI

struct ContentView: View {
    @EnvironmentObject var babyDataManager: BabyDataManager
    @EnvironmentObject var vaccinationDataManager: VaccinationDataManager
    @EnvironmentObject var growthDataManager: GrowthDataManager
    @State private var selectedTab = 0
    
    // Gender-based color scheme
    private var genderColorScheme: GenderColorScheme {
        GenderColorScheme.forGender(babyDataManager.currentBaby.gender)
    }
    
    var body: some View {
        ZStack {
            // Beautiful background gradient that changes based on selected tab
            getBackgroundGradient(for: selectedTab)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: selectedTab)
            
            TabView(selection: $selectedTab) {
                // 🏠 Dashboard
                DashboardView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        ModernTabItem(
                            icon: "house.fill",
                            title: "Ana Sayfa",
                            isSelected: selectedTab == 0,
                            genderColorScheme: genderColorScheme
                        )
                    }
                    .tag(0)
                
                // 📈 Development
                DevelopmentView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        ModernTabItem(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Gelişim",
                            isSelected: selectedTab == 1,
                            genderColorScheme: genderColorScheme
                        )
                    }
                    .tag(1)
                
                // 🌙 Sleep Sounds
                SleepSoundsView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        ModernTabItem(
                            icon: "moon.stars.fill",
                            title: "Uyku Sesleri",
                            isSelected: selectedTab == 2,
                            genderColorScheme: genderColorScheme
                        )
                    }
                    .tag(2)
                
                // 🎮 Activities
                ActivitiesView()
                    .environmentObject(babyDataManager)
                    .tabItem {
                        ModernTabItem(
                            icon: "gamecontroller.fill",
                            title: "Aktiviteler",
                            isSelected: selectedTab == 3,
                            genderColorScheme: genderColorScheme
                        )
                    }
                    .tag(3)
                
                // ⋯ More
                MoreView()
                    .environmentObject(babyDataManager)
                    .environmentObject(vaccinationDataManager)
                    .tabItem {
                        ModernTabItem(
                            icon: "ellipsis.circle.fill",
                            title: "Daha Fazla",
                            isSelected: selectedTab == 4,
                            genderColorScheme: genderColorScheme
                        )
                    }
                    .tag(4)
            }
            .tint(.babyPrimary)
            .onChange(of: selectedTab) { _ in
                HapticFeedback.selection()
            }
        }
        .preferredColorScheme(.light)
    }
    
    // Dynamic background based on selected tab
    private func getBackgroundGradient(for tab: Int) -> LinearGradient {
        switch tab {
        case 0:
            return LinearGradient(
                colors: [Color.softGray.opacity(0.2), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        case 1:
            return LinearGradient(
                colors: [Color.babySecondary.opacity(0.15), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        case 2:
            return LinearGradient(
                colors: [Color.lightPeach.opacity(0.2), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        case 3:
            return LinearGradient(
                colors: [Color.buttercream.opacity(0.25), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        case 4:
            return LinearGradient(
                colors: [Color.lavenderMist.opacity(0.2), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(
                colors: [Color.softGray.opacity(0.2), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// Modern iOS 17+ Style Tab Item with SF Symbols and Gender-based colors
struct ModernTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var genderColorScheme: GenderColorScheme?
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: isSelected ? 24 : 22, weight: isSelected ? .semibold : .regular))
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.bounce, value: isSelected)
            
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
        }
        .foregroundStyle(isSelected ? 
            (genderColorScheme != nil ? 
                LinearGradient(colors: [genderColorScheme!.primary, genderColorScheme!.accent], 
                              startPoint: .topLeading, 
                              endPoint: .bottomTrailing) :
                LinearGradient(colors: [.babyPrimary, .mintGreen], 
                              startPoint: .topLeading, 
                              endPoint: .bottomTrailing)) :
            LinearGradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)], 
                          startPoint: .topLeading, 
                          endPoint: .bottomTrailing))
    }
}

#Preview {
    ContentView()
        .environmentObject(BabyDataManager())
        .environmentObject(VaccinationDataManager())
        .environmentObject(GrowthDataManager())
}
