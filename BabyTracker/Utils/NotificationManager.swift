import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                print("Bildirim izni verildi")
            } else if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Aşı hatırlatması için bildirim programla
    func scheduleVaccinationReminder(for vaccine: Vaccination, baby: Baby) {
        guard let birthDate = baby.birthDate else { return }
        
        let vaccineDate = Calendar.current.date(
            byAdding: .month,
            value: vaccine.ageInMonths,
            to: birthDate
        ) ?? Date()
        
        // 1 hafta önceden uyar
        let reminderDate = Calendar.current.date(
            byAdding: .day,
            value: -7,
            to: vaccineDate
        ) ?? vaccineDate
        
        let content = UNMutableNotificationContent()
        content.title = "Aşı Hatırlatması"
        content.body = "\(vaccine.name) aşısının zamanı yaklaştı. Doktorunuzla randevu almayı unutmayın."
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "vaccine_\(vaccine.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim programlama hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Gelişim milestone'ı hatırlatması
    func scheduleDevelopmentMilestone(ageInMonths: Int, baby: Baby) {
        guard let birthDate = baby.birthDate else { return }
        
        let milestoneDate = Calendar.current.date(
            byAdding: .month,
            value: ageInMonths,
            to: birthDate
        ) ?? Date()
        
        let content = UNMutableNotificationContent()
        content.title = "Gelişim Takibi"
        content.body = "\(baby.name) \(ageInMonths). ayına girdi! Yeni gelişim aşamalarını kontrol edin."
        content.sound = .default
        content.badge = 1
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: milestoneDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "milestone_\(ageInMonths)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim programlama hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Günlük aktivite hatırlatması
    func scheduleDailyActivityReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Günlük Aktivite"
        content.body = "Bebeğinizle bugünün aktivitesini yapmayı unutmayın! 🎈"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_activity",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Günlük bildirim programlama hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Hamilelik haftalık hatırlatması
    func scheduleWeeklyPregnancyUpdate(pregnancyWeek: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Hamilelik Güncellemesi"
        content.body = "\(pregnancyWeek). haftanıza hoş geldiniz! Yeni gelişmeleri keşfedin."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Pazartesi
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_pregnancy",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Haftalık bildirim programlama hatası: \(error.localizedDescription)")
            }
        }
    }
    
    // Bildirimi iptal et
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Tüm bildirimleri iptal et
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Bekleyen bildirimleri listele
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Bekleyen bildirimler: \(requests.count)")
            for request in requests {
                print("- \(request.identifier): \(request.content.title)")
            }
        }
    }
}
