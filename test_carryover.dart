// Test script to debug custom dhikr carryover
import 'package:hive/hive.dart';
import 'dart:io';

void main() async {
  // Initialize Hive
  Hive.init(Directory.current.path);

  final box = await Hive.openBox('dhikr_counter');

  print('=== Dhikr Counter Box Contents ===\n');

  for (var key in box.keys) {
    print('Date: $key');
    final data = box.get(key);
    if (data != null && data is Map) {
      final items = data['items'] as List?;
      if (items != null) {
        for (var item in items) {
          if (item is Map) {
            print(
              '  - ${item['title']} | isCustom: ${item['isCustom']} | count: ${item['currentCount']}/${item['targetCount']}',
            );
          }
        }
      }
    }
    print('');
  }

  await box.close();
}
