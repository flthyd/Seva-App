import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({super.key});

  @override
  State<ManageNotificationsScreen> createState() => _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Push Notifications & Alerts Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B29),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'వినియోగదారులకు నోటిఫికేషన్లు పంపండి, షెడ్యూల్ చేయండి, సవరించండి లేదా తొలగించండి.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.flash_on, color: Color(0xFF6A1B29)),
                      label: const Text('Seed Sample Alerts', style: TextStyle(color: Color(0xFF6A1B29))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6A1B29)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: _seedSampleNotifications,
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_alert, color: Colors.white),
                      label: const Text('+ Send New Notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B29),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _openNotificationDialog(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All Notifications'),
                  const SizedBox(width: 8),
                  _buildFilterChip('festival', 'Festivals (పండుగలు)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('temple', 'Temples (దేవాలయాలు)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('pooja', 'Pooja (పూజలు)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('music', 'Devotional Music (సంగీతం)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('store', 'Store (స్టోర్ ఆఫర్లు)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('general', 'General (సాధారణ)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notifications')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading notifications: ${snapshot.error}'));
                  }

                  final allDocs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);
                  // In-memory sort descending by scheduled_at / created_at (no index required)
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

                  final filteredDocs = allDocs.where((doc) {
                    if (_selectedCategory == 'all') return true;
                    final data = doc.data() as Map<String, dynamic>;
                    return (data['category'] ?? 'general') == _selectedCategory;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'నోటిఫికేషన్లు ఏమీ లేవు',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text('కొత్త నోటిఫికేషన్ పంపడానికి పైన ఉన్న బటన్ క్లిక్ చేయండి.'),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildNotificationRow(doc.id, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String catId, String label) {
    final isSelected = _selectedCategory == catId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF6A1B29),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedCategory = catId);
      },
    );
  }

  Widget _buildNotificationRow(String docId, Map<String, dynamic> data) {
    final title = data['title'] ?? '';
    final titleTe = data['title_te'] ?? '';
    final body = data['body'] ?? '';
    final bodyTe = data['body_te'] ?? '';
    final category = data['category'] ?? 'general';
    final imageUrl = data['image_url'] as String?;
    final scheduledAt = (data['scheduled_at'] as Timestamp?)?.toDate();
    final isActive = data['is_active'] != false;
    final isScheduledFuture = scheduledAt != null && scheduledAt.isAfter(DateTime.now());

    final dateFormatted = scheduledAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(scheduledAt)
        : 'Immediate';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview / category icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.notifications_active, color: Color(0xFFE67E22), size: 30),
                  )
                : const Icon(Icons.notifications_active, color: Color(0xFFE67E22), size: 30),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF6A1B29),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isScheduledFuture)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 12, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              'Scheduled: $dateFormatted',
                              style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Pushed: $dateFormatted',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    const Spacer(),
                    // Active toggle switch
                    Row(
                      children: [
                        Text(isActive ? 'Active' : 'Disabled', style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.grey)),
                        Switch(
                          value: isActive,
                          activeColor: const Color(0xFF6A1B29),
                          onChanged: (val) {
                            _firestore.collection('notifications').doc(docId).update({'is_active': val});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Title (English & Telugu)
                Text(
                  titleTe.isNotEmpty ? '$titleTe ($title)' : title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                // Body
                Text(
                  bodyTe.isNotEmpty ? bodyTe : body,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Edit & Delete actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Edit Notification',
                onPressed: () => _openNotificationDialog(context, docId: docId, existingData: data),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete Notification',
                onPressed: () => _confirmDelete(docId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification?'),
        content: const Text('Are you sure you want to delete this notification? Users will no longer see it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _firestore.collection('notifications').doc(docId).delete();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openNotificationDialog(BuildContext context, {String? docId, Map<String, dynamic>? existingData}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _NotificationFormDialog(
        docId: docId,
        existingData: existingData,
      ),
    );
  }

  Future<void> _seedSampleNotifications() async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final samples = [
      {
        'title': 'Vaikunta Ekadashi Special Darshan',
        'title_te': 'వైకుంఠ ఏకాదశి ప్రత్యేకోత్సవం & ఉత్తర ద్వార దర్శనం',
        'body': 'Today is the auspicious Vaikunta Ekadashi. Watch live darshan and participate in divine pooja.',
        'body_te': 'ఈరోజు అత్యంత పవిత్రమైన వైకుంఠ ఏకాదశి. శ్రీ వేంకటేశ్వర స్వామి ప్రత్యక్ష దర్శనం మరియు ప్రత్యేక పూజలను తిలకించండి.',
        'category': 'festival',
        'image_url': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=800&auto=format&fit=crop',
        'action_type': 'tab',
        'action_target': 'home',
        'action_button_text': 'లైవ్ దర్శనం చూడండి',
        'is_active': true,
        'scheduled_at': Timestamp.fromDate(now),
        'created_at': Timestamp.fromDate(now),
      },
      {
        'title': 'Morning Suprabhatam & Slokas',
        'title_te': 'శుభోదయం: వేంకటేశ్వర సుప్రభాతం వినండి',
        'body': 'Start your divine day listening to Lord Venkateswara Suprabhatam chanting.',
        'body_te': 'శ్రీ వేంకటేశ్వర స్వామి సుప్రభాత స్తోత్రంతో మీ దినాన్ని ప్రశాంతంగా, భక్తి భావంతో ప్రారంభించండి.',
        'category': 'music',
        'image_url': 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=800&auto=format&fit=crop',
        'action_type': 'tab',
        'action_target': 'music',
        'action_button_text': 'సుప్రభాతం వినండి',
        'is_active': true,
        'scheduled_at': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
        'created_at': Timestamp.fromDate(now.subtract(const Duration(hours: 3))),
      },
      {
        'title': 'Special Pooja Samagri Kit Offer',
        'title_te': 'దేవోషనల్ స్టోర్: ప్రత్యేక పూజా సామగ్రి కిట్ పై 28% ఆఫర్',
        'body': 'Order pure brass lamps, kumkum patra, and sacred pooja materials delivered to your home.',
        'body_te': 'స్వచ్ఛమైన ఇత్తడి దీపాలు, పంచపాత్ర మరియు పవిత్ర పూజా ద్రవ్యాలు ఆఫర్ ధరకు ఆర్డర్ చేయండి.',
        'category': 'store',
        'image_url': 'https://images.unsplash.com/photo-1608755728617-aefab37d2edd?q=80&w=800&auto=format&fit=crop',
        'action_type': 'tab',
        'action_target': 'store',
        'action_button_text': 'స్టోర్ చూడండి',
        'is_active': true,
        'scheduled_at': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'created_at': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
    ];

    for (final s in samples) {
      final docRef = _firestore.collection('notifications').doc();
      batch.set(docRef, s);
    }

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('3 Sample notifications pushed successfully!')),
      );
    }
  }
}

class _NotificationFormDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const _NotificationFormDialog({this.docId, this.existingData});

  @override
  State<_NotificationFormDialog> createState() => _NotificationFormDialogState();
}

class _NotificationFormDialogState extends State<_NotificationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _titleTeCtrl;
  late TextEditingController _bodyCtrl;
  late TextEditingController _bodyTeCtrl;
  late TextEditingController _imageUrlCtrl;
  late TextEditingController _actionBtnCtrl;
  late TextEditingController _urlTargetCtrl;

  String _category = 'festival';
  String _actionType = 'tab'; // none, tab, url
  String _actionTargetTab = 'home'; // home, status, pooja, music, store

  bool _isScheduled = false;
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();

  Uint8List? _pickedBytes;
  String? _pickedName;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final d = widget.existingData;
    _titleCtrl = TextEditingController(text: d?['title'] ?? '');
    _titleTeCtrl = TextEditingController(text: d?['title_te'] ?? '');
    _bodyCtrl = TextEditingController(text: d?['body'] ?? '');
    _bodyTeCtrl = TextEditingController(text: d?['body_te'] ?? '');
    _imageUrlCtrl = TextEditingController(text: d?['image_url'] ?? '');
    _actionBtnCtrl = TextEditingController(text: d?['action_button_text'] ?? 'ఇప్పుడే చూడండి');
    _urlTargetCtrl = TextEditingController(text: d != null && d['action_type'] == 'url' ? d['action_target'] : '');

    _category = d?['category'] ?? 'festival';
    _actionType = d?['action_type'] ?? 'tab';
    if (_actionType == 'tab') {
      _actionTargetTab = d?['action_target'] ?? 'home';
    }

    final scheduledAt = (d?['scheduled_at'] as Timestamp?)?.toDate();
    if (scheduledAt != null && scheduledAt.isAfter(DateTime.now())) {
      _isScheduled = true;
      _scheduledDate = scheduledAt;
      _scheduledTime = TimeOfDay.fromDateTime(scheduledAt);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleTeCtrl.dispose();
    _bodyCtrl.dispose();
    _bodyTeCtrl.dispose();
    _imageUrlCtrl.dispose();
    _actionBtnCtrl.dispose();
    _urlTargetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty && result.files.first.bytes != null) {
      setState(() {
        _pickedBytes = result.files.first.bytes;
        _pickedName = result.files.first.name;
      });
    }
  }

  Future<void> _saveNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      String finalImageUrl = _imageUrlCtrl.text.trim();

      // If user uploaded a new image file, upload to Firebase Storage
      if (_pickedBytes != null) {
        final ext = _pickedName?.split('.').last ?? 'jpg';
        final fileName = 'notif_${DateTime.now().millisecondsSinceEpoch}.$ext';
        final ref = FirebaseStorage.instance.ref().child('notifications').child(fileName);
        final uploadTask = await ref.putData(
          _pickedBytes!,
          SettableMetadata(contentType: 'image/$ext'),
        );
        finalImageUrl = await uploadTask.ref.getDownloadURL();
      }

      DateTime finalSchedule = DateTime.now();
      if (_isScheduled) {
        finalSchedule = DateTime(
          _scheduledDate.year,
          _scheduledDate.month,
          _scheduledDate.day,
          _scheduledTime.hour,
          _scheduledTime.minute,
        );
      }

      final payload = {
        'title': _titleCtrl.text.trim(),
        'title_te': _titleTeCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'body_te': _bodyTeCtrl.text.trim(),
        'category': _category,
        'image_url': finalImageUrl,
        'action_type': _actionType,
        'action_target': _actionType == 'tab' ? _actionTargetTab : _urlTargetCtrl.text.trim(),
        'action_button_text': _actionBtnCtrl.text.trim(),
        'is_active': true,
        'scheduled_at': Timestamp.fromDate(finalSchedule),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.docId != null) {
        await FirebaseFirestore.instance.collection('notifications').doc(widget.docId).update(payload);
      } else {
        payload['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('notifications').add(payload);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId != null
                ? 'Notification updated successfully!'
                : (_isScheduled ? 'Notification scheduled successfully!' : 'Notification pushed to all users!')),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving notification: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.docId != null ? 'Edit Push Notification' : 'Send Push Notification to Users',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Scrollable inputs
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Schedule toggle
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              decoration: const InputDecoration(
                                labelText: 'కేటగిరీ (Category)*',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'festival', child: Text('Festivals (పండుగలు)')),
                                DropdownMenuItem(value: 'temple', child: Text('Temples (దేవాలయాలు)')),
                                DropdownMenuItem(value: 'pooja', child: Text('Pooja (పూజలు)')),
                                DropdownMenuItem(value: 'music', child: Text('Devotional Music (సంగీతం)')),
                                DropdownMenuItem(value: 'store', child: Text('Store Offers (స్టోర్ ఆఫర్లు)')),
                                DropdownMenuItem(value: 'general', child: Text('General Announcement (సాధారణ)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _category = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Schedule Date/Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(_isScheduled ? 'Date-wise scheduled' : 'Send immediately', style: const TextStyle(fontSize: 12)),
                              value: _isScheduled,
                              activeColor: const Color(0xFF6A1B29),
                              onChanged: (val) => setState(() => _isScheduled = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Schedule Pickers (if enabled)
                      if (_isScheduled) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA5D6A7)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _scheduledDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (d != null) setState(() => _scheduledDate = d);
                                },
                                child: Text(
                                  DateFormat('dd MMM yyyy').format(_scheduledDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.access_time, color: Color(0xFF2E7D32), size: 20),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _scheduledTime,
                                  );
                                  if (t != null) setState(() => _scheduledTime = t);
                                },
                                child: Text(
                                  _scheduledTime.format(context),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Titles (Telugu & English)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _titleTeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'శీర్షిక (తెలుగు Title)*',
                                hintText: 'ఉదా: వైకుంఠ ఏకాదశి ప్రత్యేకోత్సవం',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.isEmpty) && _titleCtrl.text.isEmpty
                                  ? 'Enter at least one title'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Title (English)',
                                hintText: 'e.g. Vaikunta Ekadashi Live Darshan',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Bodies (Telugu & English)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bodyTeCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'వివరణ (తెలుగు Content / Message)*',
                                hintText: 'నోటిఫికేషన్ మెసేజ్ తెలుగులో...',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.isEmpty) && _bodyCtrl.text.isEmpty
                                  ? 'Enter message content'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _bodyCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Content / Message (English)',
                                hintText: 'Notification description in English...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Image Thumbnail (Upload or URL)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _imageUrlCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Image Thumbnail URL (Optional)',
                                hintText: 'https://...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: Text(_pickedName != null ? 'Selected' : 'Pick Image'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                      if (_pickedName != null) ...[
                        const SizedBox(height: 6),
                        Text('Selected File: $_pickedName', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 14),

                      // Action Button on Notification Click
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _actionType,
                              decoration: const InputDecoration(
                                labelText: 'క్లిక్ చేసినప్పుడు చర్య (Action Type)',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'none', child: Text('No Action (Just Notice)')),
                                DropdownMenuItem(value: 'tab', child: Text('Open App Tab (స్క్రీన్‌కు వెళ్లు)')),
                                DropdownMenuItem(value: 'url', child: Text('Open External Web Link (వెబ్‌లింక్)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _actionType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_actionType == 'tab')
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _actionTargetTab,
                                decoration: const InputDecoration(
                                  labelText: 'టార్గెట్ ట్యాబ్ (Target Tab)',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'home', child: Text('హోమ్ (Home)')),
                                  DropdownMenuItem(value: 'status', child: Text('స్టేటస్ వాల్‌పేపర్ (Status)')),
                                  DropdownMenuItem(value: 'pooja', child: Text('వర్చువల్ పూజ (Pooja)')),
                                  DropdownMenuItem(value: 'music', child: Text('దివ్య సంగీతం (Music)')),
                                  DropdownMenuItem(value: 'store', child: Text('డెవోషనల్ స్టోర్ (Store)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _actionTargetTab = val);
                                },
                              ),
                            )
                          else if (_actionType == 'url')
                            Expanded(
                              child: TextFormField(
                                controller: _urlTargetCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Web Link URL (https://...)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Bottom buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B29),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isUploading ? null : _saveNotification,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.docId != null
                                ? 'Save Changes'
                                : (_isScheduled ? 'Schedule Notification' : 'Push Notification Now'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
