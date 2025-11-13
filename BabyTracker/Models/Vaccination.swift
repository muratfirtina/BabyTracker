import Foundation

struct Vaccination: Identifiable, Codable {
    let id: UUID
    let name: String
    let ageInMonths: Int
    let description: String
    let importance: String
    let sideEffects: [String]
    var isCompleted: Bool
    var completionDate: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        ageInMonths: Int,
        description: String,
        importance: String,
        sideEffects: [String],
        isCompleted: Bool = false,
        completionDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.ageInMonths = ageInMonths
        self.description = description
        self.importance = importance
        self.sideEffects = sideEffects
        self.isCompleted = isCompleted
        self.completionDate = completionDate
    }
}

struct VaccinationSchedule: Codable {
    let vaccines: [Vaccination]
    
    static let turkeySchedule = VaccinationSchedule(vaccines: [
        Vaccination(name: "BCG", ageInMonths: 0, description: "Tüberküloz aşısı", importance: "Tüberküloza karşı koruma sağlar", sideEffects: ["Enjeksiyon yerinde kızarıklık", "Hafif ateş"]),
        Vaccination(name: "Hepatit B (1. Doz)", ageInMonths: 0, description: "Hepatit B aşısının ilk dozu", importance: "Hepatit B enfeksiyonuna karşı koruma", sideEffects: ["Enjeksiyon yerinde ağrı", "Hafif ateş"]),
        Vaccination(name: "DaBT-İPA-Hib (1. Doz)", ageInMonths: 2, description: "5'li karma aşı", importance: "Difteri, boğmaca, tetanos, çocuk felci ve Hib enfeksiyonlarına karşı koruma", sideEffects: ["Enjeksiyon yerinde şişlik", "Ateş", "Huzursuzluk"]),
        Vaccination(name: "Hepatit B (2. Doz)", ageInMonths: 2, description: "Hepatit B aşısının ikinci dozu", importance: "Bağışıklığı güçlendirir", sideEffects: ["Enjeksiyon yerinde ağrı"]),
        Vaccination(name: "DaBT-İPA-Hib (2. Doz)", ageInMonths: 4, description: "5'li karma aşının 2. dozu", importance: "Bağışıklığı güçlendirir", sideEffects: ["Enjeksiyon yerinde şişlik", "Ateş"]),
        Vaccination(name: "DaBT-İPA-Hib (3. Doz)", ageInMonths: 6, description: "5'li karma aşının 3. dozu", importance: "Bağışıklığı tamamlar", sideEffects: ["Enjeksiyon yerinde şişlik", "Ateş"]),
        Vaccination(name: "Hepatit B (3. Doz)", ageInMonths: 6, description: "Hepatit B aşısının üçüncü dozu", importance: "Uzun vadeli koruma sağlar", sideEffects: ["Enjeksiyon yerinde ağrı"]),
        Vaccination(name: "KPA (1. Doz)", ageInMonths: 12, description: "Kızamık, kabakulak, kızamıkçık aşısı", importance: "Üç önemli viral enfeksiyona karşı koruma", sideEffects: ["Hafif ateş", "Döküntü", "Enjeksiyon yerinde ağrı"]),
        Vaccination(name: "Su Çiçeği", ageInMonths: 12, description: "Varisella aşısı", importance: "Su çiçeği enfeksiyonuna karşı koruma", sideEffects: ["Hafif ateş", "Enjeksiyon yerinde kızarıklık"]),
        Vaccination(name: "DaBT-İPA (Rapel)", ageInMonths: 18, description: "4'lü karma aşı rapeli", importance: "Bağışıklığı yeniler", sideEffects: ["Enjeksiyon yerinde şişlik", "Ateş"]),
        Vaccination(name: "KPA (2. Doz)", ageInMonths: 48, description: "KPA aşısının ikinci dozu", importance: "Uzun vadeli koruma sağlar", sideEffects: ["Hafif ateş", "Döküntü"])
    ])
}
