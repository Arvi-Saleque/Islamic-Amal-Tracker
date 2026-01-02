class PrayerTrackingModel {
  final String date; // Format: yyyy-MM-dd
  final Map<String, bool> prayerDone;
  final Map<String, Map<String, bool>> rakatsDone;

  PrayerTrackingModel({
    required this.date,
    required this.prayerDone,
    required this.rakatsDone,
  });

  // Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayerDone': prayerDone,
      'rakatsDone': rakatsDone.map((prayer, rakats) => MapEntry(
            prayer,
            rakats.map((rakat, done) => MapEntry(rakat, done)),
          )),
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
        'ফজর': {'২ রাকাত ফরয': false, '২ রাকাত সুন্নাত': false},
        'যুহর': {
          '৪ রাকাত সুন্নাত': false,
          '২ রাকাত ফরয': false,
          '২ রাকাত সুন্নাত': false
        },
        'আসর': {'৪ রাকাত ফরয': false},
        'মাগরিব': {'৩ রাকাত ফরয': false, '২ রাকাত সুন্নাত': false},
        'এশা': {
          '৪ রাকাত ফরয': false,
          '২ রাকাত সুন্নাত': false,
          '৩ রাকাত বেতের': false
        },
      },
    );
  }

  // Get completed prayers count
  int get completedPrayersCount {
    return prayerDone.values.where((done) => done).length;
  }

  // Copy with
  PrayerTrackingModel copyWith({
    String? date,
    Map<String, bool>? prayerDone,
    Map<String, Map<String, bool>>? rakatsDone,
  }) {
    return PrayerTrackingModel(
      date: date ?? this.date,
      prayerDone: prayerDone ?? Map.from(this.prayerDone),
      rakatsDone: rakatsDone ??
          this.rakatsDone.map(
            (prayer, rakats) => MapEntry(prayer, Map.from(rakats)),
          ),
    );
  }
}
