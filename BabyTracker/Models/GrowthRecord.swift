import Foundation

struct GrowthRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var weightKg: Double
    var heightCm: Double
    var ageInMonths: Int
    var notes: String?
    
    init(id: UUID = UUID(), date: Date = Date(), weightKg: Double, heightCm: Double, ageInMonths: Int, notes: String? = nil) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.ageInMonths = ageInMonths
        self.notes = notes
    }
}

struct PercentileData: Codable {
    let ageInMonths: Int
    let p3: Double
    let p10: Double
    let p25: Double
    let p50: Double
    let p75: Double
    let p90: Double
    let p97: Double
    
    func getPercentile(for value: Double) -> String {
        if value <= p3 { return "3. persentil altında" }
        else if value <= p10 { return "3-10. persentil" }
        else if value <= p25 { return "10-25. persentil" }
        else if value <= p50 { return "25-50. persentil" }
        else if value <= p75 { return "50-75. persentil" }
        else if value <= p90 { return "75-90. persentil" }
        else if value <= p97 { return "90-97. persentil" }
        else { return "97. persentil üzerinde" }
    }
}

// Erkek çocuklar için boy persentil verileri (0-36 ay)
struct MaleHeightPercentiles {
    static let data: [PercentileData] = [
        PercentileData(ageInMonths: 0, p3: 46.1, p10: 47.4, p25: 48.6, p50: 49.9, p75: 51.2, p90: 52.4, p97: 53.7),
        PercentileData(ageInMonths: 1, p3: 50.8, p10: 52.3, p25: 53.7, p50: 55.2, p75: 56.7, p90: 58.1, p97: 59.6),
        PercentileData(ageInMonths: 2, p3: 54.4, p10: 56.0, p25: 57.6, p50: 59.2, p75: 60.8, p90: 62.4, p97: 64.0),
        PercentileData(ageInMonths: 3, p3: 57.3, p10: 59.0, p25: 60.7, p50: 62.4, p75: 64.1, p90: 65.8, p97: 67.5),
        PercentileData(ageInMonths: 6, p3: 63.3, p10: 65.2, p25: 67.1, p50: 69.0, p75: 70.9, p90: 72.8, p97: 74.7),
        PercentileData(ageInMonths: 9, p3: 67.7, p10: 69.7, p25: 71.7, p50: 73.7, p75: 75.7, p90: 77.7, p97: 79.7),
        PercentileData(ageInMonths: 12, p3: 71.0, p10: 73.1, p25: 75.2, p50: 77.3, p75: 79.4, p90: 81.5, p97: 83.6),
        PercentileData(ageInMonths: 18, p3: 76.0, p10: 78.4, p25: 80.8, p50: 83.2, p75: 85.6, p90: 88.0, p97: 90.4),
        PercentileData(ageInMonths: 24, p3: 80.0, p10: 82.6, p25: 85.2, p50: 87.8, p75: 90.4, p90: 93.0, p97: 95.6),
        PercentileData(ageInMonths: 30, p3: 83.1, p10: 85.9, p25: 88.7, p50: 91.5, p75: 94.3, p90: 97.1, p97: 99.9),
        PercentileData(ageInMonths: 36, p3: 85.7, p10: 88.7, p25: 91.7, p50: 94.7, p75: 97.7, p90: 100.7, p97: 103.7)
    ]
}

// Erkek çocuklar için ağırlık persentil verileri (0-36 ay)
struct MaleWeightPercentiles {
    static let data: [PercentileData] = [
        PercentileData(ageInMonths: 0, p3: 2.5, p10: 2.9, p25: 3.3, p50: 3.8, p75: 4.3, p90: 4.8, p97: 5.3),
        PercentileData(ageInMonths: 1, p3: 3.4, p10: 3.9, p25: 4.5, p50: 5.1, p75: 5.8, p90: 6.6, p97: 7.4),
        PercentileData(ageInMonths: 2, p3: 4.3, p10: 4.9, p25: 5.6, p50: 6.3, p75: 7.1, p90: 8.0, p97: 9.0),
        PercentileData(ageInMonths: 3, p3: 5.0, p10: 5.7, p25: 6.4, p50: 7.2, p75: 8.0, p90: 8.9, p97: 9.9),
        PercentileData(ageInMonths: 6, p3: 6.4, p10: 7.1, p25: 7.9, p50: 8.8, p75: 9.8, p90: 10.9, p97: 12.1),
        PercentileData(ageInMonths: 9, p3: 7.1, p10: 7.8, p25: 8.6, p50: 9.6, p75: 10.7, p90: 11.9, p97: 13.2),
        PercentileData(ageInMonths: 12, p3: 7.7, p10: 8.4, p25: 9.2, p50: 10.2, p75: 11.3, p90: 12.6, p97: 14.1),
        PercentileData(ageInMonths: 18, p3: 8.4, p10: 9.2, p25: 10.1, p50: 11.2, p75: 12.4, p90: 13.8, p97: 15.4),
        PercentileData(ageInMonths: 24, p3: 9.0, p10: 9.9, p25: 10.8, p50: 12.0, p75: 13.3, p90: 14.8, p97: 16.5),
        PercentileData(ageInMonths: 30, p3: 9.6, p10: 10.5, p25: 11.5, p50: 12.7, p75: 14.1, p90: 15.7, p97: 17.5),
        PercentileData(ageInMonths: 36, p3: 10.1, p10: 11.0, p25: 12.1, p50: 13.4, p75: 14.8, p90: 16.5, p97: 18.4)
    ]
}

// Kız çocuklar için boy persentil verileri (0-36 ay)
struct FemaleHeightPercentiles {
    static let data: [PercentileData] = [
        PercentileData(ageInMonths: 0, p3: 45.4, p10: 46.7, p25: 47.9, p50: 49.1, p75: 50.4, p90: 51.7, p97: 52.9),
        PercentileData(ageInMonths: 1, p3: 49.8, p10: 51.2, p25: 52.7, p50: 54.1, p75: 55.6, p90: 57.0, p97: 58.5),
        PercentileData(ageInMonths: 2, p3: 53.0, p10: 54.6, p25: 56.2, p50: 57.8, p75: 59.4, p90: 61.0, p97: 62.6),
        PercentileData(ageInMonths: 3, p3: 55.6, p10: 57.3, p25: 59.0, p50: 60.7, p75: 62.4, p90: 64.1, p97: 65.8),
        PercentileData(ageInMonths: 6, p3: 61.2, p10: 63.1, p25: 65.0, p50: 66.9, p75: 68.8, p90: 70.7, p97: 72.6),
        PercentileData(ageInMonths: 9, p3: 65.3, p10: 67.3, p25: 69.3, p50: 71.3, p75: 73.3, p90: 75.3, p97: 77.3),
        PercentileData(ageInMonths: 12, p3: 68.3, p10: 70.4, p25: 72.5, p50: 74.6, p75: 76.7, p90: 78.8, p97: 80.9),
        PercentileData(ageInMonths: 18, p3: 73.1, p10: 75.5, p25: 77.9, p50: 80.3, p75: 82.7, p90: 85.1, p97: 87.5),
        PercentileData(ageInMonths: 24, p3: 76.7, p10: 79.3, p25: 81.9, p50: 84.5, p75: 87.1, p90: 89.7, p97: 92.3),
        PercentileData(ageInMonths: 30, p3: 79.7, p10: 82.5, p25: 85.3, p50: 88.1, p75: 90.9, p90: 93.7, p97: 96.5),
        PercentileData(ageInMonths: 36, p3: 82.3, p10: 85.3, p25: 88.3, p50: 91.3, p75: 94.3, p90: 97.3, p97: 100.3)
    ]
}

// Kız çocuklar için ağırlık persentil verileri (0-36 ay)
struct FemaleWeightPercentiles {
    static let data: [PercentileData] = [
        PercentileData(ageInMonths: 0, p3: 2.4, p10: 2.8, p25: 3.2, p50: 3.6, p75: 4.1, p90: 4.6, p97: 5.1),
        PercentileData(ageInMonths: 1, p3: 3.2, p10: 3.6, p25: 4.2, p50: 4.8, p75: 5.5, p90: 6.2, p97: 6.9),
        PercentileData(ageInMonths: 2, p3: 3.9, p10: 4.5, p25: 5.1, p50: 5.8, p75: 6.6, p90: 7.5, p97: 8.5),
        PercentileData(ageInMonths: 3, p3: 4.5, p10: 5.2, p25: 5.8, p50: 6.6, p75: 7.5, p90: 8.5, p97: 9.6),
        PercentileData(ageInMonths: 6, p3: 5.7, p10: 6.5, p25: 7.3, p50: 8.2, p75: 9.3, p90: 10.4, p97: 11.6),
        PercentileData(ageInMonths: 9, p3: 6.2, p10: 7.0, p25: 7.9, p50: 8.9, p75: 10.1, p90: 11.4, p97: 12.8),
        PercentileData(ageInMonths: 12, p3: 6.7, p10: 7.5, p25: 8.4, p50: 9.5, p75: 10.8, p90: 12.2, p97: 13.7),
        PercentileData(ageInMonths: 18, p3: 7.2, p10: 8.1, p25: 9.0, p50: 10.2, p75: 11.6, p90: 13.2, p97: 14.9),
        PercentileData(ageInMonths: 24, p3: 7.8, p10: 8.7, p25: 9.7, p50: 11.0, p75: 12.4, p90: 14.0, p97: 15.8),
        PercentileData(ageInMonths: 30, p3: 8.3, p10: 9.3, p25: 10.3, p50: 11.7, p75: 13.2, p90: 14.8, p97: 16.7),
        PercentileData(ageInMonths: 36, p3: 8.8, p10: 9.8, p25: 10.9, p50: 12.3, p75: 13.9, p90: 15.7, p97: 17.7)
    ]
}

// Persentil hesaplama yardımcı fonksiyonları
extension Array where Element == PercentileData {
    func interpolateValue(for ageInMonths: Int, keyPath: KeyPath<PercentileData, Double>) -> Double? {
        // Tam eşleşme varsa direkt döndür
        if let exact = first(where: { $0.ageInMonths == ageInMonths }) {
            return exact[keyPath: keyPath]
        }
        
        // İnterpolasyon için komşu değerleri bul
        let sortedData = self.sorted { $0.ageInMonths < $1.ageInMonths }
        
        guard let lowerIndex = sortedData.lastIndex(where: { $0.ageInMonths < ageInMonths }),
              lowerIndex + 1 < sortedData.count else {
            return nil
        }
        
        let lower = sortedData[lowerIndex]
        let upper = sortedData[lowerIndex + 1]
        
        // Linear interpolasyon
        let ratio = Double(ageInMonths - lower.ageInMonths) / Double(upper.ageInMonths - lower.ageInMonths)
        let lowerValue = lower[keyPath: keyPath]
        let upperValue = upper[keyPath: keyPath]
        
        return lowerValue + ratio * (upperValue - lowerValue)
    }
    
    func getPercentileForValue(_ value: Double, ageInMonths: Int) -> String {
        guard let p3 = interpolateValue(for: ageInMonths, keyPath: \.p3),
              let p10 = interpolateValue(for: ageInMonths, keyPath: \.p10),
              let p25 = interpolateValue(for: ageInMonths, keyPath: \.p25),
              let p50 = interpolateValue(for: ageInMonths, keyPath: \.p50),
              let p75 = interpolateValue(for: ageInMonths, keyPath: \.p75),
              let p90 = interpolateValue(for: ageInMonths, keyPath: \.p90),
              let p97 = interpolateValue(for: ageInMonths, keyPath: \.p97) else {
            return "Veri bulunamadı"
        }
        
        if value < p3 { return "3. persentil altı" }
        else if value < p10 { return "3-10. persentil" }
        else if value < p25 { return "10-25. persentil" }
        else if value < p50 { return "25-50. persentil" }
        else if value < p75 { return "50-75. persentil" }
        else if value < p90 { return "75-90. persentil" }
        else if value < p97 { return "90-97. persentil" }
        else { return "97. persentil üzeri" }
    }
}
