# আমল ট্র্যাকার (Amal Tracker)

**Professional Bengali Islamic Amal Tracker App with Cloud Sync**

A comprehensive Flutter application for tracking Islamic daily practices (Amal) including prayer times, dhikr counters, daily checklists, Quran/Hadith reading, sin tracking with Kaffara system, detailed analytics, and cloud synchronization—fully in Bangla.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)

## 🌟 Highlights

- ✅ **Real-time Prayer Times** with GPS-based accurate calculation
- 📿 **Dhikr Counter** with custom targets and haptic feedback
- ✅ **Daily Amal Checklist** with 30+ pre-configured Islamic tasks
- 📖 **Quran & Hadith Reading Tracker** with progress visualization
- 🚫 **Sin Tracker with Kaffara System** (fasting/feeding calculation)
- 📊 **Advanced Analytics** with weekly/monthly views and streaks
- ☁️ **Cloud Sync** with Firebase for multi-device support
- 🔐 **Email Authentication** with verification
- 🌙 **Beautiful Dark Theme** with gold accents

## ✨ Features

### � অথেন্টিকেশন (Authentication)
- Email/Password authentication with Firebase
- Email verification system
- Secure login with password reset
- User profile management
- Display name customization

### ☁️ ক্লাউড সিংক (Cloud Sync)
- **Real-time Auto Sync**: Data automatically syncs to Firebase on changes
- **Offline Support**: Works offline, syncs when internet is available
- **Multi-device**: Access your data from any device
- **Manual Backup/Restore**: Full data backup and restore options
- **Firestore Integration**: Secure cloud storage with offline persistence

### 🕌 নামাজ ট্র্যাকার (Prayer Tracker)
- Real-time prayer times based on GPS location
- Islamic Foundation Bangladesh calculation method
- Hanafi madhab support for accurate Asr timing
- Complete rakat tracking (Fard, Sunnah, Nafl, Witr)
- Individual prayer completion with checkboxes
- Prayer time countdown to next Salah
- Automatic daily reset
- **Cloud sync enabled**

### 📿 যিকির কাউন্টার (Dhikr Counter)
- Default dhikr list with Arabic text
- Customizable target counts (33, 100, etc.)
- Haptic feedback on tap
- Visual progress indicators
- Add custom dhikr items
- Daily statistics tracking
- **Cloud sync enabled**

### ✅ প্রতিদিনের আমল (Daily Amal Checklist)
- Pre-configured daily Islamic tasks:
  - মিসওয়াক (6 times daily)
  - নামাজের পর আযকার (5 times)
  - দৈনিক সূরা (ইয়াসিন, ওয়াকিয়া, মুলক)
  - সকাল-সন্ধ্যার দোয়া
  - কুরআন তিলাওয়াত, তাফসীর পড়া
  - হাদীস পড়া, ইসলামী বই পড়া
  - সাদকাহ, পিতা-মাতার সেবা
  - আত্মীয়তার সম্পর্ক রক্ষা
  - অসুস্থ দেখা, জানাযায় অংশগ্রহণ
- Category-wise organization
- Completion tracking with timestamps
- Add custom items
- **Cloud sync enabled**

### 📖 পড়াশোনা ট্র্যাকার (Reading Tracker)
- Track Quran, Tafsir, and Hadith reading
- Session-based logging with duration
- Surah/Ayah tracking for Quran
- Page/chapter tracking for books
- Daily reading goals (minutes)
- Progress visualization
- **Cloud sync enabled**

### 🚫 গুনাহ ট্র্যাকার (Sin Tracker with Kaffara)
- Track different types of sins
- Pre-configured sin categories (Kabira & Saghira)
- Custom sin types support
- **Kaffara Calculator**:
  - Automatic calculation of fasting days required
  - Feeding cost calculation (60 poor people per day)
  - Mixed compensation (fast + feed) support
  - Current rate: ৳100 per person
- Statistics:
  - Total sins tracked
  - Sins requiring Kaffara
  - Total fasting days needed
  - Total feeding cost
  - Total compensation calculation
- Daily tracking with timestamps
- **Cloud sync enabled**

### 📊 পরিসংখ্যান (Statistics & Analytics)
- **Weekly View**:
  - 7-day bar chart with dynamic day labels
  - Category-wise progress (নামাজ, আমল, যিকির, পড়াশোনা, গুনাহ)
  - Weekly summary with totals
  - Color-coded performance indicators
- **Monthly View**:
  - Interactive calendar with color-coded days
  - Click any date to see detailed breakdown
  - Monthly progress chart
  - Monthly summary statistics
- **Streak Tracking**:
  - Current streak counter
  - Best streak record
  - Perfect day indicators (80%+ completion)
  - Motivation messages

### 🏠 হোম ড্যাশবোর্ড (Home Dashboard)
- Greeting card with Hijri and Gregorian dates in Bengali
- Real-time prayer times display
- Next prayer countdown with automatic updates
- Today's progress section with:
  - Overall completion percentage
  - Animated circular progress bar
  - Dynamic color based on progress (Red < 50% < Orange < 80% < Green)
  - Motivational messages in Bengali
- Quick access cards to all features:
  - নামাজ (Prayer)
  - আমল (Daily Tasks)
  - যিকির (Dhikr)
  - পড়াশোনা (Reading)
  - গুনাহ (Sin Tracker)
  - পরিসংখ্যান (Statistics)

### 👤 প্রোফাইল (Profile)
- User information display
- Display name editing
- Email verification status
- Account creation date
- **Cloud sync controls**:
  - Manual backup button
  - Manual restore button
  - Auto-sync status indicator
- Logout functionality

### 🔔 নোটিফিকেশন (Notifications)
- Prayer time reminders (15-30 mins before)
- Custom reminder scheduler
- Time-based notifications
- Android 13+ notification permission support
- Configurable per-prayer notifications

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
│   │   └── app_constants.dart          # App-wide constants
│   └── theme/
│       └── app_theme.dart              # Theme configuration
├── data/
│   ├── local/
│   │   └── hive_service.dart           # Local database service
│   ├── models/
│   │   ├── prayer_tracking_model.dart  # Prayer data model
│   │   ├── dhikr_counter_model.dart    # Dhikr data model
│   │   ├── daily_amal_model.dart       # Daily amal model
│   │   ├── reading_tracker_model.dart  # Reading tracker model
│   │   ├── sin_tracker_model.dart      # Sin tracker model
│   │   └── statistics_model.dart       # Statistics model
│   └── services/
│       ├── prayer_time_service.dart    # Prayer time calculations
│       ├── permission_service.dart     # Permission handling
│       ├── notification_service.dart   # Local notifications
│       └── firestore_sync_service.dart # Cloud sync service
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart              # Authentication state
│   │   ├── prayer_times_provider.dart      # Prayer times state
│   │   ├── prayer_tracking_provider.dart   # Prayer tracking state
│   │   ├── daily_amal_provider.dart        # Daily amal state
│   │   ├── dhikr_counter_provider.dart     # Dhikr counter state
│   │   ├── reading_tracker_provider.dart   # Reading tracker state
│   │   ├── sin_tracker_provider.dart       # Sin tracker state
│   │   ├── statistics_provider.dart        # Statistics state
│   │   ├── notification_settings_provider.dart
│   │   └── custom_reminders_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   └── auth_screen.dart            # Login/Register/Forgot Password
│   │   ├── home/
│   │   │   └── home_screen.dart            # Main dashboard
│   │   ├── prayer/
│   │   │   └── prayer_tracker_screen.dart  # Prayer tracking
│   │   ├── dhikr/
│   │   │   └── dhikr_counter_screen.dart   # Dhikr counter
│   │   ├── daily_amal/
│   │   │   └── daily_amal_screen.dart      # Daily checklist
│   │   ├── reading/
│   │   │   └── reading_tracker_screen.dart # Reading tracker
│   │   ├── sin_tracker/
│   │   │   ├── sin_tracker_screen.dart     # Sin tracking
│   │   │   └── widgets/
│   │   │       ├── sin_type_manager.dart   # Manage sin types
│   │   │       ├── add_sin_dialog.dart     # Add sin entry
│   │   │       └── kaffara_calculator.dart # Kaffara calculation
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
│   │   ├── profile/
│   │   │   └── profile_screen.dart         # User profile & cloud sync
│   │   ├── settings/
│   │   │   └── settings_screen.dart        # App settings
│   │   └── notifications/
│   │       └── reminders_screen.dart       # Custom reminders
│   └── widgets/
│       └── [shared widgets]
└── main.dart                               # App entry point
```

## 🛠️ Tech Stack

### Core
- **Flutter** 3.0+ - Cross-platform framework
- **Dart** 3.0+ - Programming language
- **Riverpod** 2.5+ - State management with provider pattern

### Storage & Sync
- **Hive** 2.2+ - Local NoSQL database for offline-first storage
- **Shared Preferences** 2.3+ - Simple key-value storage
- **Firebase Core** 3.8+ - Firebase SDK initialization
- **Cloud Firestore** 5.6+ - Cloud database with offline persistence
- **Firebase Auth** 5.3+ - Authentication service

### Prayer Times & Location
- **adhan_dart** 1.2+ - Islamic prayer time calculations (ISNA/IFB methods)
- **geolocator** 13.0+ - GPS location services with permission handling

### Notifications & Scheduling
- **flutter_local_notifications** 17.2+ - Local push notifications
- **timezone** 0.9+ - Timezone support for accurate scheduling
- **flutter_timezone** 3.0+ - Device timezone detection

### UI/UX & Charts
- **fl_chart** 0.69+ - Beautiful interactive charts (bar, line, pie)
- **Google Fonts** 6.2+ - Bangla typography (Hind Siliguri)
- **shimmer** 3.0+ - Loading skeleton animations
- **flutter_svg** 2.0+ - SVG rendering support

### Localization
- **easy_localization** 3.0+ - Internationalization framework
- **intl** 0.20+ - Date/number formatting

### Utilities
- **uuid** 4.5+ - Unique ID generation
- **url_launcher** 6.3+ - External URL handling
- **permission_handler** 11.3+ - Runtime permissions
- **path_provider** 2.1+ - File system paths

## 📱 Screenshots

| হোম | নামাজ | যিকির | আমল |
|-----|-------|-------|------|
| Home Dashboard with Progress | Prayer Times & Tracker | Dhikr Counter | Daily Amal Checklist |

| পড়াশোনা | গুনাহ ট্র্যাকার | পরিসংখ্যান (সাপ্তাহিক) | পরিসংখ্যান (মাসিক) |
|----------|----------------|------------------------|-------------------|
| Reading Tracker | Sin Tracker with Kaffara | Weekly Statistics | Monthly Calendar |

| লগইন | প্রোফাইল | সেটিংস |
|------|----------|---------|
| Authentication | Profile & Cloud Sync | Settings & Notifications |

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- Android device (API 21+) or iOS device (iOS 12+)
- Firebase account (for cloud sync features)

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

3. **Firebase Setup** (Required for cloud sync)
   - Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Authentication** with Email/Password provider
   - Enable **Cloud Firestore** database
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build APK** (Android)
   ```bash
   flutter build apk --release
   ```

6. **Build IPA** (iOS)
   ```bash
   flutter build ios --release
   ```

### Firebase Configuration

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Firestore Data Structure:**
```
users/{userId}/
  ├── data/
  │   ├── prayer_tracking/days/{date}
  │   ├── daily_amal/days/{date}
  │   ├── dhikr_counter/days/{date}
  │   ├── reading_tracker/days/{date}
  │   ├── sin_tracker/days/{date}
  │   ├── sin_types
  │   └── custom_reminders
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

### Sin Types & Kaffara
| Sin Category | Type | Kaffara Required | Calculation |
|--------------|------|------------------|-------------|
| গীবত (Backbiting) | Kabira | Yes | 60 days fasting OR ৳6,000 |
| মিথ্যা (Lying) | Saghira | No | - |
| হিংসা (Envy) | Saghira | No | - |
| অহংকার (Pride) | Kabira | Yes | 60 days fasting OR ৳6,000 |
| সময় নষ্ট (Wasting time) | Saghira | No | - |

**Kaffara Calculation Formula:**
- 1 Major Sin = 60 days fasting OR 60 poor people × ৳100/person = ৳6,000
- Mixed option: Some fasting + remaining as feeding cost

## 📋 Data Persistence

### Local Storage (Hive)
All data is stored locally using Hive NoSQL database for offline-first functionality:

| Box Name | Purpose | Cloud Sync |
|----------|---------|------------|
| `prayer_tracking` | Daily prayer records with rakat details | ✅ Auto |
| `dhikr_counter` | Dhikr sessions and counts | ✅ Auto |
| `daily_amal` | Daily checklist completion | ✅ Auto |
| `reading_tracker` | Quran/Hadith reading sessions | ✅ Auto |
| `sin_tracker` | Sin entries with dates | ✅ Auto |
| `sin_types` | Custom sin type configurations | ✅ Auto |
| `statistics` | Aggregated analytics data | ❌ Local only |
| `notification_settings` | Notification preferences | ❌ Local only |
| `custom_reminders` | User-defined reminders | ✅ Auto |
| `auth_cache` | Authentication cache | ❌ Local only |

### Cloud Storage (Firestore)
- **Real-time Sync**: Changes automatically sync to Firestore when online
- **Offline Persistence**: Firestore caches data locally for offline access
- **Automatic Retry**: Failed syncs are retried when connection is restored
- **Conflict Resolution**: Last-write-wins strategy with server timestamps
- **Data Structure**: Organized by user → category → days/entries

### Data Flow
```
User Action → Local Hive Update → Firestore Sync (if online)
                                → Queued for sync (if offline)
                                
Login → Restore from Firestore → Update Local Hive → Refresh UI
```

### Backup & Restore
- **Auto Backup**: Every data change is automatically backed up to cloud
- **Manual Backup**: Full data upload via profile screen
- **Auto Restore**: Data automatically restored on login
- **Manual Restore**: Full data download via profile screen
- **Multi-device**: Same account works across multiple devices

## 🔐 Permissions

### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

**Purpose:**
- `INTERNET` - Firebase cloud sync
- `ACCESS_FINE_LOCATION` - Accurate prayer times based on GPS
- `POST_NOTIFICATIONS` - Prayer time reminders (Android 13+)
- `SCHEDULE_EXACT_ALARM` - Precise notification scheduling
- `RECEIVE_BOOT_COMPLETED` - Restore alarms after device restart
- `VIBRATE` - Notification haptic feedback
- `WAKE_LOCK` - Background notification delivery

### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>সঠিক নামাজের সময় নির্ধারণের জন্য লোকেশন প্রয়োজন</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>নামাজের সময় রিমাইন্ডার পাঠানোর জন্য লোকেশন প্রয়োজন</string>
```

## 🗓️ Development Roadmap

### ✅ Phase 1: Core Features (Completed)
- [x] Project foundation & clean architecture
- [x] Prayer times with GPS & Hanafi madhab
- [x] Prayer tracker with detailed rakat tracking
- [x] Dhikr counter with custom items & haptic feedback
- [x] Daily Amal checklist (30+ pre-configured tasks)
- [x] Reading tracker (Quran/Tafsir/Hadith)
- [x] Sin tracker with Kaffara calculation system
- [x] Statistics with weekly/monthly views
- [x] Interactive calendar with day details
- [x] Streak tracking & motivation system
- [x] Notifications & custom reminders
- [x] Settings screen with preferences
- [x] Data persistence with Hive
- [x] Bengali localization throughout

### ✅ Phase 2: Cloud Sync (Completed)
- [x] Firebase integration
- [x] Email/Password authentication
- [x] Email verification system
- [x] User profile management
- [x] Cloud Firestore data sync
- [x] Offline persistence with auto-sync
- [x] Multi-device support
- [x] Manual backup/restore options
- [x] Auto-restore on login

### 🔮 Phase 3: Enhanced Features (Planned)
- [ ] Home screen widget (Prayer times & today's progress)
- [ ] Ramadan mode:
  - [ ] Suhoor/Iftar timings
  - [ ] Taraweeh tracker
  - [ ] Sadaqah/Charity log
  - [ ] 30-day Quran completion tracker
- [ ] Achievement badges & gamification:
  - [ ] Perfect week badges
  - [ ] Prayer consistency awards
  - [ ] Reading milestone badges
- [ ] Export data (JSON/PDF/CSV)
- [ ] Import data from backup files
- [ ] Qibla compass with GPS
- [ ] Hijri calendar integration
- [ ] 99 Names of Allah with meanings
- [ ] Dua collection in Bengali

### 🌍 Phase 4: Expansion (Future)
- [ ] Multi-language support:
  - [ ] English interface
  - [ ] Arabic transliteration
  - [ ] Urdu interface
- [ ] Social features:
  - [ ] Family group tracking
  - [ ] Motivational quotes sharing
  - [ ] Community challenges
- [ ] Advanced analytics:
  - [ ] Yearly comparison charts
  - [ ] Habit formation insights
  - [ ] Personalized recommendations
- [ ] Platform expansion:
  - [ ] Apple Watch companion app
  - [ ] WearOS support
  - [ ] iPad/tablet optimization
  - [ ] Desktop app (Windows/macOS/Linux)
- [ ] Accessibility:
  - [ ] Voice commands
  - [ ] Screen reader optimization
  - [ ] High contrast mode

## 🏗️ Architecture

### Design Pattern
- **Clean Architecture** with separation of concerns
- **MVVM** (Model-View-ViewModel) pattern
- **Repository Pattern** for data access
- **Provider Pattern** (Riverpod) for state management

### Layers
```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (Screens, Widgets, Providers)      │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│       Domain Layer                  │
│    (Business Logic, Models)         │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│        Data Layer                   │
│  (Hive, Firestore, Services)        │
└─────────────────────────────────────┘
```

### State Management
- **Riverpod** for reactive state
- **ConsumerWidget** for UI updates
- **FutureProvider** for async data
- **StateNotifierProvider** for complex state

### Offline-First Strategy
1. User action triggers local Hive update
2. UI updates immediately from local data
3. Background sync to Firestore (if online)
4. Offline changes queued automatically
5. Auto-sync when connection restored

## 🔧 Key Technologies Explained

### Prayer Time Calculation
- **Library**: adhan_dart
- **Method**: Islamic Foundation Bangladesh (IFB)
- **Madhab**: Hanafi (Asr calculation)
- **Accuracy**: GPS-based coordinates with timezone support
- **Adjustments**: Manual +/- minutes for local variations

### Cloud Sync Architecture
- **Strategy**: Optimistic UI updates with background sync
- **Conflict Resolution**: Server timestamp wins
- **Security**: Firebase Auth with Firestore rules
- **Offline**: Full offline support with Firestore cache
- **Sync Trigger**: On data change, login, and manual request

### Notification System
- **Local Notifications**: flutter_local_notifications
- **Scheduling**: Exact alarms with timezone support
- **Channels**: Prayer reminders, custom reminders
- **Android 13+**: Runtime permission handling
- **Persistence**: Reschedule on device boot

## 🤝 Contributing

This is a private project. For contributions:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable/function names
- Add comments for complex logic
- Write widget tests for UI components
- Bengali strings in separate localization files

## 🐛 Known Issues & Limitations

- **iOS Background Notifications**: Limited by iOS restrictions
- **Battery Optimization**: Some devices may kill background alarms
- **Prayer Time Accuracy**: Depends on GPS accuracy and internet connection
- **Offline Sync**: Large data sets may take time to sync on reconnection
- **Android 12+**: Exact alarm permission required for precise notifications

## 📄 License

Proprietary - All rights reserved © 2026

**Terms:**
- Personal and educational use permitted
- Commercial use requires explicit permission
- Modification and redistribution prohibited without authorization
- No warranty or liability provided

## 👨‍💻 Developer

Developed with ❤️ for the Muslim Ummah

## 📞 Contact & Support

- **Email**: support@amaltracker.com
- **Issues**: GitHub Issues section
- **Discussions**: GitHub Discussions
- **Updates**: Check releases for latest features

## 🙏 Acknowledgments

- **adhan_dart** for accurate prayer time calculations
- **Flutter** team for the amazing framework
- **Firebase** for cloud infrastructure
- Islamic Foundation Bangladesh for calculation methods
- Muslim community for feedback and suggestions

---

**Project Status**: ✅ Production Ready  
**Current Version**: 1.0.0  
**Last Updated**: January 2, 2026  
**Minimum Flutter**: 3.0.0  
**Minimum Dart**: 3.0.0  
**Target Platforms**: Android 5.0+, iOS 12.0+

---

<div align="center">

### جَزَاكَ ٱللَّٰهُ خَيْرًا
*May Allah reward you with goodness*

**الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ**

Made with 💚 for tracking good deeds

</div>
