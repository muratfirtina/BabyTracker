import SwiftUI
import UserNotifications

@main
struct BabyTrackerApp: App {
    @StateObject private var babyDataManager = BabyDataManager()
    @StateObject private var vaccinationDataManager = VaccinationDataManager()
    @StateObject private var growthDataManager = GrowthDataManager()
    
    init() {
        // Uygulama başlatıldığında bildirim izni iste
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            if babyDataManager.isFirstTimeSetup {
                InitialSetupView()
                    .environmentObject(babyDataManager)
                    .environmentObject(growthDataManager)
            } else {
                ContentView()
                    .environmentObject(babyDataManager)
                    .environmentObject(vaccinationDataManager)
                    .environmentObject(growthDataManager)
            }
        }
    }
}
