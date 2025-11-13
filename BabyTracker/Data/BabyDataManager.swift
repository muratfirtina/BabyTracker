import Foundation

class BabyDataManager: ObservableObject {
    @Published var currentBaby: Baby
    @Published var isFirstTimeSetup: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let babyKey = "saved_baby"
    private let setupCompletedKey = "setup_completed"
    
    init() {
        // Load saved baby data or create default
        if let savedData = userDefaults.data(forKey: babyKey),
           let savedBaby = try? JSONDecoder().decode(Baby.self, from: savedData) {
            self.currentBaby = savedBaby
            self.isFirstTimeSetup = false
        } else {
            // Default baby for new users
            self.currentBaby = Baby(
                name: "Bebeğim",
                dueDate: Date().addingTimeInterval(60*60*24*30) // 30 days from now
            )
            self.isFirstTimeSetup = true
        }
        
        // Setup durumunu kontrol et
        let setupCompleted = userDefaults.bool(forKey: setupCompletedKey)
        if setupCompleted && currentBaby.name != "Bebeğim" {
            self.isFirstTimeSetup = false
        }
    }
    
    func saveBaby() {
        if let encoded = try? JSONEncoder().encode(currentBaby) {
            userDefaults.set(encoded, forKey: babyKey)
        }
    }
    
    func completeSetup() {
        userDefaults.set(true, forKey: setupCompletedKey)
        isFirstTimeSetup = false
        saveBaby()
    }
    
    func updateBaby(_ baby: Baby) {
        currentBaby = baby
        saveBaby()
    }
    
    func resetBaby() {
        currentBaby = Baby(
            name: "Bebeğim",
            dueDate: Date().addingTimeInterval(60*60*24*30)
        )
        isFirstTimeSetup = true
        saveBaby()
    }
}
