class AppConstants {
  // Model Versions
  static const int currentModelVersion = 1;
  
  // Prayer Constants
  static const double bangladeshFajrAngle = 18.5;
  static const double bangladeshIshaAngle = 17.5;
  static const String calculationMethod = 'Islamic Foundation Bangladesh';
  
  // Notification IDs
  static const int fajrNotificationId = 100;
  static const int dhuhrNotificationId = 101;
  static const int asrNotificationId = 102;
  static const int maghribNotificationId = 103;
  static const int ishaNotificationId = 104;
  static const int customReminderBaseId = 200;
  
  // Hive Box Names
  static const String prayerBoxName = 'prayers';
  static const String dhikrBoxName = 'dhikr';
  static const String amalBoxName = 'amal';
  static const String readingBoxName = 'reading';
  static const String statsBoxName = 'stats';
  static const String settingsBoxName = 'settings';
  static const String categoriesBoxName = 'categories';
  
  // Default Prayer Rakats
  static const Map<String, Map<String, int>> defaultPrayerRakats = {
    'fajr': {'sunnah': 2, 'fard': 2, 'witr': 0},
    'dhuhr': {'sunnah_before': 4, 'fard': 4, 'sunnah_after': 2, 'witr': 0},
    'asr': {'sunnah': 0, 'fard': 4, 'witr': 0},
    'maghrib': {'sunnah': 0, 'fard': 3, 'sunnah_after': 2, 'witr': 0},
    'isha': {'sunnah': 0, 'fard': 4, 'sunnah_after': 2, 'witr': 3},
  };
  
  // Default Dhikr List
  static const List<Map<String, dynamic>> defaultDhikrList = [
    {
      'name_bn': 'সুবহানাল্লাহ',
      'target': 100,
    },
    {
      'name_bn': 'আলহামদুলিল্লাহ',
      'target': 100,
    },
    {
      'name_bn': 'আল্লাহু আকবার',
      'target': 100,
    },
    {
      'name_bn': 'লা ইলাহা ইল্লাল্লাহ',
      'target': 100,
    },
    {
      'name_bn': 'দুরূদ শরীফ',
      'target': 100,
    },
    {
      'name_bn': 'আস্তাগফিরুল্লাহ',
      'target': 100,
    },
  ];
  
  // Default Daily Amal Categories
  static const List<String> miswakTimes = [
    'ফজরের পর',
    'যোহরের পর',
    'আসরের পর',
    'মাগরিবের পর',
    'এশার পর',
    'ঘুমানোর আগে',
  ];
  
  static const List<String> postPrayerAzkar = [
    'ফজরের পরের আজকার',
    'যোহরের পরের আজকার',
    'আসরের পরের আজকার',
    'মাগরিবের পরের আজকার',
    'এশার পরের আজকার',
  ];
  
  static const List<Map<String, String>> defaultSurahs = [
    {'name_bn': 'সূরা ইয়াসিন', 'name_ar': 'سُورَةُ يٰسٓ'},
    {'name_bn': 'সূরা ওয়াকিয়াহ', 'name_ar': 'سُورَةُ ٱلْوَاقِعَةِ'},
    {'name_bn': 'সূরা মুলক', 'name_ar': 'سُورَةُ ٱلْمُلْكِ'},
  ];
  
  static const List<String> defaultDailyDuas = [
    'ঘুম থেকে ওঠার দোয়া',
    'ঘুমাইতে যাওয়ার দোয়া',
  ];
}
