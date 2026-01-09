# 📊 Statistics পেজ - বিস্তারিত টেকনিক্যাল রিপোর্ট

## 🎯 সংক্ষিপ্ত সারসংক্ষেপ
Statistics পেজটি ব্যবহারকারীর সকল ইবাদত-আমলের ডেটা বিশ্লেষণ করে সপ্তাহিক, মাসিক এবং কাজা নামাজের পরিসংখ্যান প্রদর্শন করে। এটি **State Management**, **Data Aggregation**, এবং **Chart Visualization** এর একটি সম্পূর্ণ উদাহরণ।

---

## 📁 ফাইল স্ট্রাকচার

### **১. মূল ফাইলসমূহ:**
- **UI Layer:** `lib/presentation/screens/statistics/statistics_screen.dart`
- **State Management:** `lib/presentation/providers/statistics_provider.dart`  
- **Data Models:** `lib/data/models/statistics_model.dart`

### **২. Widget Components:**
- `lib/presentation/screens/statistics/widgets/streak_card.dart` - স্ট্রিক প্রদর্শন
- `lib/presentation/screens/statistics/widgets/weekly_progress_chart.dart` - সাপ্তাহিক চার্ট
- `lib/presentation/screens/statistics/widgets/category_progress_section.dart` - ক্যাটাগরি অগ্রগতি
- `lib/presentation/screens/statistics/widgets/weekly_summary_section.dart` - সামারি কার্ড
- `lib/presentation/screens/statistics/widgets/monthly_calendar_view.dart` - মাসিক ক্যালেন্ডার
- `lib/presentation/screens/statistics/widgets/day_details_sheet.dart` - দৈনিক বিস্তারিত

---

## 🔄 ডেটা ফ্লো ও ক্যালকুলেশন প্রসেস

### **Phase 1: ডেটা সংগ্রহ (Data Collection)**

#### 📍 **ফাইল:** `statistics_provider.dart` (লাইন 88-210)

**Function:** `rebuildFromBoxes()`

```dart
// লাইন 88-98: সকল Hive Box খোলা হয়
final prayerBox = await Hive.openBox('prayer_tracking');
final amalBox = await Hive.openBox('daily_amal');
final dhikrBox = await Hive.openBox('dhikr_counter');
final readingBox = await Hive.openBox('reading_tracker');
```

**কী হয়:**
- ৪টি আলাদা Hive database থেকে ডেটা নেওয়া হয়
- প্রতিটি box এ তারিখ অনুযায়ী ডেটা সংরক্ষিত থাকে (key: "YYYY-MM-DD")

**ইন্টারভিউতে বলবেন:**
> "আমাদের app এ প্রতিটি feature এর ডেটা আলাদা Hive box এ store হয়। Statistics page এ সব box থেকে ডেটা একসাথে aggregate করতে হয়।"

---

#### 📍 **লাইন 101-111: সকল তারিখ সংগ্রহ**

```dart
final allDates = <String>{};
for (var key in prayerBox.keys) {
  if (key is String && key.contains('-')) allDates.add(key);
}
// ... বাকি boxes থেকেও একইভাবে
```

**ইন্টারভিউতে বলবেন:**
> "আমরা প্রথমে সকল boxes থেকে unique date keys collect করি। Set ব্যবহার করায় duplicate dates এড়ানো যায়। এটা important কারণ হতে পারে কোনো দিন শুধু নামাজ track করা হয়েছে কিন্তু আমল করা হয়নি - এরকম ক্ষেত্রে সব dates capture করা জরুরি।"

---

### **Phase 2: প্রতিটি দিনের ডেটা প্রসেসিং**

#### 📍 **লাইন 114-182: দিন অনুযায়ী ক্যালকুলেশন**

```dart
for (final dateKey in allDates) {
  int prayersCompleted = 0;
  int amalCompleted = 0;
  int dhikrCount = 0;
  int readingMinutes = 0;
  
  // Prayer ডেটা প্রসেস (লাইন 124-141)
  final prayerData = prayerBox.get(dateKey);
  if (prayerData != null) {
    final rakatsDone = prayerData['rakatsDone'] as Map?;
    for (var prayerRakats in rakatsDone.values) {
      for (var entry in prayerRakats.entries) {
        final rakatName = entry.key.toString();
        final isDone = entry.value == true;
        if (isDone && rakatName.contains('ফরয')) {
          prayersCompleted++;
          break; // প্রতিটি নামাজ একবারই count হবে
        }
      }
    }
  }
```

**ইন্টারভিউতে এক্সপ্লেইন:**
> "প্রতিটি date এর জন্য আমরা nested Map traverse করি। Prayer data তে প্রতিটি নামাজের রাকাত আলাদা আলাদা stored থাকে। উদাহরণস্বরূপ, ফজরের জন্য '২ রাকাত সুন্নত', '২ রাকাত ফরয' এভাবে। আমরা শুধু ফরয নামাজগুলো count করি যেগুলো complete হয়েছে। `break` statement দিয়ে ensure করি একই নামাজ multiple times count না হয়।"

---

#### 📍 **লাইন 144-165: অন্যান্য ডেটা সংগ্রহ**

```dart
// Amal (লাইন 144-149)
final amalData = amalBox.get(dateKey);
if (amalData != null) {
  final completedAmals = amalData['completedAmals'] as List?;
  amalCompleted = completedAmals?.length ?? 0;
  totalAmal = amalData['totalCount'] as int? ?? 18;
}

// Dhikr (লাইন 151-155)
final dhikrData = dhikrBox.get(dateKey);
if (dhikrData != null) {
  dhikrCount = dhikrData['totalCount'] as int? ?? 0;
  dhikrTarget = dhikrData['totalTarget'] as int? ?? 600;
}

// Reading (লাইন 157-163)
final readingData = readingBox.get(dateKey);
if (readingData != null) {
  readingMinutes = readingData['totalMinutes'] as int? ?? 0;
  final goalData = readingData['goal'] as Map?;
  if (goalData != null) {
    readingTarget = goalData['totalMinutes'] as int? ?? 35;
  }
}
```

**বলবেন:**
> "প্রতিটি feature এর data structure আলাদা। Amal এ completed items list থাকে, Dhikr এ count থাকে, Reading এ minutes থাকে। সব জায়গায় null safety maintain করতে `??` operator ব্যবহার করি default value এর জন্য।"

---

#### 📍 **লাইন 165-175: DailyStatistics Object তৈরি**

```dart
updatedDailyStats[dateKey] = DailyStatistics(
  date: dateKey,
  prayersCompleted: prayersCompleted,
  totalPrayers: 5,
  amalCompleted: amalCompleted,
  totalAmal: totalAmal,
  dhikrCount: dhikrCount,
  dhikrTarget: dhikrTarget,
  readingMinutes: readingMinutes,
  readingTarget: readingTarget,
);
```

**বলবেন:**
> "প্রতিটি দিনের জন্য একটি DailyStatistics model তৈরি করি যাতে সেদিনের সব activity এর snapshot থাকে। এটা একটা immutable object যা সহজে serialize/deserialize করা যায়।"

---

### **Phase 3: Streak Calculation**

#### 📍 **লাইন 178-182 + 258-278**

```dart
int currentStreak = _calculateCurrentStreak(updatedDailyStats);
int bestStreak = state.data.bestStreak;
if (currentStreak > bestStreak) {
  bestStreak = currentStreak;
}

// Function definition (লাইন 258-278)
int _calculateCurrentStreak(Map<String, DailyStatistics> dailyStats) {
  int streak = 0;
  final now = DateTime.now();

  for (int i = 0; i < 365; i++) {
    final date = now.subtract(Duration(days: i));
    final dateStr = _formatDate(date);
    final dayStats = dailyStats[dateStr];

    if (dayStats != null && dayStats.overallScore >= 60) {
      streak++;
    } else if (i > 0) {
      break; // Streak ভেঙে গেছে
    }
  }
  return streak;
}
```

**ইন্টারভিউতে বলবেন:**
> "Streak calculation algorithm টা backward traversal করে - আজ থেকে শুরু করে পেছনের দিকে যায়। Threshold হিসেবে 60% overall score ব্যবহার করি। যদি কোনো দিনের score 60% এর কম হয়, streak সেখানেই থেমে যায়। 
>
> একটা important edge case handle করা হয়েছে লাইন 273-এ `i > 0` check দিয়ে - আজকের দিনটা incomplete থাকলেও streak continue থাকবে। কারণ user হয়তো দিন শেষ হয়নি তখনও data entry করছে।
>
> Best streak ও track করি - যদি current streak previous best streak cross করে, update করি।"

---

### **Phase 4: Progress Calculation (Model Layer)**

#### 📍 **ফাইল:** `statistics_model.dart` (লাইন 48-58)

```dart
// লাইন 48-51: Individual progress (0.0 to 1.0)
double get prayerProgress => totalPrayers > 0 ? prayersCompleted / totalPrayers : 0.0;
double get amalProgress => totalAmal > 0 ? amalCompleted / totalAmal : 0.0;
double get dhikrProgress => dhikrTarget > 0 ? (dhikrCount / dhikrTarget).clamp(0.0, 1.0) : 0.0;
double get readingProgress => readingTarget > 0 ? (readingMinutes / readingTarget).clamp(0.0, 1.0) : 0.0;

// লাইন 53-55: Overall average
double get overallProgress {
  return (prayerProgress + amalProgress + dhikrProgress + readingProgress) / 4;
}

// লাইন 57-59: Percentage score
int get overallScore {
  return (overallProgress * 100).toInt();
}
```

**এক্সপ্লেইন করবেন:**
> "প্রতিটি category এর আলাদা progress getter আছে যা 0.0 থেকে 1.0 মধ্যে return করে। Prayer ও Amal এর ক্ষেত্রে সরাসরি division করি কারণ এগুলো fix target (5 prayers, 18 amals)। 
>
> কিন্তু Dhikr ও Reading এর ক্ষেত্রে `.clamp(0.0, 1.0)` ব্যবহার করি কারণ user target এর চেয়ে বেশিও করতে পারে - সেক্ষেত্রে progress 1.0 এর বেশি যাবে না।
>
> Overall progress হলো এই চারটার simple average। Score হলো এটার percentage format (0-100)। এটা UI তে দেখানোর জন্য সুবিধাজনক।"

---

### **Phase 5: Weekly Stats Aggregation**

#### 📍 **ফাইল:** `statistics_model.dart` (লাইন 164-177)

```dart
WeeklyStatistics getWeeklyStats() {
  final now = DateTime.now();
  final weekDays = <DailyStatistics>[];

  // লাইন 168-172: শেষ ৭ দিনের ডেটা
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateStr = _formatDate(date);
    weekDays.add(dailyStats[dateStr] ?? DailyStatistics(date: dateStr));
  }

  return WeeklyStatistics(
    days: weekDays,
    currentStreak: currentStreak,
    bestStreak: bestStreak,
  );
}
```

**বলবেন:**
> "Weekly stats বের করতে আজ থেকে পেছনের ৬ দিন নিয়ে মোট ৭ দিন। `i = 6` থেকে `i = 0` পর্যন্ত loop করায় chronological order maintain হয়।
>
> যদি কোনো date এর data না থাকে, empty DailyStatistics object create করি `??` operator দিয়ে। এতে UI তে empty state gracefully handle হয়।"

---

#### 📍 **Weekly Totals** (`statistics_model.dart` লাইন 76-88)

```dart
// লাইন 76-79: Summing up using fold
int get totalPrayersCompleted => days.fold(0, (sum, d) => sum + d.prayersCompleted);
int get totalAmalCompleted => days.fold(0, (sum, d) => sum + d.amalCompleted);
int get totalDhikrCount => days.fold(0, (sum, d) => sum + d.dhikrCount);
int get totalReadingMinutes => days.fold(0, (sum, d) => sum + d.readingMinutes);

// লাইন 81-84: Average progress
double get averagePrayerProgress {
  if (days.isEmpty) return 0.0;
  return days.map((d) => d.prayerProgress).reduce((a, b) => a + b) / days.length;
}

double get averageAmalProgress {
  if (days.isEmpty) return 0.0;
  return days.map((d) => d.amalProgress).reduce((a, b) => a + b) / days.length;
}

double get averageDhikrProgress {
  if (days.isEmpty) return 0.0;
  return days.map((d) => d.dhikrProgress).reduce((a, b) => a + b) / days.length;
}

double get averageReadingProgress {
  if (days.isEmpty) return 0.0;
  return days.map((d) => d.readingProgress).reduce((a, b) => a + b) / days.length;
}

// লাইন 107: Perfect days count
int get perfectDays => days.where((d) => d.overallScore >= 100).length;
```

**বলবেন:**
> "`fold` method ব্যবহার করে সপ্তাহের সব দিনের data sum করি। এটা functional programming approach - immutable way তে collection process করা।
>
> Average progress বের করতে:
> 1. `map` দিয়ে সব progress values extract করি
> 2. `reduce` করে sum করি
> 3. length দিয়ে ভাগ করে average বের করি
>
> প্রতিটা method এ `days.isEmpty` check করি division by zero এড়াতে।
>
> Perfect days count করতে `where` filter ব্যবহার করি - যে দিনগুলোর score 100% বা তার বেশি।"

---

### **Phase 6: UI Rendering & Chart Display**

#### 📍 **ফাইল:** `weekly_progress_chart.dart` (লাইন 74-162)

```dart
BarChart(
  BarChartData(
    maxY: 100, // Maximum value for Y-axis
    
    // Tooltip configuration
    barTouchData: BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Colors.grey[800]!,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${rod.toY.toInt()}%',
            const TextStyle(color: Colors.white),
          );
        },
      ),
    ),
    
    // X-axis labels (weekday names)
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < weeklyStats.days.length) {
              final dayName = _getWeekdayFromDate(weeklyStats.days[index].date);
              return Text(dayName, style: TextStyle(color: Colors.grey));
            }
            return const Text('');
          },
        ),
      ),
    ),
    
    // Grid lines
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 25, // 25% intervals
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.withOpacity(0.2),
        strokeWidth: 1,
      ),
    ),
    
    // লাইন 145-159: প্রতিটি দিনের জন্য bar
    barGroups: weeklyStats.days.asMap().entries.map((entry) {
      final score = entry.value.overallScore.toDouble();
      return BarChartGroupData(
        x: entry.key, // Index হিসেবে X-position
        barRods: [
          BarChartRodData(
            toY: score, // Height হবে score অনুযায়ী
            color: _getBarColor(score), // রঙ score অনুযায়ী
            width: 24,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList(),
  ),
)

// Color logic (লাইন 164-173)
Color _getBarColor(double score) {
  if (score >= 80) return const Color(0xFF4CAF50); // Green
  if (score >= 60) return AppTheme.primaryGold;    // Gold
  if (score >= 40) return Colors.orange;           // Orange
  return Colors.red;                                // Red
}
```

**বলবেন:**
> "fl_chart package ব্যবহার করে bar chart render করি। এটা highly customizable এবং Flutter এর জন্য best chart library গুলোর একটা।
>
> Key features যা implement করেছি:
> 1. **Interactive Tooltip:** User bar এ tap করলে exact percentage দেখায়
> 2. **Dynamic Colors:** Score range অনুযায়ী রঙ পরিবর্তন (80%+ সবুজ, 60-80% গোল্ড, 40-60% কমলা, 40% এর নিচে লাল)
> 3. **Bengali Weekdays:** X-axis এ বাংলায় দিনের নাম (সোম, মঙ্গল, ইত্যাদি)
> 4. **Grid Lines:** 25% interval এ horizontal lines সহজে reading এর জন্য
> 5. **Rounded Bars:** Top corners rounded করা aesthetically pleasing UI এর জন্য
>
> `asMap().entries` ব্যবহার করে index ও value দুটোই পাই একসাথে।"

---

#### 📍 **Weekly Summary Cards** (`weekly_summary_section.dart` লাইন 128-153)

```dart
// লাইন 128-142: ডেটা calculation
final stats = widget.isMonthly && widget.monthlyStats != null
    ? widget.monthlyStats!
    : widget.weeklyStats.days;

int totalPrayers = 0;
int maxPrayers = 0;
int totalAmal = 0;
int maxAmal = 0;
int totalDhikr = 0;
int maxDhikr = 0;
int totalReadingMinutes = 0;
int maxReadingMinutes = 0;
int perfectDays = 0;

for (final day in stats) {
  totalPrayers += day.prayersCompleted;
  maxPrayers += day.totalPrayers;
  totalAmal += day.amalCompleted;
  maxAmal += day.totalAmal;
  totalDhikr += day.dhikrCount;
  maxDhikr += day.dhikrTarget;
  totalReadingMinutes += day.readingMinutes;
  maxReadingMinutes += day.readingTarget;
  if (day.overallScore >= 80) perfectDays++;
}
```

**এক্সপ্লেইন:**
> "এই widget টা reusable - weekly এবং monthly দুই view এই support করে। `isMonthly` flag অনুযায়ী appropriate data source select করি।
>
> প্রতিটি summary card এ:
> - **Total:** কতটা complete হয়েছে
> - **Maximum:** কতটা complete করা possible ছিল
> - **Percentage:** Total/Maximum ratio
>
> Perfect days count করতে 80% threshold ব্যবহার করি - এটা user কে motivated রাখে যে 'পারফেক্ট' মানে 100% না, 80%+ হলেই হয়।"

---

### **Phase 7: Prayer Details (Jamaat/Delayed)**

#### 📍 **ফাইল:** `weekly_summary_section.dart` (লাইন 45-94)

```dart
Future<void> _loadPrayerDetails() async {
  int jamaat = 0;
  int delayed = 0;

  try {
    final prayerBox = await Hive.openBox('prayer_tracking');
    final stats = widget.isMonthly && widget.monthlyStats != null
        ? widget.monthlyStats!
        : widget.weeklyStats.days;

    for (final day in stats) {
      final dateKey = day.date;
      final prayerData = prayerBox.get(dateKey);

      if (prayerData != null) {
        final rakatsDone = prayerData['rakatsDone'] as Map?;
        if (rakatsDone != null) {
          // লাইন 63-75: Nested map traversal
          for (var prayerRakats in rakatsDone.values) {
            if (prayerRakats is Map) {
              for (var entry in prayerRakats.entries) {
                final rakatName = entry.key.toString();
                final isDone = entry.value == true;

                if (isDone) {
                  // String matching দিয়ে category identify
                  if (rakatName.contains('ফরয') &&
                      rakatName.contains('জামাতে/আউয়াল ওয়াক্তে')) {
                    jamaat++;
                  } else if (rakatName.contains('ফরয') &&
                      rakatName.contains('দেরী করে')) {
                    delayed++;
                  }
                }
              }
            }
          }
        }
      }
    }
  } catch (e) {
    debugPrint('Error loading prayer details: $e');
  }

  // Update state
  if (mounted) {
    setState(() {
      jamaatPrayers = jamaat;
      delayedPrayers = delayed;
    });
  }
}
```

**বলবেন:**
> "নামাজের detailed breakdown দেখানোর জন্য আলাদা async function। এটা কারণ:
> 1. Hive box open করা asynchronous operation
> 2. UI তে loading state show করতে পারি
> 3. Error handling আলাদাভাবে করা যায়
>
> Prayer data structure অনেক nested - প্রতিটি নামাজের জন্য multiple rakats, প্রতিটি rakat এর type (ফরয/সুন্নত) এবং timing (জামাতে/দেরী করে)। 
>
> String matching ব্যবহার করি category identify করতে কারণ rakat names Bengali তে stored। 'ফরয' আছে কিনা check করে ensure করি শুধু fard prayers count হচ্ছে, sunnah না।
>
> `mounted` check important - async operation complete হওয়ার আগে widget unmount হতে পারে, সেক্ষেত্রে setState call করলে error হবে।"

---

### **Phase 8: Category Progress**

#### 📍 **ফাইল:** `category_progress_section.dart` (লাইন 19-38)

```dart
// লাইন 20-22: Data source selection
final stats = isMonthly && monthlyStats != null 
    ? monthlyStats! 
    : weeklyStats.days;

// লাইন 24-29: Average calculation
double avgPrayer = 0;
double avgAmal = 0;
double avgDhikr = 0;
double avgReading = 0;

if (stats.isNotEmpty) {
  avgPrayer = stats.map((d) => d.prayerProgress).reduce((a, b) => a + b) / stats.length;
  avgAmal = stats.map((d) => d.amalProgress).reduce((a, b) => a + b) / stats.length;
  avgDhikr = stats.map((d) => d.dhikrProgress).reduce((a, b) => a + b) / stats.length;
  avgReading = stats.map((d) => d.readingProgress).reduce((a, b) => a + b) / stats.length;
}

// লাইন 49-78: UI rendering with progress bars
_CategoryProgressItem(
  icon: Icons.mosque,
  iconColor: AppTheme.primaryGold,
  title: 'নামাজ',
  progress: avgPrayer, // 0.0 to 1.0
)

// Progress bar widget (লাইন 109-142)
class _CategoryProgressItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Row(
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        
        // Progress bar
        Expanded(
          child: Column(
            children: [
              // Title and percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(color: Colors.white)),
                  Text('$percentage%', style: TextStyle(color: AppTheme.primaryGold)),
                ],
              ),
              
              // Linear progress indicator
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

**বলবেন:**
> "Category Progress Section এ প্রতিটি ইবাদত category এর average performance একটা progress bar দিয়ে visualize করি।
>
> Design approach:
> 1. **Icon with Background:** প্রতিটা category এর আলাদা icon ও color theme
> 2. **Percentage Display:** User কে exact number দেখানো
> 3. **Progress Bar:** Visual representation - একনজরে বুঝা যায়
> 4. **Clamping:** `.clamp(0.0, 1.0)` ensure করে progress bar overflow না করে
>
> এই component টা fully reusable - weekly ও monthly view দুজায়গায় same code."

---

### **Phase 9: Monthly Calendar View**

#### 📍 **ফাইল:** `monthly_calendar_view.dart` (লাইন 35-120)

```dart
// Calendar grid building
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 7, // 7 days in a week
    childAspectRatio: 1,
  ),
  itemCount: 42, // 6 weeks × 7 days
  itemBuilder: (context, index) {
    // Calculate date for this cell
    final dayNumber = index - firstWeekdayIndex + 1;
    
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return Container(); // Empty cell
    }
    
    final date = DateTime(year, month, dayNumber);
    final dateStr = _formatDate(date);
    final dayStats = statsData.dailyStats[dateStr];
    
    // Get score and color
    final score = dayStats?.overallScore ?? 0;
    final color = _getScoreColor(score);
    
    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: _isToday(date) 
              ? Border.all(color: AppTheme.primaryGold, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _toBengaliNumber(dayNumber),
              style: TextStyle(
                color: score >= 60 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (score > 0)
              Text(
                '${score}%',
                style: TextStyle(fontSize: 8),
              ),
          ],
        ),
      ),
    );
  },
)

// Color logic
Color _getScoreColor(int score) {
  if (score >= 80) return const Color(0xFF4CAF50).withOpacity(0.8);
  if (score >= 60) return AppTheme.primaryGold.withOpacity(0.8);
  if (score >= 40) return Colors.orange.withOpacity(0.6);
  if (score > 0) return Colors.red.withOpacity(0.4);
  return Colors.grey.withOpacity(0.2); // No data
}
```

**বলবেন:**
> "Monthly calendar view GitHub style contribution graph এর মতো - প্রতিটা দিনের performance color দিয়ে represent করা।
>
> Technical challenges:
> 1. **Grid alignment:** প্রথম দিন সপ্তাহের কোন দিনে পড়ছে সেটা calculate করে empty cells add করি
> 2. **42 cells:** সব মাস fit করতে 6 weeks (6×7=42) grid ব্যবহার করি
> 3. **Today highlight:** Border দিয়ে আজকের দিন highlight করি
> 4. **Interactive:** Tap করলে সেই দিনের details bottom sheet এ show হয়
> 5. **Bengali numbers:** Date display করি বাংলায়
> 6. **Empty state:** যে দিনের data নেই তা grey দেখায়
>
> GridView.builder performance efficient কারণ শুধু visible cells render হয়।"

---

### **Phase 10: Day Details Bottom Sheet**

#### 📍 **ফাইল:** `day_details_sheet.dart` (লাইন 30-60)

```dart
Future<void> _loadData() async {
  final dateKey = _formatDate(widget.date);
  
  // Get aggregated data from provider
  final data = await widget.statsNotifier.getDetailedDataForDate(dateKey);
  
  // Load sin data separately
  final sinBox = await Hive.openBox('sin_tracker');
  final sinData = sinBox.get(dateKey);
  
  DailySinRecord? sinRecord;
  if (sinData != null) {
    sinRecord = DailySinRecord.fromJson(Map<String, dynamic>.from(sinData));
  }
  
  // Load sin types for display
  final sinTypesBox = await Hive.openBox('sin_types');
  final allSinTypes = sinTypesBox.values
      .map((e) => SinType.fromJson(Map<String, dynamic>.from(e)))
      .toList();
  
  setState(() {
    detailedData = data;
    this.sinRecord = sinRecord;
    this.allSinTypes = allSinTypes;
    isLoading = false;
  });
}
```

**Provider থেকে ডেটা সংগ্রহ** (`statistics_provider.dart` লাইন 295-331):

```dart
Future<DayDetailedData> getDetailedDataForDate(String dateKey) async {
  final amalBox = await Hive.openBox('daily_amal');
  final dhikrBox = await Hive.openBox('dhikr_counter');
  final readingBox = await Hive.openBox('reading_tracker');
  final prayerBox = await Hive.openBox('prayer_tracking');

  // Get and deserialize each type of data
  DailyAmalModel? amalModel;
  final amalData = amalBox.get(dateKey);
  if (amalData != null) {
    amalModel = DailyAmalModel.fromJson(Map<String, dynamic>.from(amalData));
  }

  DhikrCounterModel? dhikrModel;
  final dhikrData = dhikrBox.get(dateKey);
  if (dhikrData != null) {
    dhikrModel = DhikrCounterModel.fromJson(Map<String, dynamic>.from(dhikrData));
  }

  ReadingTrackerModel? readingModel;
  final readingData = readingBox.get(dateKey);
  if (readingData != null) {
    readingModel = ReadingTrackerModel.fromJson(Map<String, dynamic>.from(readingData));
  }

  PrayerTrackingModel? prayerModel;
  final prayerData = prayerBox.get(dateKey);
  if (prayerData != null) {
    prayerModel = PrayerTrackingModel.fromJson(Map<String, dynamic>.from(prayerData));
  }

  return DayDetailedData(
    amalModel: amalModel,
    dhikrModel: dhikrModel,
    readingModel: readingModel,
    prayerModel: prayerModel,
  );
}
```

**বলবেন:**
> "Day details bottom sheet এ specific date এর সব ডেটা বিস্তারিতভাবে দেখানো হয়। এটার জন্য:
>
> 1. **Detailed Models:** Summary statistics এ শুধু numbers থাকে, কিন্তু details এ individual items (কোন আমল করা হয়েছে, কোন যিকির কতবার, কোন নামাজ জামাতে ইত্যাদি)
> 
> 2. **Lazy Loading:** User যখন calendar এ tap করে তখনই load হয় - আগে না। এতে initial load fast হয়
>
> 3. **Separation of Concerns:** Provider থেকে data fetch logic আলাদা, UI component শুধু display করে
>
> 4. **Type Safety:** Raw Map থেকে proper Model objects এ convert করি type safety এর জন্য
>
> 5. **Loading State:** `isLoading` flag দিয়ে loading indicator show করি until data ready
>
> এই pattern টা complex data fetch এর জন্য best practice - async loading, error handling, state management সব proper way তে।"

---

## 📊 মূল ক্যালকুলেশন সূত্র

### **1. Individual Progress:**
```dart
Prayer Progress = Completed Prayers / Total Prayers (5)
                = prayersCompleted / 5

Amal Progress = Completed Amals / Total Amals (18)
              = amalCompleted / 18

Dhikr Progress = Dhikr Count / Target (600) [clamped 0-1]
               = (dhikrCount / 600).clamp(0.0, 1.0)

Reading Progress = Minutes / Target (35) [clamped 0-1]
                 = (readingMinutes / 35).clamp(0.0, 1.0)
```

### **2. Overall Score:**
```dart
Overall Progress = (Prayer + Amal + Dhikr + Reading) / 4

Overall Score = Overall Progress × 100
```

**ব্যাখ্যা:**
> "চারটা category এর simple average নিয়ে overall progress calculate করি। এটাকে percentage এ convert করে score বানাই যা user friendly।"

### **3. Streak Algorithm:**
```dart
streak = 0
for i from 0 to 364:
    date = today - i days
    if date এর score >= 60%:
        streak++
    else if i > 0:  // আজকের দিন ছাড়া
        break
return streak
```

**ব্যাখ্যা:**
> "আজ থেকে backward traversal করে consecutive 60%+ days count করি। আজকের দিন incomplete থাকলেও streak টা maintain হয়।"

### **4. Perfect Days:**
```dart
Perfect Day = Overall Score >= 80%
```

### **5. Weekly/Monthly Totals:**
```dart
Total = Σ(daily values for all days)
Average = Σ(daily progress) / number of days
```

---

## 🎨 UI Components Summary

| Component | File | Purpose | Key Features |
|-----------|------|---------|-------------|
| **Streak Card** | `streak_card.dart` | Current ও Best streak display | Fire icon, gradient background, Bengali numbers |
| **Tab Selector** | `tab_selector.dart` | Weekly/Monthly/Qaza toggle | Pill-shaped tabs, smooth transition |
| **Weekly Chart** | `weekly_progress_chart.dart` | 7 দিনের bar chart | Interactive tooltips, color-coded bars, Bengali labels |
| **Category Progress** | `category_progress_section.dart` | ৪টি category এর progress bars | Icon-based, percentage display |
| **Weekly Summary** | `weekly_summary_section.dart` | নামাজ, আমল, যিকির, পড়ার totals | Jamaat/delayed breakdown, perfect days count |
| **Monthly Calendar** | `monthly_calendar_view.dart` | GitHub-style calendar heatmap | Color-coded cells, interactive, today highlight |
| **Day Details Sheet** | `day_details_sheet.dart` | Specific date এর বিস্তারিত | Bottom sheet modal, lazy loaded, expandable sections |

---

## 🔑 Key Interview Points

### **1. Multi-Source Data Aggregation:**
> "৪টি আলাদা Hive box (prayer, amal, dhikr, reading) থেকে data একসাথে aggregate করি। প্রতিটা box এ date-wise data store থাকে। Set ব্যবহার করে unique dates collect করি, then প্রতিটা date এর জন্য সব sources থেকে data merge করে DailyStatistics object তৈরি করি।"

### **2. Efficient Calculation with Functional Programming:**
> "`fold`, `map`, `reduce` এর মতো functional methods ব্যবহার করি যা declarative ও readable। For loop এর চেয়ে এগুলো immutable operations promote করে এবং side effects কম।"

### **3. Streak Algorithm:**
> "Backward traversal approach - আজ থেকে শুরু করে past এ যাই। 60% threshold ব্যবহার করি realistic goals এর জন্য। Edge case handle করি আজকের দিন incomplete থাকলে।"

### **4. State Management with Riverpod:**
> "StatisticsNotifier extends StateNotifier - reactive state management। যখন কোনো provider থেকে data update হয়, automatically statistics recalculate হয়। `ref.watch()` দিয়ে UI reactive থাকে।"

### **5. Chart Visualization:**
> "fl_chart package ব্যবহার করে professional charts। Custom colors, tooltips, animations সব configure করা। Data visualization user engagement অনেক বাড়ায়।"

### **6. Null Safety & Error Handling:**
> "সব জায়গায় null checks (`??` operator, `.clamp()`, `if != null`). Try-catch blocks async operations এ। `mounted` check করি setState এ। Division by zero avoid করতে empty checks।"

### **7. Performance Optimization:**
> "- **Lazy Loading:** Day details শুধু tap করলেই load হয়
> - **GridView.builder:** শুধু visible cells render হয়
> - **Caching:** StatisticsModel এ data cache থাকে, bar bar calculate না করে
> - **Async operations:** Heavy calculations main thread block করে না"

### **8. Separation of Concerns:**
> "- **Models:** Data structure ও calculations
> - **Providers:** State management ও business logic
> - **Widgets:** শুধু UI rendering
> - **Services:** Data persistence (Hive)
>
> এই architecture maintainable ও testable code produce করে।"

### **9. Reusable Components:**
> "WeeklySummarySection, CategoryProgressSection - এগুলো weekly ও monthly দুই view এই কাজ করে। `isMonthly` flag দিয়ে behavior control করি। Code duplication এড়াই।"

### **10. User Experience:**
> "- **Bengali localization:** Numbers ও text সব বাংলায়
> - **Color coding:** Score অনুযায়ী intuitive colors (green=good, red=needs improvement)
> - **Interactive elements:** Charts এ tooltips, calendar এ tap interactions
> - **Loading states:** Async operations এর জন্য proper feedback
> - **Empty states:** যখন data নেই graceful fallback"

---

## ✅ Complete Data Flow Diagram

```
USER ACTIONS
    ↓
├─ Home Screen → Update Stats Button
├─ Daily Activities (Prayer/Amal/Dhikr/Reading)
│       ↓
│   Individual Providers Update
│       ↓
│   Save to Hive Boxes
│       ↓
│   statisticsProvider.updateTodayStats()
│       ↓
├─ Statistics Screen Opened
    ↓
statisticsProvider.rebuildFromBoxes()
    ↓
┌─────────────────────────────────────┐
│  PHASE 1: DATA COLLECTION           │
│  - Open 4 Hive boxes                │
│  - Collect all unique dates         │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  PHASE 2: DAILY PROCESSING          │
│  For each date:                     │
│  - Extract prayer count             │
│  - Extract amal count               │
│  - Extract dhikr count              │
│  - Extract reading minutes          │
│  - Create DailyStatistics object    │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  PHASE 3: AGGREGATION               │
│  - Calculate current streak         │
│  - Update best streak               │
│  - Build StatisticsModel            │
│  - Generate WeeklyStatistics        │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  PHASE 4: STATE UPDATE              │
│  - Update state with new data       │
│  - Notify all listeners             │
│  - Save to Hive                     │
│  - Sync to Firestore                │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│  PHASE 5: UI RENDERING              │
│  ├─ Streak Card                     │
│  ├─ Weekly Progress Chart           │
│  ├─ Category Progress Bars          │
│  ├─ Summary Cards                   │
│  ├─ Monthly Calendar (if selected)  │
│  └─ Qaza Section (if selected)      │
└─────────────────────────────────────┘
    ↓
USER INTERACTIONS
│
├─ Tap on Chart → Show Tooltip
├─ Tap on Calendar Date → Show Day Details Bottom Sheet
│       ↓
│   getDetailedDataForDate()
│       ↓
│   Load individual models
│       ↓
│   Display prayers, amals, dhikr items, reading sessions, sins
│
├─ Switch Tab → Change view (Weekly/Monthly/Qaza)
└─ Change Month → Update calendar view
```

---

## 🎓 Interview Tips

### **যখন Statistics feature explain করবেন:**

1. **Start with Overview:**
   > "আমাদের app এ Statistics feature টা একটা comprehensive analytics dashboard যেখানে user তার সব ইবাদত-আমলের performance track করতে পারে। এটা তিনটা main view আছে - Weekly, Monthly, এবং Qaza prayers।"

2. **Architecture Explain করুন:**
   > "আমরা clean architecture follow করেছি। Data layer এ Models আছে যা শুধু data structure define করে। Provider layer এ business logic থাকে - data fetching, calculations, state management। UI layer শুধু presentation এর জন্য।"

3. **Technical Challenges highlight করুন:**
   > "সবচেয়ে বড় challenge ছিল multiple data sources থেকে efficiently data aggregate করা without performance issues। আমরা solve করেছি async operations, lazy loading, এবং proper state management দিয়ে।"

4. **Show Problem-Solving:**
   > "Streak calculation এ একটা edge case handle করতে হয়েছে - user যদি আজকের data entry এখনো complete না করে থাকে, তাহলে streak break করা উচিত না। তাই `i > 0` check add করেছি।"

5. **User-Centric Approach:**
   > "আমরা শুধু data দেখাই না, meaningful insights provide করি। Color coding দিয়ে quick visual feedback, perfect days count করে motivation, streak system দিয়ে consistency encourage করি।"

---

## � মাসিক ক্যালেন্ডারে দিনের উপর ক্লিক করলে বিস্তারিত দেখানোর প্রসেস

এটি একটি **multi-step asynchronous process** যেখানে user interaction থেকে শুরু করে detailed data display পর্যন্ত সবকিছু ঘটে।

---

### **Step 1: Calendar Cell এ Tap Detection**

#### 📍 **ফাইল:** `monthly_calendar_view.dart` (লাইন 300-350 approx)

```dart
// Calendar grid এ প্রতিটা date একটা GestureDetector wrapped
GestureDetector(
  onTap: () {
    final date = DateTime(year, month, dayNumber);
    widget.onDateSelected(date); // Callback trigger
  },
  child: Container(
    // Date cell UI
    decoration: BoxDecoration(
      color: _getDateColor(_monthScores[dateKey] ?? 0),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('${_toBengaliNumber(dayNumber)}'),
  ),
)
```

**ইন্টারভিউতে বলবেন:**
> "User যখন calendar এর কোনো তারিখে tap করে, `onDateSelected` callback trigger হয় যা parent widget (StatisticsScreen) কে inform করে। এটা standard Flutter callback pattern।"

---

### **Step 2: Statistics Screen এ Callback Handler**

#### 📍 **ফাইল:** `statistics_screen.dart` (লাইন 90-105)

```dart
MonthlyCalendarView(
  selectedMonth: selectedMonth,
  selectedDate: selectedDate,
  statsData: statsState.data,
  onDateSelected: (date) {
    setState(() {
      selectedDate = date; // Selected date save করা
    });
    _showDayDetails(date, statsState); // Bottom sheet দেখানো
  },
)

// লাইন 355-365: Bottom sheet show করার function
void _showDayDetails(DateTime date, StatisticsState statsState) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return DayDetailsSheet(
        date: date,
        statsNotifier: ref.read(statisticsProvider.notifier),
      );
    },
  );
}
```

**বলবেন:**
> "Callback receive করার পর দুটো কাজ হয়:
> 1. `setState` করে selected date store করি - এতে UI তে selected date highlight হয়
> 2. `showModalBottomSheet` call করে DayDetailsSheet widget show করি
>
> `isScrollControlled: true` দিয়ে full-height bottom sheet enable করি যাতে user scroll করতে পারে।"

---

### **Step 3: DayDetailsSheet Initialization**

#### 📍 **ফাইল:** `day_details_sheet.dart` (লাইন 26-30)

```dart
@override
void initState() {
  super.initState();
  _loadData(); // Async data loading শুরু
}
```

**বলবেন:**
> "Bottom sheet যখন create হয়, `initState` তে `_loadData()` function call হয় যা asynchronous data fetching শুরু করে। এই সময় `isLoading = true` থাকে এবং UI তে loading spinner দেখায়।"

---

### **Step 4: Detailed Data Fetching**

#### 📍 **লাইন 32-69: Data Loading Process**

```dart
Future<void> _loadData() async {
  // Step 4.1: Date format করা
  final dateKey = _formatDate(widget.date); // "2026-01-09" format
  
  // Step 4.2: Provider থেকে aggregated data fetch
  final data = await widget.statsNotifier.getDetailedDataForDate(dateKey);
  
  // Step 4.3: Sin tracker data আলাদাভাবে load
  DailySinRecord? sinData;
  List<SinType> sinTypes = getDefaultSinTypes();
  
  try {
    final box = Hive.box('sin_tracker');
    
    // Sin record load
    final sinJson = box.get(dateKey);
    if (sinJson != null) {
      sinData = DailySinRecord.fromJson(Map<String, dynamic>.from(sinJson));
    }
    
    // Sin types load (default + custom)
    final sinTypesData = box.get('sin_types');
    if (sinTypesData != null) {
      final List<dynamic> typesList = List<dynamic>.from(sinTypesData);
      sinTypes = typesList.map((s) {
        final map = Map<String, dynamic>.from(s);
        return SinType.fromJson(map);
      }).toList();
    }
  } catch (e) {
    // Silent error handling
  }
  
  // Step 4.4: State update করা
  if (mounted) {
    setState(() {
      detailedData = data;
      sinRecord = sinData;
      allSinTypes = sinTypes;
      isLoading = false; // Loading complete
    });
  }
}
```

**বলবেন:**
> "Data loading চারটা step এ হয়:
> 
> **4.1 Date Formatting:** DateTime object কে 'YYYY-MM-DD' string এ convert করি কারণ Hive box এ এই format এ key থাকে
>
> **4.2 Main Data Fetch:** `statisticsProvider.getDetailedDataForDate()` call করি যা prayer, amal, dhikr, reading - এই চারটা category এর complete model return করে
>
> **4.3 Sin Data Separate Load:** Sin tracker data আলাদা box এ থাকে, তাই direct Hive access করি। Default sin types load করি, তারপর custom types থাকলে merge করি
>
> **4.4 State Update:** `mounted` check করে ensure করি widget এখনো tree তে আছে কিনা, তারপর `setState` করে UI update করি। `isLoading = false` করায় loading spinner হাইড হয়ে actual content show হয়।"

---

### **Step 5: Provider থেকে Detailed Data Extraction**

#### 📍 **ফাইল:** `statistics_provider.dart` (লাইন 295-331)

```dart
Future<DayDetailedData> getDetailedDataForDate(String dateKey) async {
  // Step 5.1: সব Hive boxes open করা
  final amalBox = await Hive.openBox('daily_amal');
  final dhikrBox = await Hive.openBox('dhikr_counter');
  final readingBox = await Hive.openBox('reading_tracker');
  final prayerBox = await Hive.openBox('prayer_tracking');

  // Step 5.2: প্রতিটা box থেকে raw data extract করা
  DailyAmalModel? amalModel;
  final amalData = amalBox.get(dateKey);
  if (amalData != null) {
    // Raw Map কে typed Model এ convert
    amalModel = DailyAmalModel.fromJson(Map<String, dynamic>.from(amalData));
  }

  DhikrCounterModel? dhikrModel;
  final dhikrData = dhikrBox.get(dateKey);
  if (dhikrData != null) {
    dhikrModel = DhikrCounterModel.fromJson(Map<String, dynamic>.from(dhikrData));
  }

  ReadingTrackerModel? readingModel;
  final readingData = readingBox.get(dateKey);
  if (readingData != null) {
    readingModel = ReadingTrackerModel.fromJson(Map<String, dynamic>.from(readingData));
  }

  PrayerTrackingModel? prayerModel;
  final prayerData = prayerBox.get(dateKey);
  if (prayerData != null) {
    prayerModel = PrayerTrackingModel.fromJson(Map<String, dynamic>.from(prayerData));
  }

  // Step 5.3: Aggregated object return করা
  return DayDetailedData(
    amalModel: amalModel,
    dhikrModel: dhikrModel,
    readingModel: readingModel,
    prayerModel: prayerModel,
  );
}
```

**ইন্টারভিউতে বলবেন:**
> "এই function টা critical কারণ:
>
> **5.1 Concurrent Box Access:** চারটা আলাদা Hive box async ভাবে open করি। Hive locally stored NoSQL database।
>
> **5.2 Type-Safe Conversion:** Hive থেকে dynamic Map আসে। আমরা প্রতিটা Map কে proper Model class এ convert করি `fromJson` method দিয়ে। এতে:
> - Type safety পাই (compile-time error detection)
> - Code readability বাড়ে
> - Model properties access করা সহজ হয় (autocomplete support)
>
> **5.3 Aggregated Response:** সব data একটা `DayDetailedData` wrapper object এ pack করে return করি। এতে single async call এ সব data পাওয়া যায়।
>
> **Null Handling:** যদি কোনো date এর data না থাকে (user সেদিন track করেনি), model null হবে। UI layer এ proper empty state show করি।"

---

### **Step 6: Overall Score Calculation**

#### 📍 **ফাইল:** `day_details_sheet.dart` (লাইন 98-122)

```dart
int _calculateOverallScore() {
  if (detailedData == null) return 0;
  
  // Individual scores (0.0 to 1.0)
  double prayerScore = 0;
  double amalScore = 0;
  double dhikrScore = 0;
  double readingScore = 0;

  // Prayer score: completed prayers / 5
  final prayer = detailedData!.prayerModel;
  if (prayer != null) {
    prayerScore = prayer.completedPrayersCount / 5;
  }

  // Amal score: completed amals / total amals
  final amal = detailedData!.amalModel;
  if (amal != null && amal.totalCount > 0) {
    amalScore = amal.completedCount / amal.totalCount;
  }

  // Dhikr score: dhikr count / target (clamped to 1.0)
  final dhikr = detailedData!.dhikrModel;
  if (dhikr != null && dhikr.totalTarget > 0) {
    dhikrScore = (dhikr.totalCount / dhikr.totalTarget).clamp(0.0, 1.0);
  }

  // Reading score: minutes / target (clamped to 1.0)
  final reading = detailedData!.readingModel;
  if (reading != null && reading.goal.totalMinutes > 0) {
    readingScore = (reading.totalMinutes / reading.goal.totalMinutes).clamp(0.0, 1.0);
  }

  // Average of all four scores → percentage
  return ((prayerScore + amalScore + dhikrScore + readingScore) / 4 * 100).toInt();
}
```

**বলবেন:**
> "Overall score calculation একই formula follow করে যা monthly calendar view এ ছিল, কিন্তু এখানে আমরা detailed models থেকে data নিচ্ছি।
>
> **Key Points:**
> 1. **Individual Scores:** প্রতিটা category এর আলাদা score 0.0-1.0 range এ
> 2. **Division by Zero Protection:** প্রতিটা division এ denominator > 0 check করি
> 3. **Clamping:** Dhikr ও Reading এ `.clamp(0.0, 1.0)` করি কারণ user target exceed করতে পারে
> 4. **Average Formula:** চারটার simple average নিয়ে 100 দিয়ে multiply করে percentage পাই
> 5. **Null Safety:** Model null হলে score 0 return হয়
>
> এই score টা header এ badge হিসেবে display হয় যাতে user একনজরে বুঝতে পারে সেদিন কেমন করেছে।"

---

### **Step 7: UI Rendering with Detailed Breakdown**

#### 📍 **লাইন 145-200: Build Method Structure**

```dart
@override
Widget build(BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: 0.85,  // 85% screen height
    minChildSize: 0.5,       // Minimum 50%
    maxChildSize: 0.95,      // Maximum 95%
    builder: (context, scrollController) {
      return Container(
        child: Column(
          children: [
            // Drag handle
            Container(width: 40, height: 4, /* styling */),
            
            // Main content
            Expanded(
              child: isLoading
                  ? CircularProgressIndicator() // Loading state
                  : ListView(
                      controller: scrollController,
                      children: [
                        _buildDateHeader(),      // Date + Score
                        _buildNamazSection(),    // Prayer details
                        _buildDailyAmalSection(), // Amal checklist
                        _buildDhikrSection(),    // Dhikr counts
                        _buildReadingSection(),  // Reading breakdown
                        _buildSinSection(),      // Sin tracker
                      ],
                    ),
            ),
          ],
        ),
      );
    },
  );
}
```

**বলবেন:**
> "`DraggableScrollableSheet` ব্যবহার করেছি যা user কে sheet টা drag করে resize করতে দেয়। এটা modern mobile UX pattern।
>
> **Loading State Management:** 
> - `isLoading = true` থাকা অবস্থায় spinner
> - Data load হলে ListView with actual content
>
> **ListView Controller:** ScrollController pass করি যাতে dragging ও scrolling দুটোই smooth work করে।"

---

### **Step 8: Category-wise Data Display**

#### **8.1 Prayer Section** (লাইন 267-286)

```dart
Widget _buildNamazSection() {
  final prayer = detailedData?.prayerModel;
  final completedCount = prayer?.completedPrayersCount ?? 0;
  final progress = completedCount / 5; // Progress ratio

  return _CategoryCard(
    icon: Icons.mosque,
    title: 'নামাজ',
    subtitle: '${_toBengaliNumber(completedCount)} টি / ৫ টি সম্পন্ন',
    progress: progress,
    child: prayer != null
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prayer.prayerDone.entries.map((entry) {
              return _PrayerChip(
                name: entry.key,       // "ফজর", "জোহর", etc.
                isCompleted: entry.value, // true/false
              );
            }).toList(),
          )
        : Text('কোনো ডেটা নেই'),
  );
}
```

**বলবেন:**
> "Prayer section এ:
> - **Completed Count:** Model থেকে `completedPrayersCount` property directly পাই
> - **Progress Bar:** 5 দিয়ে ভাগ করে 0-1 ratio পাই
> - **Individual Chips:** `prayerDone` Map এ prayer name → boolean mapping থাকে। `map()` করে প্রতিটা prayer এর জন্য chip widget তৈরি করি
> - **Wrap Widget:** Chips গুলো responsive layout এ automatically wrap হয় screen size অনুযায়ী"

---

#### **8.2 Amal Section** (লাইন 288-311)

```dart
Widget _buildDailyAmalSection() {
  final amal = detailedData?.amalModel;
  final completedCount = amal?.completedCount ?? 0;
  final totalCount = amal?.totalCount ?? 18;
  final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

  return _CategoryCard(
    icon: Icons.check_circle_outline,
    title: 'প্রতিদিনের আমল',
    subtitle: '${_toBengaliNumber(completedCount)} টি / ${_toBengaliNumber(totalCount)} টি সম্পন্ন',
    progress: progress,
    isExpandable: true, // Can collapse/expand
    child: amal != null
        ? Column(
            children: amal.items.map((item) {
              return _AmalItem(
                title: item.title,
                isCompleted: item.isCompleted,
              );
            }).toList(),
          )
        : Text('কোনো ডেটা নেই'),
  );
}
```

**বলবেন:**
> "Amal section unique কারণ:
> - **Dynamic List:** User এর configured amal items list dynamic (18 items by default কিন্তু customizable)
> - **Expandable:** `isExpandable: true` করায় user চাইলে collapse করতে পারে space save করতে
> - **Item Iteration:** `items` list এর প্রতিটা element এর জন্য `_AmalItem` widget তৈরি করি with title ও completion status
> - **Strikethrough Effect:** Completed items এ strikethrough text decoration apply হয়"

---

#### **8.3 Dhikr Section** (লাইন 313-343)

```dart
Widget _buildDhikrSection() {
  final dhikr = detailedData?.dhikrModel;
  final totalCount = dhikr?.totalCount ?? 0;
  final totalTarget = dhikr?.totalTarget ?? 600;
  final progress = totalTarget > 0 ? (totalCount / totalTarget).clamp(0.0, 1.0) : 0.0;

  return _CategoryCard(
    icon: Icons.favorite,
    title: 'যিকির',
    subtitle: '${_toBengaliNumber(totalCount)} বার / ${_toBengaliNumber(totalTarget)} বার সম্পন্ন',
    progress: progress,
    isExpandable: true,
    child: dhikr != null
        ? Column(
            children: dhikr.items.map((item) {
              return _DhikrItem(
                title: item.title,           // "সুবহানাল্লাহ"
                arabic: item.arabic,         // "سبحان الله"
                currentCount: item.currentCount,
                targetCount: item.targetCount,
                toBengaliNumber: _toBengaliNumber,
              );
            }).toList(),
          )
        : Text('কোনো ডেটা নেই'),
  );
}
```

**বলবেন:**
> "Dhikr section এ special features:
> - **Total Aggregation:** সব dhikr items এর count ও target sum করে overall progress show করি
> - **Arabic Text:** প্রতিটা dhikr এর Arabic text display করি authenticity এর জন্য
> - **Individual Progress:** প্রতিটা dhikr item এর নিজস্ব count/target badge থাকে
> - **Color Coding:** Target complete হলে gold color, না হলে grey - instant visual feedback"

---

#### **8.4 Reading Section** (লাইন 345-385)

```dart
Widget _buildReadingSection() {
  final reading = detailedData?.readingModel;
  final totalMinutes = reading?.totalMinutes ?? 0;
  final targetMinutes = reading?.goal.totalMinutes ?? 35;
  final progress = targetMinutes > 0 ? (totalMinutes / targetMinutes).clamp(0.0, 1.0) : 0.0;

  return _CategoryCard(
    icon: Icons.menu_book,
    title: 'পড়াশোনা',
    subtitle: '${_toBengaliNumber(totalMinutes)} মিনিট / ${_toBengaliNumber(targetMinutes)} মিনিট সম্পন্ন',
    progress: progress,
    child: reading != null
        ? Column(
            children: [
              _ReadingItem(
                icon: Icons.book,
                title: 'কুরআন তিলাওয়াত',
                minutes: reading.quranMinutes,
                target: reading.goal.quranMinutes,
              ),
              _ReadingItem(
                icon: Icons.book_outlined,
                title: 'তাফসীর',
                minutes: reading.tafsirMinutes,
                target: reading.goal.tafsirMinutes,
              ),
              _ReadingItem(
                icon: Icons.auto_stories,
                title: 'হাদিস',
                minutes: reading.hadithMinutes,
                target: reading.goal.hadithMinutes,
              ),
            ],
          )
        : Text('কোনো ডেটা নেই'),
  );
}
```

**বলবেন:**
> "Reading section তিনটা sub-category এ divided:
> - **Quran Tilawat:** কুরআন পড়ার সময়
> - **Tafsir:** তাফসীর পড়ার সময়
> - **Hadith:** হাদিস পড়ার সময়
>
> প্রতিটার আলাদা icon, individual progress tracking, এবং target থাকে। User দেখতে পারে exact কোথায় বেশি/কম সময় দিচ্ছে।"

---

#### **8.5 Sin Tracker Section** (লাইন 387-532)

```dart
Widget _buildSinSection() {
  final sins = sinRecord?.records ?? [];
  final committedSins = sins.where((s) => s.hasSinned).toList();
  final totalSins = committedSins.length;
  final kaffaraDone = committedSins.where((s) => s.kaffaraDone).length;

  String getSinName(String sinTypeId) {
    // Search in loaded sin types (custom + default)
    for (final sinType in allSinTypes) {
      if (sinType.id == sinTypeId) return sinType.name;
    }
    return 'অজানা গুনাহ';
  }

  return Container(
    child: Column(
      children: [
        // Header with count
        Row(
          children: [
            Icon(Icons.auto_fix_high),
            Text(
              totalSins == 0
                  ? 'মাশাআল্লাহ! কোনো গুনাহ নেই'
                  : '${_toBengaliNumber(totalSins)} টি গুনাহ, ${_toBengaliNumber(kaffaraDone)} টি কাফফারা দেওয়া',
            ),
          ],
        ),
        
        // Sin list
        if (committedSins.isNotEmpty)
          ...committedSins.map((sin) {
            final sinName = getSinName(sin.sinTypeId);
            return Row(
              children: [
                Icon(sin.kaffaraDone ? Icons.check_circle : Icons.cancel),
                Text(sinName),
                if (sin.kaffaraDone)
                  Container(child: Text(getKaffaraName(sin.kaffaraType)))
                else
                  Container(child: Text('কাফফারা বাকি')),
              ],
            );
          }),
      ],
    ),
  );
}
```

**বলবেন:**
> "Sin tracker section sensitive ও private data handle করে:
> - **Filtering:** শুধু `hasSinned = true` records show করি
> - **Sin Type Mapping:** `sinTypeId` থেকে human-readable name বের করি lookup করে
> - **Kaffara Status:** প্রতিটা sin এর পাশে কাফফারা দেওয়া হয়েছে কিনা badge দেখায়
> - **Positive Feedback:** কোনো sin না থাকলে 'মাশাআল্লাহ!' message - positive reinforcement
> - **Color Coding:** Green check = kaffara done, Red cross = pending"

---

### **Step 9: Reusable _CategoryCard Component**

#### 📍 **লাইন 553-653**

```dart
class _CategoryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final Widget child;
  final bool isExpandable;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool isExpanded = true; // Default expanded

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress * 100).toInt();

    return Container(
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: widget.isExpandable
                ? () => setState(() => isExpanded = !isExpanded)
                : null,
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: AppTheme.primaryGold),
                ),
                
                // Title & subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: TextStyle(fontSize: 16, bold)),
                    Text(widget.subtitle, style: TextStyle(fontSize: 12, grey)),
                  ],
                ),
                
                // Percentage
                Text('$percentage%', style: TextStyle(fontSize: 14, bold)),
                
                // Expand/collapse icon
                if (widget.isExpandable)
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
          
          // Progress bar (always visible)
          LinearProgressIndicator(
            value: widget.progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryGold),
          ),
          
          // Content (conditionally visible)
          if (isExpanded || !widget.isExpandable)
            Padding(
              padding: EdgeInsets.all(16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
```

**বলবেন:**
> "_CategoryCard একটা highly reusable component যা সব sections এ common structure provide করে:
>
> **Features:**
> 1. **Consistent Layout:** Icon, title, subtitle, progress সব sections এ same position এ
> 2. **Collapsible:** `isExpandable` flag দিয়ে control করি কোন sections collapse করা যাবে
> 3. **State Management:** নিজস্ব state maintain করে expand/collapse tracking এর জন্য
> 4. **Visual Hierarchy:** Header always visible থাকে quick overview এর জন্য, details optional
> 5. **Percentage Display:** Progress bar ছাড়াও exact percentage number show করি precision এর জন্য
>
> এই pattern টা code duplication কমায় এবং consistent UX ensure করে।"

---

## 🔄 Complete Flow Diagram: Calendar Tap to Details Display

```
┌─────────────────────────────────────────────────┐
│ USER TAPS ON CALENDAR DATE (e.g., Jan 9, 2026) │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ MonthlyCalendarView.onTap()                     │
│ - GestureDetector triggered                     │
│ - Create DateTime object from tap position      │
│ - Call widget.onDateSelected(date) callback     │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ StatisticsScreen.onDateSelected()               │
│ - setState({ selectedDate = date })             │
│ - Call _showDayDetails(date, statsState)        │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ showModalBottomSheet()                          │
│ - Create DayDetailsSheet widget                 │
│ - Pass: date, statsNotifier                     │
│ - isScrollControlled: true                      │
│ - backgroundColor: transparent                  │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ DayDetailsSheet.initState()                     │
│ - Set isLoading = true                          │
│ - Call _loadData()                              │
│ - Show CircularProgressIndicator               │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ _loadData() - ASYNC OPERATIONS                  │
│                                                  │
│ ┌─────────────────────────────────────────┐    │
│ │ 1. Format date to "YYYY-MM-DD"          │    │
│ │    "2026-01-09"                          │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ 2. Call statsNotifier.getDetailedData() │    │
│ │    ↓                                     │    │
│ │    ┌───────────────────────────────┐    │    │
│ │    │ Open 4 Hive Boxes:            │    │    │
│ │    │ - prayer_tracking             │    │    │
│ │    │ - daily_amal                  │    │    │
│ │    │ - dhikr_counter               │    │    │
│ │    │ - reading_tracker             │    │    │
│ │    └───────────────────────────────┘    │    │
│ │    ↓                                     │    │
│ │    ┌───────────────────────────────┐    │    │
│ │    │ Extract data for date:        │    │    │
│ │    │ - PrayerTrackingModel         │    │    │
│ │    │ - DailyAmalModel              │    │    │
│ │    │ - DhikrCounterModel           │    │    │
│ │    │ - ReadingTrackerModel         │    │    │
│ │    └───────────────────────────────┘    │    │
│ │    ↓                                     │    │
│ │    Return DayDetailedData                │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ 3. Load sin data from sin_tracker box   │    │
│ │    - DailySinRecord for date            │    │
│ │    - All SinTypes (default + custom)    │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ 4. setState()                            │    │
│ │    - detailedData = loaded data         │    │
│ │    - sinRecord = sin data               │    │
│ │    - allSinTypes = types list           │    │
│ │    - isLoading = false                  │    │
│ └─────────────────────────────────────────┘    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ UI RE-RENDERS with data                         │
│                                                  │
│ ┌─────────────────────────────────────────┐    │
│ │ Date Header                              │    │
│ │ - _formatDateBengali(date)              │    │
│ │ - _getWeekdayBengali(weekday)           │    │
│ │ - _calculateOverallScore()              │    │
│ │   → (prayer+amal+dhikr+reading)/4*100  │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ Namaz Section                            │    │
│ │ - Extract prayerModel                    │    │
│ │ - Show completed count / 5              │    │
│ │ - Display prayer chips (Fajr, Dhuhr...) │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ Daily Amal Section (Expandable)          │    │
│ │ - Extract amalModel                      │    │
│ │ - Show completed / total                │    │
│ │ - List all amal items with checkmarks   │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ Dhikr Section (Expandable)               │    │
│ │ - Extract dhikrModel                     │    │
│ │ - Show total count / target             │    │
│ │ - List each dhikr with:                 │    │
│ │   * Bengali title                        │    │
│ │   * Arabic text                          │    │
│ │   * Current/target count badge          │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ Reading Section                          │    │
│ │ - Extract readingModel                   │    │
│ │ - Show total minutes / target           │    │
│ │ - Breakdown:                             │    │
│ │   * Quran: X/Y min                      │    │
│ │   * Tafsir: X/Y min                     │    │
│ │   * Hadith: X/Y min                     │    │
│ └─────────────────────────────────────────┘    │
│                   ↓                              │
│ ┌─────────────────────────────────────────┐    │
│ │ Sin Tracker Section                      │    │
│ │ - Extract sinRecord                      │    │
│ │ - Filter hasSinned = true               │    │
│ │ - Show count: X sins, Y kaffara done   │    │
│ │ - List sins with:                        │    │
│ │   * Sin name (from sinTypes lookup)     │    │
│ │   * Kaffara status badge                │    │
│ │   * Color coding (green/red)            │    │
│ └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ USER INTERACTIONS                                │
│ - Scroll up/down to see all sections            │
│ - Tap to expand/collapse Amal/Dhikr sections   │
│ - Drag handle to resize bottom sheet            │
│ - Swipe down to dismiss                         │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Key Calculation Summary

### **Overall Score Formula:**
```dart
prayerScore = completedPrayers / 5
amalScore = completedAmals / totalAmals
dhikrScore = (dhikrCount / dhikrTarget).clamp(0.0, 1.0)
readingScore = (readingMinutes / targetMinutes).clamp(0.0, 1.0)

overallScore = ((prayerScore + amalScore + dhikrScore + readingScore) / 4) * 100
```

### **Category Progress Formula:**
```dart
progress = current / target
percentage = (progress * 100).toInt()

// For dhikr & reading:
progress = (current / target).clamp(0.0, 1.0)  // Max 100%
```

---

## 💡 Interview Tips for This Feature

**Q: মাসিক ক্যালেন্ডারে tap করার পর কীভাবে data load হয়?**

**A:** "এটা একটা multi-layer async process:

1. **UI Layer:** User tap করলে callback trigger হয় যা date information pass করে parent widget এ

2. **Bottom Sheet:** Modal bottom sheet show হয় loading state দিয়ে

3. **Provider Layer:** Statistics provider এর `getDetailedDataForDate()` method call হয় যা:
   - ৪টা Hive box parallel open করে
   - Date-specific data extract করে
   - Raw Maps কে typed Models এ convert করে
   - Aggregated response return করে

4. **Sin Data:** Separately sin tracker box থেকে sin records ও types load হয়

5. **State Update:** সব data load হলে setState করে UI re-render হয় actual content দিয়ে

6. **Calculation:** Each section নিজের data থেকে progress calculate করে, overall score চারটা section এর average

এই পুরো process typically 100-300ms লাগে local Hive database এর speed এর কারণে।"

---

**Q: কেন sin data আলাদাভাবে load করা হয়?**

**A:** "Architecture decision:

1. **Privacy Consideration:** Sin tracker sensitive data, তাই আলাদা box এ isolated থাকে

2. **Optional Feature:** সব user sin tracker use করে না, তাই main statistics flow এ couple করিনি

3. **Error Isolation:** Sin data load এ error হলেও বাকি sections normal কাজ করবে

4. **Custom Sin Types:** User নিজের sin types add করতে পারে, সেটা আলাদা lookup require করে"

---

**Q: Performance optimize করার জন্য কী কী করেছেন?**

**A:** "Several optimization strategies:

1. **Lazy Loading:** শুধু selected date এর data load করি, calendar এর সব dates এর details না

2. **Parallel Async:** চারটা Hive box concurrent open হয় `await` serially না করে

3. **Cached Models:** Models immutable, তাই memory efficient

4. **Collapsible Sections:** User unnecessary sections collapse করে memory ও render time save করতে পারে

5. **ListView Builder:** Large lists এর জন্য builder pattern যাতে only visible items render হয়

6. **Type Conversion:** Hive থেকে data আসার সাথে সাথে typed models এ convert করি - future access fast হয়"

---

এই section টা আপনার explain1.md এ add হয়ে গেছে! 🎉

---

## �🚀 Advanced Topics (যদি জিজ্ঞাসা করে)

### **Q: How would you optimize for large datasets?**
> "Currently আমরা 365 দিন পর্যন্ত process করি। যদি years এর data হয়:
> 1. **Pagination:** শুধু visible month/week এর data load করব
> 2. **Indexing:** Hive box এ compound keys ব্যবহার করব (year-month-day)
> 3. **Caching:** Computed statistics cache করব, expire করব যখন underlying data change হয়
> 4. **Background Processing:** Heavy calculations isolate করব separate isolate এ"

### **Q: How do you handle offline/online sync?**
> "Firestore sync service আছে। Local-first approach:
> 1. সব operations প্রথমে local Hive এ হয়
> 2. Background এ Firestore sync হয়
> 3. Conflict resolution: last-write-wins strategy
> 4. Sync status indicator user কে দেখাই"

### **Q: Testing strategy?**
> "Unit tests লিখব:
> 1. Model calculations (progress, score formulas)
> 2. Streak algorithm (various scenarios)
> 3. Date formatting/parsing functions
> 4. Widget tests for UI components
> 5. Integration tests full flow এর জন্য"

### **Q: Accessibility considerations?**
> "1. Semantic labels widgets এ
> 2. Color alone না, icon/text ও ব্যবহার করি
> 3. Touch targets minimum 48×48
> 4. Screen reader support test করব
> 5. High contrast mode support"

---

এই রিপোর্ট প্রিন্ট করে নিয়ে interview এ reference হিসেবে ব্যবহার করতে পারবেন! 🎯
