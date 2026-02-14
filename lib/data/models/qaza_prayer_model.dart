class QazaPrayerModel {
  final String date; // Format: yyyy-MM-dd
  final String prayerName; // ফজর, যোহর, আসর, মাগরিব, এশা
  final bool isCompleted;
  final DateTime? completedAt;

  QazaPrayerModel({
    required this.date,
    required this.prayerName,
    this.isCompleted = false,
    this.completedAt,
  });

  // Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayerName': prayerName,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory QazaPrayerModel.fromJson(Map<String, dynamic> json) {
    return QazaPrayerModel(
      date: json['date'] as String,
      prayerName: json['prayerName'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  // Copy with
  QazaPrayerModel copyWith({
    String? date,
    String? prayerName,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return QazaPrayerModel(
      date: date ?? this.date,
      prayerName: prayerName ?? this.prayerName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Unique key for this qaza prayer
  String get key => '${date}_$prayerName';
}

// Model to hold all qaza prayers grouped by prayer type
class QazaPrayerSummary {
  final String prayerName;
  final List<QazaPrayerModel> missedPrayers;
  final int totalMissed;
  final int totalCompleted;

  QazaPrayerSummary({
    required this.prayerName,
    required this.missedPrayers,
  })  : totalMissed = missedPrayers.where((p) => !p.isCompleted).length,
        totalCompleted = missedPrayers.where((p) => p.isCompleted).length;

  int get totalCount => missedPrayers.length;
  int get pendingCount => totalMissed;
}
