import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesState {
  final Map<String, DateTime> prayerTimes;
  final Map<String, DateTime> waqtEndTimes; // Each prayer's actual end time
  final String? nextPrayer;
  final String? timeToNextPrayer;
  final String? currentPrayer;
  final String? timeToCurrentPrayerEnd;
  final bool
      isForbiddenTime; // True during forbidden prayer times (post-sunrise & zawal)
  final bool isNaflTime; // True during voluntary prayer time
  final bool isLoading;
  final String? error;

  PrayerTimesState({
    required this.prayerTimes,
    this.waqtEndTimes = const {},
    this.nextPrayer,
    this.timeToNextPrayer,
    this.currentPrayer,
    this.timeToCurrentPrayerEnd,
    this.isForbiddenTime = false,
    this.isNaflTime = false,
    this.isLoading = false,
    this.error,
  });

  PrayerTimesState copyWith({
    Map<String, DateTime>? prayerTimes,
    Map<String, DateTime>? waqtEndTimes,
    String? nextPrayer,
    String? timeToNextPrayer,
    String? currentPrayer,
    String? timeToCurrentPrayerEnd,
    bool? isForbiddenTime,
    bool? isNaflTime,
    bool? isLoading,
    String? error,
  }) {
    return PrayerTimesState(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      waqtEndTimes: waqtEndTimes ?? this.waqtEndTimes,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeToNextPrayer: timeToNextPrayer ?? this.timeToNextPrayer,
      currentPrayer: currentPrayer ?? this.currentPrayer,
      timeToCurrentPrayerEnd:
          timeToCurrentPrayerEnd ?? this.timeToCurrentPrayerEnd,
      isForbiddenTime: isForbiddenTime ?? this.isForbiddenTime,
      isNaflTime: isNaflTime ?? this.isNaflTime,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  Timer? _timer;

  PrayerTimesNotifier()
      : super(PrayerTimesState(prayerTimes: {}, isLoading: true)) {
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
    if (state.prayerTimes.isEmpty || state.waqtEndTimes.isEmpty) return;

    final now = DateTime.now();
    final result = _calculateCurrentAndNextPrayer(
        now, state.prayerTimes, state.waqtEndTimes);

    state = state.copyWith(
      nextPrayer: result['nextPrayer'],
      timeToNextPrayer: result['timeToNext'],
      currentPrayer: result['currentPrayer'],
      timeToCurrentPrayerEnd: result['timeToCurrentEnd'],
      isForbiddenTime: result['isForbiddenTime'] ?? false,
      isNaflTime: result['isNaflTime'] ?? false,
    );
  }

  /// Calculate current prayer and next prayer based on actual waqt end times
  ///
  /// Prayer Time Rules:
  /// - Fajr: starts at fajr time, ends at sunrise
  /// - Forbidden: sunrise to sunrise+15min (sun fully rising)
  /// - Nafl (voluntary): sunrise+15min to dhuhr-10min
  /// - Forbidden: dhuhr-10min to dhuhr (zawal - sun at zenith)
  /// - Dhuhr: starts at dhuhr time, ends at asr start
  /// - Asr: starts at asr time, ends at maghrib-15min
  /// - Forbidden: maghrib-15min to maghrib (sun setting)
  /// - Maghrib: starts at maghrib time, ends at isha start
  /// - Isha: starts at isha time, ends at fajr (next day)
  Map<String, dynamic> _calculateCurrentAndNextPrayer(
    DateTime now,
    Map<String, DateTime> prayerTimes,
    Map<String, DateTime> waqtEndTimes,
  ) {
    String? currentPrayer;
    String? nextPrayer;
    String? timeToNext;
    String? timeToCurrentEnd;
    bool isForbiddenTime = false;
    bool isNaflTime = false;

    // Convert all times to today's date for comparison
    DateTime toToday(DateTime time) {
      return DateTime(
          now.year, now.month, now.day, time.hour, time.minute, time.second);
    }

    // Get today's times
    final fajrStart =
        prayerTimes['fajr'] != null ? toToday(prayerTimes['fajr']!) : null;
    final sunrise = prayerTimes['sunrise'] != null
        ? toToday(prayerTimes['sunrise']!)
        : null;
    final dhuhrStart =
        prayerTimes['dhuhr'] != null ? toToday(prayerTimes['dhuhr']!) : null;
    final asrStart =
        prayerTimes['asr'] != null ? toToday(prayerTimes['asr']!) : null;
    final maghribStart = prayerTimes['maghrib'] != null
        ? toToday(prayerTimes['maghrib']!)
        : null;
    final ishaStart =
        prayerTimes['isha'] != null ? toToday(prayerTimes['isha']!) : null;

    // Calculate forbidden times
    final sunriseEnd =
        sunrise?.add(const Duration(minutes: 15)); // ~15 min after sunrise
    final zawalStart = dhuhrStart
        ?.subtract(const Duration(minutes: 10)); // ~10 min before dhuhr
    final sunsetForbiddenStart = maghribStart
        ?.subtract(const Duration(minutes: 15)); // ~15 min before maghrib

    // Get waqt end times (adjusted for sunset forbidden time)
    final fajrEnd =
        waqtEndTimes['fajr'] != null ? toToday(waqtEndTimes['fajr']!) : sunrise;
    final dhuhrEnd = waqtEndTimes['dhuhr'] != null
        ? toToday(waqtEndTimes['dhuhr']!)
        : asrStart;
    final asrEnd =
        sunsetForbiddenStart; // Asr ends 15 min before maghrib (sunset)
    final maghribEnd = waqtEndTimes['maghrib'] != null
        ? toToday(waqtEndTimes['maghrib']!)
        : ishaStart;
    // Isha ends at fajr next day
    final ishaEnd = fajrStart != null
        ? DateTime(now.year, now.month, now.day + 1, fajrStart.hour,
            fajrStart.minute, fajrStart.second)
        : null;

    // Check each time period
    if (fajrStart != null && fajrEnd != null) {
      // Before Fajr starts - current is Isha (from yesterday)
      if (now.isBefore(fajrStart)) {
        currentPrayer = 'isha';
        nextPrayer = 'fajr';
        timeToNext = formatTimeToNext(fajrStart.difference(now));
        timeToCurrentEnd = timeToNext;
      }
      // During Fajr time (fajr start to sunrise)
      else if (now.isAfter(fajrStart) && now.isBefore(fajrEnd)) {
        currentPrayer = 'fajr';
        nextPrayer = 'dhuhr';
        timeToCurrentEnd = formatTimeToNext(fajrEnd.difference(now));
        if (dhuhrStart != null) {
          timeToNext = formatTimeToNext(dhuhrStart.difference(now));
        }
      }
    }

    // Forbidden time after sunrise (~15 minutes)
    if (sunrise != null && sunriseEnd != null) {
      if (now.isAfter(sunrise) && now.isBefore(sunriseEnd)) {
        currentPrayer = null;
        nextPrayer = 'dhuhr';
        timeToNext = formatTimeToNext(dhuhrStart!.difference(now));
        timeToCurrentEnd = formatTimeToNext(sunriseEnd.difference(now));
        isForbiddenTime = true;
        return {
          'currentPrayer': currentPrayer,
          'nextPrayer': nextPrayer,
          'timeToNext': timeToNext,
          'timeToCurrentEnd': timeToCurrentEnd,
          'isForbiddenTime': isForbiddenTime,
          'isNaflTime': isNaflTime,
        };
      }
    }

    // Nafl time (after sunrise forbidden period, before zawal)
    if (sunriseEnd != null && zawalStart != null) {
      if (now.isAfter(sunriseEnd) && now.isBefore(zawalStart)) {
        currentPrayer = null;
        nextPrayer = 'dhuhr';
        timeToNext = formatTimeToNext(dhuhrStart!.difference(now));
        timeToCurrentEnd = formatTimeToNext(zawalStart.difference(now));
        isNaflTime = true;
        return {
          'currentPrayer': currentPrayer,
          'nextPrayer': nextPrayer,
          'timeToNext': timeToNext,
          'timeToCurrentEnd': timeToCurrentEnd,
          'isForbiddenTime': isForbiddenTime,
          'isNaflTime': isNaflTime,
        };
      }
    }

    // Forbidden time before dhuhr (zawal - sun at zenith)
    if (zawalStart != null && dhuhrStart != null) {
      if (now.isAfter(zawalStart) && now.isBefore(dhuhrStart)) {
        currentPrayer = null;
        nextPrayer = 'dhuhr';
        timeToNext = formatTimeToNext(dhuhrStart.difference(now));
        timeToCurrentEnd = timeToNext;
        isForbiddenTime = true;
        return {
          'currentPrayer': currentPrayer,
          'nextPrayer': nextPrayer,
          'timeToNext': timeToNext,
          'timeToCurrentEnd': timeToCurrentEnd,
          'isForbiddenTime': isForbiddenTime,
          'isNaflTime': isNaflTime,
        };
      }
    }

    // During Dhuhr time
    if (dhuhrStart != null && dhuhrEnd != null) {
      if (now.isAfter(dhuhrStart) && now.isBefore(dhuhrEnd)) {
        currentPrayer = 'dhuhr';
        nextPrayer = 'asr';
        timeToCurrentEnd = formatTimeToNext(dhuhrEnd.difference(now));
        if (asrStart != null) {
          timeToNext = formatTimeToNext(asrStart.difference(now));
        }
      }
    }

    // During Asr time (but not in forbidden sunset period)
    if (asrStart != null && asrEnd != null) {
      if (now.isAfter(asrStart) && now.isBefore(asrEnd)) {
        currentPrayer = 'asr';
        nextPrayer = 'maghrib';
        timeToCurrentEnd = formatTimeToNext(asrEnd.difference(now));
        if (maghribStart != null) {
          timeToNext = formatTimeToNext(maghribStart.difference(now));
        }
      }
    }

    // Forbidden time before maghrib (sunset - 15 min before)
    if (sunsetForbiddenStart != null && maghribStart != null) {
      if (now.isAfter(sunsetForbiddenStart) && now.isBefore(maghribStart)) {
        currentPrayer = null;
        nextPrayer = 'maghrib';
        timeToNext = formatTimeToNext(maghribStart.difference(now));
        timeToCurrentEnd = timeToNext;
        isForbiddenTime = true;
        return {
          'currentPrayer': currentPrayer,
          'nextPrayer': nextPrayer,
          'timeToNext': timeToNext,
          'timeToCurrentEnd': timeToCurrentEnd,
          'isForbiddenTime': isForbiddenTime,
          'isNaflTime': isNaflTime,
        };
      }
    }

    // During Maghrib time
    if (maghribStart != null && maghribEnd != null) {
      if (now.isAfter(maghribStart) && now.isBefore(maghribEnd)) {
        currentPrayer = 'maghrib';
        nextPrayer = 'isha';
        timeToCurrentEnd = formatTimeToNext(maghribEnd.difference(now));
        if (ishaStart != null) {
          timeToNext = formatTimeToNext(ishaStart.difference(now));
        }
      }
    }

    // During Isha time (after isha starts)
    if (ishaStart != null && ishaEnd != null) {
      if (now.isAfter(ishaStart)) {
        currentPrayer = 'isha';
        nextPrayer = 'fajr';
        // Isha ends at fajr next day
        timeToCurrentEnd = formatTimeToNext(ishaEnd.difference(now));
        timeToNext = timeToCurrentEnd;
      }
    }

    return {
      'currentPrayer': currentPrayer,
      'nextPrayer': nextPrayer,
      'timeToNext': timeToNext,
      'timeToCurrentEnd': timeToCurrentEnd,
      'isForbiddenTime': isForbiddenTime,
      'isNaflTime': isNaflTime,
    };
  }

  Future<void> fetchPrayerTimes() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get location
      Position position = await _getCurrentLocation();

      // Debug: Print location
      print('Location: Lat ${position.latitude}, Lon ${position.longitude}');

      // Calculate prayer times using adhan_dart
      final coordinates = Coordinates(position.latitude, position.longitude);

      // Use Islamic Foundation Bangladesh method (similar to Karachi with adjustments)
      final params = CalculationMethodParameters.karachi();
      params.madhab = Madhab.hanafi;
      // Adjustments for Bangladesh (Islamic Foundation method approximation)
      params.adjustments[Prayer.fajr] = 0; // +2 minutes for Fajr
      params.adjustments[Prayer.dhuhr] = 0; // +3 minutes for Dhuhr
      params.adjustments[Prayer.asr] = 0; // +3 minutes for Asr
      params.adjustments[Prayer.maghrib] = 0; // +3 minutes for Maghrib
      params.adjustments[Prayer.isha] = 0; // +2 minutes for Isha

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: DateTime.now(),
        calculationParameters: params,
        precision: true,
      );

      // Debug: Print prayer times
      print('Prayer Times (raw from adhan_dart):');
      print('  Fajr: ${prayerTimes.fajr}');
      print('  Dhuhr: ${prayerTimes.dhuhr}');
      print('  Asr: ${prayerTimes.asr}');
      print('  Maghrib: ${prayerTimes.maghrib}');
      print('  Isha: ${prayerTimes.isha}');

      // adhan_dart returns UTC times, convert to local
      // Include sunrise for waqt end time calculation
      final times = {
        'fajr': prayerTimes.fajr.toLocal(),
        'sunrise':
            prayerTimes.sunrise.toLocal(), // Important: Fajr ends at sunrise
        'dhuhr': prayerTimes.dhuhr.toLocal(),
        'asr': prayerTimes.asr.toLocal(),
        'maghrib': prayerTimes.maghrib.toLocal(),
        'isha': prayerTimes.isha.toLocal(),
      };

      // Calculate waqt end times for each prayer
      // These are the ACTUAL end times, not just when next prayer starts
      final waqtEndTimes = <String, DateTime>{
        'fajr': times['sunrise']!, // Fajr ends at sunrise
        'dhuhr': times['asr']!, // Dhuhr ends when Asr starts
        'asr': times['maghrib']!, // Asr ends at sunset (Maghrib)
        'maghrib': times['isha']!, // Maghrib ends when Isha starts
        'isha': times['fajr']!
            .add(const Duration(days: 1)), // Isha ends at next day Fajr
      };

      print('Local Prayer Times:');
      print('  Fajr: ${times['fajr']}');
      print('  Sunrise: ${times['sunrise']}');
      print('  Dhuhr: ${times['dhuhr']}');
      print('  Asr: ${times['asr']}');
      print('  Maghrib: ${times['maghrib']}');
      print('  Isha: ${times['isha']}');
      print('Waqt End Times:');
      print('  Fajr ends: ${waqtEndTimes['fajr']}');
      print('  Dhuhr ends: ${waqtEndTimes['dhuhr']}');
      print('  Asr ends: ${waqtEndTimes['asr']}');
      print('  Maghrib ends: ${waqtEndTimes['maghrib']}');
      print('  Isha ends: ${waqtEndTimes['isha']}');
      print('  Current time: ${DateTime.now()}');

      // Calculate current and next prayer using proper waqt end times
      final now = DateTime.now();
      final result = _calculateCurrentAndNextPrayer(now, times, waqtEndTimes);

      state = PrayerTimesState(
        prayerTimes: times,
        waqtEndTimes: waqtEndTimes,
        nextPrayer: result['nextPrayer'],
        currentPrayer: result['currentPrayer'],
        timeToCurrentPrayerEnd: result['timeToCurrentEnd'],
        timeToNextPrayer: result['timeToNext'],
        isForbiddenTime: result['isForbiddenTime'] ?? false,
        isNaflTime: result['isNaflTime'] ?? false,
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
      return '$hoursঘ $minutesমি';
    } else {
      return '$minutesমি';
    }
  }

  Future<Position> _getCurrentLocation() async {
    // Default Dhaka coordinates (NO permission request here)
    const fallbackLat = 23.8103;
    const fallbackLon = 90.4125;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Position(
          latitude: fallbackLat,
          longitude: fallbackLon,
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

      final permission = await Geolocator.checkPermission();

      final canUseLocation = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!canUseLocation) {
        // DO NOT request permission here
        return Position(
          latitude: fallbackLat,
          longitude: fallbackLon,
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

      // Permission already granted -> safe to read location
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return Position(
        latitude: fallbackLat,
        longitude: fallbackLon,
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
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  return PrayerTimesNotifier();
});
