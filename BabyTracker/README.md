# Baby Tracker iOS Uygulaması

Anne-bebek takip uygulaması, hamilelik döneminden 5 yaşına kadar bebeğin gelişimini takip etmek için tasarlanmış SwiftUI tabanlı bir iOS uygulamasıdır.

## 🍼 Özellikler

### 📊 Ana Dashboard
- Bebek bilgileri ve genel durumu
- Hamilelik ilerlemesi veya bebek yaşı takibi
- Hızlı erişim butonları
- Günlük öneriler

### 📈 Gelişim Takibi
- **Hamilelik Dönemı**: Haftalık gelişim bilgileri
- **Doğum Sonrası**: Aylık gelişim aşamaları
- Fiziksel, bilişsel ve sosyal gelişim takibi
- Gelişim aşamasına özel öneriler

### 💉 Aşı Takvimi
- Türkiye aşı takvimine uygun program
- Aşı durumu takibi
- Yaklaşan ve geciken aşı uyarıları
- Aşı detayları ve yan etkileri

### 🎮 Aktiviteler
- Yaşa uygun günlük aktivite önerileri
- Kategori bazında aktiviteler (Motor, Bilişsel, Sosyal, vb.)
- Detaylı aktivite açıklamaları
- Malzeme listesi ve uygulama adımları

### 🌙 Uyku Sesleri
- Farklı kategorilerde uyku sesleri
- Beyaz gürültü, doğa sesleri, ninniler
- Müzik çalar ve zamanlayıcı
- Otomatik durdurma özelliği

### 🔔 Bildirimler
- Aşı hatırlatmaları
- Gelişim milestone'ları
- Günlük aktivite önerileri
- Hamilelik haftalık güncellemeleri

## 🏗️ Teknik Yapı

### Kullanılan Teknolojiler
- **SwiftUI**: Modern UI framework
- **Combine**: Reaktif programlama
- **UserNotifications**: Bildirim yönetimi
- **AVFoundation**: Ses çalma
- **UserDefaults**: Veri saklama

### Proje Yapısı
```
BabyTracker/
├── BabyTracker/
│   ├── Models/          # Veri modelleri
│   ├── Views/           # UI ekranları
│   ├── Components/      # Ortak UI bileşenleri
│   ├── Data/           # Veri yöneticileri
│   ├── Utils/          # Yardımcı dosyalar
│   ├── BabyTrackerApp.swift
│   ├── ContentView.swift
│   └── Info.plist
```

### Ana Dosyalar

#### Models
- `Baby.swift` - Bebek veri modeli
- `DevelopmentStage.swift` - Gelişim aşamaları
- `Vaccination.swift` - Aşı bilgileri
- `Activity.swift` - Aktivite ve uyku sesleri

#### Views
- `DashboardView.swift` - Ana dashboard
- `DevelopmentView.swift` - Gelişim takibi
- `VaccinationView.swift` - Aşı takvimi
- `ActivitiesView.swift` - Aktivite önerileri
- `SleepSoundsView.swift` - Uyku sesleri
- `BabySetupView.swift` - Bebek bilgileri ayarları

#### Data Management
- `BabyDataManager.swift` - Bebek verisi yönetimi
- `VaccinationDataManager.swift` - Aşı verisi yönetimi

#### Utils
- `DateExtensions.swift` - Tarih fonksiyonları
- `ColorExtensions.swift` - Renk ve stil tanımları
- `NotificationManager.swift` - Bildirim yönetimi

#### Components
- `CommonComponents.swift` - Ortak UI bileşenleri

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Xcode 15.0+
- iOS 16.0+
- macOS 13.0+

### Adımlar
1. Bu projeyi klonlayın:
```bash
git clone https://github.com/muratfirtina/BabyTracker.git
cd BabyTracker
```

2. Xcode ile açın:
```bash
open BabyTracker.xcodeproj
```

3. Simulator veya gerçek cihazda çalıştırın

### Xcode Projesi Oluşturma
Eğer Xcode proje dosyası yoksa:

1. Xcode'u açın
2. "Create a new Xcode project" seçin
3. "iOS" > "App" seçin
4. Project details:
   - Product Name: `BabyTracker`
   - Bundle Identifier: `com.muratfirtina.babytracker`
   - Language: `Swift`
   - Interface: `SwiftUI`
   - Use Core Data: ❌
   - Include Tests: ✅

5. Proje dosyalarını kopyalayın

## 📱 Ekran Görüntüleri

### Ana Dashboard
- Bebek bilgileri kartı
- Gelişim ilerlemesi
- Hızlı erişim butonları
- Günlük öneriler

### Aşı Takvimi
- Aşı listesi ve durumları
- İlerleme göstergesi
- Geciken/yaklaşan aşı uyarıları

### Aktiviteler
- Kategori seçimi
- Yaşa uygun aktivite listesi
- Detaylı aktivite açıklamaları

### Uyku Sesleri
- Ses kategorileri
- Müzik çalar kontrolü
- Zamanlayıcı ayarları

## 🔧 Özelleştirme

### Renk Teması
`ColorExtensions.swift` dosyasından ana renkleri değiştirebilirsiniz:
```swift
static let babyBlue = Color(red: 0.53, green: 0.81, blue: 0.98)
static let babyPink = Color(red: 1.0, green: 0.71, blue: 0.76)
```

### Aşı Takvimi
`Vaccination.swift` dosyasından Türkiye aşı takvimini güncelleyebilirsiniz.

### Aktiviteler
`ActivitiesView.swift` dosyasındaki `sampleActivities` array'ini düzenleyerek yeni aktiviteler ekleyebilirsiniz.

## 🎯 Gelecek Özellikler

- [ ] Fotoğraf albümü
- [ ] Büyüme grafiği
- [ ] Doktor randevuları
- [ ] Beslenme takibi
- [ ] Uyku düzeni takibi
- [ ] İstatistik raporları
- [ ] Aile paylaşımı
- [ ] Cloud backup
- [ ] Widget desteği
- [ ] Apple Watch uygulaması

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 👨‍💻 Geliştirici

**Murat Fırtına**
- GitHub: [@muratfirtina](https://github.com/muratfirtina)

## 🙏 Teşekkürler

- Apple SwiftUI Documentation
- Türkiye Sağlık Bakanlığı Aşı Takvimi
- Çocuk gelişimi uzmanları
- Beta test kullanıcıları

---

**Not**: Bu uygulama eğitim amaçlıdır. Tıbbi kararlar için mutlaka sağlık uzmanına danışın.
