import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

/// Firestore Sync Service
/// ক্লাউডে ডেটা সিংক করার জন্য সার্ভিস
class FirestoreSyncService {
  static final FirestoreSyncService _instance = FirestoreSyncService._internal();
  factory FirestoreSyncService() => _instance;
  FirestoreSyncService._internal();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isAvailable = false;

  /// Initialize the service
  Future<void> init() async {
    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _isAvailable = true;
      
      // Enable offline persistence
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      _isAvailable = false;
      print('Firestore not available: $e');
    }
  }

  /// Check if user is logged in and sync is available
  bool get canSync => _isAvailable && _auth?.currentUser != null;
  
  /// Get current user ID
  String? get userId => _auth?.currentUser?.uid;

  /// Get user's data collection reference
  CollectionReference? get _userDataCollection {
    if (!canSync) return null;
    return _firestore!.collection('users').doc(userId).collection('data');
  }

  // ==================== SYNC METHODS ====================

  /// Sync prayer tracking data
  Future<void> syncPrayerTracking(String date, Map<String, dynamic> data) async {
    if (!canSync) {
      print('⚠️ Cannot sync prayer_tracking - not logged in');
      return;
    }
    try {
      await _userDataCollection!.doc('prayer_tracking').collection('days').doc(date).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Synced prayer_tracking for $date');
    } catch (e) {
      print('❌ Error syncing prayer tracking: $e');
    }
  }

  /// Sync daily amal data
  Future<void> syncDailyAmal(String date, Map<String, dynamic> data) async {
    if (!canSync) {
      print('⚠️ Cannot sync daily_amal - not logged in');
      return;
    }
    try {
      await _userDataCollection!.doc('daily_amal').collection('days').doc(date).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Synced daily_amal for $date');
    } catch (e) {
      print('❌ Error syncing daily amal: $e');
    }
  }

  /// Sync dhikr counter data
  Future<void> syncDhikrCounter(String date, Map<String, dynamic> data) async {
    if (!canSync) return;
    try {
      await _userDataCollection!.doc('dhikr_counter').collection('days').doc(date).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing dhikr counter: $e');
    }
  }

  /// Sync reading tracker data
  Future<void> syncReadingTracker(String date, Map<String, dynamic> data) async {
    if (!canSync) return;
    try {
      await _userDataCollection!.doc('reading_tracker').collection('days').doc(date).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing reading tracker: $e');
    }
  }

  /// Sync sin tracker data
  Future<void> syncSinTracker(String date, Map<String, dynamic> data) async {
    if (!canSync) return;
    try {
      await _userDataCollection!.doc('sin_tracker').collection('days').doc(date).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing sin tracker: $e');
    }
  }

  /// Sync sin types configuration
  Future<void> syncSinTypes(List<Map<String, dynamic>> sinTypes) async {
    if (!canSync) return;
    try {
      await _userDataCollection!.doc('sin_types').set({
        'types': sinTypes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing sin types: $e');
    }
  }

  /// Sync custom reminders
  Future<void> syncCustomReminders(List<Map<String, dynamic>> reminders) async {
    if (!canSync) return;
    try {
      await _userDataCollection!.doc('custom_reminders').set({
        'reminders': reminders,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing custom reminders: $e');
    }
  }

  // ==================== RESTORE METHODS ====================

  /// Restore all data from cloud to local
  Future<bool> restoreAllData() async {
    print('🔄 RestoreAllData called. canSync: $canSync, userId: $userId');
    
    if (!canSync) {
      print('❌ Cannot sync - Firebase not available or user not logged in');
      return false;
    }
    
    try {
      print('📥 Starting restore from Firestore...');
      await Future.wait([
        _restorePrayerTracking(),
        _restoreDailyAmal(),
        _restoreDhikrCounter(),
        _restoreReadingTracker(),
        _restoreSinTracker(),
        _restoreSinTypes(),
        _restoreCustomReminders(),
      ]);
      print('✅ All data restored successfully!');
      return true;
    } catch (e) {
      print('❌ Error restoring data: $e');
      return false;
    }
  }

  Future<void> _restorePrayerTracking() async {
    final snapshot = await _userDataCollection!
        .doc('prayer_tracking')
        .collection('days')
        .get();
    
    print('📥 Restoring prayer_tracking: ${snapshot.docs.length} documents');
    final box = await Hive.openBox('prayer_tracking');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data.remove('updatedAt');
      await box.put(doc.id, data);
    }
  }

  Future<void> _restoreDailyAmal() async {
    final snapshot = await _userDataCollection!
        .doc('daily_amal')
        .collection('days')
        .get();
    
    print('📥 Restoring daily_amal: ${snapshot.docs.length} documents');
    final box = await Hive.openBox('daily_amal');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data.remove('updatedAt');
      await box.put(doc.id, data);
    }
  }

  Future<void> _restoreDhikrCounter() async {
    final snapshot = await _userDataCollection!
        .doc('dhikr_counter')
        .collection('days')
        .get();
    
    print('📥 Restoring dhikr_counter: ${snapshot.docs.length} documents');
    final box = await Hive.openBox('dhikr_counter');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data.remove('updatedAt');
      await box.put(doc.id, data);
    }
  }

  Future<void> _restoreReadingTracker() async {
    final snapshot = await _userDataCollection!
        .doc('reading_tracker')
        .collection('days')
        .get();
    
    final box = await Hive.openBox('reading_tracker');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data.remove('updatedAt');
      await box.put(doc.id, data);
    }
  }

  Future<void> _restoreSinTracker() async {
    final snapshot = await _userDataCollection!
        .doc('sin_tracker')
        .collection('days')
        .get();
    
    final box = await Hive.openBox('sin_tracker');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data.remove('updatedAt');
      await box.put(doc.id, data);
    }
  }

  Future<void> _restoreSinTypes() async {
    final doc = await _userDataCollection!.doc('sin_types').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final types = data['types'] as List<dynamic>?;
      if (types != null) {
        final box = await Hive.openBox('sin_tracker');
        await box.put('sin_types', types);
      }
    }
  }

  Future<void> _restoreCustomReminders() async {
    final doc = await _userDataCollection!.doc('custom_reminders').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final reminders = data['reminders'] as List<dynamic>?;
      if (reminders != null) {
        final box = await Hive.openBox('custom_reminders');
        await box.clear();
        for (var reminder in reminders) {
          final r = reminder as Map<String, dynamic>;
          await box.put(r['id'], r);
        }
      }
    }
  }

  // ==================== BACKUP ALL LOCAL DATA ====================

  /// Backup all local data to cloud
  Future<bool> backupAllData() async {
    if (!canSync) return false;
    
    try {
      await _backupPrayerTracking();
      await _backupDailyAmal();
      await _backupDhikrCounter();
      await _backupReadingTracker();
      await _backupSinTracker();
      await _backupCustomReminders();
      return true;
    } catch (e) {
      print('Error backing up data: $e');
      return false;
    }
  }

  Future<void> _backupPrayerTracking() async {
    final box = await Hive.openBox('prayer_tracking');
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && key is String) {
        await syncPrayerTracking(key, Map<String, dynamic>.from(data));
      }
    }
  }

  Future<void> _backupDailyAmal() async {
    final box = await Hive.openBox('daily_amal');
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && key is String) {
        await syncDailyAmal(key, Map<String, dynamic>.from(data));
      }
    }
  }

  Future<void> _backupDhikrCounter() async {
    final box = await Hive.openBox('dhikr_counter');
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && key is String) {
        await syncDhikrCounter(key, Map<String, dynamic>.from(data));
      }
    }
  }

  Future<void> _backupReadingTracker() async {
    final box = await Hive.openBox('reading_tracker');
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null && key is String) {
        await syncReadingTracker(key, Map<String, dynamic>.from(data));
      }
    }
  }

  Future<void> _backupSinTracker() async {
    final box = await Hive.openBox('sin_tracker');
    
    // Backup daily records
    for (var key in box.keys) {
      if (key == 'sin_types') continue;
      final data = box.get(key);
      if (data != null && key is String) {
        await syncSinTracker(key, Map<String, dynamic>.from(data));
      }
    }
    
    // Backup sin types
    final sinTypes = box.get('sin_types');
    if (sinTypes != null) {
      final types = (sinTypes as List).map((e) => Map<String, dynamic>.from(e)).toList();
      await syncSinTypes(types);
    }
  }

  Future<void> _backupCustomReminders() async {
    final box = await Hive.openBox('custom_reminders');
    final reminders = <Map<String, dynamic>>[];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        reminders.add(Map<String, dynamic>.from(data));
      }
    }
    if (reminders.isNotEmpty) {
      await syncCustomReminders(reminders);
    }
  }

  // ==================== DELETE USER DATA ====================

  /// Delete all user data from cloud
  Future<bool> deleteAllUserData() async {
    if (!canSync) return false;
    
    try {
      // Delete all subcollections
      final collections = [
        'prayer_tracking',
        'daily_amal', 
        'dhikr_counter',
        'reading_tracker',
        'sin_tracker',
      ];
      
      for (var col in collections) {
        final snapshot = await _userDataCollection!
            .doc(col)
            .collection('days')
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        await _userDataCollection!.doc(col).delete();
      }
      
      // Delete config docs
      await _userDataCollection!.doc('sin_types').delete();
      await _userDataCollection!.doc('custom_reminders').delete();
      
      // Delete user doc
      await _firestore!.collection('users').doc(userId).delete();
      
      return true;
    } catch (e) {
      print('Error deleting user data: $e');
      return false;
    }
  }

  // ==================== GET LAST SYNC TIME ====================

  /// Get last sync time for a category
  Future<DateTime?> getLastSyncTime(String category) async {
    if (!canSync) return null;
    try {
      final doc = await _userDataCollection!.doc(category).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final timestamp = data?['lastSync'] as Timestamp?;
        return timestamp?.toDate();
      }
    } catch (e) {
      print('Error getting last sync time: $e');
    }
    return null;
  }
}

/// Global instance
final firestoreSyncService = FirestoreSyncService();
