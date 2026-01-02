class CustomReminder {
  final String id;
  final String title;
  final String description;
  final String time; // Format: "HH:mm"
  final bool isEnabled;
  final List<int> daysOfWeek; // 0=Sunday, 1=Monday, ..., 6=Saturday
  final DateTime createdAt;

  CustomReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isEnabled,
    required this.daysOfWeek,
    required this.createdAt,
  });

  CustomReminder copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    bool? isEnabled,
    List<int>? daysOfWeek,
    DateTime? createdAt,
  }) {
    return CustomReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'isEnabled': isEnabled,
      'daysOfWeek': daysOfWeek,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomReminder.fromJson(Map<String, dynamic> json) {
    return CustomReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      isEnabled: json['isEnabled'] as bool,
      daysOfWeek: List<int>.from(json['daysOfWeek'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'CustomReminder(id: $id, title: $title, time: $time, isEnabled: $isEnabled)';
  }
}
