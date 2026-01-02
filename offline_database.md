# Amal Tracker - Offline Database (Hive) Structure

## Database Technology
- **Hive**: NoSQL key-value database for Flutter
- **Location**: Local device storage (offline-first)
- **Format**: Binary format (.hive files)

---

## Database Boxes (Collections)

### 1. **prayer_tracking** Box
**Purpose**: নামাজের ট্র্যাকিং ডেটা

**Stored Data**:
- **Key Format**: Date string (YYYY-MM-DD)
- **Value**: Prayer tracking JSON
  ```json
  {
    "date": "2026-01-02",
    "fajr": true/false,
    "dhuhr": true/false,
    "asr": true/false,
    "maghrib": true/false,
    "isha": true/false
  }
  ```

---

### 2. **daily_amal** Box
**Purpose**: দৈনিক আমল ট্র্যাকিং

**Stored Data**:
- **Key Format**: Date string (YYYY-MM-DD)
- **Value**: Daily amal JSON
  ```json
  {
    "date": "2026-01-02",
    "items": [
      {
        "id": "miswak_fajr",
        "title": "ফজরের আগে মিসওয়াক",
        "category": "miswak",
        "isCompleted": true,
        "completedAt": "2026-01-02T05:30:00.000Z"
      },
      {
        "id": "surah_mulk",
        "title": "সূরা মুলক",
        "category": "surah",
        "isCompleted": false,
        "completedAt": null
      },
      {
        "id": "tahajjud",
        "title": "তাহাজ্জুদ নামাজ",
        "category": "prayer",
        "isCompleted": true,
        "completedAt": "2026-01-02T03:15:00.000Z"
      }
    ]
  }
  ```

**Categories (category field)**:
- `miswak` - মিসওয়াক (৫ ওয়াক্ত: ফজর, যোহর, আসর, মাগরিব, এশা)
- `surah` - সূরা পড়া (মুলক, ওয়াকিয়া, কাহফ, ইয়াসিন)
- `dua` - দোয়া (সকাল, সন্ধ্যা, ঘুম)
- `prayer` - নফল নামাজ (তাহাজ্জুদ, ইশরাক, চাশত, আউওয়াবীন)
- `other` - অন্যান্য (দান/সাদাকা, সাহায্য করা)

**Default Items** (automatically created for each day):
1. **মিসওয়াক** (5 items): ফজর, যোহর, আসর, মাগরিব, এশা
2. **সূরা** (4 items): মুলক, ওয়াকিয়া, কাহফ (জুমআ), ইয়াসিন
3. **দোয়া** (3 items): সকালের দোয়া, সন্ধ্যার দোয়া, ঘুমের দোয়া
4. **নফল নামাজ** (4 items): তাহাজ্জুদ, ইশরাক, চাশত, আউওয়াবীন
5. **অন্যান্য** (2 items): দান/সাদাকা, কাউকে সাহায্য করা

**Total**: ১৮ টি ডিফল্ট আমল প্রতিদিন

---

### 3. **dhikr_counter** Box
**Purpose**: যিকির কাউন্টার ডেটা

**Stored Data**:
- **Key Format**: Date string (YYYY-MM-DD)
- **Value**: Dhikr counter JSON
  ```json
  {
    "date": "2026-01-02",
    "items": [
      {
        "title": "সুবহানাল্লাহ",
        "arabic": "سبحان الله",
        "currentCount": 50,
        "targetCount": 100
      }
    ]
  }
  ```

---

### 4. **reading_tracker** Box
**Purpose**: পড়াশোনা ট্র্যাকিং (কুরআন, তাফসীর, হাদিস)

**Stored Data**:
- **Key Format**: Date string (YYYY-MM-DD)
- **Value**: Reading tracker JSON
  ```json
  {
    "date": "2026-01-02",
    "quranMinutes": 15,
    "tafsirMinutes": 10,
    "hadithMinutes": 5,
    "goal": {
      "quranMinutes": 20,
      "tafsirMinutes": 10,
      "hadithMinutes": 5
    }
  }
  ```

---

### 5. **sin_tracker** Box ⭐ NEW
**Purpose**: গুনাহ ট্র্যাকিং এবং কাফফারা

**Stored Data**:

#### A. Daily Sin Records
- **Key Format**: Date string (YYYY-MM-DD)
- **Value**: DailySinRecord JSON
  ```json
  {
    "date": "2026-01-02",
    "records": [
      {
        "sinTypeId": "sin_lie",
        "hasSinned": true,
        "kaffaraDone": true,
        "kaffaraType": "istighfar"
      },
      {
        "sinTypeId": "sin_eye",
        "hasSinned": false,
        "kaffaraDone": false,
        "kaffaraType": null
      }
    ]
  }
  ```

#### B. Sin Types Configuration
- **Key**: "sin_types"
- **Value**: List of sin types (default + custom)
  ```json
  [
    {
      "id": "sin_lie",
      "name": "মিথ্যা বলা",
      "isDefault": true,
      "icon": "voice"
    },
    {
      "id": "custom_sin_1767343066617",
      "name": "রাগ করা",
      "isDefault": false,
      "icon": "warning"
    }
  ]
  ```

**Default Sin Types**:
1. `sin_lie` - মিথ্যা বলা
2. `sin_backbiting` - গিবত করা
3. `sin_eye` - চোখের গুনাহ
4. `sin_ear` - কানের গুনাহ

**Kaffara Types**:
- `istighfar` - এস্তেগফার/যিকির
- `quran` - কোরআন তেলাওয়াত
- `charity` - দান-সদকা
- `prayer` - নফল নামাজ

---

### 6. **statistics** Box
**Purpose**: পরিসংখ্যান ক্যাশিং

**Stored Data**:
- Cached statistics data
- Weekly/Monthly summary cache

---

### 7. **notification_settings** Box
**Purpose**: নোটিফিকেশন সেটিংস

**Stored Data**:
- Prayer time notifications
- Dhikr reminders
- Custom reminder settings

---

### 8. **custom_reminders** Box
**Purpose**: কাস্টম রিমাইন্ডার

**Stored Data**:
- **Key Format**: Reminder ID (timestamp)
- **Value**: Reminder JSON
  ```json
  {
    "id": "1704196800000",
    "title": "তাহাজ্জুদ নামাজ",
    "time": "03:00",
    "enabled": true,
    "days": ["monday", "wednesday", "friday"]
  }
  ```

---

### 9. **categories** Box
**Purpose**: আমল ক্যাটাগরি কনফিগারেশন

**Stored Data**:
- Dhikr categories
- Amal categories
- Custom categories

---

### 10. **settings** Box
**Purpose**: অ্যাপ সেটিংস

**Stored Data**:
- **Key**: "app_settings"
- **Value**: App settings JSON
  ```json
  {
    "theme": "dark",
    "language": "bn",
    "notifications": true,
    "location": {
      "latitude": 23.8103,
      "longitude": 90.4125
    }
  }
  ```

---

## Data Models with Hive Type IDs

### HiveType Registry
```dart
@HiveType(typeId: 10) - SinRecord
@HiveType(typeId: 11) - SinType
@HiveType(typeId: 12) - DailySinRecord
```

---

## Key Features

### ✅ Offline-First Architecture
- All data stored locally first
- No internet required
- Instant read/write operations

### ✅ Data Persistence
- Daily records stored by date (YYYY-MM-DD format)
- Historical data preserved indefinitely
- Easy date-based queries

### ✅ Flexible Schema
- JSON-based storage
- Easy to add new fields
- Backward compatible

### ✅ Type Safety
- Custom models with toJson/fromJson
- Type adapters for complex objects
- Null-safety support

---

## Common Operations

### Save Daily Data
```dart
final box = await Hive.openBox('sin_tracker');
await box.put('2026-01-02', dailyRecord.toJson());
```

### Load Daily Data
```dart
final box = await Hive.openBox('sin_tracker');
final data = box.get('2026-01-02');
if (data != null) {
  final record = DailySinRecord.fromJson(data);
}
```

### Get Historical Data
```dart
// Get all keys (dates)
final keys = box.keys.toList();

// Filter by date range
for (var key in keys) {
  if (key.startsWith('2026-01')) {
    final data = box.get(key);
  }
}
```

---

## Database File Location

### Android
`/data/data/com.example.amal_tracker/files/hive/`

### iOS
`Library/Application Support/hive/`

### Windows
`%APPDATA%\amal_tracker\hive\`

---

## Summary

**Total Boxes**: 10
**Total Data Types**: 
- নামাজ (Prayer)
- দৈনিক আমল (Daily Amal)
- যিকির (Dhikr)
- পড়াশোনা (Reading)
- গুনাহ ট্র্যাকার (Sin Tracker) ⭐
- পরিসংখ্যান (Statistics)
- সেটিংস (Settings)
- রিমাইন্ডার (Reminders)

**Storage Type**: Key-Value (NoSQL)
**Format**: Binary + JSON
**Backup**: Manual export/import capability (can be added)
