# 🏥 Google Places API - Çocuk Doktorları Entegrasyonu

Bu dokümantasyon, Baby Tracker uygulamasında Google Places API ile çocuk doktorlarını bulma özelliğinin kurulum ve kullanım rehberidir.

## 📋 İçindekiler
1. [API Anahtarı Alma](#api-anahtarı-alma)
2. [API'yi Aktifleştirme](#apiyi-aktifleştirme)
3. [Fiyatlandırma](#fiyatlandırma)
4. [Kurulum Adımları](#kurulum-adımları)
5. [Test Etme](#test-etme)
6. [Sorun Giderme](#sorun-giderme)

---

## 🔑 API Anahtarı Alma

### 1. Google Cloud Console'a Giriş Yapın
- [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
- Google hesabınızla giriş yapın

### 2. Yeni Proje Oluşturun
```
1. Sol üst köşede proje seçici menüsünü açın
2. "NEW PROJECT" butonuna tıklayın
3. Proje adı girin: "BabyTracker" (veya istediğiniz bir ad)
4. "CREATE" butonuna tıklayın
```

### 3. Places API'yi Etkinleştirin
```
1. Sol menüden "APIs & Services" > "Library" seçin
2. Arama çubuğuna "Places API" yazın
3. "Places API" sonucuna tıklayın
4. "ENABLE" butonuna tıklayın
```

### 4. API Anahtarı Oluşturun
```
1. Sol menüden "APIs & Services" > "Credentials" seçin
2. Üst menüden "CREATE CREDENTIALS" > "API key" seçin
3. API anahtarınız oluşturuldu! Kopyalayın ve güvenli bir yere kaydedin
4. "RESTRICT KEY" butonuna tıklayarak güvenlik ayarlarını yapın
```

### 5. API Anahtarını Kısıtlayın (ÖNEMLİ!)
```
API key restrictions:
1. Application restrictions:
   - "iOS apps" seçin
   - Bundle ID'nizi ekleyin: "com.yourcompany.BabyTracker"

2. API restrictions:
   - "Restrict key" seçin
   - "Places API" seçin
   - "OK" butonuna tıklayın
```

---

## 🚀 API'yi Aktifleştirme

### Proje Dosyalarını Güncelleyin

#### 1. APIConfig.swift dosyasını açın
```swift
// BabyTracker/Utils/APIConfig.swift

struct GooglePlacesAPI {
    static let apiKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE" // Buraya API anahtarınızı yapıştırın
}
```

#### 2. Feature Flag'i Aktifleştirin
```swift
// BabyTracker/Utils/APIConfig.swift

struct FeatureFlags {
    static let enableRealDoctorAPI = true // false'dan true'ya çevirin
}
```

#### 3. (Opsiyonel) Info.plist'e Ekleyin
Daha güvenli bir yöntem için API anahtarınızı Info.plist'e ekleyin:

```xml
<key>GOOGLE_PLACES_API_KEY</key>
<string>AIzaSy...YourAPIKey...xyz</string>
```

---

## 💰 Fiyatlandırma

### Aylık Ücretsiz Kullanım
Google her ay $200 değerinde ücretsiz kullanım sunar:

| API Çağrısı | Fiyat (1000 istek) | Ücretsiz Limit |
|-------------|-------------------|----------------|
| Nearby Search | $32 | ~6,250 istek |
| Text Search | $32 | ~6,250 istek |
| Place Details | $17 | ~11,750 istek |

### Aylık Kullanım Tahmini
**Orta ölçekli kullanım senaryosu:**
- 1000 aktif kullanıcı
- Her kullanıcı ayda 5 arama yapar
- Toplam: 5,000 arama/ay
- **Maliyet: $0** (Ücretsiz limitin çok altında)

**Yoğun kullanım senaryosu:**
- 5000 aktif kullanıcı  
- Her kullanıcı ayda 10 arama yapar
- Toplam: 50,000 arama/ay
- **Maliyet: ~$1,280/ay**

### Maliyet Optimizasyonu İpuçları
1. **Cache Kullanın**: Aynı arama sonuçlarını 5-10 dakika önbelleğe alın
2. **Radius Sınırlayın**: Gereksiz geniş arama yapılmasın (max 10km)
3. **Pagination**: Çok fazla sonuç getirmeyin (max 20 sonuç)
4. **Rate Limiting**: Kullanıcı başına arama limiti koyun

---

## ⚙️ Kurulum Adımları

### 1. API Anahtarını Yapıştırın

```swift
// BabyTracker/Utils/APIConfig.swift

struct GooglePlacesAPI {
    // ❌ YANLIŞ
    static let apiKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE"
    
    // ✅ DOĞRU
    static let apiKey = ""
}
```

### 2. Feature Flag'i Açın

```swift
// BabyTracker/Utils/APIConfig.swift

struct FeatureFlags {
    // ❌ YANLIŞ (mock data kullanılır)
    static let enableRealDoctorAPI = false
    
    // ✅ DOĞRU (gerçek API kullanılır)
    static let enableRealDoctorAPI = true
}
```

### 3. Projeyi Derleyin
```bash
# Xcode'da Cmd+B ile projeyi derleyin
# Hata yoksa başarılı!
```

---

## 🧪 Test Etme

### Simulator'de Test

1. **İlk Test - Mock Data ile**
   ```swift
   // APIConfig.swift
   static let enableRealDoctorAPI = false
   ```
   - Uygulamayı çalıştırın
   - "Yakındaki Hizmetler" > "Çocuk Doktorları" sekmesine gidin
   - Mock data görmelisiniz ✅

2. **İkinci Test - Real API ile**
   ```swift
   // APIConfig.swift
   static let enableRealDoctorAPI = true
   ```
   - Uygulamayı yeniden çalıştırın
   - Konum izni verin
   - Gerçek doktorları görmelisiniz ✅

### Test Konumları (Simulator)

Simulator'de konum test etmek için:
```
Debug > Location > Custom Location...
Latitude: 41.0082
Longitude: 28.9784
(İstanbul, Taksim)
```

### Beklenen Davranış

✅ **Başarılı Senaryo:**
- Loading indicator görünür
- 1-2 saniye sonra doktor listesi yüklenir
- Her doktorun rating, mesafe, adres bilgisi var
- Harita simgesine tıklayınca konum açılır

❌ **Hata Senaryoları:**
- API Key hatası → Mesaj: "Google Places API anahtarı bulunamadı"
- Network hatası → Mesaj: "İnternet bağlantısı bulunamadı"
- Sonuç yok → Boş liste, "Yakında doktor bulunamadı" mesajı

---

## 🔧 Sorun Giderme

### Problem 1: "API anahtarı bulunamadı" Hatası

**Çözüm:**
```swift
// APIConfig.swift dosyasını kontrol edin
struct GooglePlacesAPI {
    static let apiKey = "AIza..." // API key'iniz doğru mu?
}
```

### Problem 2: "API Hatası: REQUEST_DENIED"

**Nedenleri:**
1. API key kısıtlaması yanlış yapılandırılmış
2. Places API etkinleştirilmemiş
3. Bundle ID yanlış

**Çözüm:**
1. Google Cloud Console'a gidin
2. Credentials > API Key'iniz > Edit
3. "Application restrictions" > iOS apps
4. Bundle ID'yi kontrol edin: `com.yourcompany.BabyTracker`
5. "API restrictions" > Places API'nin seçili olduğunu kontrol edin

### Problem 3: Doktorlar Yüklenmiyor

**Debug Adımları:**
```swift
// DoctorService.swift içinde log ekleyin
print("🔍 API kullanılıyor mu? \(isUsingRealAPI)")
print("🔍 API Key var mı? \(googlePlacesService.hasValidAPIKey)")
```

**Olası Nedenler:**
1. Feature flag kapalı → `enableRealDoctorAPI = true` yapın
2. API key yanlış → Console'dan kontrol edin
3. Network problemi → İnternet bağlantısını kontrol edin
4. Konum izni yok → Settings > BabyTracker > Location

### Problem 4: Yanlış/İlgisiz Sonuçlar Geliyor

**Çözüm:**
Arama query'sini optimize edin:

```swift
// GooglePlacesService.swift
func searchNearbyPediatricDoctors(...) {
    // Daha spesifik keyword kullanın
    let keyword = "çocuk doktoru pediatri bebek"
}
```

### Problem 5: Telefonlar Görünmüyor

**Açıklama:**
Nearby Search API'de telefon bilgisi yok. Place Details API çağrısı gerekli.

**Geliştirme:**
```swift
// Gelecekte eklenecek özellik
func fetchDoctorDetails(placeId: String) async -> Doctor {
    try await googlePlacesService.fetchPlaceDetails(placeId: placeId)
}
```

---

## 📊 Monitoring ve Analytics

### API Kullanımını İzleme

1. **Google Cloud Console**
   - APIs & Services > Dashboard
   - Places API seçin
   - Günlük istek sayısını görüntüleyin

2. **Maliyet Takibi**
   - Billing > Cost Table
   - Places API maliyetlerini görüntüleyin

### Önerilen Limitler

```swift
// APIConfig.swift

struct GooglePlacesAPI {
    static let maxDailyRequestsPerUser = 20
    static let cacheTimeout: TimeInterval = 600 // 10 dakika
    static let defaultRadius = 5000.0 // 5 km (10 km yerine)
}
```

---

## 🔒 Güvenlik Best Practices

### 1. API Key'i Koruyun
```swift
// ❌ YAPMAYIN: API key'i Git'e commit etmeyin
static let apiKey = "AIzaSy..."

// ✅ YAPIN: .gitignore'a ekleyin
/Secrets.swift
*.xcconfig
```

### 2. Environment Variables Kullanın

**Secrets.swift oluşturun:**
```swift
// Secrets.swift (.gitignore'a ekleyin)
struct Secrets {
    static let googlePlacesAPIKey = "AIzaSy..."
}
```

**APIConfig.swift'te kullanın:**
```swift
struct GooglePlacesAPI {
    static let apiKey = Secrets.googlePlacesAPIKey
}
```

### 3. Rate Limiting Ekleyin
```swift
class RateLimiter {
    private var lastRequest: Date?
    private let minimumInterval: TimeInterval = 1.0 // 1 saniye
    
    func canMakeRequest() -> Bool {
        guard let last = lastRequest else {
            lastRequest = Date()
            return true
        }
        
        if Date().timeIntervalSince(last) > minimumInterval {
            lastRequest = Date()
            return true
        }
        return false
    }
}
```

---

## 📞 Destek ve Kaynaklar

### Resmi Dokümantasyon
- [Google Places API Docs](https://developers.google.com/maps/documentation/places/web-service/overview)
- [API Key Best Practices](https://developers.google.com/maps/api-security-best-practices)
- [Pricing Calculator](https://mapsplatform.google.com/pricing/)

### Yardım Alma
- Google Cloud Support: [support.google.com](https://support.google.com/)
- Stack Overflow: `google-places-api` tag
- GitHub Issues: BabyTracker repository

---

## ✅ Checklist

Entegrasyon tamamlandı mı?

- [ ] Google Cloud Console'da proje oluşturuldu
- [ ] Places API etkinleştirildi
- [ ] API anahtarı oluşturuldu ve kısıtlandı
- [ ] API key APIConfig.swift'e eklendi
- [ ] Feature flag aktifleştirildi
- [ ] Simulator'de test edildi
- [ ] Gerçek cihazda test edildi
- [ ] Konum izni çalışıyor
- [ ] Doktorlar listeleniyor
- [ ] Harita entegrasyonu çalışıyor
- [ ] Error handling test edildi
- [ ] API maliyeti izleniyor

---

**Son Güncelleme:** Kasım 2024  
**Versiyon:** 1.0  
**Geliştirici:** Baby Tracker Team

🎉 **Tebrikler!** Google Places API entegrasyonunuz tamamlandı!
