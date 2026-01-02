class DailyAmalItem {
  final String id;
  final String title;
  final String category; // 'miswak', 'surah', 'dua', 'custom'
  final bool isCompleted;
  final DateTime? completedAt;

  DailyAmalItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DailyAmalItem.fromJson(Map<String, dynamic> json) {
    return DailyAmalItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  DailyAmalItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return DailyAmalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class DailyAmalModel {
  final String date; // Format: yyyy-MM-dd
  final List<DailyAmalItem> items;

  DailyAmalModel({
    required this.date,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory DailyAmalModel.fromJson(Map<String, dynamic> json) {
    return DailyAmalModel(
      date: json['date'] as String,
      items: (json['items'] as List)
          .map((item) => DailyAmalItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  factory DailyAmalModel.empty(String date) {
    return DailyAmalModel(
      date: date,
      items: [
        // মিসওয়াক
        DailyAmalItem(
          id: 'miswak_fajr',
          title: 'ফজরের আগে মিসওয়াক',
          category: 'miswak',
        ),
        DailyAmalItem(
          id: 'miswak_dhuhr',
          title: 'যোহরের আগে মিসওয়াক',
          category: 'miswak',
        ),
        DailyAmalItem(
          id: 'miswak_asr',
          title: 'আসরের আগে মিসওয়াক',
          category: 'miswak',
        ),
        DailyAmalItem(
          id: 'miswak_maghrib',
          title: 'মাগরিবের আগে মিসওয়াক',
          category: 'miswak',
        ),
        DailyAmalItem(
          id: 'miswak_isha',
          title: 'এশার আগে মিসওয়াক',
          category: 'miswak',
        ),
        // সূরাহ পড়া
        DailyAmalItem(
          id: 'surah_mulk',
          title: 'সূরা মুলক',
          category: 'surah',
        ),
        DailyAmalItem(
          id: 'surah_waqi',
          title: 'সূরা ওয়াকিয়া',
          category: 'surah',
        ),
        DailyAmalItem(
          id: 'surah_kahf',
          title: 'সূরা কাহফ (জুমআ)',
          category: 'surah',
        ),
        DailyAmalItem(
          id: 'surah_yaseen',
          title: 'সূরা ইয়াসিন',
          category: 'surah',
        ),
        // দোয়া
        DailyAmalItem(
          id: 'dua_morning',
          title: 'সকালের দোয়া',
          category: 'dua',
        ),
        DailyAmalItem(
          id: 'dua_evening',
          title: 'সন্ধ্যার দোয়া',
          category: 'dua',
        ),
        DailyAmalItem(
          id: 'dua_sleep',
          title: 'ঘুমানোর আগে দোয়া',
          category: 'dua',
        ),
        // অন্যান্য
        DailyAmalItem(
          id: 'tahajjud',
          title: 'তাহাজ্জুদ নামাজ',
          category: 'prayer',
        ),
        DailyAmalItem(
          id: 'ishraq',
          title: 'ইশরাক নামাজ',
          category: 'prayer',
        ),
        DailyAmalItem(
          id: 'duha',
          title: 'চাশত নামাজ',
          category: 'prayer',
        ),
        DailyAmalItem(
          id: 'awwabin',
          title: 'আউওয়াবীন নামাজ',
          category: 'prayer',
        ),
        DailyAmalItem(
          id: 'charity',
          title: 'দান/সাদাকা',
          category: 'other',
        ),
        DailyAmalItem(
          id: 'helping',
          title: 'কাউকে সাহায্য করা',
          category: 'other',
        ),
      ],
    );
  }

  int get completedCount => items.where((item) => item.isCompleted).length;
  int get totalCount => items.length;
  double get progressPercentage => totalCount > 0 ? completedCount / totalCount : 0;

  DailyAmalModel copyWith({
    String? date,
    List<DailyAmalItem>? items,
  }) {
    return DailyAmalModel(
      date: date ?? this.date,
      items: items ?? this.items,
    );
  }
}
