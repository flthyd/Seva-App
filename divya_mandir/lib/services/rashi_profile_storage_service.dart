import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rashi_models.dart';

class RashiProfileStorageService {
  static final RashiProfileStorageService _instance = RashiProfileStorageService._internal();
  factory RashiProfileStorageService() => _instance;
  RashiProfileStorageService._internal();

  static const String _localKey = 'saved_rashi_profiles_v1';

  /// Load all saved profiles (from local cache and sync with Firestore if signed in)
  Future<List<UserAstrologyProfile>> loadProfiles() async {
    List<UserAstrologyProfile> localList = [];

    // 1. First fetch from SharedPreferences for instant offline display
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_localKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as List<dynamic>;
        localList = decoded
            .map((item) => UserAstrologyProfile.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
    } catch (_) {}

    // 2. If user is signed in with Firebase, fetch/sync from Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rashi_profiles')
            .get();

        if (snap.docs.isNotEmpty) {
          final cloudList = snap.docs.map((d) => UserAstrologyProfile.fromMap(d.data())).toList();

          // Merge: use cloud list while preserving any local-only profiles
          final Map<String, UserAstrologyProfile> mergedMap = {};
          for (final p in localList) {
            mergedMap[p.id] = p;
          }
          for (final p in cloudList) {
            mergedMap[p.id] = p; // cloud overrides/augments
          }

          final mergedList = mergedMap.values.toList();
          // Sort with recent first
          mergedList.sort((a, b) => b.id.compareTo(a.id));

          // Save merged to SharedPreferences
          await _saveToLocal(mergedList);
          return mergedList;
        } else if (localList.isNotEmpty) {
          // Sync local list up to Firestore
          for (final p in localList) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('rashi_profiles')
                .doc(p.id)
                .set(p.toMap(), SetOptions(merge: true));
          }
        }
      } catch (_) {}
    }

    return localList;
  }

  /// Save or update a single profile (both local and cloud)
  Future<void> saveProfile(UserAstrologyProfile profile) async {
    final currentList = await loadProfiles();
    currentList.removeWhere((p) => p.id == profile.id);
    currentList.insert(0, profile);

    await _saveToLocal(currentList);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rashi_profiles')
            .doc(profile.id)
            .set(profile.toMap(), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  /// Delete a profile by ID (both local and cloud)
  Future<void> deleteProfile(String id) async {
    final currentList = await loadProfiles();
    currentList.removeWhere((p) => p.id == id);
    await _saveToLocal(currentList);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rashi_profiles')
            .doc(id)
            .delete();
      } catch (_) {}
    }
  }

  Future<void> _saveToLocal(List<UserAstrologyProfile> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final maps = list.map((p) => p.toMap()).toList();
      await prefs.setString(_localKey, jsonEncode(maps));
    } catch (_) {}
  }
}
