import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/language_service.dart';
import '../services/notification_service.dart';
import 'dashboard.dart';
import 'now_playing_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  String _selectedFilter = 'all'; // all, devotional, temple, festival, updates

  @override
  void initState() {
    super.initState();
    _notificationService.init();
  }

  void _handleNotificationAction(Map<String, dynamic> data) {
    final actionType = data['action_type'] as String? ?? 'none';
    final actionTarget = data['action_target'] as String? ?? '';

    if (actionType == 'tab') {
      int tabIndex = 0;
      switch (actionTarget) {
        case 'home':
          tabIndex = 0;
          break;
        case 'status':
          tabIndex = 1;
          break;
        case 'pooja':
          tabIndex = 2;
          break;
        case 'music':
          tabIndex = 3;
          break;
        case 'store':
          tabIndex = 4;
          break;
      }
      Navigator.pop(context);
      DashboardScreen.switchTab(context, tabIndex);
    } else if (actionType == 'url') {
      if (actionTarget.isNotEmpty) {
        final uri = Uri.tryParse(actionTarget);
        if (uri != null) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } else if (actionType == 'now_playing') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
      );
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return mins <= 1 ? 'Just now' : '$mins mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hrs ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'festival':
        return Icons.celebration_rounded;
      case 'temple':
        return Icons.temple_hindu_rounded;
      case 'pooja':
        return Icons.flare_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'store':
        return Icons.shopping_bag_rounded;
      case 'quote':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'festival':
        return const Color(0xFFE67E22);
      case 'temple':
        return const Color(0xFF8E44AD);
      case 'pooja':
        return const Color(0xFFD35400);
      case 'music':
        return const Color(0xFF27AE60);
      case 'store':
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFF6A1B29);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = LanguageService().isTelugu;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF1C40F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTelugu ? 'నోటిఫికేషన్లు' : 'Notifications',
          style: const TextStyle(
            color: Color(0xFFF1C40F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final snap = await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('is_active', isEqualTo: true)
                  .get();
              final allIds = snap.docs.map((d) => d.id).toList();
              await _notificationService.markAllAsRead(allIds);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isTelugu
                        ? 'అన్ని నోటిఫికేషన్లు చదివినట్లుగా గుర్తించబడ్డాయి'
                        : 'All notifications marked as read'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            label: Text(
              isTelugu ? 'అన్నీ చదివాను' : 'Mark all read',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(isTelugu),

          // Notification List Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text('Error loading notifications: ${snapshot.error}', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                final allDocs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);
                final now = DateTime.now();

                // Sort descending in memory (no composite index required)
                allDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final dateA = (dataA['scheduled_at'] ?? dataA['created_at']) as Timestamp?;
                  final dateB = (dataB['scheduled_at'] ?? dataB['created_at']) as Timestamp?;
                  if (dateA == null && dateB == null) return 0;
                  if (dateA == null) return 1;
                  if (dateB == null) return -1;
                  return dateB.compareTo(dateA);
                });

                // Client filter for active, scheduled date & category
                final validDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['is_active'] == false) return false;
                  final scheduledAt = (data['scheduled_at'] as Timestamp?)?.toDate();
                  if (scheduledAt != null && scheduledAt.isAfter(now)) {
                    return false; // Future scheduled notifications hidden until date arrives
                  }
                  if (_selectedFilter != 'all') {
                    final cat = (data['category'] as String? ?? 'general').toLowerCase();
                    if (cat != _selectedFilter) return false;
                  }
                  return true;
                }).toList();

                // Update unread count in service
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _notificationService.updateUnreadCount(validDocs);
                });

                if (validDocs.isEmpty) {
                  return _buildEmptyState(isTelugu);
                }

                return ListenableBuilder(
                  listenable: _notificationService,
                  builder: (context, _) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      itemCount: validDocs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final doc = validDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;
                        final isRead = _notificationService.isRead(docId);

                        return _buildNotificationCard(
                          docId: docId,
                          data: data,
                          isRead: isRead,
                          isTelugu: isTelugu,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isTelugu) {
    final filters = [
      {'id': 'all', 'label': isTelugu ? 'అన్నీ' : 'All'},
      {'id': 'festival', 'label': isTelugu ? 'పండుగలు' : 'Festivals'},
      {'id': 'temple', 'label': isTelugu ? 'దేవాలయాలు' : 'Temples'},
      {'id': 'pooja', 'label': isTelugu ? 'పూజలు' : 'Pooja'},
      {'id': 'music', 'label': isTelugu ? 'సంగీతం' : 'Music'},
      {'id': 'store', 'label': isTelugu ? 'స్టోర్' : 'Store'},
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _selectedFilter == f['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6A1B29),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF6A1B29),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFE8DCC9),
                ),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedFilter = f['id']!);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required String docId,
    required Map<String, dynamic> data,
    required bool isRead,
    required bool isTelugu,
  }) {
    final title = isTelugu && (data['title_te'] != null && data['title_te'].toString().isNotEmpty)
        ? data['title_te']
        : (data['title'] ?? '');
    final body = isTelugu && (data['body_te'] != null && data['body_te'].toString().isNotEmpty)
        ? data['body_te']
        : (data['body'] ?? '');
    final imageUrl = data['image_url'] as String?;
    final category = (data['category'] as String? ?? 'general').toLowerCase();
    final timeStr = _formatTimestamp(data['scheduled_at'] ?? data['created_at']);
    final catColor = _getCategoryColor(category);
    final catIcon = _getCategoryIcon(category);

    return InkWell(
      onTap: () {
        _notificationService.markAsRead(docId);
        _handleNotificationAction(data);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFFFF9EC), // highlight unread with soft warm gold
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? const Color(0xFFEFE6D6) : const Color(0xFFF1C40F),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isRead ? 0.03 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Category badge + Unread dot + Timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(catIcon, color: catColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (!isRead)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Content row: Image (if any) + Title & Body
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 68,
                        height: 68,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: const Color(0xFF6A1B29),
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action button label if available
            if (data['action_type'] != null && data['action_type'] != 'none') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  data['action_button_text'] ?? (isTelugu ? 'ఇప్పుడే చూడండి →' : 'View now →'),
                  style: const TextStyle(
                    color: Color(0xFFB71C1C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTelugu) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 46,
                color: Color(0xFFE67E22),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isTelugu ? 'ఎటువంటి నోటిఫికేషన్లు లేవు' : 'No Notifications Yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B29),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isTelugu
                  ? 'కొత్త పూజలు, పండుగలు, దేవాలయ దర్శనాలు లేదా ప్రత్యేకోత్సవాల నోటిఫికేషన్లు ఇక్కడ కనిపిస్తాయి.'
                  : 'You will receive auspicious festival updates, daily slokas, pooja timings, and announcements here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
