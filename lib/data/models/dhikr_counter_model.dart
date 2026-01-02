class DhikrItem {
  final String id;
  final String title;
  final String? arabic;
  final int targetCount;
  final int currentCount;
  final bool isCustom;
  final DateTime? lastUpdated;

  DhikrItem({
    required this.id,
    required this.title,
    this.arabic,
    required this.targetCount,
    this.currentCount = 0,
    this.isCustom = false,
    this.lastUpdated,
  });

  DhikrItem copyWith({
    String? id,
    String? title,
    String? arabic,
    int? targetCount,
    int? currentCount,
    bool? isCustom,
    DateTime? lastUpdated,
  }) {
    return DhikrItem(
      id: id ?? this.id,
      title: title ?? this.title,
      arabic: arabic ?? this.arabic,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isCustom: isCustom ?? this.isCustom,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabic': arabic,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'isCustom': isCustom,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory DhikrItem.fromJson(Map<String, dynamic> json) {
    return DhikrItem(
      id: json['id'] as String,
      title: json['title'] as String,
      arabic: json['arabic'] as String?,
      targetCount: json['targetCount'] as int,
      currentCount: json['currentCount'] as int? ?? 0,
      isCustom: json['isCustom'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  bool get isCompleted => currentCount >= targetCount;
  double get progress => targetCount > 0 ? currentCount / targetCount : 0.0;
}

class DhikrCounterModel {
  final String date;
  final List<DhikrItem> items;

  DhikrCounterModel({
    required this.date,
    required this.items,
  });

  DhikrCounterModel copyWith({
    String? date,
    List<DhikrItem>? items,
  }) {
    return DhikrCounterModel(
      date: date ?? this.date,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory DhikrCounterModel.fromJson(Map<String, dynamic> json) {
    return DhikrCounterModel(
      date: json['date'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => DhikrItem.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          [],
    );
  }

  factory DhikrCounterModel.empty() {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return DhikrCounterModel(
      date: dateStr,
      items: _getDefaultDhikrItems(),
    );
  }

  static List<DhikrItem> _getDefaultDhikrItems() {
    return [
      // সকাল-সন্ধ্যার যিকির
      DhikrItem(
        id: 'subhanallah_33',
        title: 'সুবহানাল্লাহ',
        arabic: 'سُبْحَانَ اللّٰهِ',
        targetCount: 33,
      ),
      DhikrItem(
        id: 'alhamdulillah_33',
        title: 'আলহামদুলিল্লাহ',
        arabic: 'الْحَمْدُ لِلّٰهِ',
        targetCount: 33,
      ),
      DhikrItem(
        id: 'allahu_akbar_34',
        title: 'আল্লাহু আকবার',
        arabic: 'اللّٰهُ أَكْبَرُ',
        targetCount: 34,
      ),
      
      // ইস্তিগফার
      DhikrItem(
        id: 'astaghfirullah_100',
        title: 'আস্তাগফিরুল্লাহ',
        arabic: 'أَسْتَغْفِرُ اللّٰهَ',
        targetCount: 100,
      ),
      
      // দরূদ শরীফ
      DhikrItem(
        id: 'durood_100',
        title: 'দরূদ শরীফ',
        arabic: 'صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ',
        targetCount: 100,
      ),
      
      // লা ইলাহা ইল্লাল্লাহ
      DhikrItem(
        id: 'kalima_100',
        title: 'লা ইলাহা ইল্লাল্লাহ',
        arabic: 'لَا إِلٰهَ إِلَّا اللّٰهُ',
        targetCount: 100,
      ),
      
      // সুবহানাল্লাহি ওয়াবিহামদিহি
      DhikrItem(
        id: 'subhanallahi_wabihamdihi_100',
        title: 'সুবহানাল্লাহি ওয়াবিহামদিহি',
        arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
        targetCount: 100,
      ),
      
      // সুবহানাল্লাহিল আযীম
      DhikrItem(
        id: 'subhanallahil_azim_100',
        title: 'সুবহানাল্লাহিল আযীম',
        arabic: 'سُبْحَانَ اللّٰهِ الْعَظِيمِ',
        targetCount: 100,
      ),
    ];
  }

  int get totalCount => items.fold(0, (sum, item) => sum + item.currentCount);
  int get totalTarget => items.fold(0, (sum, item) => sum + item.targetCount);
  int get completedItemsCount => items.where((item) => item.isCompleted).length;
  double get overallProgress => totalTarget > 0 ? totalCount / totalTarget : 0.0;
}
