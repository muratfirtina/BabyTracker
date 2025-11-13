import Foundation

struct Baby: Identifiable, Codable {
    let id: UUID
    var name: String
    var birthDate: Date?
    var dueDate: Date
    var gender: Gender?
    var birthWeight: Double? // gram
    var birthHeight: Double? // cm
    
    init(id: UUID = UUID(), name: String, birthDate: Date? = nil, dueDate: Date? = nil, gender: Gender? = nil, birthWeight: Double? = nil, birthHeight: Double? = nil) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.dueDate = dueDate ?? Date().addingTimeInterval(60*60*24*30) // 30 gün sonra default
        self.gender = gender
        self.birthWeight = birthWeight
        self.birthHeight = birthHeight
    }
    var pregnancyWeek: Int {
        if let birthDate = birthDate {
            return 40 // Doğmuş bebek
        } else {
            let calendar = Calendar.current
            let weeks = calendar.dateComponents([.weekOfYear], from: dueDate.addingTimeInterval(-40*7*24*60*60), to: Date()).weekOfYear ?? 0
            return max(0, min(40, weeks))
        }
    }
    
    var ageInMonths: Int {
        guard let birthDate = birthDate else { return -1 }
        let calendar = Calendar.current
        let months = calendar.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
        return max(0, months)
    }
    
    var ageInDays: Int {
        guard let birthDate = birthDate else { return -1 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
        return max(0, days)
    }
    
    var isPregnancy: Bool {
        return birthDate == nil
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Erkek"
    case female = "Kız"
    case unknown = "Bilinmiyor"
}
