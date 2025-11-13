import Foundation

extension Date {
    // Tarihi daha okunabilir formatta göstermek için
    func toReadableString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
    
    // Sadece tarih kısmını almak için
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
    
    // İki tarih arasındaki hafta sayısını hesaplar
    func weeksFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: date, to: self)
        return components.weekOfYear ?? 0
    }
    
    // İki tarih arasındaki ay sayısını hesaplar
    func monthsFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date, to: self)
        return components.month ?? 0
    }
    
    // İki tarih arasındaki gün sayısını hesaplar
    func daysFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: self)
        return components.day ?? 0
    }
    
    // Hamilelik başlangıç tarihini hesaplar (doğum tarihinden 40 hafta önce)
    func pregnancyStartDate() -> Date {
        return self.addingTimeInterval(-40 * 7 * 24 * 60 * 60)
    }
    
    // Belirtilen hafta sayısı kadar ileri tarih
    func addingWeeks(_ weeks: Int) -> Date {
        return self.addingTimeInterval(TimeInterval(weeks * 7 * 24 * 60 * 60))
    }
    
    // Belirtilen ay sayısı kadar ileri tarih
    func addingMonths(_ months: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: months, to: self) ?? self
    }
}

extension Calendar {
    static var turkish: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "tr_TR")
        return calendar
    }
}
