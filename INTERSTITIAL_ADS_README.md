# 🎯 Interstitial Ads System

Bu dokümantasyon, uygulamada her 15 route işleminde bir gösterilen interstitial reklam sistemini açıklar.

## 📋 Genel Bakış

Interstitial reklamlar, kullanıcılar sayfalar arasında geçiş yaparken tam ekran olarak gösterilen reklamlardır. Bu sistem, kullanıcı deneyimini bozmadan gelir elde etmeyi amaçlar.

## ⚙️ Teknik Detaylar

### Route Takip Sistemi

- **Sayaç**: Her route değişikliğinde `_routeCounter` artırılır
- **Geri Çıkış Takibi**: Sayfadan geri çıkışlar da route olarak sayılır
- **Eşik**: 15 route sonra reklam gösterilir
- **Sıfırlama**: Reklam gösterildikten sonra sayaç sıfırlanır

### Reklam Yönetimi

- **Otomatik Yükleme**: Uygulama başlatıldığında ilk reklam yüklenir
- **Önbellekleme**: Bir reklam gösterildikten sonra otomatik olarak yeni reklam yüklenir
- **Hata Yönetimi**: Yükleme başarısız olursa exponential backoff ile tekrar denenir

## 🚀 Kullanım

### Temel Kullanım

```dart
// Her route değişikliğinde çağrılır
context.read<AdmobProvider>().onRouteChanged();

// Her geri çıkışta çağrılır
context.read<AdmobProvider>().onBackNavigation();
```

### Debug Bilgileri

```dart
// Debug bilgilerini al
final debugInfo = admobProvider.getDebugInfo();
```

## 📱 Debug Widget

Geliştirici modunda (`kDebugMode = true`) ana ekranda debug widget'ı görünür:

### Özellikler

- **Route Counter**: Mevcut route sayısı / 15
- **Next Ad In**: Bir sonraki reklama kalan route sayısı
- **Total Routes**: Toplam takip edilen route sayısı (ileri + geri)
- **Total Ads Shown**: Gösterilen toplam reklam sayısı
- **Ad Loading**: Reklam yükleme durumu
- **Last Ad**: Son reklam gösterim zamanı

## 🔧 Konfigürasyon

### Reklam Sıklığı

```dart
static const int _routesBeforeAd = 15; // Her 15 route'da bir reklam
```

### Yeniden Deneme Limitleri

```dart
final int maxFailedAttempt = 3; // Maksimum 3 başarısız deneme
```

### Yeniden Deneme Gecikmeleri

```dart
// Exponential backoff: 2s, 4s, 6s
final delay = Duration(seconds: _interstitialLoadAttempts * 2);
```

## 📊 Performans Metrikleri

### Takip Edilen Veriler

- Toplam route sayısı
- Gösterilen reklam sayısı
- Son reklam gösterim zamanı
- Reklam yükleme durumu
- Başarısız yükleme denemeleri

### Debug Bilgileri

```dart
Map<String, dynamic> debugInfo = {
  'routeCounter': 5,
  'routesBeforeAd': 15,
  'totalAdsShown': 2,
  'totalRoutesTracked': 35,
  'lastAdShownTime': '2024-01-15T10:30:00.000Z',
  'isAdLoading': false,
  'interstitialLoadAttempts': 0,
  'hasInterstitialAd': true,
};
```

## 🛡️ Hata Yönetimi

### Yükleme Hataları

1. **İlk Deneme**: Hemen tekrar dene
2. **İkinci Deneme**: 2 saniye sonra tekrar dene
3. **Üçüncü Deneme**: 4 saniye sonra tekrar dene
4. **Limit Aşıldı**: Daha fazla deneme yapma

### Gösterim Hataları

- Reklam gösterilemezse otomatik olarak yeni reklam yüklenir
- Hata durumunda kullanıcı deneyimi etkilenmez

## 📍 Entegrasyon Noktaları

### Ana Ekran

- `home_view.dart`: Debug widget eklendi

### Route Değişiklikleri

- `elements_list_view.dart`: Element detay sayfasına geçiş + geri çıkış
- `metal_group_view.dart`: Metal grup sayfalarına geçiş + geri çıkış
- `element_group_view.dart`: Element grup sayfalarına geçiş + geri çıkış
- `quiz_home.dart`: Quiz sayfalarına geçiş + geri çıkış
- `info_view.dart`: Bilgi sayfalarına geçiş + geri çıkış
- `home_view.dart`: Ana ekran navigasyonları + geri çıkış

## 🎨 UI Bileşenleri

### Debug Widget

- **InterstitialDebugWidget**: Tam özellikli debug paneli
- **CompactInterstitialDebugWidget**: Kompakt debug bilgisi

### Görsel Özellikler

- Koyu mavi arka plan
- Yeşil kenarlık
- Emoji ikonlar
- Responsive tasarım

## 📈 Gelecek Geliştirmeler

### Planlanan Özellikler

- [ ] A/B testing için farklı reklam sıklıkları
- [ ] Kullanıcı segmentasyonu
- [ ] Reklam performans analitikleri
- [ ] Otomatik reklam sıklığı optimizasyonu

### Teknik İyileştirmeler

- [ ] Reklam önbellekleme stratejileri
- [ ] Network durumuna göre reklam yükleme
- [ ] Battery optimization
- [ ] Offline reklam desteği

## 🚨 Önemli Notlar

### Kullanıcı Deneyimi

- Reklamlar her 15 route'da bir gösterilir
- Kullanıcı akışı kesintiye uğramaz
- Reklam yüklenemezse uygulama çalışmaya devam eder

### Geliştirici Deneyimi

- Debug widget sadece geliştirici modunda görünür
- Manuel kontroller test için mevcuttur
- Detaylı log mesajları console'da görünür

### Performans

- Reklamlar arka planda yüklenir
- Exponential backoff ile yeniden deneme
- Memory leak'leri önlemek için proper disposal

## 📞 Destek

Herhangi bir sorun veya öneri için:

- GitHub Issues kullanın
- Pull Request gönderin
- Dokümantasyonu güncelleyin

---

**Son Güncelleme**: 2024-01-15
**Versiyon**: 1.0.0
**Geliştirici**: Elements App Team
