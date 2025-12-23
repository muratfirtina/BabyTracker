# Yakındaki Hizmetler - API Entegrasyonu

Bu dokümantasyon, Baby Tracker uygulamasındaki "Yakındaki Hizmetler" özelliği için API entegrasyonu rehberini içerir.

## 🔑 API Anahtarları Kurulumu

### 1. Google Places API (Çocuk Doktorları) - ⭐ ÖNERİLEN ⭐

**Durum:** ✅ Entegre edildi ve kullanıma hazır

Google Places API, çocuk doktorlarını bulmak için en kapsamlı ve güvenilir çözümdür.

#### Hızlı Başlangıç:
1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
2. Yeni proje oluşturun veya mevcut projeyi seçin
3. "Places API"'yi etkinleştirin
4. API anahtarı oluşturun ve iOS uygulamanız için kısıtlayın
5. `APIConfig.swift` dosyasını güncelleyin:

```swift
struct GooglePlacesAPI {
    static let apiKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE" // Buraya API anahtarınızı yazın
}

// Feature flag'i aktifleştirin
struct FeatureFlags {
    static let enableRealDoctorAPI = true // false'dan true'ya değiştirin
}
```

#### Detaylı Kurulum:
📖 **Tam rehber için:** [GOOGLE_PLACES_SETUP_GUIDE.md](./GOOGLE_PLACES_SETUP_GUIDE.md) dosyasına bakın

#### Özellikler:
- ✅ Gerçek zamanlı çocuk doktoru arama
- ✅ Rating ve yorum sayıları
- ✅ Çalışma saatleri
- ✅ Mesafe hesaplama
- ✅ Adres ve konum bilgisi
- ✅ Harita entegrasyonu
- ✅ Otomatik fallback (API hata verirse mock data)

#### Fiyatlandırma:
- İlk $200 **ÜCRETSİZ** (ayda ~6,250 arama)
- Orta ölçekli kullanım: **$0-5/ay**
- Detaylı fiyatlandırma için kurulum rehberine bakın

---

### 2. NosyAPI (Nöbetçi Eczaneler)

**Durum:** ✅ Entegre edildi

1. [NosyAPI](https://nosyapi.com) sitesine gidin
2. Hesap oluşturun ve API anahtarınızı alın
3. `APIConfig.swift` dosyasındaki `NosyAPI.apiKey` değerini güncelleyin:

```swift
struct NosyAPI {
    static let baseURL = "https://api.nosyapi.com/apiv2"
    static let apiKey = "YOUR_NOSY_API_KEY_HERE" // Buraya API anahtarınızı yazın
}

// Feature flag'i aktifleştirin
struct FeatureFlags {
    static let enableRealPharmacyAPI = true // false'dan true'ya değiştirin
}
```

---

### 3. Alternatif Doktor API'leri (Gelecek için)

#### e-Nabız API
- [e-Devlet API Portal](https://api.turkiye.gov.tr/) üzerinden başvuru yapın
- Sağlık Bakanlığı e-Nabız servisleri için özel izin gerekli
- **Not:** Resmi API henüz genel kullanıma açık değil

#### DoktorTakvimi API
- [DoktorTakvimi](https://www.doktortakvimi.com) ile iletişime geçin
- Ticari API paketi için anlaşma yapın
- **Not:** Özel anlaşma gerektirir

#### MHRS API
- Sağlık Bakanlığı MHRS sistemi
- Özel izin gerektirir
- **Not:** Genel kullanıma kapalı

---

## 🗺️ Harita Entegrasyonu

### Desteklenen Harita Uygulamaları

1. **Apple Haritalar** ✅ Varsayılan olarak mevcut
2. **Google Maps** ✅ Web versiyonu her zaman çalışır
3. **Yandex Maps** ✅ Türkiye için önerilen

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

---

## 📱 Konum İzinleri

### Info.plist Ayarları

Aşağıdaki izinler Info.plist'e eklenmiştir:

- `NSLocationWhenInUseUsageDescription`: "Yakınızdaki doktorları ve eczaneleri göstermek için konumunuza ihtiyacımız var."
- `NSLocationAlwaysAndWhenInUseUsageDescription`: "Konum servisleri için izin gerekli."
- `LSApplicationQueriesSchemes`: Harita uygulamaları için URL şemaları

### Konum İzni Akışı

1. Uygulama açıldığında otomatik izin istenir
2. İzin reddedilirse manuel konum seçimi sunulur
3. Ayarlardan izin verilerek GPS kullanılabilir

---

## 🔧 Geliştirme Notları

### API Kullanım Durumu

Proje şu anda **hybrid mode** ile çalışmaktadır:

```swift
// APIConfig.swift
struct FeatureFlags {
    static let enableRealPharmacyAPI = false  // NosyAPI
    static let enableRealDoctorAPI = false    // Google Places API
}
```

- `false` = Mock data kullanılır (geliştirme için)
- `true` = Gerçek API kullanılır (production için)

### Mock Data Kullanımı

Geliştirme aşamasında mock data kullanılmaktadır:

- **DoctorService.swift**: Mock çocuk doktorları verisi
- **PharmacyService.swift**: Mock eczane verisi (NosyAPI entegresi mevcut)

**Avantajları:**
- API limitleri tüketilmez
- Hızlı geliştirme
- Offline çalışma
- Consistent test data

**API'ye Geçiş:**
```swift
// APIConfig.swift
static let enableRealDoctorAPI = true  // Mock'tan API'ye geçiş
```

### Error Handling

Tüm servisler kapsamlı error handling içerir:

```swift
do {
    let doctors = try await googlePlacesService.searchNearbyPediatricDoctors(...)
} catch {
    // Otomatik fallback: API hatası olursa mock data kullanılır
    print("⚠️ Google Places API hatası, mock data'ya geçiliyor")
}
```

- Network hatalarını yakalar
- Kullanıcı dostu hata mesajları gösterir
- Automatic fallback (API → Mock Data)
- Retry mekanizması

### Performance Optimizasyonu

- ✅ Async/await pattern kullanılır
- ✅ Location updates throttling ile optimize edilir
- ✅ LazyVStack ile büyük listeler optimize edilir
- ✅ API response caching (gelecekte eklenecek)
- ✅ Pagination support (gelecekte eklenecek)

---

## 🚀 Deployment Checklist

### Development Aşaması (Şu an)
- [x] Google Places API entegrasyonu tamamlandı
- [x] NosyAPI entegrasyonu tamamlandı
- [x] Mock data hazır ve çalışıyor
- [x] Error handling implementasyonu
- [x] Automatic fallback mekanizması
- [ ] API anahtarları eklendi (sizin yapmanız gereken)

### Pre-Production
- [ ] Google Places API key eklendi ve test edildi
- [ ] NosyAPI key eklendi ve test edildi
- [ ] Feature flags aktifleştirildi
- [ ] Real API endpoints test edildi
- [ ] Konum izinleri test edildi
- [ ] Harita entegrasyonları test edildi
- [ ] API maliyet analizi yapıldı

### App Store Submission
- [ ] Privacy Policy güncellendi (konum + API kullanımı)
- [ ] App Store açıklamasında konum kullanımı belirtildi
- [ ] KVKK uyumluluk kontrol edildi
- [ ] API rate limiting uygulandı
- [ ] Crash reporting aktif
- [ ] Analytics aktif

---

## 📊 API Kullanım İstatistikleri

### Google Places API Monitoring

1. **Google Cloud Console'dan İzleme:**
   - APIs & Services > Dashboard
   - Places API seçin
   - Günlük/aylık istek grafiklerini görüntüleyin

2. **Maliyet Takibi:**
   - Billing > Cost Table
   - Places API maliyetlerini izleyin

### Önerilen Metrikler

- API response times
- Success/failure rates
- Location permission grant rates
- Map app preferences
- Search success rates
- Average searches per user

### Error Tracking

- API failures (Google Places, NosyAPI)
- Location errors
- Network timeouts
- Parsing errors

---

## 🔐 Güvenlik Best Practices

### API Anahtarı Güvenliği

**❌ YAPMAYIN:**
```swift
// API key'i doğrudan kod içinde
static let apiKey = "AIzaSyD..."
```

**✅ YAPIN:**
```swift
// 1. Secrets.swift dosyası oluşturun (.gitignore'a ekleyin)
struct Secrets {
    static let googlePlacesAPIKey = "AIzaSyD..."
}

// 2. APIConfig'de kullanın
static let apiKey = Secrets.googlePlacesAPIKey

// 3. Veya Info.plist kullanın
static let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String
```

### Rate Limiting

```swift
// Kullanıcı başına limitleme
class RateLimiter {
    static let maxRequestsPerMinute = 10
    static let maxRequestsPerDay = 100
}
```

### Data Encryption

- HTTPS kullanımı zorunlu ✅
- User data encryption ✅
- Secure keychain storage (gelecekte)

---

## 🛠️ Troubleshooting

### Problem: Doktorlar yüklenmiyor

**Kontrol Listesi:**
1. Feature flag açık mı? → `enableRealDoctorAPI = true`
2. API key doğru mu? → APIConfig.swift
3. İnternet bağlantısı var mı?
4. Konum izni verilmiş mi?

**Debug:**
```swift
print("🔍 API kullanılıyor mu? \(isUsingRealAPI)")
print("🔍 API Key geçerli mi? \(googlePlacesService.hasValidAPIKey)")
```

### Problem: "API anahtarı bulunamadı" hatası

**Çözüm:**
```swift
// APIConfig.swift
struct GooglePlacesAPI {
    static let apiKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE" // ← Buraya key'inizi yapıştırın
}
```

### Problem: "REQUEST_DENIED" hatası

**Nedenleri:**
1. API key kısıtlaması yanlış
2. Places API etkinleştirilmemiş
3. Bundle ID yanlış

**Çözüm:** [GOOGLE_PLACES_SETUP_GUIDE.md](./GOOGLE_PLACES_SETUP_GUIDE.md) dosyasındaki "Sorun Giderme" bölümüne bakın

---

## 📞 Destek ve Kaynaklar

### API Sağlayıcılar
1. **Google Places API**
   - Dokümantasyon: https://developers.google.com/maps/documentation/places
   - Support: https://support.google.com/
   - Detaylı Rehber: [GOOGLE_PLACES_SETUP_GUIDE.md](./GOOGLE_PLACES_SETUP_GUIDE.md)

2. **NosyAPI**
   - Website: https://nosyapi.com
   - Email: support@nosyapi.com
   - Dokümantasyon: https://api.nosyapi.com/docs

3. **Harita Servisleri**
   - Google Maps: Google Cloud Support
   - Yandex Maps: Yandex Developer Support
   - Apple Maps: Apple Developer Support

### Topluluk Kaynakları
- Stack Overflow: `google-places-api`, `ios-location-services`
- GitHub Issues: BabyTracker repository
- Swift Forums: https://forums.swift.org

---

## 📝 Versiyon Geçmişi

### v1.1 (Kasım 2024) - ✅ Mevcut
- ✅ Google Places API entegrasyonu eklendi
- ✅ Hybrid mode (Mock + Real API)
- ✅ Automatic fallback mekanizması
- ✅ Detaylı error handling
- ✅ Comprehensive documentation

### v1.0 (Ekim 2024)
- ✅ NosyAPI entegrasyonu
- ✅ Mock data implementation
- ✅ Temel UI ve UX
- ✅ Konum servisleri

---

## ✅ Hızlı Başlangıç Checklist

**5 Dakikada Çalışır Hale Getirin:**

1. [ ] [Google Cloud Console](https://console.cloud.google.com/)'a gidin
2. [ ] Places API'yi etkinleştirin
3. [ ] API key oluşturun
4. [ ] API key'i `APIConfig.swift` dosyasına yapıştırın
5. [ ] Feature flag'i açın: `enableRealDoctorAPI = true`
6. [ ] Xcode'da Cmd+R ile çalıştırın
7. [ ] "Yakındaki Hizmetler" > "Çocuk Doktorları" sekmesini test edin

**Tebrikler! 🎉 Sisteminiz çalışıyor!**

---

**Son Güncelleme:** Kasım 2024  
**Versiyon:** 1.1  
**Maintainer:** Baby Tracker Team

*Bu dokümantasyon, Baby Tracker uygulaması için hazırlanmıştır.*
