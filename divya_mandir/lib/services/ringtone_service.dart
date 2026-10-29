import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RingtoneTargetType {
  ringtone,
  notification,
  alarm,
}

class RingtoneService extends ChangeNotifier {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;

  final Set<String> _ringtoneSongIds = {};

  Set<String> get ringtoneSongIds => _ringtoneSongIds;

  RingtoneService._internal() {
    _loadRingtoneSongIds();
  }

  Future<void> _loadRingtoneSongIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('saved_ringtone_song_ids');
      if (list != null) {
        _ringtoneSongIds.addAll(list);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved ringtone song ids: $e');
    }
  }

  Future<void> markAsRingtone(String songId) async {
    _ringtoneSongIds.add(songId);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('saved_ringtone_song_ids', _ringtoneSongIds.toList());
    } catch (e) {
      debugPrint('Error saving ringtone song id: $e');
    }
  }

  bool isRingtoneSong(String songId) => _ringtoneSongIds.contains(songId);

  /// Set the sound from URL or Local file as Phone Ringtone, Notification, or Alarm
  Future<bool> setSound({
    required String songId,
    required String audioPathOrUrl,
    required RingtoneTargetType type,
    bool isLocal = false,
  }) async {
    try {
      File audioFile;
      if (isLocal) {
        audioFile = File(audioPathOrUrl);
      } else {
        // Download and cache remote audio file first
        final fileInfo = await DefaultCacheManager().downloadFile(audioPathOrUrl);
        audioFile = fileInfo.file;
      }

      if (!await audioFile.exists()) {
        return false;
      }

      bool success = false;
      switch (type) {
        case RingtoneTargetType.ringtone:
          success = await RingtoneSet.setRingtoneFromFile(audioFile);
          break;
        case RingtoneTargetType.notification:
          success = await RingtoneSet.setNotificationFromFile(audioFile);
          break;
        case RingtoneTargetType.alarm:
          success = await RingtoneSet.setAlarmFromFile(audioFile);
          break;
      }

      if (success) {
        await markAsRingtone(songId);
      }

      return success;
    } catch (e) {
      debugPrint('Error setting sound as ringtone: $e');
      return false;
    }
  }

  /// Show standard bottom dialog to choose Ringtone / Notification / Alarm
  static Future<void> showSetRingtoneSheet({
    required BuildContext context,
    required String songId,
    required String songTitle,
    required String audioUrl,
    bool isLocal = false,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool isLoading = false;
        String loadingText = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            void performSet(RingtoneTargetType type, String targetName) async {
              setSheetState(() {
                isLoading = true;
                loadingText = '$targetName గా సెట్ చేస్తున్నాము...';
              });

              final success = await RingtoneService().setSound(
                songId: songId,
                audioPathOrUrl: audioUrl,
                type: type,
                isLocal: isLocal,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'విజయవంతంగా $targetName గా సెట్ చేయబడింది! 🔔'
                          : 'రింగ్‌టోన్ సెట్ చేయలేకపోయాము. దయచేసి సెట్టింగ్స్ పర్మిషన్ చెక్ చేయండి.',
                    ),
                    backgroundColor: success ? const Color(0xFF6A1B29) : Colors.red.shade800,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.ring_volume_rounded, color: Color(0xFF6A1B29), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Set As Ringtone / సౌండ్‌గా సెట్ చేయండి',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A1B29),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                songTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF6A1B29)),
                            const SizedBox(height: 14),
                            Text(loadingText, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF6A1B29))),
                          ],
                        ),
                      )
                    else ...[
                      ListTile(
                        leading: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF6A1B29)),
                        title: const Text('ఫోన్ రింగ్‌టోన్ (Phone Ringtone)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('కాల్ వచ్చినప్పుడు ఈ భక్తి పాట రింగ్ అవుతుంది', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () => performSet(RingtoneTargetType.ringtone, 'ఫోన్ రింగ్‌టోన్'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications_active_rounded, color: Color(0xFF6A1B29)),
                        title: const Text('నోటిఫికేషన్ టోన్ (Notification Sound)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('మెసేజ్ లేదా అలర్ట్ వచ్చినప్పుడు మోగుతుంది', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () => performSet(RingtoneTargetType.notification, 'నోటిఫికేషన్ టోన్'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.alarm_rounded, color: Color(0xFF6A1B29)),
                        title: const Text('అలారం టోన్ (Alarm Tone)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('ఉదయాన్నే భక్తి పాటతో మేల్కొనండి', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                        onTap: () => performSet(RingtoneTargetType.alarm, 'అలారం టోన్'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
