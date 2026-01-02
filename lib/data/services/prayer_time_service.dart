import 'package:adhan_dart/adhan_dart.dart';
import '../../core/constants/app_constants.dart';
import '../models/prayer_record.dart';

class PrayerTimeService {
  // Calculate prayer times for Bangladesh using Islamic Foundation parameters
  static PrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    Map<String, int>? adjustments,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    
    // Use Karachi method parameters for Bangladesh
    // Karachi: Fajr 18°, Isha 18° (close to Islamic Foundation BD: 18.5°, 17.5°)
    final params = CalculationMethodParameters.karachi();
    
    final prayers = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
    );
    
    // Apply manual adjustments if provided
    if (adjustments != null) {
      return _applyAdjustments(prayers, adjustments);
    }
    
    return prayers;
  }
  
  static PrayerTimes _applyAdjustments(PrayerTimes prayers, Map<String, int> adjustments) {
    // Note: adhan_dart doesn't support direct time modification
    // We'll handle adjustments in the UI layer by adding/subtracting minutes
    return prayers;
  }
  
  static DateTime getAdjustedPrayerTime(DateTime originalTime, int adjustmentMinutes) {
    return originalTime.add(Duration(minutes: adjustmentMinutes));
  }
  
  static Map<PrayerType, DateTime> getPrayerTimesMap({
    required double latitude,
    required double longitude,
    required DateTime date,
    Map<String, int>? adjustments,
  }) {
    final prayers = calculatePrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: date,
      adjustments: adjustments,
    );
    
    final adj = adjustments ?? {};
    
    return {
      PrayerType.fajr: getAdjustedPrayerTime(prayers.fajr, adj['fajr'] ?? 0),
      PrayerType.dhuhr: getAdjustedPrayerTime(prayers.dhuhr, adj['dhuhr'] ?? 0),
      PrayerType.asr: getAdjustedPrayerTime(prayers.asr, adj['asr'] ?? 0),
      PrayerType.maghrib: getAdjustedPrayerTime(prayers.maghrib, adj['maghrib'] ?? 0),
      PrayerType.isha: getAdjustedPrayerTime(prayers.isha, adj['isha'] ?? 0),
    };
  }
  
  static PrayerType? getNextPrayer(DateTime now, Map<PrayerType, DateTime> prayerTimes) {
    for (final entry in prayerTimes.entries) {
      if (now.isBefore(entry.value)) {
        return entry.key;
      }
    }
    return null; // All prayers passed, next is tomorrow's Fajr
  }
  
  static DateTime? getNextPrayerTime(DateTime now, Map<PrayerType, DateTime> prayerTimes) {
    final nextPrayer = getNextPrayer(now, prayerTimes);
    if (nextPrayer == null) {
      // Return tomorrow's Fajr
      final tomorrowPrayers = getPrayerTimesMap(
        latitude: 23.8103, // Will be replaced with actual location
        longitude: 90.4125,
        date: now.add(const Duration(days: 1)),
      );
      return tomorrowPrayers[PrayerType.fajr];
    }
    return prayerTimes[nextPrayer];
  }
  
  static Duration? getTimeUntilNextPrayer(DateTime now, Map<PrayerType, DateTime> prayerTimes) {
    final nextTime = getNextPrayerTime(now, prayerTimes);
    if (nextTime == null) return null;
    return nextTime.difference(now);
  }
  
  static String getPrayerName(PrayerType type, {bool inBangla = true}) {
    if (!inBangla) return type.name;
    
    switch (type) {
      case PrayerType.fajr:
        return 'ফজর';
      case PrayerType.dhuhr:
        return 'যোহর';
      case PrayerType.asr:
        return 'আসর';
      case PrayerType.maghrib:
        return 'মাগরিব';
      case PrayerType.isha:
        return 'এশা';
    }
  }
  
  static Map<String, int> getDefaultRakats(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return {'sunnah': 2, 'fard': 2};
      case PrayerType.dhuhr:
        return {'sunnah_before': 4, 'fard': 4, 'sunnah_after': 2};
      case PrayerType.asr:
        return {'fard': 4};
      case PrayerType.maghrib:
        return {'fard': 3, 'sunnah': 2};
      case PrayerType.isha:
        return {'fard': 4, 'sunnah': 2, 'witr': 3};
    }
  }
  
  static String formatRakatDisplay(PrayerType type, Map<String, int> rakats) {
    switch (type) {
      case PrayerType.fajr:
        return '${rakats['sunnah'] ?? 0}S + ${rakats['fard'] ?? 0}F';
      case PrayerType.dhuhr:
        return '${rakats['sunnah_before'] ?? 0}S + ${rakats['fard'] ?? 0}F + ${rakats['sunnah_after'] ?? 0}S';
      case PrayerType.asr:
        return '${rakats['fard'] ?? 0}F';
      case PrayerType.maghrib:
        return '${rakats['fard'] ?? 0}F + ${rakats['sunnah'] ?? 0}S';
      case PrayerType.isha:
        return '${rakats['fard'] ?? 0}F + ${rakats['sunnah'] ?? 0}S + ${rakats['witr'] ?? 0}W';
    }
  }
  
  static PrayerRecord createDailyPrayerRecord({
    required PrayerType type,
    required DateTime date,
    required DateTime scheduledTime,
    int adjustmentMinutes = 0,
  }) {
    return PrayerRecord(
      id: '${type.name}_${date.year}_${date.month}_${date.day}',
      date: date,
      prayerType: type,
      rakatTarget: getDefaultRakats(type),
      scheduledTime: scheduledTime,
      adjustmentMinutes: adjustmentMinutes,
      modelVersion: AppConstants.currentModelVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
