import 'dart:convert';
import 'dart:io';

class PrayerTimesApiService {
  /// Fetch prayer times for a specific date from an API.
  ///
  /// Example API used: AlAdhan timings endpoint.
  /// Date format: DD-MM-YYYY
  ///
  /// Returns map keys: fajr, dhuhr, asr, maghrib, isha (DateTime in local time)
  static Future<Map<String, DateTime>> fetchPrayerTimesForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    int method = 1, // API method id (University of Islamic Sciences, Karachi)
    int school = 1, // 0 = Shafi (shadow = 1x), 1 = Hanafi (shadow = 2x)
  }) async {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();

    // Round coords to 2 decimal places so nearby devices get identical results
    final lat = (latitude * 100).round() / 100;
    final lon = (longitude * 100).round() / 100;

    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$dd-$mm-$yyyy'
      '?latitude=$lat&longitude=$lon&method=$method&school=$school',
    );

    final client = HttpClient();
    try {
      final req = await client.getUrl(url);
      final res = await req.close();

      final body = await res.transform(utf8.decoder).join();
      final jsonMap = json.decode(body) as Map<String, dynamic>;

      final data = jsonMap['data'] as Map<String, dynamic>;
      final timings = data['timings'] as Map<String, dynamic>;

      String cleanTime(String raw) {
        // API sometimes returns "05:12 (+06)" → keep only HH:MM
        final m = RegExp(r'(\d{1,2}:\d{2})').firstMatch(raw);
        return m?.group(1) ?? raw;
      }

      DateTime toDateTime(String hhmm) {
        final parts = hhmm.split(':');
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        return DateTime(date.year, date.month, date.day, h, m);
      }

      return {
        'fajr': toDateTime(cleanTime('${timings['Fajr']}')),
        'sunrise': toDateTime(cleanTime('${timings['Sunrise']}')),
        'dhuhr': toDateTime(cleanTime('${timings['Dhuhr']}')),
        'asr': toDateTime(cleanTime('${timings['Asr']}')),
        'maghrib': toDateTime(cleanTime('${timings['Maghrib']}')),
        'isha': toDateTime(cleanTime('${timings['Isha']}')),
      };
    } finally {
      client.close(force: true);
    }
  }
}
