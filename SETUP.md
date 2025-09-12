# Setup Guide

Bu proje hassas bilgileri (API keys, AdMob IDs, Firebase config) içerir. Bu dosyalar güvenlik nedeniyle `.gitignore` dosyasına eklenmiştir.

## Gerekli Dosyalar

Aşağıdaki dosyaları oluşturmanız gerekiyor:

### 1. Firebase Configuration

#### Android

```bash
# Template dosyasını kopyalayın
cp android/app/google-services.json.template android/app/google-services.json

# Dosyayı düzenleyin ve gerçek değerleri girin
```

#### iOS

```bash
# Template dosyasını kopyalayın
cp ios/Runner/GoogleService-Info.plist.template ios/Runner/GoogleService-Info.plist

# Dosyayı düzenleyin ve gerçek değerleri girin
```

### 2. Firebase Options

```bash
# Template dosyasını kopyalayın
cp lib/firebase_options.dart.template lib/firebase_options.dart

# Dosyayı düzenleyin ve gerçek API key'leri girin
```

### 3. Google Ads Service

```bash
# Template dosyasını kopyalayın
cp lib/feature/service/google_ads_service.dart.template lib/feature/service/google_ads_service.dart

# Dosyayı düzenleyin ve gerçek AdMob ID'lerini girin
```

## Firebase Setup

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. Projenizi oluşturun veya mevcut projeyi seçin
3. Android ve iOS uygulamalarını ekleyin
4. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını indirin
5. Bu dosyaları yukarıdaki adımlara göre yerleştirin

## AdMob Setup

1. [AdMob Console](https://apps.admob.com/)'a gidin
2. Uygulamanızı oluşturun
3. Ad unit'leri oluşturun (Banner, Interstitial)
4. Ad unit ID'lerini `google_ads_service.dart` dosyasına ekleyin

## Önemli Notlar

- **Asla gerçek API key'leri ve ID'leri Git'e commit etmeyin**
- Template dosyaları Git'te tutulur, gerçek dosyalar `.gitignore`'da
- Her geliştirici kendi Firebase ve AdMob projelerini oluşturmalı
- Production'da farklı API key'ler kullanın

## Güvenlik

Bu setup, GitHub'da tespit edilen güvenlik uyarılarını önlemek için tasarlanmıştır. Hassas bilgiler artık version control'de tutulmayacak.
