# আমল ট্র্যাকার (Amal Tracker)

**Professional Bengali Islamic Amal Tracker App**

A comprehensive Flutter application for tracking Islamic daily practices (Amal) including prayer times, dhikr counters, daily checklists, Quran/Hadith reading, and detailed analytics—fully in Bangla.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)

## ✨ Features

### 🕌 নামাজ ট্র্যাকার (Prayer Tracker)
- Real-time prayer times based on GPS location
- Islamic Foundation Bangladesh calculation method
- Hanafi madhab support for accurate Asr timing
- Complete rakat tracking (Fard, Sunnah, Nafl, Witr)
- Individual prayer completion with checkboxes
- Prayer time countdown to next Salah
- Automatic daily reset

### 📿 যিকির কাউন্টার (Dhikr Counter)
- Default dhikr list with Arabic text
- Customizable target counts (33, 100, etc.)
- Haptic feedback on tap
- Visual progress indicators
- Add custom dhikr items
- Daily statistics tracking

### ✅ প্রতিদিনের আমল (Daily Amal Checklist)
- Pre-configured daily Islamic tasks:
  - মিসওয়াক (6 times daily)
  - নামাজের পর আযকার (5 times)
  - দৈনিক সূরা (ইয়াসিন, ওয়াকিয়া, মুলক)
  - সকাল-সন্ধ্যার দোয়া
- Category-wise organization
- Completion tracking with timestamps
- Add custom items

### 📖 পড়াশোনা ট্র্যাকার (Reading Tracker)
- Track Quran, Tafsir, and Hadith reading
- Session-based logging with duration
- Surah/Ayah tracking for Quran
- Page/chapter tracking for books
- Daily reading goals (minutes)
- Progress visualization

### 📊 পরিসংখ্যান (Statistics & Analytics)
- **Weekly View**:
  - 7-day bar chart with dynamic day labels
  - Category-wise progress (নামাজ, আমল, যিকির, পড়াশোনা)
  - Weekly summary with totals
- **Monthly View**:
  - Interactive calendar with color-coded days
  - Click any date to see detailed breakdown
  - Monthly progress chart
  - Monthly summary statistics
- **Streak Tracking**:
  - Current streak counter
  - Best streak record
  - Perfect day indicators (80%+ completion)

### 🏠 হোম ড্যাশবোর্ড (Home Dashboard)
- Greeting card with date in Bengali
- Real-time prayer times display
- Next prayer countdown
- Today's progress section with:
  - Overall completion percentage
  - Animated progress bar
  - Dynamic color based on progress
  - Motivational messages
- Quick access cards to all features

### 🔔 নোটিফিকেশন (Notifications)
- Prayer time reminders (15-30 mins before)
- Custom reminder scheduler
- Time-based notifications
- Android 13+ notification permission support

### ⚙️ সেটিংস (Settings)
- Notification preferences per prayer
- Custom reminder management
- Prayer time adjustments (+/- minutes)
- Theme customization

## 🎨 Design

- **Theme**: Dark mode with Gold (#D4AF37) accent
- **Font**: Hind Siliguri (Bengali)
- **Colors**:
  - Background: #0A0A0A, #1A1A1A
  - Primary: #D4AF37 (Gold)
  - Success: #4CAF50
  - Warning: #FF9800
  - Error: #E57373

## 📁 Project Structure

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
│   │   ├── prayer_tracking_model.dart
│   │   ├── dhikr_counter_model.dart
│   │   ├── daily_amal_model.dart
│   │   ├── reading_tracker_model.dart
│   │   └── statistics_model.dart
│   └── services/
│       ├── prayer_time_service.dart
│       ├── permission_service.dart
│       └── notification_service.dart
├── presentation/
│   ├── providers/
│   │   ├── prayer_times_provider.dart
│   │   ├── prayer_tracking_provider.dart
│   │   ├── daily_amal_provider.dart
│   │   ├── dhikr_counter_provider.dart
│   │   ├── reading_tracker_provider.dart
│   │   ├── statistics_provider.dart
│   │   ├── notification_settings_provider.dart
│   │   └── custom_reminders_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── prayer/
│   │   │   └── prayer_tracker_screen.dart
│   │   ├── dhikr/
│   │   │   └── dhikr_counter_screen.dart
│   │   ├── daily_amal/
│   │   │   └── daily_amal_screen.dart
│   │   ├── reading/
│   │   │   └── reading_tracker_screen.dart
│   │   ├── statistics/
│   │   │   ├── statistics_screen.dart
│   │   │   └── widgets/
│   │   │       ├── streak_card.dart
│   │   │       ├── tab_selector.dart
│   │   │       ├── weekly_progress_chart.dart
│   │   │       ├── monthly_calendar_view.dart
│   │   │       ├── category_progress_section.dart
│   │   │       ├── weekly_summary_section.dart
│   │   │       └── day_details_sheet.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── notifications/
│   │       └── reminders_screen.dart
│   └── widgets/
└── main.dart
```

## 🛠️ Tech Stack

### Core
- **Flutter** 3.0+ - Cross-platform framework
- **Dart** 3.0+ - Programming language
- **Riverpod** 2.5+ - State management

### Storage
- **Hive** 4.x - Local NoSQL database
- **Shared Preferences** - Simple key-value storage

### Prayer Times
- **adhan_dart** - Islamic prayer time calculations
- **geolocator** - GPS location services

### Notifications
- **flutter_local_notifications** - Local push notifications
- **timezone** - Timezone support

### UI/UX
- **fl_chart** - Beautiful charts
- **Google Fonts** - Bangla typography
- **shimmer** - Loading animations

## 📱 Screenshots

| হোম | নামাজ | যিকির |
|-----|-------|-------|
| Home Dashboard | Prayer Tracker | Dhikr Counter |

| পরিসংখ্যান (সাপ্তাহিক) | পরিসংখ্যান (মাসিক) |
|------------------------|-------------------|
| Weekly Statistics | Monthly Calendar |

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Android device (API 21+) or iOS device

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/amal-tracker.git
   cd amal-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK**
   ```bash
   flutter build apk --release
   ```

## ⚙️ Configuration

### Prayer Calculation
| Setting | Value |
|---------|-------|
| Method | Islamic Foundation Bangladesh |
| Fajr Angle | 18.5° |
| Isha Angle | 17.5° |
| Madhab | Hanafi |

### Default Prayer Rakats
| Prayer | Rakats |
|--------|--------|
| ফজর | 2 সুন্নত + 2 ফরজ |
| যোহর | 4 সুন্নত + 4 ফরজ + 2 সুন্নত + 2 নফল |
| আসর | 4 সুন্নত + 4 ফরজ |
| মাগরিব | 3 ফরজ + 2 সুন্নত + 2 নফল |
| এশা | 4 সুন্নত + 4 ফরজ + 2 সুন্নত + 2 নফল + 3 বিতর |

### Default Dhikr (100x each)
- لا إله إلا الله (লা ইলাহা ইল্লাল্লাহ)
- ﷺ দুরূদ শরীফ
- أستغفر الله (আস্তাগফিরুল্লাহ)
- سبحان الله (সুবহানাল্লাহ)
- الحمد لله (আলহামদুলিল্লাহ)
- الله أكبر (আল্লাহু আকবার)
- لا حول ولا قوة إلا بالله (লা হাওলা ওয়ালা কুওয়াতা)

## 📋 Data Persistence

All data is stored locally using Hive with the following boxes:
- `prayer_tracking` - Daily prayer records
- `dhikr_counter` - Dhikr sessions
- `daily_amal` - Daily checklist items
- `reading_tracker` - Reading sessions
- `statistics` - Aggregated statistics
- `notification_settings` - Notification preferences
- `custom_reminders` - User-defined reminders

### Data Model Features
- Automatic JSON serialization
- Deep conversion for Hive compatibility
- Cloud-ready with sync metadata fields

## 🔐 Permissions

### Android
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### iOS
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>সঠিক নামাজের সময় নির্ধারণের জন্য লোকেশন প্রয়োজন</string>
```

## 🗓️ Roadmap

### ✅ Completed
- [x] Project foundation & architecture
- [x] Prayer times with GPS
- [x] Prayer tracker with rakat details
- [x] Dhikr counter with custom items
- [x] Daily Amal checklist
- [x] Reading tracker (Quran/Tafsir/Hadith)
- [x] Statistics with weekly/monthly views
- [x] Interactive calendar
- [x] Notifications & reminders
- [x] Settings screen
- [x] Data persistence with Hive
- [x] Bengali localization

### 🔮 Future Features
- [ ] Cloud backup (Firebase/Google Drive)
- [ ] Home screen widget
- [ ] Ramadan mode (Suhoor/Iftar, Taraweeh)
- [ ] Achievement badges & gamification
- [ ] Export/import data (JSON/PDF)
- [ ] Multi-language (English, Arabic)
- [ ] Apple Watch / WearOS support
- [ ] Qibla compass
- [ ] Hijri calendar integration

## 🤝 Contributing

This is a private project. For contributions, please contact the development team.

## 📄 License

Proprietary - All rights reserved © 2026

## 📞 Contact

For questions or support, please contact the development team.

---

**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Last Updated**: January 2, 2026
