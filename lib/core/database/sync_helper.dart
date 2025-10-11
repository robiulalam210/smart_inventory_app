// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';


// class SyncHelper {
//   static const _lastSyncKey = 'last_daily_sync';

//   /// Save last sync date to SharedPreferences
//   static Future<void> saveLastSyncDate(DateTime date) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_lastSyncKey, date.toIso8601String());
//   }

//   /// Get last sync date from SharedPreferences
//   static Future<DateTime?> getLastSyncDate() async {
//     final prefs = await SharedPreferences.getInstance();
//     final str = prefs.getString(_lastSyncKey);
//     if (str == null) return null;
//     return DateTime.tryParse(str);
//   }

//   /// Check if we should sync (once per day, after 6 AM)
//   static Future<bool> shouldRunDailySync() async {
//     final lastSync = await getLastSyncDate();
//     final now = DateTime.now();

//     if (lastSync != null &&
//         lastSync.year == now.year &&
//         lastSync.month == now.month &&
//         lastSync.day == now.day) {
//       debugPrint("✅ Already synced today");
//       return false;
//     }

//     if (now.hour < 6) {
//       debugPrint("⏰ It's before 6 AM");
//       return false;
//     }

//     return true;
//   }

// }
