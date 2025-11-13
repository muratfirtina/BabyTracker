# Yakındaki Hizmetler - API Entegrasyonu

Bu dokümantasyon, Baby Tracker uygulamasındaki "Yakındaki Hizmetler" özelliği için API entegrasyonu rehberini içerir.

## 🔑 API Anahtarları Kurulumu

### 1. NosyAPI (Nöbetçi Eczaneler) Kurulumu

1. [NosyAPI](https://nosyapi.com) sitesine gidin
2. Hesap oluşturun ve API anahtarınızı alın
3. `APIConfig.swift` dosyasındaki `NosyAPI.apiKey` değerini güncelleyin:

```swift
struct NosyAPI {
    static let baseURL = "https://api.nosyapi.com/"
    static let apiKey = "YOUR_NOSY_API_KEY_HERE" // Buraya API anahtarınızı yazın
    
    struct Endpoints {
        static let gpsPharmacies = "pharmacies-on-duty/locations"
        static let cityPharmacies = "pharmacies-on-duty"
        static let cities = "pharmacies-on-duty/cities"
    }
}
```

### 2. Doktor API'leri (Opsiyonel)

Şu anda mock data kullanılıyor. Gerçek API entegrasyonu için:

#### e-Nabız API
- [e-Devlet API Portal](https://api.turkiye.gov.tr/) üzerinden başvuru yapın
- Sağlık Bakanlığı e-Nabız servisleri için özel izin gerekli

#### DoktorTakvimi API
- [DoktorTakvimi](https://www.doktortakvimi.com) ile iletişime geçin
- Ticari API paketi için anlaşma yapın

## 🗺️ Harita Entegrasyonu

### Desteklenen Harita Uygulamaları

1. **Apple Haritalar** - Varsayılan olarak mevcut
2. **Google Maps** - Web versiyonu her zaman çalışır
3. **Yandex Maps** - Türkiye için önerilen

### URL Şemaları Test Etme

Simulator'de test etmek için aşağıdaki URL'leri Safari'de açabilirsiniz:

```
// Apple Maps
http://maps.apple.com/?ll=41.0082,28.9784&z=15

// Google Maps
https://www.google.com/maps/search/?api=1&query=41.0082,28.9784

// Yandex Maps
yandexmaps://maps.yandex.com/?ll=28.9784,41.0082&z=15
```

## 📱 Konum İzinleri

### Info.plist Ayarları

Aşağıdaki izinler Info.plist'e eklenmiştir:

- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `LSApplicationQueriesSchemes`

### Konum İzni Akışı

1. Uygulama açıldığında otomatik izin istenir
2. İzin reddedilirse manuel konum seçimi sunulur
3. Ayarlardan izin verilerek GPS kullanılabilir

## 🔧 Geliştirme Notları

### Mock Data Kullanımı

Geliştirme aşamasında mock data kullanılmaktadır:

- `DoctorService.swift` içinde `generateMockDoctors()` fonksiyonu
- Gerçek API entegrasyonu için bu fonksiyonlar kaldırılıp API çağrıları yapılmalı

### Error Handling

Tüm servisler kapsamlı error handling içerir:

- Network hatalarını yakalar
- Kullanıcı dostu hata mesajları gösterir
- Retry mekanizması sunar

### Performance Optimizasyonu

- Async/await pattern kullanılır
- Location updates throttling ile optimize edilir
- LazyVStack ile büyük listeler optimize edilir

## 🚀 Deployment Checklist

### Prodüksiyon Öncesi

- [ ] API anahtarları güncellendi
- [ ] Mock data kaldırıldı
- [ ] Real API endpoints test edildi
- [ ] Konum izinleri test edildi
- [ ] Harita entegrasyonları test edildi

### App Store Submission

- [ ] Privacy Policy güncellendi (konum kullanımı için)
- [ ] App Store açıklamasında konum kullanımı belirtildi
- [ ] KVKK uyumluluk kontrol edildi

## 📊 Analytics ve Monitoring

### Önerilen Metrikler

- API response times
- Location permission grant rates
- Map app preferences
- Search success rates

### Error Tracking

- API failures
- Location errors
- Network timeouts

## 🔐 Güvenlik Notları

- API anahtarları environment variables olarak saklanmalı
- HTTPS kullanımı zorunlu
- Rate limiting uygulanmalı
- User data encryption gerekli

## 📞 Destek

API entegrasyonu sorunları için:

1. NosyAPI: [support@nosyapi.com](mailto:support@nosyapi.com)
2. e-Nabız: e-Devlet İletişim Merkezi
3. Google Maps: Google Cloud Support
4. Yandex Maps: Yandex Developer Support

---

*Bu dokümantasyon, Baby Tracker v1.0 için hazırlanmıştır.*
