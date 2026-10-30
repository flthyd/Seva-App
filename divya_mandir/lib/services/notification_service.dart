import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _readIdsKey = 'read_notification_ids';
  final Set<String> _readIds = {};
  int _unreadCount = 0;
  bool _initialized = false;

  Set<String> get readIds => _readIds;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_readIdsKey) ?? [];
      _readIds.addAll(saved);
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  void updateUnreadCount(List<QueryDocumentSnapshot> docs) {
    int unread = 0;
    for (final doc in docs) {
      if (!_readIds.contains(doc.id)) {
        unread++;
      }
    }
    if (_unreadCount != unread) {
      _unreadCount = unread;
      notifyListeners();
    }
  }

  bool isRead(String id) => _readIds.contains(id);

  Future<void> markAsRead(String id) async {
    if (_readIds.contains(id)) return;
    _readIds.add(id);
    if (_unreadCount > 0) _unreadCount--;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readIdsKey, _readIds.toList());
    } catch (e) {
      debugPrint('Error saving read notification id: $e');
    }
  }

  Future<void> markAllAsRead(List<String> allIds) async {
    _readIds.addAll(allIds);
    _unreadCount = 0;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readIdsKey, _readIds.toList());
    } catch (e) {
      debugPrint('Error saving all read notifications: $e');
    }
  }

  Future<void> clearAllReadStatus() async {
    _readIds.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_readIdsKey);
    } catch (e) {
      debugPrint('Error clearing read status: $e');
    }
  }
}
