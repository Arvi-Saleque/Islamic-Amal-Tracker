# Home Screen Structure - আমল ট্র্যাকার

## Overview
Home Screen হল app এর main screen যেখানে user সব কিছু এক নজরে দেখতে পারে। এটি **1597 lines** এর একটি বড় file যা বিভিন্ন section এ বিভক্ত।

---

## File Structure

### 1. Imports (Lines 1-23)
```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

**কী করে:**
- Flutter UI components import করে
- Riverpod state management library
- Date/time formatting (intl, hijri_calendar)
- Location services (geolocator)
- App এর নিজস্ব theme, providers, screens import

---

## Main Components

### 2. HomeScreen Class (Lines 25-31)
```dart
class HomeScreen extends ConsumerStatefulWidget
```

**কী করে:**
- `ConsumerStatefulWidget` = Riverpod এর state management ব্যবহার করে
- State পরিবর্তন হলে automatically UI update হয়
- `_HomeScreenState` এর মাধ্যমে screen এর logic handle করে

---

### 3. InitState & Permissions (Lines 33-50)
```dart
void initState() {
  super.initState();
  _checkLocationAndShowNotificationPopup();
}
```

**কী করে:**
- App খোলার সাথে সাথে location permission check করে
- 2 second delay দিয়ে notification permission popup দেখায়
- Location granted থাকলে notification request করে

---

### 4. Main Build Method (Lines 52-163)

#### 4.1 Scaffold Structure
```dart
Scaffold(
  backgroundColor: AppColors.backgroundDark,  // #0A0A0A (very dark)
  appBar: AppBar(...),
  body: RefreshIndicator(...)
)
```

**Color System:**
- **Background**: `AppColors.backgroundDark` = `#0A0A0A` (main dark background)
- **Cards**: `AppColors.backgroundLight` = `#1A1A1A` → updated to `#1C1C1C`
- **Primary (Golden)**: `AppColors.primary` = `#D4AF37`
- **Text Primary**: `Colors.white`
- **Text Secondary**: `Colors.grey[500]`, `Colors.grey[600]`

#### 4.2 AppBar (Lines 59-115)
```dart
AppBar(
  backgroundColor: AppColors.backgroundDark,
  title: Text('আমল ট্র্যাকার'),
  actions: [
    IconButton(refresh),
    IconButton(statistics),
    IconButton(settings)
  ]
)
```

**Features:**
- **Refresh Button**: সব providers এর data reload করে
- **Statistics Button**: Statistics screen এ navigate করে
- **Settings Button**: Settings screen এ navigate করে
- Golden color (`#D4AF37`) icons ব্যবহার করে

#### 4.3 Body - ScrollView (Lines 117-163)
```dart
RefreshIndicator(
  child: SingleChildScrollView(
    child: Column([
      _buildDateSunCard(),      // Date & Sunrise/Sunset
      _buildPrayerTimesCard(),  // Prayer Times
      _buildTodayProgress(),    // Today's Progress
      _buildAmalCards()         // Amal Cards Grid
    ])
  )
)
```

**Pull-to-refresh enabled**: User নিচে swipe করে data refresh করতে পারে

---

## UI Components Detail

### 5. Date & Sun Card (Lines 165-340)

#### Structure:
```dart
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  decoration: BoxDecoration(
    color: AppColors.backgroundLight,  // #1A1A1A
    borderRadius: BorderRadius.circular(20),
    boxShadow: [...]
  )
)
```

#### Shows:
- **Left Side:**
  - Hijri date (Bengali): "২৪ শাবান"
  - Gregorian date: "২৪ জানুয়ারি"
  - Bengali date: "১০ মাঘ"
  
- **Right Side:**
  - Sunrise time with icon: "৬:৪০ সূর্যোদয়"
  - Sunset time with icon: "৫:৪৪ সূর্যাস্ত"

#### Date Calculations:
```dart
// Hijri Date (adjusted -1 day)
final yesterday = now.subtract(Duration(days: 1));
final hijri = HijriCalendar.fromDate(yesterday);

// Bengali Date (approximate calculation)
final bengaliYear = (now.year - 593);
final bengaliMonth = (now.month + 8) % 12;
```

#### Shadow Effect:
```dart
boxShadow: [
  BoxShadow(
    color: AppColors.shadowDark,  // Black with opacity
    blurRadius: 12,
    offset: Offset(0, 4),
    spreadRadius: -2,
  )
]
```

---

### 6. Prayer Times Card (Lines 483-580)

#### Card Design:
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(
    color: Color(0xFF1C1C1C),  // Lighter than background
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 16,
        offset: Offset(0, 6),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.02),  // Subtle top highlight
        blurRadius: 1,
        offset: Offset(0, -1),
      ),
    ],
  )
)
```

#### Two Main Sections:

##### 6.1 Current Prayer Section (Lines 578-850)
```dart
_buildCurrentPrayerSection(state)
```

**Shows:**
- **Status Badge**: "এখন চলছে" / "নফল সময়" / "নিষিদ্ধ সময়"
- **Prayer Name**: Large golden text (32px)
- **Countdown Timer**: 48px bold golden text
- **Subtitle**: "পরবর্তী ওয়াক্তের বাকি"

**Badge Colors:**
```dart
if (state.isForbiddenTime) {
  statusColor = Colors.red;
  statusText = 'নিষিদ্ধ সময়';
} else if (state.isNaflTime) {
  statusColor = Color(0xFFD4AF37);
  statusText = 'এখন চলছে';
  mainText = 'নফল';
} else if (state.currentPrayer != null) {
  statusColor = Color(0xFFD4AF37);
  statusText = 'এখন চলছে';
}
```

**Progress Bar (Lines 780-830):**
```dart
Container(
  height: 6,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final totalWidth = constraints.maxWidth;
      final goldenWidth = totalWidth * progress;
      return Stack([
        Container(width: totalWidth, color: grey),  // Gray background
        Container(width: goldenWidth, color: golden), // Golden progress
      ]);
    }
  )
)
```

**Progress Calculation:**
```dart
// For regular prayers
final totalDuration = prayerEndTime.difference(currentPrayerTime).inSeconds;
final elapsedDuration = now.difference(currentPrayerTime).inSeconds;
progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);

// For Nafl time (sunrise to dhuhr)
final totalDuration = dhuhr.difference(sunrise).inSeconds;
final elapsedDuration = now.difference(sunrise).inSeconds;

// For Isha after midnight
if (state.currentPrayer == 'isha' && now.hour < 6) {
  currentPrayerTime = currentPrayerTime.subtract(Duration(days: 1));
  prayerEndTime = todayFajr;
}
```

##### 6.2 Prayer Times List (Lines 852-935)
```dart
Column(
  children: [
    _buildPrayerTimeRow('ফজর', fajr, isCurrent),
    _buildPrayerTimeRow('যোহর', dhuhr, isCurrent),
    _buildPrayerTimeRow('আসর', asr, isCurrent),
    _buildPrayerTimeRow('মাগরিব', maghrib, isCurrent),
    _buildPrayerTimeRow('এশা', isha, isCurrent),
  ]
)
```

**Each Row:**
```dart
Row(
  children: [
    // Golden dot if current
    if (isCurrent) Container(
      width: 8, 
      height: 8,
      decoration: BoxDecoration(
        color: Color(0xFFD4AF37),
        shape: BoxShape.circle
      )
    ),
    
    // Prayer name
    Text(name, style: golden/white),
    
    Spacer(),
    
    // Time
    Text(time, style: golden/grey)
  ]
)
```

---

### 7. Today's Progress Card (Lines 1028-1155)

#### Card Design:
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16),
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: Color(0xFF1C1C1C),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 16,
        offset: Offset(0, 6),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Colors.white.withOpacity(0.02),
        blurRadius: 1,
        offset: Offset(0, -1),
      ),
    ],
  )
)
```

#### Title Section:
```dart
Row([
  Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Color(0xFFD4AF37).withOpacity(0.15),  // Light golden bg
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(Icons.trending_up, color: golden)
  ),
  Text('আজকের অগ্রগতি')
])
```

#### Progress Calculation:
```dart
// 4 categories
final prayerProgress = completedPrayers / 5;
final amalProgress = totalAmal > 0 ? completedAmal / totalAmal : 0.0;
final dhikrProgress = dhikrTarget > 0 ? (dhikrCount / dhikrTarget).clamp(0.0, 1.0) : 0.0;
final readingProgress = readingTarget > 0 ? (readingMinutes / readingTarget).clamp(0.0, 1.0) : 0.0;

// Overall average
final overallProgress = (prayerProgress + amalProgress + dhikrProgress + readingProgress) / 4;
final overallPercentage = (overallProgress * 100).toInt();
```

#### Circular Progress:
```dart
Stack(
  alignment: Alignment.center,
  children: [
    // Background circle
    CircularProgressIndicator(
      value: 1.0,
      color: Colors.grey[800],
    ),
    // Progress circle
    CircularProgressIndicator(
      value: overallProgress,
      color: Color(0xFFD4AF37),
    ),
    // Percentage text
    Text('$overallPercentage%', fontSize: 48)
  ]
)
```

#### Category Rows:
```dart
Row([
  Icon(Icons.mosque),
  Column([
    Text('নামাজ'),
    Text('$completedPrayers/৫')
  ]),
  Spacer(),
  LinearProgressIndicator(progress)
])
```

---

### 8. Amal Cards Grid (Lines 1250-1367)

#### Grid Layout:
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: Column([
    Row([
      Expanded(child: _buildAmalCard(...)),
      SizedBox(width: 16),
      Expanded(child: _buildAmalCard(...)),
    ]),
    Row([
      Expanded(child: _buildAmalCard(...)),
      SizedBox(width: 16),
      Expanded(child: _buildAmalCard(...)),
    ]),
    _buildSinTrackerCard(...)  // Full width
  ])
)
```

**4 Amal Cards:**
1. Daily Amal (দৈনিক আমল)
2. Dhikr Counter (যিকির কাউন্টার)
3. Prayer Tracker (নামাজ ট্র্যাকার)
4. Reading Tracker (পড়া ট্র্যাকার)

#### Individual Card Design:
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFF1C1C1C),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 12,
        offset: Offset(0, 4),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Color(0xFFD4AF37).withOpacity(0.08),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: InkWell(  // For tap effect
    onTap: () => Navigator.push(...),
    child: Padding(...)
  )
)
```

#### Card Content:
```dart
Column([
  Row([
    Icon(icon, color: golden),
    Spacer(),
    Text('$current/$total')
  ]),
  SizedBox(height: 12),
  Text(title, style: TextStyle(golden, bold)),
  Text(subtitle, style: TextStyle(grey, small)),
  SizedBox(height: 12),
  LinearProgressIndicator(
    value: percentage,
    backgroundColor: grey,
    color: golden
  )
])
```

---

## Helper Methods

### 9. Bengali Conversion Methods (Lines 340-480)

#### Number Conversion:
```dart
String _toBengaliNumber(int number) {
  const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return number.toString().split('').map((digit) {
    return bengaliDigits[int.parse(digit)];
  }).join();
}
```

#### Day Names:
```dart
String _getBengaliDayName(int weekday) {
  const days = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 
                'শুক্রবার', 'শনিবার', 'রবিবার'];
  return days[weekday - 1];
}
```

#### Month Names:
```dart
String _getBengaliMonthName(int month) {
  const months = ['জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', ...];
  return months[month - 1];
}
```

#### Hijri Month Names:
```dart
String _getHijriMonthBengali(int month) {
  const months = ['মহররম', 'সফর', 'রবিউল আউয়াল', ...];
  return months[month - 1];
}
```

### 10. Time Formatting (Lines 870-900)

```dart
String _formatTime(DateTime time) {
  final hour = time.hour > 12 ? time.hour - 12 : time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _formatTimeShort(DateTime time) {
  return DateFormat('h:mm').format(time);
}

String _formatTimeShort2(DateTime time) {
  return DateFormat('h:mm').format(time);
}
```

### 11. Prayer Name Conversion (Lines 850-890)

```dart
String _getPrayerDisplayName(String prayerName) {
  switch (prayerName) {
    case 'fajr': return 'ফজর';
    case 'dhuhr': return 'যোহর';
    case 'asr': return 'আসর';
    case 'maghrib': return 'মাগরিব';
    case 'isha': return 'এশা';
    default: return prayerName;
  }
}

String _getPrayerNameInBangla(String prayerName) {
  return _getPrayerDisplayName(prayerName);
}
```

---

## Background Colors - Detailed Code Locations

### 📱 Screen Level (Lines 58-60)
```dart
Scaffold(
  backgroundColor: AppColors.backgroundDark,  // #0A0A0A
  appBar: AppBar(
    backgroundColor: AppColors.backgroundDark,  // #0A0A0A
```
**Purpose:** Main screen background - very dark to create depth

---

### 📅 Date & Sun Card (Line 203)
```dart
Container(
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  decoration: BoxDecoration(
    color: AppColors.backgroundLight,  // Uses theme color
```
**Purpose:** Shows Hijri date, Gregorian date, sunrise/sunset times
**Color:** Theme dependent (usually `#1A1A1A`)

---

### 🕌 Prayer Times Card - Main Container (Line 485)
```dart
Container(
  margin: const EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(
    color: const Color(0xFF1C1C1C),  // Lighter dark gray
```
**Purpose:** Main prayer times card wrapper
**Color:** `#1C1C1C` - Lighter than background for elevation effect

---

### 🕋 Current Prayer Section (Line 710)
```dart
return Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: const Color(0xFF141414),  // Darker than prayer list
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
```
**Purpose:** Shows current/next prayer with countdown timer
**Color:** `#141414` - Darker than `#1C1C1C` to separate from prayer list below

---

### ⏰ Next Prayer Info Badge (Line 872)
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  decoration: BoxDecoration(
    color: const Color(0xFF1A1A1A),  // Subtle inner container
    borderRadius: BorderRadius.circular(10),
```
**Purpose:** Small badge showing "পরবর্তী: ফজর (আগামীকাল)"
**Color:** `#1A1A1A` - Subtle gray for nested container

---

### 📊 Today's Progress Card (Line 1073)
```dart
return Container(
  margin: const EdgeInsets.symmetric(horizontal: 16),
  padding: const EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: const Color(0xFF1C1C1C),  // Same as prayer card
```
**Purpose:** Shows overall daily progress with circular indicator
**Color:** `#1C1C1C` - Consistent card elevation

---

### 📋 Amal Cards (Lines 1513, 1423)
```dart
// Individual Amal Cards (Prayer, Daily Amal, Dhikr, Reading)
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF1C1C1C),  // Line 1513
    borderRadius: BorderRadius.circular(16),

// Sin Tracker Card
Container(
  decoration: BoxDecoration(
    color: const Color(0xFF1C1C1C),  // Line 1423
    borderRadius: BorderRadius.circular(16),
```
**Purpose:** 
- 4 small cards: Prayer, Daily Amal, Dhikr, Reading
- 1 full-width card: Sin Tracker
**Color:** `#1C1C1C` - All amal cards use consistent background

---

### 🎯 Active Prayer Row (Line 992)
```dart
decoration: isActive
  ? BoxDecoration(
      color: const Color(0xFFD4AF37),  // Golden background
      borderRadius: BorderRadius.circular(12),
```
**Purpose:** Highlights current active prayer in the prayer list
**Color:** `#D4AF37` (Golden) - High contrast highlight
**Text Color:** `#0A0A0A` (Black) when active for maximum readability

---

### 🎨 Icon Background Containers
```dart
// Golden semi-transparent backgrounds for icons
Container(
  padding: const EdgeInsets.all(10/14),
  decoration: BoxDecoration(
    color: const Color(0xFFD4AF37).withOpacity(0.15),  // 15% golden
    borderRadius: BorderRadius.circular(12/14),
  ),
  child: Icon(icon, color: Color(0xFFD4AF37))
)
```
**Locations:**
- Today's Progress icon (Line 1101): 15% opacity golden bg
- All Amal Card icons (Line 1542): 15% opacity golden bg
- Sin Tracker icon (Line 1457): 15% opacity golden bg

**Purpose:** Soft golden glow behind icons for visual hierarchy

---

## Color System Summary

### Background Colors:
- **Main Background**: `#0A0A0A` (very dark black) - Screen level
- **Cards/Boxes**: `#1C1C1C` (lighter dark gray) - Most cards
- **Current Prayer Section**: `#141414` (darker) - Top section of prayer card
- **Subtle Elements**: `#1A1A1A` (middle gray) - Nested badges

### Primary Colors:
- **Golden**: `#D4AF37` (main accent color)
- **Golden Light**: `#E5C158`
- **Golden Transparent**: `#D4AF37` with 8-15% opacity for backgrounds

### Text Colors:
- **Primary Text**: `#FFFFFF` (white)
- **Secondary Text**: `#E0E0E0` (light gray)
- **Tertiary Text**: `Colors.grey[500]` = `#9E9E9E`
- **Quaternary Text**: `Colors.grey[600]` = `#757575`
- **Active Text**: `#0A0A0A` (black) - Used on golden backgrounds

### Shadow System:
```dart
// Main shadow (depth)
BoxShadow(
  color: Colors.black.withOpacity(0.4),  // 40% black
  blurRadius: 16,
  offset: Offset(0, 6),
  spreadRadius: -4,
)

// Top highlight (subtle glow)
BoxShadow(
  color: Colors.white.withOpacity(0.02),  // 2% white
  blurRadius: 1,
  offset: Offset(0, -1),
  spreadRadius: 0,
)

// Golden glow (for special cards)
BoxShadow(
  color: Color(0xFFD4AF37).withOpacity(0.08),  // 8% golden
  blurRadius: 12,
  offset: Offset(0, 2),
)
```

---

## State Management

### Providers Used:
```dart
// Prayer times and current prayer
ref.watch(prayerTimesProvider)

// Prayer tracking (completed prayers)
ref.watch(prayerTrackingProvider)

// Daily amal tasks
ref.watch(dailyAmalProvider)

// Dhikr counter
ref.watch(dhikrCounterProvider)

// Reading tracker
ref.watch(readingTrackerProvider)

// Statistics
ref.watch(statisticsProvider)

// Sin tracker
ref.watch(sinTrackerProvider)
```

### Data Refresh:
```dart
// Refresh all providers
ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();
ref.read(prayerTrackingProvider.notifier).loadTodayData();
ref.read(dailyAmalProvider.notifier).loadTodayData();
// ... etc
```

---

## Design Principles

### 1. Card Elevation:
- **Level 1**: Main background (`#0A0A0A`)
- **Level 2**: Cards (`#1C1C1C`) with shadow
- **Level 3**: Nested containers (subtle variations)

### 2. Visual Hierarchy:
- **Primary**: Golden color for important elements
- **Secondary**: White for main text
- **Tertiary**: Gray for supporting text

### 3. Spacing System:
- **Small**: 8px, 12px
- **Medium**: 16px, 20px
- **Large**: 24px, 32px
- **XLarge**: 48px

### 4. Border Radius:
- **Cards**: 16px, 20px (rounded corners)
- **Small elements**: 8px, 10px, 12px

### 5. Shadow Intensity:
- **Subtle**: opacity 0.02-0.08
- **Medium**: opacity 0.25-0.3
- **Strong**: opacity 0.4

---

## Performance Optimizations

1. **const Constructors**: যেখানে সম্ভব `const` ব্যবহার করা হয়েছে
2. **Lazy Loading**: Data শুধুমাত্র প্রয়োজন হলে load হয়
3. **Selective Rebuilds**: Riverpod শুধু changed data এর জন্য rebuild করে
4. **Caching**: Prayer times cache করা থাকে

---

## Navigation Flow

```
Home Screen
├── Prayer Tracker Screen (নামাজ ট্র্যাকার)
├── Daily Amal Screen (দৈনিক আমল)
├── Dhikr Counter Screen (যিকির কাউন্টার)
├── Reading Tracker Screen (পড়া ট্র্যাকার)
├── Statistics Screen (পরিসংখ্যান)
├── Settings Screen (সেটিংস)
└── Sin Tracker Screen (গুনাহ ট্র্যাকার)
```

---

## Total Lines Breakdown

- **Imports & Setup**: ~50 lines
- **Main Build & AppBar**: ~100 lines
- **Date & Sun Card**: ~180 lines
- **Prayer Times Card**: ~450 lines
- **Current Prayer Section**: ~300 lines
- **Today's Progress**: ~150 lines
- **Amal Cards Grid**: ~250 lines
- **Helper Methods**: ~120 lines
- **Total**: **~1597 lines**

---

## Key Takeaways

### ✅ Strengths:
1. **Well-organized**: Clear section separation
2. **Consistent styling**: Unified color system
3. **Responsive**: Works on different screen sizes
4. **Bengali support**: Full Bengali UI
5. **Real-time updates**: Prayer times update automatically

### 🎨 Design Updates (Recent):
- Changed card color from `#0A0A0A` to `#1C1C1C`
- Enhanced shadow system for better depth
- Added subtle top highlights
- Increased golden glow opacity
- No borders - clean minimal look

### 📱 User Experience:
- Pull-to-refresh enabled
- Smooth navigation
- Visual feedback on tap
- Clear progress indicators
- Easy-to-read typography
