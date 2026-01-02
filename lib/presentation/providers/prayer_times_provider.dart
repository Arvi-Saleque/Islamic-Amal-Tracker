import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesState {
  final Map<String, DateTime> prayerTimes;
  final String? nextPrayer;
  final String? timeToNextPrayer;
  final bool isLoading;
  final String? error;

  PrayerTimesState({
    required this.prayerTimes,
    this.nextPrayer,
    this.timeToNextPrayer,
    this.isLoading = false,
    this.error,
  });

  PrayerTimesState copyWith({
    Map<String, DateTime>? prayerTimes,
    String? nextPrayer,
    String? timeToNextPrayer,
    bool? isLoading,
    String? error,
  }) {
    return PrayerTimesState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeToNextPrayer: timeToNextPrayer ?? this.timeToNextPrayer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  Timer? _timer;
  
  PrayerTimesNotifier() : super(PrayerTimesState(prayerTimes: {}, isLoading: true)) {
    fetchPrayerTimes();
    _startTimer();
  }
  
  void _startTimer() {
    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateNextPrayerTime();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _updateNextPrayerTime() {
    if (state.prayerTimes.isEmpty) return;
    
    final now = DateTime.now();
    String? nextPrayer;
    String? timeToNext;

    // Prayer times are stored with today's date in local timezone
    // We need to compare properly
    for (var entry in state.prayerTimes.entries) {
      final prayerTime = entry.value;
      // Create comparable DateTime with same timezone as now
      final prayerTimeLocal = DateTime(
        now.year, now.month, now.day,
        prayerTime.hour, prayerTime.minute, prayerTime.second
      );
      
      if (prayerTimeLocal.isAfter(now)) {
        nextPrayer = entry.key;
        final duration = prayerTimeLocal.difference(now);
        timeToNext = formatTimeToNext(duration);
        break;
      }
    }

    // If no prayer found (all prayers done for today), next is Fajr tomorrow
    if (nextPrayer == null && state.prayerTimes.containsKey('fajr')) {
      nextPrayer = 'fajr';
      final fajrTime = state.prayerTimes['fajr']!;
      // Tomorrow's Fajr
      final tomorrowFajr = DateTime(
        now.year, now.month, now.day + 1,
        fajrTime.hour, fajrTime.minute, fajrTime.second
      );
      final duration = tomorrowFajr.difference(now);
      timeToNext = formatTimeToNext(duration);
    }

    state = state.copyWith(
      nextPrayer: nextPrayer,
      timeToNextPrayer: timeToNext,
    );
  }

  Future<void> fetchPrayerTimes() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get location
      Position position = await _getCurrentLocation();
      
      // Debug: Print location
      print('📍 Location: Lat ${position.latitude}, Lon ${position.longitude}');

      // Calculate prayer times using adhan_dart
      final coordinates = Coordinates(position.latitude, position.longitude);
      
      // Use Islamic Foundation Bangladesh method (similar to Karachi with adjustments)
      final params = CalculationMethodParameters.karachi();
      params.madhab = Madhab.hanafi;
      // Adjustments for Bangladesh (Islamic Foundation method approximation)
      params.adjustments[Prayer.fajr] = 2; // +2 minutes for Fajr
      params.adjustments[Prayer.dhuhr] = 3; // +3 minutes for Dhuhr
      params.adjustments[Prayer.asr] = 3; // +3 minutes for Asr
      params.adjustments[Prayer.maghrib] = 3; // +3 minutes for Maghrib
      params.adjustments[Prayer.isha] = 2; // +2 minutes for Isha

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: DateTime.now(),
        calculationParameters: params,
        precision: true,
      );
      
      // Debug: Print prayer times
      print('🕌 Prayer Times (raw from adhan_dart):');
      print('  Fajr: ${prayerTimes.fajr}');
      print('  Dhuhr: ${prayerTimes.dhuhr}');
      print('  Asr: ${prayerTimes.asr}');
      print('  Maghrib: ${prayerTimes.maghrib}');
      print('  Isha: ${prayerTimes.isha}');

      // adhan_dart returns UTC times, convert to local
      final times = {
        'fajr': prayerTimes.fajr!.toLocal(),
        'dhuhr': prayerTimes.dhuhr!.toLocal(),
        'asr': prayerTimes.asr!.toLocal(),
        'maghrib': prayerTimes.maghrib!.toLocal(),
        'isha': prayerTimes.isha!.toLocal(),
      };
      
      print('🕌 Local Prayer Times:');
      print('  Fajr: ${times['fajr']}');
      print('  Dhuhr: ${times['dhuhr']}');
      print('  Asr: ${times['asr']}');
      print('  Maghrib: ${times['maghrib']}');
      print('  Isha: ${times['isha']}');
      print('  Current time: ${DateTime.now()}');

      // Calculate next prayer using proper local time comparison
      final now = DateTime.now();
      String? nextPrayer;
      String? timeToNext;

      for (var entry in times.entries) {
        final prayerTime = entry.value;
        // Create comparable DateTime with today's date
        final prayerTimeToday = DateTime(
          now.year, now.month, now.day,
          prayerTime.hour, prayerTime.minute, prayerTime.second
        );
        
        if (prayerTimeToday.isAfter(now)) {
          nextPrayer = entry.key;
          final duration = prayerTimeToday.difference(now);
          timeToNext = formatTimeToNext(duration);
          break;
        }
      }

      // If no prayer found (all prayers done for today), next is Fajr tomorrow
      if (nextPrayer == null) {
        nextPrayer = 'fajr';
        final fajrTime = times['fajr']!;
        final tomorrowFajr = DateTime(
          now.year, now.month, now.day + 1,
          fajrTime.hour, fajrTime.minute, fajrTime.second
        );
        final duration = tomorrowFajr.difference(now);
        timeToNext = formatTimeToNext(duration);
      }

      state = PrayerTimesState(
        prayerTimes: times,
        nextPrayer: nextPrayer,
        timeToNextPrayer: timeToNext,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  String formatTimeToNext(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}ঘ ${minutes}মি';
    } else {
      return '${minutes}মি';
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Return default Dhaka coordinates
      return Position(
        latitude: 23.8103,
        longitude: 90.4125,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Return default Dhaka coordinates
        return Position(
          latitude: 23.8103,
          longitude: 90.4125,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Return default Dhaka coordinates
      return Position(
        latitude: 23.8103,
        longitude: 90.4125,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}

final prayerTimesProvider = StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  return PrayerTimesNotifier();
});
