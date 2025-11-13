import Foundation
import CoreLocation
import UIKit

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10 metre değişim
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
        locationManager.requestLocation()
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
        
        DispatchQueue.main.async {
            self.location = location
            self.isLoading = false
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
