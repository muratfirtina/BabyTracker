import Foundation

struct Activity: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let ageRange: ClosedRange<Int>
    let duration: Int // dakika
    let category: ActivityCategory
    let benefits: [String]
    let materials: [String]
    let steps: [String]
    let difficulty: ActivityDifficulty
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        ageRange: ClosedRange<Int>,
        duration: Int,
        category: ActivityCategory,
        benefits: [String],
        materials: [String],
        steps: [String],
        difficulty: ActivityDifficulty
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.ageRange = ageRange
        self.duration = duration
        self.category = category
        self.benefits = benefits
        self.materials = materials
        self.steps = steps
        self.difficulty = difficulty
    }
}

enum ActivityCategory: String, CaseIterable, Codable {
    case sensory = "Duyusal Gelişim"
    case motor = "Motor Beceri"
    case cognitive = "Bilişsel Gelişim"
    case language = "Dil Gelişimi"
    case social = "Sosyal Beceri"
    case creative = "Yaratıcılık"
    case music = "Müzik"
    case reading = "Okuma"
}

enum ActivityDifficulty: String, CaseIterable, Codable {
    case easy = "Kolay"
    case medium = "Orta"
    case hard = "Zor"
}

struct SleepSound: Identifiable, Codable {
    let id: UUID
    let name: String
    let fileName: String
    let duration: Int // saniye
    let category: SleepSoundCategory
    let description: String
    
    init(
        id: UUID = UUID(),
        name: String,
        fileName: String,
        duration: Int,
        category: SleepSoundCategory,
        description: String
    ) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.duration = duration
        self.category = category
        self.description = description
    }
}

enum SleepSoundCategory: String, CaseIterable, Codable {
    case whiteNoise = "Beyaz Gürültü"
    case nature = "Doğa Sesleri"
    case lullaby = "Ninni"
    case classical = "Klasik Müzik"
    case rain = "Yağmur Sesi"
    case ocean = "Okyanus Sesi"
}
