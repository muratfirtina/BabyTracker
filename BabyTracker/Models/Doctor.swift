import Foundation
import CoreLocation

struct Doctor: Identifiable, Codable {
    let id: UUID
    let name: String
    let title: String
    let specialization: String
    let hospital: String
    let address: String
    let phone: String
    let location: LocationCoordinate
    let rating: Double?
    let reviewCount: Int?
    let workingHours: [WorkingHour]
    let acceptsAppointments: Bool
    let distance: Double? // km cinsinden
    
    init(
        id: UUID = UUID(),
        name: String,
        title: String,
        specialization: String,
        hospital: String,
        address: String,
        phone: String,
        location: LocationCoordinate,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        workingHours: [WorkingHour],
        acceptsAppointments: Bool,
        distance: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.specialization = specialization
        self.hospital = hospital
        self.address = address
        self.phone = phone
        self.location = location
        self.rating = rating
        self.reviewCount = reviewCount
        self.workingHours = workingHours
        self.acceptsAppointments = acceptsAppointments
        self.distance = distance
    }
    
    struct LocationCoordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        var clLocation: CLLocation {
            CLLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    struct WorkingHour: Codable {
        let day: String
        let startTime: String
        let endTime: String
        let isAvailable: Bool
    }
}

extension Doctor {
    static let mockDoctors: [Doctor] = [
        Doctor(
            name: "Dr. Ayşe Yılmaz",
            title: "Uzm. Dr.",
            specialization: "Çocuk Sağlığı ve Hastalıkları",
            hospital: "Acıbadem Maslak Hastanesi",
            address: "Büyükdere Cd. No:40, 34485 Sarıyer/İstanbul",
            phone: "+90 212 304 44 44",
            location: LocationCoordinate(latitude: 41.1086, longitude: 29.0219),
            rating: 4.8,
            reviewCount: 156,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "09:00", endTime: "17:00", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "09:00", endTime: "17:00", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "09:00", endTime: "17:00", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "09:00", endTime: "17:00", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "09:00", endTime: "17:00", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "09:00", endTime: "13:00", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "", endTime: "", isAvailable: false)
            ],
            acceptsAppointments: true
        ),
        Doctor(
            name: "Dr. Mehmet Kaya",
            title: "Prof. Dr.",
            specialization: "Çocuk Kardiyolojisi",
            hospital: "Memorial Şişli Hastanesi",
            address: "Piyale Paşa Blv. No:4, 34384 Şişli/İstanbul",
            phone: "+90 212 314 66 66",
            location: LocationCoordinate(latitude: 41.0603, longitude: 28.9846),
            rating: 4.9,
            reviewCount: 243,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "08:00", endTime: "16:00", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "08:00", endTime: "16:00", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "08:00", endTime: "16:00", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "08:00", endTime: "16:00", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "08:00", endTime: "16:00", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "", endTime: "", isAvailable: false),
                WorkingHour(day: "Pazar", startTime: "", endTime: "", isAvailable: false)
            ],
            acceptsAppointments: true
        ),
        Doctor(
            name: "Dr. Zeynep Demir",
            title: "Uzm. Dr.",
            specialization: "Çocuk Gastroenterolojisi",
            hospital: "Koç Üniversitesi Hastanesi",
            address: "Davutpaşa Cd. No:4, 34010 Topkapı/İstanbul",
            phone: "+90 212 538 00 00",
            location: LocationCoordinate(latitude: 41.0188, longitude: 28.9323),
            rating: 4.7,
            reviewCount: 89,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "13:00", endTime: "18:00", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "13:00", endTime: "18:00", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "13:00", endTime: "18:00", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "13:00", endTime: "18:00", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "13:00", endTime: "18:00", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "09:00", endTime: "14:00", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "", endTime: "", isAvailable: false)
            ],
            acceptsAppointments: true
        )
    ]
    
    static let mockHospitals: [Doctor] = [
        Doctor(
            name: "Açıbadem Maslak Hastanesi",
            title: "",
            specialization: "Genel Hastane",
            hospital: "Açıbadem Maslak",
            address: "Büyükdere Cd. No:40, 34485 Sarıyer/İstanbul",
            phone: "+90 212 304 44 44",
            location: LocationCoordinate(latitude: 41.1086, longitude: 29.0219),
            rating: 4.7,
            reviewCount: 523,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "00:00", endTime: "23:59", isAvailable: true)
            ],
            acceptsAppointments: true
        ),
        Doctor(
            name: "Memorial Şişli Hastanesi",
            title: "",
            specialization: "Genel Hastane",
            hospital: "Memorial Şişli",
            address: "Piyale Paşa Blv. No:4, 34384 Şişli/İstanbul",
            phone: "+90 212 314 66 66",
            location: LocationCoordinate(latitude: 41.0603, longitude: 28.9846),
            rating: 4.8,
            reviewCount: 892,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "00:00", endTime: "23:59", isAvailable: true)
            ],
            acceptsAppointments: true
        ),
        Doctor(
            name: "Koç Üniversitesi Hastanesi",
            title: "",
            specialization: "Genel & Araştırma Hastanesi",
            hospital: "Koç Üniversitesi",
            address: "Davutpaşa Cd. No:4, 34010 Topkapı/İstanbul",
            phone: "+90 212 538 00 00",
            location: LocationCoordinate(latitude: 41.0188, longitude: 28.9323),
            rating: 4.9,
            reviewCount: 1256,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "00:00", endTime: "23:59", isAvailable: true)
            ],
            acceptsAppointments: true
        ),
        Doctor(
            name: "Amerikan Hastanesi",
            title: "",
            specialization: "Genel Hastane",
            hospital: "Amerikan",
            address: "Güzelb ahçe Sk. No:20, 34365 Nişantaşı/İstanbul",
            phone: "+90 212 444 3777",
            location: LocationCoordinate(latitude: 41.0472, longitude: 28.9930),
            rating: 4.6,
            reviewCount: 678,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "00:00", endTime: "23:59", isAvailable: true)
            ],
            acceptsAppointments: true
        ),
        Doctor(
            name: "Florence Nightingale Hastanesi",
            title: "",
            specialization: "Genel Hastane",
            hospital: "Florence Nightingale",
            address: "Abide-i Hürriyet Cd. No:290, 34381 Şişli/İstanbul",
            phone: "+90 212 224 49 50",
            location: LocationCoordinate(latitude: 41.0591, longitude: 28.9793),
            rating: 4.7,
            reviewCount: 734,
            workingHours: [
                WorkingHour(day: "Pazartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Salı", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Çarşamba", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Perşembe", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cuma", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Cumartesi", startTime: "00:00", endTime: "23:59", isAvailable: true),
                WorkingHour(day: "Pazar", startTime: "00:00", endTime: "23:59", isAvailable: true)
            ],
            acceptsAppointments: true
        )
    ]
}
