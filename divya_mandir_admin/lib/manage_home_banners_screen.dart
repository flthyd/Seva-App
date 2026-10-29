import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class ManageHomeBannersScreen extends StatefulWidget {
  const ManageHomeBannersScreen({Key? key}) : super(key: key);

  @override
  State<ManageHomeBannersScreen> createState() => _ManageHomeBannersScreenState();
}

class _ManageHomeBannersScreenState extends State<ManageHomeBannersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _filter = "all"; // all, active, scheduled, inactive

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF6A1B29)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Hero Banners Management",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B29),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 48.0),
                      child: Text(
                        "Configure sliding promotional & devotional banners, schedule dates, action buttons and links.",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.auto_awesome, color: Color(0xFF6A1B29)),
                      label: const Text(
                        "Seed 3 Default Banners",
                        style: TextStyle(color: Color(0xFF6A1B29)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6A1B29)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: _seedDefaultBanners,
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
                      label: const Text(
                        "+ Add New Banner",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B29),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: () => _openBannerDialog(null),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Tabs
            Row(
              children: [
                _buildFilterChip("All Banners", "all"),
                const SizedBox(width: 8),
                _buildFilterChip("Active Now", "active"),
                const SizedBox(width: 8),
                _buildFilterChip("Scheduled", "scheduled"),
                const SizedBox(width: 8),
                _buildFilterChip("Inactive", "inactive"),
              ],
            ),
            const SizedBox(height: 16),

            // Banner Stream List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('home_banners').orderBy('order').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading banners: ${snapshot.error}"));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final now = DateTime.now();

                  // Filter logic
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isActive = data['is_active'] != false;
                    final hasSchedule = data['has_schedule'] == true;
                    DateTime? start = (data['start_date'] as Timestamp?)?.toDate();
                    DateTime? end = (data['end_date'] as Timestamp?)?.toDate();

                    if (_filter == "active") {
                      if (!isActive) return false;
                      if (hasSchedule) {
                        if (start != null && now.isBefore(start)) return false;
                        if (end != null && now.isAfter(end)) return false;
                      }
                      return true;
                    } else if (_filter == "scheduled") {
                      if (!hasSchedule || !isActive) return false;
                      return (start != null && now.isBefore(start));
                    } else if (_filter == "inactive") {
                      return !isActive;
                    }
                    return true;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_carousel_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            "No banners found",
                            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Click '+ Add New Banner' or 'Seed 3 Default Banners' to get started.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildBannerCard(doc.id, data);
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF6A1B29),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      onSelected: (val) {
        if (val) setState(() => _filter = value);
      },
    );
  }

  Widget _buildBannerCard(String id, Map<String, dynamic> data) {
    final imageUrl = data['image_url'] as String? ?? "";
    final tag = data['tag'] as String? ?? "";
    final title = data['title'] as String? ?? "";
    final subtitle = data['subtitle'] as String? ?? "";
    final buttonText = data['button_text'] as String? ?? "";
    final actionType = data['action_type'] as String? ?? "none";
    final actionTarget = data['action_target'] as String? ?? "";
    final isActive = data['is_active'] != false;
    final hasSchedule = data['has_schedule'] == true;
    final order = data['order'] ?? 1;

    DateTime? startDate = (data['start_date'] as Timestamp?)?.toDate();
    DateTime? endDate = (data['end_date'] as Timestamp?)?.toDate();

    final now = DateTime.now();
    bool isCurrentlyLive = isActive;
    bool isFutureScheduled = false;
    bool isExpired = false;

    if (hasSchedule) {
      if (startDate != null && now.isBefore(startDate)) {
        isFutureScheduled = true;
        isCurrentlyLive = false;
      } else if (endDate != null && now.isAfter(endDate)) {
        isExpired = true;
        isCurrentlyLive = false;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Thumbnail Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 240,
                height: 110,
                color: const Color(0xFF4A101C),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 36),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, color: Colors.white54, size: 36),
                      ),
              ),
            ),
            const SizedBox(width: 20),

            // Info Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Status Badge
                      if (!isActive)
                        _badge("Inactive", Colors.grey)
                      else if (isFutureScheduled)
                        _badge("Scheduled for Future", Colors.orange)
                      else if (isExpired)
                        _badge("Expired Schedule", Colors.red)
                      else
                        _badge("Active Live", Colors.green),

                      const SizedBox(width: 8),
                      _badge("Order: #$order", Colors.blueGrey),

                      if (tag.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _badge(tag, const Color(0xFF6A1B29)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Heading
                  Text(
                    title.isNotEmpty ? title : "Banner #$order",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      if (buttonText.isNotEmpty)
                        Text(
                          "🔘 Button: '$buttonText' (${_actionLabel(actionType, actionTarget)})",
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      if (hasSchedule)
                        Text(
                          "📅 Schedule: ${startDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(startDate) : 'Now'} to ${endDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(endDate) : 'End'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrentlyLive ? Colors.green.shade800 : Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        const Text(
                          "📅 Schedule: Always Visible",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      isActive ? "Active" : "Disabled",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: isActive,
                      activeColor: const Color(0xFF6A1B29),
                      onChanged: (val) {
                        _firestore.collection('home_banners').doc(id).update({'is_active': val});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: "Edit Banner",
                      onPressed: () => _openBannerDialog(id, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: "Delete Banner",
                      onPressed: () => _confirmDeleteBanner(id, imageUrl),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _actionLabel(String type, String target) {
    if (type == "tab") {
      return "Opens $target Tab";
    } else if (type == "url") {
      return "Opens URL: $target";
    }
    return "No link";
  }

  // DIALOG FOR ADD / EDIT BANNER
  void _openBannerDialog(String? docId, [Map<String, dynamic>? existingData]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BannerFormDialog(
        docId: docId,
        existingData: existingData,
      ),
    );
  }

  void _confirmDeleteBanner(String id, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Banner?"),
        content: const Text("Are you sure you want to permanently delete this home banner?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore.collection('home_banners').doc(id).delete();
                if (imageUrl.contains('firebasestorage')) {
                  try {
                    await _storage.refFromURL(imageUrl).delete();
                  } catch (_) {}
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Banner deleted successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error deleting banner: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // SEED 3 DEFAULT DEVOTIONAL BANNERS
  Future<void> _seedDefaultBanners() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seed 3 Default Banners?"),
        content: const Text(
          "This will create 3 default devotional banners (Lord Venkateswara, Lord Shiva, Goddess Lakshmi) with sample Telugu text and buttons. You can edit or replace their images anytime.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Seed Banners", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final batch = _firestore.batch();

    final defaults = [
      {
        'tag': 'నేటి దైవ సందేశం',
        'title': 'ఓం నమో వేంకటేశాయ',
        'subtitle': '“భక్తి ఉన్న హృదయంలో ఎప్పుడూ దేవుడు ఉంటాడు.”',
        'button_text': 'శ్లోకం వినండి',
        'action_type': 'tab',
        'action_target': 'music',
        'image_url': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?q=80&w=1200&auto=format&fit=crop',
        'is_active': true,
        'has_schedule': false,
        'order': 1,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'tag': 'నిత్య ఆరాధన',
        'title': 'ఓం నమః శివాయ',
        'subtitle': '“సర్వ మంగళ మాంగల్యే శివే సర్వార్థ సాధికే”',
        'button_text': 'పూజ చేయండి',
        'action_type': 'tab',
        'action_target': 'pooja',
        'image_url': 'https://images.unsplash.com/photo-1608755728617-aefab37d45f6?q=80&w=1200&auto=format&fit=crop',
        'is_active': true,
        'has_schedule': false,
        'order': 2,
        'created_at': FieldValue.serverTimestamp(),
      },
      {
        'tag': 'లక్ష్మీ కటాక్షం',
        'title': 'శ్రీ మహాలక్ష్మీ నమః',
        'subtitle': '“సర్వ సంపదలు, సౌభాగ్యాలు ప్రసాదించే దివ్య స్వరూపిణి”',
        'button_text': 'పంచాంగం చూడండి',
        'action_type': 'tab',
        'action_target': 'panchangam',
        'image_url': 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=1200&auto=format&fit=crop',
        'is_active': true,
        'has_schedule': false,
        'order': 3,
        'created_at': FieldValue.serverTimestamp(),
      },
    ];

    for (final item in defaults) {
      final docRef = _firestore.collection('home_banners').doc();
      batch.set(docRef, item);
    }

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("3 Default banners seeded successfully!")),
      );
    }
  }
}

// FORM DIALOG WITH REAL-TIME COMPRESSION & UPLOAD PROGRESS
class _BannerFormDialog extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const _BannerFormDialog({Key? key, this.docId, this.existingData}) : super(key: key);

  @override
  State<_BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends State<_BannerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tagController;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _buttonTextController;
  late TextEditingController _urlTargetController;
  late TextEditingController _orderController;

  String _actionType = "tab"; // none, tab, url
  String _selectedTab = "music"; // pooja, music, status, panchangam

  bool _isActive = true;
  bool _hasSchedule = false;
  DateTime? _startDate;
  DateTime? _endDate;

  String? _existingImageUrl;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  int? _originalSize;
  int? _compressedSize;

  bool _isSaving = false;
  double _uploadProgress = 0.0;
  String _statusText = "";

  @override
  void initState() {
    super.initState();
    final data = widget.existingData;
    _tagController = TextEditingController(text: data?['tag'] ?? 'నేటి దైవ సందేశం');
    _titleController = TextEditingController(text: data?['title'] ?? '');
    _subtitleController = TextEditingController(text: data?['subtitle'] ?? '');
    _buttonTextController = TextEditingController(text: data?['button_text'] ?? 'శ్లోకం వినండి');
    String initialUrl = '';
    if (data != null && data['action_type'] == 'url') {
      initialUrl = data['action_target'] as String? ?? '';
    }
    _urlTargetController = TextEditingController(text: initialUrl);
    _orderController = TextEditingController(text: (data?['order'] ?? 1).toString());

    _actionType = data?['action_type'] ?? 'tab';
    if (_actionType == 'tab') {
      _selectedTab = data?['action_target'] ?? 'music';
    }

    _isActive = data?['is_active'] != false;
    _hasSchedule = data?['has_schedule'] == true;
    _startDate = (data?['start_date'] as Timestamp?)?.toDate();
    _endDate = (data?['end_date'] as Timestamp?)?.toDate();

    _existingImageUrl = data?['image_url'];
  }

  @override
  void dispose() {
    _tagController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonTextController.dispose();
    _urlTargetController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  // IMAGE PICK & AUTO COMPRESSION
  Future<void> _pickAndCompressImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result == null || result.files.isEmpty || result.files.first.bytes == null) {
      return;
    }

    final rawBytes = result.files.first.bytes!;
    final name = result.files.first.name;

    setState(() {
      _statusText = "Compressing image for fast loading...";
    });

    try {
      // Decode image
      final decoded = img.decodeImage(rawBytes);
      if (decoded != null) {
        // Resize to optimal mobile banner max width 1200px maintaining aspect ratio
        img.Image resized = decoded;
        if (decoded.width > 1200) {
          resized = img.copyResize(decoded, width: 1200);
        }
        // Encode to quality 82 JPG
        final compressedJpg = img.encodeJpg(resized, quality: 82);
        final compressedBytes = Uint8List.fromList(compressedJpg);

        setState(() {
          _pickedImageBytes = compressedBytes;
          _pickedImageName = name;
          _originalSize = rawBytes.lengthInBytes;
          _compressedSize = compressedBytes.lengthInBytes;
          _statusText = "Compressed from ${(_originalSize! / 1024).toStringAsFixed(1)} KB to ${(_compressedSize! / 1024).toStringAsFixed(1)} KB";
        });
      } else {
        setState(() {
          _pickedImageBytes = rawBytes;
          _pickedImageName = name;
          _statusText = "Ready to upload";
        });
      }
    } catch (e) {
      debugPrint("Compression fallback: $e");
      setState(() {
        _pickedImageBytes = rawBytes;
        _pickedImageName = name;
        _statusText = "Ready to upload";
      });
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? (_startDate?.add(const Duration(days: 7)) ?? DateTime.now().add(const Duration(days: 7))));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF6A1B29),
            colorScheme: const ColorScheme.light(primary: Color(0xFF6A1B29)),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    final finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? 0,
      pickedTime?.minute ?? 0,
    );

    setState(() {
      if (isStart) {
        _startDate = finalDateTime;
      } else {
        _endDate = finalDateTime;
      }
    });
  }

  // SAVE & UPLOAD
  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    if (_existingImageUrl == null && _pickedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a banner image")),
      );
      return;
    }

    if (_hasSchedule) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please pick both start and end dates for the schedule")),
        );
        return;
      }
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("End date must be after start date")),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
      _uploadProgress = 0.0;
      _statusText = "Saving banner details...";
    });

    String finalImageUrl = _existingImageUrl ?? "";

    try {
      // If new image picked, upload to Firebase Storage with progress tracking
      if (_pickedImageBytes != null) {
        setState(() {
          _statusText = "Uploading banner image...";
        });

        final fileName = "home_banners/${DateTime.now().millisecondsSinceEpoch}_banner.jpg";
        final ref = FirebaseStorage.instance.ref().child(fileName);

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'compressed': 'true'},
        );

        final uploadTask = ref.putData(_pickedImageBytes!, metadata);

        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / (snapshot.totalBytes > 0 ? snapshot.totalBytes : 1);
          setState(() {
            _uploadProgress = progress;
            _statusText = "Uploading: ${(progress * 100).toStringAsFixed(0)}%";
          });
        });

        final taskSnapshot = await uploadTask;
        finalImageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      final data = {
        'tag': _tagController.text.trim(),
        'title': _titleController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'button_text': _buttonTextController.text.trim(),
        'action_type': _actionType,
        'action_target': _actionType == 'tab' ? _selectedTab : _urlTargetController.text.trim(),
        'image_url': finalImageUrl,
        'order': int.tryParse(_orderController.text.trim()) ?? 1,
        'is_active': _isActive,
        'has_schedule': _hasSchedule,
        'start_date': _hasSchedule && _startDate != null ? Timestamp.fromDate(_startDate!) : null,
        'end_date': _hasSchedule && _endDate != null ? Timestamp.fromDate(_endDate!) : null,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.docId == null) {
        data['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('home_banners').add(data);
      } else {
        await FirebaseFirestore.instance.collection('home_banners').doc(widget.docId).update(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.docId == null ? "Banner created successfully!" : "Banner updated successfully!"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _statusText = "Error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save banner: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 750,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
                    widget.docId == null ? "Create New Home Banner" : "Edit Home Banner",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B29),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Scrollable Form Body
              Expanded(
                child: ListView(
                  children: [
                    // 1. BANNER IMAGE SECTION
                    const Text(
                      "Banner Image * (Recommended size: 1080 x 430 px)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Preview Box
                        Container(
                          width: 280,
                          height: 125,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A101C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _pickedImageBytes != null
                              ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                              : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                                  ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                                  : const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, size: 36, color: Colors.white54),
                                          SizedBox(height: 4),
                                          Text("No Image Selected", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                        ),
                        const SizedBox(width: 16),

                        // Pick Button & Compression Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: Text(
                                  _existingImageUrl != null || _pickedImageBytes != null
                                      ? "Replace Banner Image"
                                      : "Select Banner Image",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A1B29),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _isSaving ? null : _pickAndCompressImage,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "⚡ Images are automatically compressed to high-efficiency Web/Mobile format for instant loading.",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              if (_statusText.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.amber.shade300),
                                  ),
                                  child: Text(
                                    _statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_isSaving && _uploadProgress > 0) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A1B29)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Divider(),

                    // 2. TEXT & CONTENT OVERLAY
                    const Text(
                      "Banner Texts & Content (Optional Overlay)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: "Small Tag / Category",
                              hintText: "e.g. నేటి దైవ సందేశం / ప్రత్యేక పూజ",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: "Main Heading / Title",
                              hintText: "e.g. ఓం నమో వేంకటేశాయ",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _subtitleController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Subtitle / Devotional Quote",
                        hintText: "e.g. భక్తి ఉన్న హృదయంలో ఎప్పుడూ దేవుడు ఉంటాడు.",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    // 3. ACTION BUTTON & NAVIGATION
                    const Text(
                      "Action Button & Target Link",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _buttonTextController,
                            decoration: const InputDecoration(
                              labelText: "Button Text",
                              hintText: "e.g. శ్లోకం వినండి / పూజ చేయండి",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _actionType,
                            decoration: const InputDecoration(
                              labelText: "Action Type",
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: "none", child: Text("No Action (Display only)")),
                              DropdownMenuItem(value: "tab", child: Text("Open In-App Tab")),
                              DropdownMenuItem(value: "url", child: Text("Open External URL")),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _actionType = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_actionType == "tab")
                      DropdownButtonFormField<String>(
                        value: _selectedTab,
                        decoration: const InputDecoration(
                          labelText: "Select In-App Destination Tab",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "music", child: Text("Devotional Music Tab")),
                          DropdownMenuItem(value: "pooja", child: Text("Virtual Pooja Tab")),
                          DropdownMenuItem(value: "status", child: Text("Status / Wallpapers Tab")),
                          DropdownMenuItem(value: "panchangam", child: Text("Panchangam Tab")),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTab = val);
                        },
                      )
                    else if (_actionType == "url")
                      TextFormField(
                        controller: _urlTargetController,
                        decoration: const InputDecoration(
                          labelText: "Target Website / URL Link",
                          hintText: "https://example.com/festival",
                          border: OutlineInputBorder(),
                        ),
                      ),

                    const SizedBox(height: 20),
                    const Divider(),

                    // 4. DATE SCHEDULE & PRIORITY
                    const Text(
                      "Scheduling & Display Settings",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Schedule Banner (Date-wise Display)"),
                      subtitle: const Text("Set advance dates for festivals or occasions. Banner displays only during this time."),
                      value: _hasSchedule,
                      activeColor: const Color(0xFF6A1B29),
                      onChanged: (val) {
                        setState(() {
                          _hasSchedule = val;
                          if (val && _startDate == null) {
                            _startDate = DateTime.now();
                            _endDate = DateTime.now().add(const Duration(days: 7));
                          }
                        });
                      },
                    ),

                    if (_hasSchedule) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                _startDate != null
                                    ? "From: ${DateFormat('dd MMM yyyy, hh:mm a').format(_startDate!)}"
                                    : "Pick Start Date",
                              ),
                              onPressed: () => _pickDateTime(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.event, size: 16),
                              label: Text(
                                _endDate != null
                                    ? "To: ${DateFormat('dd MMM yyyy, hh:mm a').format(_endDate!)}"
                                    : "Pick End Date",
                              ),
                              onPressed: () => _pickDateTime(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _orderController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Display Order / Priority (1, 2, 3...)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("Is Active"),
                            value: _isActive,
                            activeColor: const Color(0xFF6A1B29),
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(),

              // Dialog Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B29),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: _isSaving ? null : _saveBanner,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            widget.docId == null ? "Create Banner" : "Update Banner",
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

