class PrayerTrackingModel {
  final String date; // Format: yyyy-MM-dd
  final Map<String, bool> prayerDone;
  final Map<String, Map<String, bool>> rakatsDone;
  final Map<String, bool> qazaDone; // Track if qaza has been completed for missed prayers

  PrayerTrackingModel({
    required this.date,
    required this.prayerDone,
    required this.rakatsDone,
    Map<String, bool>? qazaDone,
  }) : qazaDone = qazaDone ?? {
          'ফজর': false,
          'যুহর': false,
          'আসর': false,
          'মাগরিব': false,
          'এশা': false,
        };

  // Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayerDone': prayerDone,
      'rakatsDone': rakatsDone.map((prayer, rakats) => MapEntry(
            prayer,
            rakats.map((rakat, done) => MapEntry(rakat, done)),
          )),
      'qazaDone': qazaDone,
    };
  }

  // Create from JSON
  factory PrayerTrackingModel.fromJson(Map<String, dynamic> json) {
    return PrayerTrackingModel(
      date: json['date'] as String,
      prayerDone: Map<String, bool>.from(json['prayerDone'] as Map),
      rakatsDone: (json['rakatsDone'] as Map).map(
        (prayer, rakats) => MapEntry(
          prayer.toString(),
          Map<String, bool>.from(rakats as Map),
        ),
      ),
      qazaDone: json['qazaDone'] != null 
          ? Map<String, bool>.from(json['qazaDone'] as Map)
          : null,
    );
  }

  // Create empty model for a date
  factory PrayerTrackingModel.empty(String date) {
    return PrayerTrackingModel(
      date: date,
      prayerDone: {
        'ফজর': false,
        'যুহর': false,
        'আসর': false,
        'মাগরিব': false,
        'এশা': false,
      },
      rakatsDone: {
        'ফজর': {
          '২ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
          '২ রাকাত ফরয (দেরী করে)': false,
          '২ রাকাত সুন্নাত': false,
        },
        'যুহর': {
          '৪ রাকাত সুন্নাত (আগে)': false,
          '৪ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
          '৪ রাকাত ফরয (দেরী করে)': false,
          '২ রাকাত সুন্নাত (পরে)': false,
        },
        'আসর': {
          '৪ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
          '৪ রাকাত ফরয (দেরী করে)': false,
        },
        'মাগরিব': {
          '৩ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
          '৩ রাকাত ফরয (দেরী করে)': false,
          '২ রাকাত সুন্নাত': false,
        },
        'এশা': {
          '৪ রাকাত ফরয (জামাতে/আউয়াল ওয়াক্তে)': false,
          '৪ রাকাত ফরয (দেরী করে)': false,
          '২ রাকাত সুন্নাত': false,
          '৩ রাকাত বেতের': false,
        },
      },
    );
  }

  // Get completed prayers count
  int get completedPrayersCount {
    return prayerDone.values.where((done) => done).length;
  }

  // Check if a prayer needs qaza (missed and not yet done qaza)
  bool needsQaza(String prayer) {
    final isMissed = !(prayerDone[prayer] ?? false);
    final isQazaDone = qazaDone[prayer] ?? false;
    return isMissed && !isQazaDone;
  }

  // Copy with
  PrayerTrackingModel copyWith({
    String? date,
    Map<String, bool>? prayerDone,
    Map<String, Map<String, bool>>? rakatsDone,
    Map<String, bool>? qazaDone,
  }) {
    return PrayerTrackingModel(
      date: date ?? this.date,
      prayerDone: prayerDone ?? Map.from(this.prayerDone),
      rakatsDone: rakatsDone ??
          this.rakatsDone.map(
            (prayer, rakats) => MapEntry(prayer, Map.from(rakats)),
          ),
      qazaDone: qazaDone ?? Map.from(this.qazaDone),
    );
  }
}
