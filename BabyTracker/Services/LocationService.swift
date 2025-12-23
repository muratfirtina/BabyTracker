import Foundation
import CoreLocation
import UIKit

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Manuel konum seçimi için
    @Published var manualCity: String?
    @Published var manualDistrict: String?
    @Published var currentLocationName: String?
    @Published var isUsingManualLocation = false
    
    // Son konum güncellemesi (duplicate'leri filtrelemek için)
    private var lastLocationUpdate: CLLocation?
    private let minimumDistanceForUpdate: Double = 50.0 // 50 metre
    
    // Konum var mı kontrolü (GPS veya manuel)
    var hasValidLocation: Bool {
        return currentLocation != nil || (manualCity != nil && !manualCity!.isEmpty)
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // 100 metre değişim (daha az güncelleme)
        
        // Başlangıçta konum al
        // Sadece izin verildiyse, otomatik olarak delege üzerinden gelecek
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Kullanıcıyı ayarlara yönlendir
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation()
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        isLoading = true
        errorMessage = nil
        isUsingManualLocation = false
        locationManager.requestLocation()
    }
    
    // Manuel konum ayarlama
    func setManualLocation(city: String, district: String?) {
        manualCity = city
        manualDistrict = district
        isUsingManualLocation = true
        
        // Şehir ve ilçeyi birleştir
        if let district = district, !district.isEmpty {
            currentLocationName = "\(district), \(city)"
        } else {
            currentLocationName = city
        }
        
        // Manuel konum için yaklaşık koordinat al (Geocoding)
        geocodeLocation(city: city, district: district)
    }
    
    // Şehir/ilçe ismine göre koordinat al
    private func geocodeLocation(city: String, district: String?) {
        let geocoder = CLGeocoder()
        var address = city
        if let district = district {
            address = "\(district), \(city), Türkiye"
        } else {
            address = "\(city), Türkiye"
        }
        
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                DispatchQueue.main.async {
                    self.currentLocation = location
                }
            }
        }
    }
    
    // Konum sıfırlama
    func clearLocation() {
        currentLocation = nil
        manualCity = nil
        manualDistrict = nil
        currentLocationName = nil
        isUsingManualLocation = false
    }
    
    func calculateDistance(from userLocation: CLLocation, to targetLocation: CLLocation) -> Double {
        return userLocation.distance(from: targetLocation) / 1000.0 // km cinsinden
    }
    
    // Harita URL'leri oluşturma
    func createAppleMapsURL(latitude: Double, longitude: Double, name: String? = nil) -> URL? {
        var urlString = "http://maps.apple.com/?q=\(latitude),\(longitude)"
        if let name = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "&z=15&t=m&address=\(name)"
        }
        return URL(string: urlString)
    }
    
    func createGoogleMapsURL(latitude: Double, longitude: Double, name: String? = nil) -> URL? {
        if let name = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "https://www.google.com/maps/search/?api=1&query=\(name)")
        } else {
            return URL(string: "https://www.google.com/maps/search/?api=1&query=\(latitude),\(longitude)")
        }
    }
    
    func createYandexMapsURL(latitude: Double, longitude: Double) -> URL? {
        // Yandex Maps için koordinat formatı lon,lat olarak
        return URL(string: "yandexmaps://maps.yandex.com/?ll=\(longitude),\(latitude)&z=15")
    }
    
    // Navigasyon URL'leri (yol tarifi için)
    func createAppleMapsDirectionURL(latitude: Double, longitude: Double, name: String? = nil) -> URL? {
        if let name = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "http://maps.apple.com/?daddr=\(name)&dirflg=d")
        } else {
            return URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d")
        }
    }
    
    func createGoogleMapsDirectionURL(latitude: Double, longitude: Double, name: String? = nil) -> URL? {
        if let name = name?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(name)")
        } else {
            return URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)")
        }
    }
    
    func createYandexMapsDirectionURL(latitude: Double, longitude: Double) -> URL? {
        return URL(string: "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Aynı konumu tekrar gönderme (1m'den az değişiklik)
        if let lastLocation = lastLocationUpdate {
            let distance = location.distance(from: lastLocation)
            if distance < 1.0 { // 1 metre
                print("ℹ️ Aynı konum, güncelleme atlandı")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
        }
        
        // Konum güncellemesi
        print("📍 Yeni konum: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        lastLocationUpdate = location
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.isLoading = false
            
            // Reverse geocoding ile şehir/ilçe adını al
            self.reverseGeocodeLocation(location)
        }
    }
    
    // Koordinatlardan şehir/ilçe adını al
    private func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("⚠️ Reverse geocoding hatası: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    if let district = placemark.subLocality ?? placemark.locality,
                       let city = placemark.administrativeArea {
                        self.currentLocationName = "\(district), \(city)"
                        self.manualCity = city
                        self.manualDistrict = district
                        print("📍 Konum adı: \(district), \(city)")
                    } else if let city = placemark.locality {
                        self.currentLocationName = city
                        self.manualCity = city
                        print("📍 Konum adı: \(city)")
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let clError = error as? CLError {
                switch clError.code {
                case .locationUnknown:
                    self.errorMessage = "Konum belirlenemedi. Tekrar deneyin."
                case .denied:
                    self.errorMessage = "Konum erişimi reddedildi. Ayarlardan izin verin."
                case .network:
                    self.errorMessage = "Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin."
                default:
                    self.errorMessage = "Konum hatası: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "Bilinmeyen konum hatası."
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.getCurrentLocation()
            case .denied, .restricted:
                self.errorMessage = "Konum erişimi için ayarlardan izin verin."
            default:
                break
            }
        }
    }
}
