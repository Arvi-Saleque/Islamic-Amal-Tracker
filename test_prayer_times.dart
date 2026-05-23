import 'package:adhan_dart/adhan_dart.dart';

void main() {
  // Khulna coordinates (user mentioned Khulna)
  const coordinates = Coordinates(22.8456, 89.5403);

  // Today: January 3, 2026
  final date = DateTime(2026, 1, 3);

  // Use Karachi method (similar to Islamic Foundation Bangladesh)
  final params = CalculationMethodParameters.karachi();
  params.madhab = Madhab.hanafi;

  final prayerTimes = PrayerTimes(
    coordinates: coordinates,
    date: date,
    calculationParameters: params,
    precision: true,
  );

  // Convert to local time (Bangladesh is UTC+6)
  final fajr = prayerTimes.fajr.toLocal();
  final sunrise = prayerTimes.sunrise.toLocal();
  final dhuhr = prayerTimes.dhuhr.toLocal();
  final asr = prayerTimes.asr.toLocal();
  final maghrib = prayerTimes.maghrib.toLocal();
  final isha = prayerTimes.isha.toLocal();

  // Calculate forbidden times
  final sunriseEnd = sunrise.add(const Duration(minutes: 15));
  final zawalStart = dhuhr.subtract(const Duration(minutes: 10));
  final sunsetForbiddenStart = maghrib.subtract(const Duration(minutes: 15));

  print('📅 আজ ৩ জানুয়ারি ২০২৬ - খুলনার নামাজের সময়:\n');

  print('🌅 ফজর:');
  print('   শুরু: ${_formatTime(fajr)}');
  print('   শেষ: ${_formatTime(sunrise)} (সূর্যোদয়)');
  print('   ওয়াক্ত রেঞ্জ: ${_formatTime(fajr)} - ${_formatTime(sunrise)}\n');

  print(' নিষিদ্ধ সময় #1 (সূর্যোদয়ের পর):');
  print('   ${_formatTime(sunrise)} - ${_formatTime(sunriseEnd)}\n');

  print('✨ নফল নামাজের সময়:');
  print('   ${_formatTime(sunriseEnd)} - ${_formatTime(zawalStart)}\n');

  print(' নিষিদ্ধ সময় #2 (যাওয়াল - সূর্য মাথার উপরে):');
  print('   ${_formatTime(zawalStart)} - ${_formatTime(dhuhr)}\n');

  print('☀️ যোহর:');
  print('   শুরু: ${_formatTime(dhuhr)}');
  print('   শেষ: ${_formatTime(asr)} (আসর শুরু)');
  print('   ওয়াক্ত রেঞ্জ: ${_formatTime(dhuhr)} - ${_formatTime(asr)}\n');

  print('🌤️ আসর:');
  print('   শুরু: ${_formatTime(asr)}');
  print(
    '   শেষ: ${_formatTime(sunsetForbiddenStart)} (সূর্যাস্তের ১৫ মিনিট আগে)',
  );
  print(
    '   ওয়াক্ত রেঞ্জ: ${_formatTime(asr)} - ${_formatTime(sunsetForbiddenStart)}\n',
  );

  print(' নিষিদ্ধ সময় #3 (সূর্যাস্তের আগে):');
  print('   ${_formatTime(sunsetForbiddenStart)} - ${_formatTime(maghrib)}\n');

  print('🌇 মাগরিব:');
  print('   শুরু: ${_formatTime(maghrib)}');
  print('   শেষ: ${_formatTime(isha)} (ইশা শুরু)');
  print('   ওয়াক্ত রেঞ্জ: ${_formatTime(maghrib)} - ${_formatTime(isha)}\n');

  // Calculate next day's Fajr for Isha end time
  final tomorrowDate = DateTime(2026, 1, 4);
  final tomorrowPrayerTimes = PrayerTimes(
    coordinates: coordinates,
    date: tomorrowDate,
    calculationParameters: params,
    precision: true,
  );
  final tomorrowFajr = tomorrowPrayerTimes.fajr.toLocal();

  print('🌙 ইশা:');
  print('   শুরু: ${_formatTime(isha)}');
  print('   শেষ: ${_formatTime(tomorrowFajr)} (পরের দিন ফজর)');
  print(
    '   ওয়াক্ত রেঞ্জ: ${_formatTime(isha)} - ${_formatTime(tomorrowFajr)}\n',
  );

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📊 সারাংশ:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('ফজর:          ${_formatTime(fajr)} → ${_formatTime(sunrise)}');
  print(' নিষিদ্ধ #1:  ${_formatTime(sunrise)} → ${_formatTime(sunriseEnd)}');
  print('✨ নফল:       ${_formatTime(sunriseEnd)} → ${_formatTime(zawalStart)}');
  print(' যাওয়াল:    ${_formatTime(zawalStart)} → ${_formatTime(dhuhr)}');
  print('যোহর:         ${_formatTime(dhuhr)} → ${_formatTime(asr)}');
  print(
    'আসর:          ${_formatTime(asr)} → ${_formatTime(sunsetForbiddenStart)}',
  );
  print(
    'নিষিদ্ধ #3:  ${_formatTime(sunsetForbiddenStart)} → ${_formatTime(maghrib)}',
  );
  print('মাগরিব:       ${_formatTime(maghrib)} → ${_formatTime(isha)}');
  print('ইশা:          ${_formatTime(isha)} → ${_formatTime(tomorrowFajr)}');
}

String _formatTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
