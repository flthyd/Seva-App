import 'dart:io';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';

class StatusDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int initialIndex;
  final String? initialCategoryId;

  const StatusDetailScreen({
    super.key,
    required this.items,
    required this.initialIndex,
    this.initialCategoryId,
  });

  @override
  State<StatusDetailScreen> createState() => _StatusDetailScreenState();
}

class _StatusDetailScreenState extends State<StatusDetailScreen> {
  bool _isProcessing = false;
  bool _isCapturingForShare = false; // Hide edit pencil & camera badge during capture
  late PageController _pageController;
  late int _currentIndex;

  // GlobalKey to capture composite photo with name strip when sharing
  late ScrollController _scrollController;
  final GlobalKey _captureKey = GlobalKey();
  // GlobalKey to capture strip specifically for video overlay
  final GlobalKey _stripKey = GlobalKey();

  // User profile data
  String? _userProfileImageUrl;
  String? _userName;
  String? _userDesignation;

  // Design and Color state
  Color _userStripColor = const Color(0xFF6A1B29); // Default maroon
  int? _manualDesignIndex; // null = alternate based on page index (_currentIndex % 2)

  // Top Category filter and search state
  late List<Map<String, dynamic>> _displayItems;
  String? _activeCategoryId;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Map<String, String>> _categoriesCache = {};

  final List<Color> _availableColors = const [
    Color(0xFF6A1B29), // Maroon (Default)
    Color(0xFF1B5E20), // Dark Forest Green
    Color(0xFF0D47A1), // Deep Navy Blue
    Color(0xFFB71C1C), // Rich Crimson Red
    Color(0xFF4A148C), // Royal Purple
    Color(0xFFE65100), // Deep Orange / Saffron
    Color(0xFF880E4F), // Deep Rose
    Color(0xFF212121), // Charcoal Black
  ];

  @override
  void initState() {
    super.initState();
    _displayItems = List.from(widget.items);
    _currentIndex = widget.initialIndex;
    _activeCategoryId = widget.initialCategoryId;
    _scrollController = ScrollController();
    _pageController = PageController(
      initialPage: _currentIndex,
    );
    _loadUserProfile();
    _fetchCategoriesData();

    // Scroll to initial selected item if not 0
    if (_currentIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_currentIndex * 520.0);
        }
      });
    }
  }

  Future<void> _fetchCategoriesData() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('status_categories').get();
      if (mounted) {
        setState(() {
          for (var doc in snap.docs) {
            final data = doc.data();
            _categoriesCache[doc.id] = {
              'name': (data['name'] ?? '').toString(),
              'image_url': (data['image_url'] ?? '').toString(),
            };
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentItem =>
      _displayItems.isNotEmpty && _currentIndex < _displayItems.length
          ? _displayItems[_currentIndex]
          : (widget.items.isNotEmpty ? widget.items[0] : {});
  String get _currentUrl => (_currentItem['url'] ?? '') as String;
  bool get _isCurrentVideo => _currentItem['is_video'] == true;

  // Active design index: 0 = Straight Strip (Model 1), 1 = Mandala Circular Card (Model 2)
  int get _effectiveDesignIndex => _manualDesignIndex ?? (_currentIndex % 2);

  void _onCategorySelected(String? categoryId) async {
    setState(() {
      _activeCategoryId = categoryId;
      _isProcessing = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('status_photos')
          .where('is_active', isEqualTo: true);
      if (categoryId != null && categoryId != 'all') {
        query = query.where('category_id', isEqualTo: categoryId);
      }
      final snap = await query.get();
      final newItems = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'url': data['image_url'] ?? '',
          'is_video': data['is_video'] == true,
          'title': data['title'] ?? '',
          'category_id': data['category_id'],
        };
      }).where((item) => (item['url'] as String).isNotEmpty).toList();

      if (mounted) {
        setState(() {
          _displayItems = newItems.isNotEmpty ? newItems : widget.items;
          _currentIndex = 0;
          _isProcessing = false;
        });
        if (_displayItems.isNotEmpty && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _filterBySearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _displayItems = List.from(widget.items);
        _currentIndex = 0;
      });
      return;
    }
    final filtered = widget.items.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      return title.contains(q);
    }).toList();

    setState(() {
      _displayItems = filtered;
      _currentIndex = 0;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _openColorPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E070B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'రంగు మార్చండి (Choose Color)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Toggle Alternate auto vs fixed design
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFF1C40F)),
                      onPressed: () {
                        setState(() {
                          _manualDesignIndex = (_effectiveDesignIndex == 0) ? 1 : 0;
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.style_rounded, size: 18),
                      label: Text(_effectiveDesignIndex == 0 ? 'డిజైన్ 2 (మండల)' : 'డిజైన్ 1 (స్ట్రిప్)'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: _availableColors.map((color) {
                    final isSelected = _userStripColor.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () {
                        setState(() => _userStripColor = color);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                            width: isSelected ? 3.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _userName = data['name'];
              _userDesignation = data['designation'] ?? 'Devotee';
              _userProfileImageUrl = data['profile_image_url'];
            });
          }
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
  }

  /// Pick and crop image from Camera or Gallery
  Future<File?> _pickAndCropImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return null;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: const Color(0xFF6A1B29),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Profile Photo'),
        if (mounted) WebUiSettings(context: context),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }

  /// Direct tap on photo / camera icon -> Choose Camera or Gallery
  Future<void> _changeProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text("Take Photo (Camera)", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.photo_library, color: Colors.purple),
                ),
                title: const Text("Choose from Gallery / Device", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    setState(() => _isProcessing = true);
    try {
      final file = await _pickAndCropImage(source);
      if (file != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profile_image_url': url,
        }, SetOptions(merge: true));

        if (mounted) {
          setState(() => _userProfileImageUrl = url);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated!')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Click on Pencil -> Premium dialog with Photo (Camera/Gallery), Name, Position/Designation, and Frame Color + Save/Cancel
  Future<void> _openEditProfileDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    final nameController = TextEditingController(text: _userName ?? '');
    final designationController = TextEditingController(text: _userDesignation ?? '');
    File? tempPickedFile;
    String? currentUrl = _userProfileImageUrl;
    Color selectedColor = _userStripColor;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFDF9), Color(0xFFFAF3E8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2C485), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Premium Header with Gold Gradient Accent
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A0F1A), Color(0xFF42070D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                            ),
                            child: const Icon(Icons.edit_note_rounded, color: Color(0xFFFFD700), size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ఫ్రేమ్ వివరాలు సవరించండి',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Edit Frame Details & Style',
                                  style: TextStyle(
                                    color: Color(0xFFFFE0B2),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            onPressed: () => Navigator.pop(dialogCtx),
                            tooltip: "Cancel",
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Form Body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Photo Avatar Section
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      final source = await showModalBottomSheet<ImageSource>(
                                        context: dialogCtx,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        builder: (c) => SafeArea(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text("Select Photo From", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                const SizedBox(height: 12),
                                                ListTile(
                                                  leading: const Icon(Icons.camera_alt, color: Color(0xFF6A0F1A)),
                                                  title: const Text("Camera (కెమెరా)"),
                                                  onTap: () => Navigator.pop(c, ImageSource.camera),
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.photo_library, color: Color(0xFFD4AF37)),
                                                  title: const Text("Gallery (గ్యాలరీ)"),
                                                  onTap: () => Navigator.pop(c, ImageSource.gallery),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                      if (source != null) {
                                        final file = await _pickAndCropImage(source);
                                        if (file != null) {
                                          setDialogState(() {
                                            tempPickedFile = file;
                                          });
                                        }
                                      }
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 98,
                                          decoration: BoxDecoration(
                                            color: selectedColor,
                                            border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.25),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: tempPickedFile != null
                                              ? Image.file(tempPickedFile!, fit: BoxFit.cover)
                                              : (currentUrl != null
                                                  ? Image.network(
                                                      currentUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) =>
                                                          const Icon(Icons.person, size: 54, color: Colors.white),
                                                    )
                                                  : const Icon(Icons.person, size: 54, color: Colors.white)),
                                        ),
                                        Positioned(
                                          bottom: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFC107),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black87, width: 1.5),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                                              ],
                                            ),
                                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "ఫోటో మార్చడానికి తాకండి (Change Photo)",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF6A0F1A).withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 2. Name Field
                            const Text(
                              "పేరు (Your Name)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D121B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2C485), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: nameController,
                                style: const TextStyle(
                                  color: Color(0xFF222222),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'మీ పేరు నమోదు చేయండి (Enter name)',
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.normal),
                                  prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF6A0F1A)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 3. Position / Designation Field
                            const Text(
                              "హోదా / స్థానం (Position / Designation)",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D121B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2C485), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: designationController,
                                style: const TextStyle(
                                  color: Color(0xFF222222),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'ఉదా: Devotee / Member / భక్తుడు',
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.normal),
                                  prefixIcon: Icon(Icons.badge_rounded, color: Color(0xFF6A0F1A)),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 4. Frame Color Picker Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "ఫ్రేమ్ రంగు (Frame Color)",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5D121B),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: selectedColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                                    ],
                                  ),
                                  child: const Text(
                                    "Selected",
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _availableColors.map((color) {
                                final isChosen = selectedColor.toARGB32() == color.toARGB32();
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setDialogState(() {
                                      selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isChosen ? const Color(0xFF6A0F1A) : Colors.white,
                                        width: isChosen ? 3 : 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: isChosen ? 8 : 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isChosen
                                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions Bar (Save & Cancel Buttons)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7EEDB),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                        border: Border(
                          top: BorderSide(color: const Color(0xFFE2C485).withValues(alpha: 0.7), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFBCAAA4), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Cancel (రద్దు)',
                                style: TextStyle(
                                  color: Color(0xFF5D4037),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Save Button
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8E1424), Color(0xFF5B0C16)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6A0F1A).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  final name = nameController.text.trim();
                                  final designation = designationController.text.trim();

                                  Navigator.pop(dialogCtx);
                                  setState(() => _isProcessing = true);

                                  try {
                                    String? newPhotoUrl = _userProfileImageUrl;
                                    if (tempPickedFile != null) {
                                      if (userId != null) {
                                        final ref = FirebaseStorage.instance
                                            .ref()
                                            .child('profile_images')
                                            .child('$userId.jpg');
                                        await ref.putFile(tempPickedFile!);
                                        newPhotoUrl = await ref.getDownloadURL();
                                      } else {
                                        // If local guest user, save locally
                                        newPhotoUrl = tempPickedFile!.path;
                                      }
                                    }

                                    final finalName = name.isNotEmpty ? name : (_userName ?? 'Add Your Name');
                                    final finalDesignation = designation.isNotEmpty ? designation : 'Devotee / Member';

                                    if (userId != null) {
                                      await FirebaseFirestore.instance.collection('users').doc(userId).set({
                                        'name': finalName,
                                        'designation': finalDesignation,
                                        ...?newPhotoUrl != null ? {'profile_image_url': newPhotoUrl} : null,
                                      }, SetOptions(merge: true));
                                    }

                                    if (mounted) {
                                      setState(() {
                                        _userName = finalName;
                                        _userDesignation = finalDesignation;
                                        _userStripColor = selectedColor;
                                        if (newPhotoUrl != null) _userProfileImageUrl = newPhotoUrl;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('ఫ్రేమ్ వివరాలు విజయవంతంగా అప్‌డేట్ అయ్యాయి! (Updated successfully)'),
                                          backgroundColor: Color(0xFF2E7D32),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  } finally {
                                    if (mounted) setState(() => _isProcessing = false);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Save (సేవ్)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Captures wallpaper + rectangular strip with NO pencil/camera icons
  Future<String?> _captureCompositeImage() async {
    try {
      // 1. Trigger rebuild with icons hidden
      setState(() => _isCapturingForShare = true);
      await WidgetsBinding.instance.endOfFrame;
      // Allow repaint
      await Future.delayed(const Duration(milliseconds: 60));

      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isCapturingForShare = false);
        return null;
      }

      // Crisp 3x HD rendering
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      // Restore icons in UI
      if (mounted) setState(() => _isCapturingForShare = false);

      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/status_with_strip_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      return filePath;
    } catch (e) {
      if (mounted) setState(() => _isCapturingForShare = false);
      debugPrint("Error capturing composite image: $e");
      return null;
    }
  }

  /// Captures ONLY the devotee name strip to a transparent PNG for video watermarking
  Future<String?> _captureStripOnlyImage() async {
    try {
      setState(() => _isCapturingForShare = true);
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 60));

      final boundary = _stripKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) setState(() => _isCapturingForShare = false);
        return null;
      }

      // 3.0 pixel ratio ensures sharp text and crisp devotee photo
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (mounted) setState(() => _isCapturingForShare = false);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/strip_overlay_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      return filePath;
    } catch (e) {
      if (mounted) setState(() => _isCapturingForShare = false);
      debugPrint("Error capturing devotee strip: $e");
      return null;
    }
  }

  /// Overlays devotee strip onto video using FFmpeg
  Future<String> _generateWatermarkedVideo(String inputVideoPath) async {
    try {
      final stripPngPath = await _captureStripOnlyImage();
      if (stripPngPath == null) {
        debugPrint("Could not capture strip PNG, falling back to original video");
        return inputVideoPath;
      }

      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/status_watermarked_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // We scale the overlay PNG to match video width and preserve proportional height:
      // scale2ref=w=iw:h='2*trunc(ow/mdar/2)'
      // Position matches bottom 95dp out of ~800dp screen height (~11.8% above bottom)
      // FFmpeg command:
      final command = '-y -i "$inputVideoPath" -i "$stripPngPath" '
          '-filter_complex "[1:v][0:v]scale2ref=w=iw:h=\'2*trunc(ow/mdar/2)\'[ovr][base];[base][ovr]overlay=x=0:y=\'main_h-overlay_h-(main_h*0.118)\'" '
          '-c:v libx264 -preset ultrafast -crf 23 -pix_fmt yuv420p -c:a copy "$outputPath"';

      debugPrint("Running FFmpeg: $command");
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("FFmpeg watermarking succeeded: $outputPath");
        return outputPath;
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint("FFmpeg failed with return code $returnCode, logs: $logs");
        return inputVideoPath;
      }
    } catch (e) {
      debugPrint("Error generating watermarked video: $e");
      return inputVideoPath;
    }
  }

  Future<String> _downloadOriginalFile() async {
    final isVideo = _isCurrentVideo;
    final ext = isVideo ? 'mp4' : 'jpg';
    final tempDir = await getTemporaryDirectory();
    final savePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await Dio().download(_currentUrl, savePath);
    return savePath;
  }

  Future<void> _downloadMedia() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download is only available on Mobile.")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final isVideo = _isCurrentVideo;

      if (!isVideo) {
        // Save photo WITH name strip attached (clean: no pencil/camera icons)
        final capturedPath = await _captureCompositeImage();
        final finalPath = capturedPath ?? await _downloadOriginalFile();

        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) await Gal.requestAccess();
        await Gal.putImage(finalPath, album: 'Divya Mandir');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Saved with Name Strip to Gallery!"),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        // Video download WITH devotee name strip overlay
        final originalPath = await _downloadOriginalFile();
        final finalVideoPath = await _generateWatermarkedVideo(originalPath);

        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) await Gal.requestAccess();
        await Gal.putVideo(finalVideoPath, album: 'Divya Mandir');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Video saved to Gallery!"),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareMedia() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Share is only available on Mobile.")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final isVideo = _isCurrentVideo;
      String shareFilePath;

      if (!isVideo) {
        final captured = await _captureCompositeImage();
        shareFilePath = captured ?? await _downloadOriginalFile();
      } else {
        final original = await _downloadOriginalFile();
        shareFilePath = await _generateWatermarkedVideo(original);
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(shareFilePath)],
          text: "Check out this wallpaper from Divya Mandir app!",
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sharing: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareToWhatsAppStatus() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("WhatsApp Status is only available on Mobile.")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final isVideo = _isCurrentVideo;
      String shareFilePath;

      if (!isVideo) {
        final captured = await _captureCompositeImage();
        shareFilePath = captured ?? await _downloadOriginalFile();
      } else {
        final original = await _downloadOriginalFile();
        shareFilePath = await _generateWatermarkedVideo(original);
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(shareFilePath)],
          text: "Divya Mandir 🙏",
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const maroonNavColor = Color(0xFF6A0F1A);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: maroonNavColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Content captured by RepaintBoundary
            RepaintBoundary(
              key: _captureKey,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 118, bottom: 40),
                itemCount: _displayItems.length,
                itemBuilder: (context, index) {
                final item = _displayItems[index];
                final isVideo = item['is_video'] == true;
                final url = item['url'] as String;
                final categoryId = (item['category_id'] ?? '').toString();

                // Alternate designs if not manually overridden: Even = Straight Strip (Model 1), Odd = Circular Mandala (Model 2)
                final designIndex = _manualDesignIndex ?? (index % 2);

                final catInfo = _categoriesCache[categoryId];
                final catName = catInfo != null && catInfo['name']!.isNotEmpty
                    ? catInfo['name']!
                    : (categoryId.isNotEmpty ? categoryId : 'దివ్య మందిర్');
                final catImageUrl = catInfo?['image_url'];

                return Padding(
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 14,
                    bottom: 24, // 24px gap between buttons of current item and next wallpaper card
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 0. Category Header above each wallpaper: Round circle image + Category Name + "చూడండి ->" button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF6A0F1A), width: 1.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: (catImageUrl != null && catImageUrl.isNotEmpty)
                                    ? Image.network(
                                        catImageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: const Color(0xFF6A0F1A),
                                          child: const Icon(Icons.temple_hindu, color: Colors.white, size: 18),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFF6A0F1A),
                                        child: const Icon(Icons.temple_hindu, color: Colors.white, size: 18),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                catName,
                                style: const TextStyle(
                                  color: Color(0xFF212121),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Professional "చూడండి ->" pill button
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1E6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2C485), width: 0.8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'చూడండి',
                                    style: TextStyle(
                                      color: Color(0xFF6A0F1A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF6A0F1A)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 1. 4:5 Wallpaper Card with Devotee Nameplate attached inside + Heart & Resolution Badges
                      AspectRatio(
                        aspectRatio: 4 / 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Wallpaper Image or Video
                              if (isVideo)
                                _LoopingVideoPlayer(
                                  key: ValueKey(url),
                                  videoUrl: url,
                                  scrollController: _scrollController,
                                )
                              else
                                Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator(color: Color(0xFF6A0F1A)));
                                  },
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                  ),
                                ),

                              // Floating Top-Right Heart / Favorite Icon
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24, width: 0.8),
                                  ),
                                  child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
                                ),
                              ),

                              // Devotee Nameplate attached directly inside the 4:5 wallpaper image at the bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: RepaintBoundary(
                                  key: (index == _currentIndex) ? _stripKey : null,
                                  child: _buildNameplateByDesign(designIndex),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 2. Action Buttons placed AFTER the wallpaper image (not overlapping nameplate)
                      if (!_isCapturingForShare)
                        (_isProcessing && index == _currentIndex
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFF6A0F1A), strokeWidth: 2)),
                              )
                            : Row(
                                children: [
                                  // Share Button (Blue)
                                  Expanded(
                                    child: _buildPillButton(
                                      icon: Icons.share_rounded,
                                      label: "Share",
                                      color: const Color(0xFF1976D2),
                                      onPressed: () {
                                        setState(() => _currentIndex = index);
                                        _shareMedia();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // WhatsApp Status Button (Green)
                                  Expanded(
                                    child: _buildPillButton(
                                      icon: Icons.chat_bubble_rounded,
                                      label: "Status",
                                      color: const Color(0xFF25D366),
                                      onPressed: () {
                                        setState(() => _currentIndex = index);
                                        _shareToWhatsAppStatus();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Download Button (Dark Green)
                                  Expanded(
                                    child: _buildPillButton(
                                      icon: Icons.download_rounded,
                                      label: "Download",
                                      color: const Color(0xFF1B5E20),
                                      onPressed: () {
                                        setState(() => _currentIndex = index);
                                        _downloadMedia();
                                      },
                                    ),
                                  ),
                                ],
                              )),
                    ],
                  ),
                );
              },
            ),
          ),

          // 2. Top Header Overlay (Top Navbar with Back, Status Title, Search, Palette Color Changer)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopHeaderOverlay(),
          ),
        ],
      ),
    ),
  );
}

  /// Top Navbar Header Overlay with Back icon, Status Title, Search Icon, Color Palette, and Separate Filter Tabs below it
  Widget _buildTopHeaderOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Separate Top Navbar (Maroon with Back, Status Title, Search, Color Palette)
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF6A0F1A), // Exact rich maroon matching home screen top navbar
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  // Back Icon
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Title or Search Input
                  Expanded(
                    child: _isSearchOpen
                        ? Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              cursorColor: Colors.white,
                              onChanged: _filterBySearch,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'శోధించండి (Search)...',
                                hintStyle: TextStyle(color: Colors.white70, fontSize: 13),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          )
                        : Row(
                            children: const [
                              Text(
                                'Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '— Wallpapers',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                  ),

                  // Search toggle icon
                  IconButton(
                    icon: Icon(
                      _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isSearchOpen) {
                          _isSearchOpen = false;
                          _searchController.clear();
                          _displayItems = List.from(widget.items);
                        } else {
                          _isSearchOpen = true;
                        }
                      });
                    },
                  ),

                  // Color Palette Changer Button
                  IconButton(
                    tooltip: 'Change Color',
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _userStripColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.palette_rounded, color: Colors.white, size: 16),
                    ),
                    onPressed: _openColorPickerSheet,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Separate Category Filter Tabs Bar (Below Top Navbar, matching user's reference image style)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFCF8F2), // Elegant soft cream backdrop
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 38,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('status_categories')
                  .where('is_active', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                List<Map<String, String>> categories = [
                  {'id': 'all', 'name': 'అన్నీ (All)'},
                ];

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final firestoreCats = <Map<String, String>>[];
                  firestoreCats.add({'id': 'all', 'name': 'అన్నీ (All)'});
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final rawName = (data['name'] ?? '').toString();
                    if (rawName.isEmpty || rawName.toLowerCase().startsWith('image')) {
                      continue;
                    }
                    firestoreCats.add({
                      'id': doc.id,
                      'name': rawName,
                    });
                  }
                  if (firestoreCats.length > 1) {
                    categories = firestoreCats;
                  }
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = (_activeCategoryId == null && cat['id'] == 'all') ||
                        (_activeCategoryId == cat['id']);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        showCheckmark: isSelected,
                        checkmarkColor: const Color(0xFFF1C40F),
                        avatar: isSelected
                            ? null
                            : (index == 0
                                ? const Icon(Icons.temple_hindu, size: 14, color: Color(0xFF6A0F1A))
                                : null),
                        label: Text(cat['name']!),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            _onCategorySelected(cat['id']);
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF6A0F1A), // Deep maroon matching user screenshot
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFFF1C40F) : const Color(0xFF2C3E50),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF6A0F1A) : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        elevation: isSelected ? 1.5 : 0.5,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Master selector between Model 1 (Straight Rectangle Strip) & Model 2 (Mandala Circular Badge)
  Widget _buildNameplateByDesign(int designIndex) {
    if (designIndex == 1) {
      return _buildMandalaCircularNameplate();
    }
    return _buildNameStrip();
  }

  /// Model 1: Full-width straight rectangle colored name strip with prominent rounded square avatar extending top
  Widget _buildNameStrip() {
    const double photoWidth = 84;
    const double photoHeight = 94;
    const double stripHeight = 74;

    return SizedBox(
      height: photoHeight + 4,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background solid strip
          Container(
            height: stripHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _userStripColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.only(left: photoWidth + 24, right: 14),
            child: Row(
              children: [
                // Name and Devotee / Member Subtitle
                Expanded(
                  child: GestureDetector(
                    onTap: _openEditProfileDialog,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName != null && _userName!.isNotEmpty ? _userName! : 'Add Your Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _userDesignation != null && _userDesignation!.isNotEmpty
                              ? _userDesignation!
                              : 'Devotee / Member',
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Edit pencil icon
                if (!_isCapturingForShare)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _openEditProfileDialog,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.edit, color: Colors.white, size: 21),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // User Photo: Prominent Complete Sharp Square with Crisp White Border (No rounded corners)
          Positioned(
            left: 12,
            bottom: 4,
            child: GestureDetector(
              onTap: _changeProfilePhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: photoWidth,
                    height: photoHeight,
                    decoration: BoxDecoration(
                      color: _userStripColor,
                      border: Border.all(color: Colors.white, width: 2.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _userProfileImageUrl != null
                        ? Image.network(
                            _userProfileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.person, color: Colors.white, size: 48),
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 48),
                  ),
                  if (!_isCapturingForShare)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black87, size: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Model 2: Golden Mandala Circular Badge + Curved Warm Ivory Card with Temple Backdrop (Matching Professional UI Reference)
  Widget _buildMandalaCircularNameplate() {
    const double circleSize = 100;
    const double cardHeight = 84;

    return SizedBox(
      height: circleSize + 6,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background Warm Ivory / Soft Golden Card with Golden Temple Backdrop
          Container(
            height: cardHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF9EE), Color(0xFFFFECCC)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2C485), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // Golden Temple Silhouette / Gopuram on right
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 140,
                    child: Opacity(
                      opacity: 0.22,
                      child: Image.asset(
                        'assets/images/temple_telugu.png',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.temple_hindu, size: 70, color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ),

                  // Name, Subtitle and Edit Icon
                  Padding(
                    padding: const EdgeInsets.only(left: circleSize + 8, right: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _openEditProfileDialog,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _userName != null && _userName!.isNotEmpty ? _userName! : 'Add Your Name',
                                  style: const TextStyle(
                                    color: Color(0xFF6A0F1A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _userDesignation != null && _userDesignation!.isNotEmpty
                                      ? _userDesignation!
                                      : 'Devotee / Member',
                                  style: const TextStyle(
                                    color: Color(0xFF8A5A36),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Pencil Edit Icon inside round soft circle with border
                        if (!_isCapturingForShare)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _openEditProfileDialog,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBEAD0),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE2C485), width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.edit, color: Color(0xFF6A0F1A), size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Square Avatar Box with Golden Mandala Accent & White Border (No rounded user icons, complete square box)
          Positioned(
            left: 14,
            bottom: 4,
            child: GestureDetector(
              onTap: _changeProfilePhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 78,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _userStripColor,
                      border: Border.all(color: Colors.white, width: 2.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _userProfileImageUrl != null
                        ? Image.network(
                            _userProfileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.person, color: Colors.white, size: 44),
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 44),
                  ),

                  // Camera Icon Badge (Hidden on share capture)
                  if (!_isCapturingForShare)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black87, size: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Looping Video Player for Fullscreen Wallpaper with Mute/Unmute & Tap to Play/Pause
class _LoopingVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final ScrollController? scrollController;

  const _LoopingVideoPlayer({
    super.key,
    required this.videoUrl,
    this.scrollController,
  });

  @override
  State<_LoopingVideoPlayer> createState() => _LoopingVideoPlayerState();
}

class _LoopingVideoPlayerState extends State<_LoopingVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = false;
  bool _isUserPaused = false;
  bool _isAutoPausedByScroll = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    widget.scrollController?.addListener(_checkVisibilityAndControlPlayback);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkVisibilityAndControlPlayback();
    });
  }

  void _checkVisibilityAndControlPlayback() {
    if (!_isInitialized || !mounted || _isUserPaused) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final mediaQuery = MediaQuery.of(context);
    final topNavbarHeight = 102.0 + mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;

    final position = renderBox.localToGlobal(Offset.zero);
    final itemTop = position.dy;
    final itemHeight = renderBox.size.height;
    final itemBottom = itemTop + itemHeight;

    // Visible region of the video between topNavbar and bottom screen
    final visibleTop = itemTop < topNavbarHeight ? topNavbarHeight : itemTop;
    final visibleBottom = itemBottom > screenHeight ? screenHeight : itemBottom;

    final visibleHeight = (visibleBottom - visibleTop).clamp(0.0, itemHeight);
    final visibleRatio = itemHeight > 0 ? (visibleHeight / itemHeight) : 0.0;

    // Rules:
    // 1) Upper side 50% gone under topnavbar -> visibleRatio < 0.50 -> PAUSE
    // 2) From bottom scrolling up, when >= 50% visible -> PLAY
    final shouldPlay = visibleRatio >= 0.50;

    if (shouldPlay) {
      if (_isAutoPausedByScroll) {
        _isAutoPausedByScroll = false;
        _controller.play();
      } else if (!_controller.value.isPlaying) {
        _controller.play();
      }
    } else {
      if (!_isAutoPausedByScroll && _controller.value.isPlaying) {
        _isAutoPausedByScroll = true;
        _controller.pause();
      }
    }
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _checkVisibilityAndControlPlayback();
        }
      }).catchError((error) {
        debugPrint("Error initializing video wallpaper: $error");
        if (mounted) {
          setState(() => _hasError = true);
        }
      });
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isUserPaused = true;
      } else {
        _controller.play();
        _isUserPaused = false;
      }
    });
  }

  void _toggleMute() {
    if (!_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_checkVisibilityAndControlPlayback);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white70, size: 48),
            SizedBox(height: 8),
            Text("Failed to load video wallpaper", style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fullscreen Video Content
          Center(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // Audio Mute/Unmute Icon Button in Top Left Corner
          Positioned(
            top: 12,
            left: 12,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
