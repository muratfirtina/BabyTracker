import Foundation

struct DevelopmentStage: Identifiable, Codable {
    let id = UUID()
    let ageInMonths: Int
    let title: String
    let description: String
    let physicalDevelopment: [String]
    let cognitiveSkills: [String]
    let socialSkills: [String]
    let recommendations: [String]
    let warnings: [String]
}

struct PregnancyWeek: Identifiable, Codable {
    let id = UUID()
    let week: Int
    let title: String
    let babySize: String
    let description: String
    let developments: [String]
    let motherChanges: [String]
    let recommendations: [String]
}
