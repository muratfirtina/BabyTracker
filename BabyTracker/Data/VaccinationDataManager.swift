import Foundation

class VaccinationDataManager: ObservableObject {
    @Published var vaccines: [Vaccination] = []
    
    private let userDefaults = UserDefaults.standard
    private let vaccinesKey = "saved_vaccines"
    
    init() {
        loadVaccines()
    }
    
    private func loadVaccines() {
        if let savedData = userDefaults.data(forKey: vaccinesKey),
           let savedVaccines = try? JSONDecoder().decode([Vaccination].self, from: savedData) {
            self.vaccines = savedVaccines
        } else {
            // Use default Turkey vaccination schedule
            self.vaccines = VaccinationSchedule.turkeySchedule.vaccines
            saveVaccines()
        }
    }
    
    func saveVaccines() {
        if let encoded = try? JSONEncoder().encode(vaccines) {
            userDefaults.set(encoded, forKey: vaccinesKey)
        }
    }
    
    func toggleVaccination(_ vaccine: Vaccination) {
        if let index = vaccines.firstIndex(where: { $0.id == vaccine.id }) {
            vaccines[index].isCompleted.toggle()
            if vaccines[index].isCompleted {
                vaccines[index].completionDate = Date()
            } else {
                vaccines[index].completionDate = nil
            }
            saveVaccines()
        }
    }
    
    func getVaccinesForAge(_ ageInMonths: Int) -> [Vaccination] {
        return vaccines.filter { $0.ageInMonths <= ageInMonths }
    }
    
    func getUpcomingVaccines(_ ageInMonths: Int, within months: Int = 2) -> [Vaccination] {
        return vaccines.filter { vaccine in
            !vaccine.isCompleted &&
            vaccine.ageInMonths > ageInMonths &&
            vaccine.ageInMonths <= ageInMonths + months
        }
    }
    
    func getOverdueVaccines(_ ageInMonths: Int) -> [Vaccination] {
        return vaccines.filter { vaccine in
            !vaccine.isCompleted && vaccine.ageInMonths <= ageInMonths
        }
    }
    
    func getCompletionRate() -> Double {
        let completed = vaccines.filter { $0.isCompleted }.count
        return Double(completed) / Double(vaccines.count)
    }
    
    func resetToDefault() {
        vaccines = VaccinationSchedule.turkeySchedule.vaccines
        saveVaccines()
    }
}
