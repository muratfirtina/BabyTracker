# Baby Tracker iOS Uygulaması - Kurulum Rehberi

Bu rehber, Baby Tracker iOS uygulamasını Xcode'da çalıştırmak için gereken adımları açıklar.

## 🎯 Xcode'da Proje Açma

### Seçenek 1: Mevcut Proje Dosyasını Kullanma
1. Xcode'u açın
2. "Open a project or file" seçin
3. `BabyTracker.xcodeproj` dosyasını seçin
4. Projeyi açın

### Seçenek 2: Sıfırdan Proje Oluşturma
Eğer proje dosyası açılmazsa, yeni proje oluşturun:

1. Xcode'u açın
2. "Create a new Xcode project" seçin
3. "iOS" sekmesini seçin
4. "App" template'ini seçin
5. Proje detayları:
   - **Product Name**: `BabyTracker`
   - **Bundle Identifier**: `com.muratfirtina.babytracker`
   - **Language**: `Swift`
   - **Interface**: `SwiftUI`
   - **Use Core Data**: ❌ (deaktif)
   - **Include Tests**: ✅ (aktif)

6. Proje konumunu seçin ve "Create" butonuna basın

## 📁 Dosyaları Projeye Ekleme

1. Xcode'da sol paneldeki Navigator'ı açın
2. Proje dosyalarını organize etmek için folder'lar oluşturun:
   - Models
   - Views
   - Data
   - Utils
   - Components

3. Her dosyayı uygun klasöre sürükleyin veya kopyalayın

## ⚙️ Proje Ayarları

### Build Settings
1. Proje navigator'da projeyi seçin
2. "Build Settings" sekmesine gidin
3. Şu ayarları kontrol edin:
   - **iOS Deployment Target**: 16.0
   - **Swift Language Version**: 5

### Info.plist Ayarları
Info.plist dosyasında şu izinlerin olduğundan emin olun:
```xml
<key>NSHealthShareUsageDescription</key>
<string>Bu uygulama bebeğinizin sağlık verilerini takip etmek için kullanılır.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Bu uygulama uyku sesleri kaydetmek için mikrofon kullanabilir.</string>

<key>NSCameraUsageDescription</key>
<string>Bu uygulama bebeğinizin fotoğraflarını çekmek için kamera kullanabilir.</string>
```

## 🔧 Gerekli Framework'ler

Bu proje şu framework'leri kullanır (otomatik olarak dahil edilir):
- SwiftUI
- Combine
- UserNotifications
- AVFoundation
- Foundation

## 🏃‍♂️ Uygulamayı Çalıştırma

1. Simulator veya gerçek cihaz seçin
2. ⌘ + R tuşlarına basın veya "Play" butonuna tıklayın
3. İlk çalıştırmada bildirim izni istenecek

## 🐛 Olası Sorunlar ve Çözümler

### Problem: "No such module" hataları
**Çözüm**: Product → Clean Build Folder (⌘ + Shift + K) yapın

### Problem: Preview çalışmıyor
**Çözüm**: 
1. Xcode'u yeniden başlatın
2. Derived Data'yı temizleyin
3. Canvas'ı yenileyin (⌘ + Option + P)

### Problem: Bildirimler çalışmıyor
**Çözüm**: 
1. Simulator'da Settings > Notifications > BabyTracker'ın açık olduğunu kontrol edin
2. Gerçek cihazda izinleri kontrol edin

## 📝 Development Notları

### Veri Yönetimi
- `BabyDataManager`: Bebek verilerini yönetir
- `VaccinationDataManager`: Aşı verilerini yönetir
- Veriler UserDefaults'ta saklanır

### Bildirimler
- `NotificationManager`: Tüm bildirimleri yönetir
- Aşı hatırlatmaları otomatik programlanır
- Günlük aktivite bildirimleri

### Ses Dosyaları
Gerçek implementasyonda ses dosyalarını bundle'a eklemeniz gerekir:
1. Ses dosyalarını projeye sürükleyin
2. "Add to target" seçeneğini işaretleyin
3. `AudioPlayerManager`'da dosya isimlerini güncelleyin

## 🎨 UI Customization

### Renkler
`ColorExtensions.swift` dosyasında tema renklerini değiştirebilirsiniz:
```swift
static let babyBlue = Color(red: 0.53, green: 0.81, blue: 0.98)
static let babyPink = Color(red: 1.0, green: 0.71, blue: 0.76)
```

### Aktiviteler
`ActivitiesView.swift` dosyasında `sampleActivities` array'ini düzenleyerek yeni aktiviteler ekleyebilirsiniz.

## 📱 Test Etme

1. Hamilelik modu testi:
   - Bebek bilgilerinde doğum tarihi boş bırakın
   - Haftalık gelişim ekranını kontrol edin

2. Bebek modu testi:
   - Doğum tarihi girin
   - Aylık gelişim ekranını kontrol edin
   - Aşı takvimini kontrol edin

3. Bildirim testi:
   - Simulator'da Date & Time ayarlarını değiştirin
   - Aşı hatırlatmalarını test edin

## 🚀 Release Hazırlığı

App Store'a yüklemeden önce:
1. Bundle version'ı artırın
2. Release build yapın
3. Archive oluşturun
4. App Store Connect'e yükleyin

---

**İyi geliştirmeler! 👶📱**
