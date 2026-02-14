import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../data/services/firestore_sync_service.dart';

// Simple model for missed prayer
class MissedPrayer {
  final String date;
  final String prayerName;
  final bool isQazaDone;

  MissedPrayer({
    required this.date,
    required this.prayerName,
    required this.isQazaDone,
  });
}

// Summary for each prayer type
class QazaPrayerSummary {
  final String prayerName;
  final List<MissedPrayer> missedPrayers;

  QazaPrayerSummary({
    required this.prayerName,
    required this.missedPrayers,
  });

  int get pendingCount => missedPrayers.where((p) => !p.isQazaDone).length;
  int get completedCount => missedPrayers.where((p) => p.isQazaDone).length;
  int get totalCount => missedPrayers.length;
}

// Qaza prayer state
class QazaPrayerState {
  final List<QazaPrayerSummary> prayerSummaries;
  final bool isLoading;

  QazaPrayerState({
    required this.prayerSummaries,
    this.isLoading = false,
  });

  QazaPrayerState copyWith({
    List<QazaPrayerSummary>? prayerSummaries,
    bool? isLoading,
  }) {
    return QazaPrayerState(
      prayerSummaries: prayerSummaries ?? this.prayerSummaries,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalPendingCount {
    return prayerSummaries.fold(0, (sum, s) => sum + s.pendingCount);
  }
}

// Qaza prayer notifier
class QazaPrayerNotifier extends StateNotifier<QazaPrayerState> {
  static const String _boxName = 'prayer_tracking';
  Box? _box;

  final List<String> prayerNames = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];

  QazaPrayerNotifier()
      : super(QazaPrayerState(
          prayerSummaries: [],
        )) {
    _init();
  }

  Future<void> _init() async {
    try {
      state = state.copyWith(isLoading: true);
      _box = await Hive.openBox(_boxName);
      await loadQazaPrayers();
    } catch (e) {
      print('Error initializing qaza prayers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Load missed prayers from prayer_tracking for last 30 days
  Future<void> loadQazaPrayers() async {
    if (_box == null) return;

    try {
      final today = DateTime.now();
      final missedByPrayer = <String, List<MissedPrayer>>{};

      // Initialize lists for each prayer
      for (final prayer in prayerNames) {
        missedByPrayer[prayer] = [];
      }

      // Check last 30 days for missed prayers (exclude today)
      for (int i = 1; i <= 30; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final prayerData = _box!.get(dateKey);

        if (prayerData != null) {
          try {
            final data = Map<String, dynamic>.from(prayerData);
            final prayerDone = Map<String, bool>.from(data['prayerDone'] as Map);
            final qazaDone = data['qazaDone'] != null 
                ? Map<String, bool>.from(data['qazaDone'] as Map)
                : <String, bool>{};

            // Migrate old 'যুহর' key to 'যোহর'
            if (prayerDone.containsKey('যুহর') && !prayerDone.containsKey('যোহর')) {
              prayerDone['যোহর'] = prayerDone.remove('যুহর')!;
            }
            if (qazaDone.containsKey('যুহর') && !qazaDone.containsKey('যোহর')) {
              qazaDone['যোহর'] = qazaDone.remove('যুহর')!;
            }

            // Check each prayer
            for (final prayer in prayerNames) {
              final isDone = prayerDone[prayer] ?? false;
              if (!isDone) {
                // Prayer was missed
                final isQazaDone = qazaDone[prayer] ?? false;
                missedByPrayer[prayer]!.add(MissedPrayer(
                  date: dateKey,
                  prayerName: prayer,
                  isQazaDone: isQazaDone,
                ));
              }
            }
          } catch (e) {
            print('Error parsing prayer data for $dateKey: $e');
          }
        }
        // If no data for this day, we don't count it as missed
        // because the user might not have been using the app
      }

      // Create summaries
      final summaries = prayerNames.map((prayer) {
        final prayers = missedByPrayer[prayer] ?? [];
        // Sort by date descending (most recent first)
        prayers.sort((a, b) => b.date.compareTo(a.date));
        return QazaPrayerSummary(
          prayerName: prayer,
          missedPrayers: prayers,
        );
      }).toList();

      state = state.copyWith(
        prayerSummaries: summaries,
        isLoading: false,
      );
    } catch (e) {
      print('Error loading qaza prayers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  // Mark qaza prayer as completed
  Future<void> markQazaCompleted(String date, String prayerName) async {
    if (_box == null) return;

    try {
      final prayerData = _box!.get(date);
      if (prayerData != null) {
        final data = Map<String, dynamic>.from(prayerData);
        
        // Get or create qazaDone map
        final qazaDone = data['qazaDone'] != null 
            ? Map<String, bool>.from(data['qazaDone'] as Map)
            : <String, bool>{
                'ফজর': false,
                'যোহর': false,
                'আসর': false,
                'মাগরিব': false,
                'এশা': false,
              };
        
        qazaDone[prayerName] = true;
        data['qazaDone'] = qazaDone;
        
        // Save back to Hive
        await _box!.put(date, data);
        
        // Sync to cloud
        firestoreSyncService.syncPrayerTracking(date, data);
        
        // Reload to update state
        await loadQazaPrayers();
      }
    } catch (e) {
      print('Error marking qaza completed: $e');
    }
  }

  // Unmark qaza prayer (undo)
  Future<void> unmarkQazaCompleted(String date, String prayerName) async {
    if (_box == null) return;

    try {
      final prayerData = _box!.get(date);
      if (prayerData != null) {
        final data = Map<String, dynamic>.from(prayerData);
        
        final qazaDone = data['qazaDone'] != null 
            ? Map<String, bool>.from(data['qazaDone'] as Map)
            : <String, bool>{};
        
        qazaDone[prayerName] = false;
        data['qazaDone'] = qazaDone;
        
        // Save back to Hive
        await _box!.put(date, data);
        
        // Sync to cloud
        firestoreSyncService.syncPrayerTracking(date, data);
        
        // Reload to update state
        await loadQazaPrayers();
      }
    } catch (e) {
      print('Error unmarking qaza: $e');
    }
  }

  // Toggle qaza prayer completion
  Future<void> toggleQazaCompletion(String date, String prayerName) async {
    // Find current state
    final summary = state.prayerSummaries.firstWhere(
      (s) => s.prayerName == prayerName,
      orElse: () => QazaPrayerSummary(prayerName: prayerName, missedPrayers: []),
    );
    
    final missedPrayer = summary.missedPrayers.firstWhere(
      (p) => p.date == date,
      orElse: () => MissedPrayer(date: date, prayerName: prayerName, isQazaDone: false),
    );
    
    if (missedPrayer.isQazaDone) {
      await unmarkQazaCompleted(date, prayerName);
    } else {
      await markQazaCompleted(date, prayerName);
    }
  }

  // Get pending qaza count for a specific prayer
  int getPendingCount(String prayerName) {
    final summary = state.prayerSummaries.firstWhere(
      (s) => s.prayerName == prayerName,
      orElse: () => QazaPrayerSummary(prayerName: prayerName, missedPrayers: []),
    );
    return summary.pendingCount;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadQazaPrayers();
  }
}

// Provider
final qazaPrayerProvider =
    StateNotifierProvider<QazaPrayerNotifier, QazaPrayerState>((ref) {
  return QazaPrayerNotifier();
});
