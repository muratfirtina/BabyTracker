import Foundation

class GrowthDataManager: ObservableObject {
    @Published var growthRecords: [GrowthRecord] = []
    
    private let userDefaults = UserDefaults.standard
    private let recordsKey = "growth_records"
    
    init() {
        loadGrowthRecords()
    }
    
    private func loadGrowthRecords() {
        if let savedData = userDefaults.data(forKey: recordsKey),
           let savedRecords = try? JSONDecoder().decode([GrowthRecord].self, from: savedData) {
            self.growthRecords = savedRecords.sorted { $0.date < $1.date }
        }
    }
    
    func saveGrowthRecords() {
        if let encoded = try? JSONEncoder().encode(growthRecords) {
            userDefaults.set(encoded, forKey: recordsKey)
        }
    }
    
    func addGrowthRecord(_ record: GrowthRecord) {
        growthRecords.append(record)
        growthRecords.sort { $0.date < $1.date }
        saveGrowthRecords()
    }
    
    func updateGrowthRecord(_ record: GrowthRecord) {
        if let index = growthRecords.firstIndex(where: { $0.id == record.id }) {
            growthRecords[index] = record
            growthRecords.sort { $0.date < $1.date }
            saveGrowthRecords()
        }
    }
    
    func deleteGrowthRecord(_ record: GrowthRecord) {
        growthRecords.removeAll { $0.id == record.id }
        saveGrowthRecords()
    }
    
    func getLatestRecord() -> GrowthRecord? {
        return growthRecords.last
    }
    
    func getRecordsForDateRange(from startDate: Date, to endDate: Date) -> [GrowthRecord] {
        return growthRecords.filter { record in
            record.date >= startDate && record.date <= endDate
        }
    }
    
    func getHeightPercentile(for baby: Baby, record: GrowthRecord) -> String {
        guard let gender = baby.gender else { return "Cinsiyet bilgisi gerekli" }
        
        let percentileData = gender == .male ? MaleHeightPercentiles.data : FemaleHeightPercentiles.data
        return percentileData.getPercentileForValue(record.heightCm, ageInMonths: record.ageInMonths)
    }
    
    func getWeightPercentile(for baby: Baby, record: GrowthRecord) -> String {
        guard let gender = baby.gender else { return "Cinsiyet bilgisi gerekli" }
        
        let percentileData = gender == .male ? MaleWeightPercentiles.data : FemaleWeightPercentiles.data
        return percentileData.getPercentileForValue(record.weightKg, ageInMonths: record.ageInMonths)
    }
    
    func addBirthRecord(for baby: Baby, weightKg: Double, heightCm: Double) {
        guard let birthDate = baby.birthDate else { return }
        
        let birthRecord = GrowthRecord(
            date: birthDate,
            weightKg: weightKg,
            heightCm: heightCm,
            ageInMonths: 0,
            notes: "Doğum kaydı"
        )
        
        addGrowthRecord(birthRecord)
    }
    
    func resetData() {
        growthRecords.removeAll()
        saveGrowthRecords()
    }
}
