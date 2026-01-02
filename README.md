# আমল ট্র্যাকার (Amal Tracker)

**Professional Bengali Islamic Amal Tracker App**

A comprehensive Flutter application for tracking Islamic daily practices (Amal) including prayer times, dhikr counters, daily checklists, Quran/Hadith reading, and detailed analytics—fully in Bangla.

## Features

### ✅ Completed Features
- **Project Foundation**
  - Clean Architecture structure (Data, Domain, Presentation layers)
  - Hive 4.x local database with cloud-ready data models
  - Versioned models with sync metadata for future cloud backup
  - Professional Bangla UI theme (Golden/Teal colors)
  - Full Bangla localization support

- **Prayer Times**
  - Islamic Foundation Bangladesh calculation method (Fajr: 18.5°, Isha: 17.5°)
  - Hanafi madhab support for accurate Asr timing
  - Manual time adjustments (+/- minutes per prayer)
  - Detailed rakat tracking (Fajr: 2S+2F, Dhuhr: 4S+4F+2S, Asr: 4F, Maghrib: 3F+2S, Isha: 4F+2S+3W)

- **Permissions & Notifications**
  - Location permission for accurate prayer times
  - Notification permission (Android 13+ support)
  - Prayer reminders 15-30 minutes before each Salah
  - Custom reminders for any task

- **Data Models**
  - `PrayerRecord` - Daily prayer tracking with rakat counts
  - `DhikrSession` - Dhikr counter with session history
  - `AmalCategory` - Customizable daily Amal categories
  - `ReadingProgress` - Quran/Tafsir/Hadith reading tracker
  - `DailyStats` - Comprehensive daily statistics
  - `AppSettings` - User preferences and configuration

### 🚧 In Progress
- Prayer tracker UI
- Dhikr counter interface
- Daily Amal checklist
- Reading tracker
- Home dashboard
- Analytics & history

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── local/
│   │   └── hive_service.dart
│   ├── models/
│   │   ├── prayer_record.dart
│   │   ├── dhikr_session.dart
│   │   ├── amal_category.dart
│   │   ├── reading_progress.dart
│   │   ├── daily_stats.dart
│   │   └── app_settings.dart
│   └── services/
│       ├── prayer_time_service.dart
│       ├── permission_service.dart
│       └── notification_service.dart
├── domain/
│   └── (Business logic - TBD)
├── presentation/
│   ├── screens/
│   │   └── splash/
│   └── widgets/
│       └── (Reusable widgets - TBD)
└── main.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Android device/emulator (API 21+) or iOS device/simulator

### Installation

1. **Clone the repository**
   ```bash
   cd "d:\work\app development\amal-tracker"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Download Bangla font**
   - Download "Hind Siliguri" font from Google Fonts
   - Place font files in `assets/fonts/`:
     - `HindSiliguri-Regular.ttf`
     - `HindSiliguri-Bold.ttf`

4. **Add app icon**
   - Place app icon in `assets/images/`
   - Update `@mipmap/ic_launcher` in notification service

5. **Run the app**
   ```bash
   flutter run
   ```

## Dependencies

### Core
- `flutter_riverpod: ^2.5.1` - State management
- `hive: ^4.0.0-dev.2` - Local NoSQL database
- `easy_localization: ^3.0.7` - Internationalization

### Prayer & Location
- `adhan_dart: ^2.0.0` - Prayer time calculations
- `permission_handler: ^11.3.1` - Runtime permissions

### Notifications
- `flutter_local_notifications: ^17.2.2` - Local notifications
- `timezone: ^0.9.4` - Timezone support

### UI & Charts
- `fl_chart: ^0.69.0` - Analytics charts
- `google_fonts: ^6.2.1` - Bangla font support
- `shimmer: ^3.0.0` - Loading animations

### Utilities
- `uuid: ^4.5.1` - Unique ID generation
- `path_provider: ^2.1.2` - File system paths
- `shared_preferences: ^2.3.2` - Simple data persistence

## Configuration

### Prayer Calculation
- **Method**: Islamic Foundation Bangladesh
- **Fajr Angle**: 18.5°
- **Isha Angle**: 17.5°
- **Madhab**: Hanafi (affects Asr calculation)

### Default Prayer Rakats
- **Fajr**: 2 Sunnah + 2 Fard
- **Dhuhr**: 4 Sunnah + 4 Fard + 2 Sunnah
- **Asr**: 4 Fard
- **Maghrib**: 3 Fard + 2 Sunnah
- **Isha**: 4 Fard + 2 Sunnah + 3 Witr

### Default Dhikr List (100x each)
- লা ইলাহা ইল্লাল্লাহ
- দুরূদ শরীফ
- আস্তাগফিরুল্লাহ
- সুবহানাল্লাহ
- আলহামদুলিল্লাহ
- আল্লাহু আকবার

### Daily Amal Categories
- **Miswak**: 6 times (after each prayer + before sleep)
- **Post-Prayer Azkar**: 5 times (after each prayer)
- **Daily Surahs**: Yasin, Waqiah, Mulk
- **Daily Duas**: Morning/evening duas

## Data Models

All models include cloud-ready fields:
- `id` (UUID)
- `modelVersion` (for schema migrations)
- `createdAt`, `updatedAt` (timestamps)
- `syncStatus` (synced, pending, failed)
- `lastSyncedAt` (last cloud sync time)

This enables future cloud backup implementation with **last-write-wins** conflict resolution strategy.

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>সঠিক নামাজের সময় নির্ধারণের জন্য লোকেশন প্রয়োজন</string>
<key>NSNotificationUsageDescription</key>
<string>নামাজের সময় এবং রিমাইন্ডারের জন্য নোটিফিকেশন প্রয়োজন</string>
```

## Next Steps

1. ✅ ~~Setup project foundation~~
2. ✅ ~~Create data models with versioning~~
3. ✅ ~~Implement prayer time service~~
4. ✅ ~~Add permission handlers~~
5. ✅ ~~Setup notification service~~
6. 🚧 Build prayer tracker UI
7. 🚧 Implement dhikr counter
8. 🚧 Create daily Amal checklist
9. 🚧 Build reading tracker
10. 🚧 Implement home widget
11. 🚧 Add analytics & charts
12. 🚧 Design professional UI

## Future Features

- ☁️ Cloud backup (Firebase/Google Drive)
- 📊 Advanced analytics & insights
- 🌙 Ramadan mode (Suhoor/Iftar times, Taraweeh tracker)
- 🎯 Achievement badges & streaks
- 📤 Export/import data (JSON)
- 🌐 Multi-language support (English, Arabic)

## License

Proprietary - All rights reserved

## Contact

For questions or support, please contact the development team.

---

**Development Status**: In Progress (Foundation Complete)
**Last Updated**: January 1, 2026
