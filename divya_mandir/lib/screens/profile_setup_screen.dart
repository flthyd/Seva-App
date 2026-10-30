import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'interests_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  String _loadingMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ప్రొఫైల్ ఫోటో ఎంచుకోండి',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7A1B29),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      icon: Icons.camera_alt,
                      label: 'కెమెరా (Camera)',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndCompressImage(ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.photo_library,
                      label: 'గ్యాలరీ (Gallery)',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickAndCompressImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7EFE4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEADBCE)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF7A1B29), size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D131F))),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCompressImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      final fileToCompress = File(pickedFile.path);
      final size = await fileToCompress.length();

      if (size > 200 * 1024) {
        setState(() {
          _isLoading = true;
          _loadingMessage = 'ఫోటో ఆప్టిమైజ్ చేయబడుతోంది...';
        });

        int quality = 85;
        int minWidth = 800;
        int minHeight = 800;
        File currentFile = fileToCompress;

        while (quality >= 30) {
          final targetPath = '${fileToCompress.parent.path}/comp_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final compressedXFile = await FlutterImageCompress.compressAndGetFile(
            currentFile.absolute.path,
            targetPath,
            quality: quality,
            minWidth: minWidth,
            minHeight: minHeight,
          );

          if (compressedXFile == null) break;
          final compressedFile = File(compressedXFile.path);
          final newSize = await compressedFile.length();
          currentFile = compressedFile;

          if (newSize <= 200 * 1024) break;
          quality -= 15;
          minWidth = (minWidth * 0.8).round();
          minHeight = (minHeight * 0.8).round();
        }

        setState(() {
          _selectedImage = currentFile;
          _isLoading = false;
          _loadingMessage = '';
        });
      } else {
        setState(() {
          _selectedImage = fileToCompress;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ఫోటో ఎంచుకోవడంలో సమస్య ఏర్పడింది: $e')),
        );
      }
    }
  }

  Future<void> _navigateToNext() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('దయచేసి మీ పేరును నమోదు చేయండి')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'వివరాలు భద్రపరుస్తున్నాము...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? uploadedImageUrl;

      if (user != null) {
        if (_selectedImage != null) {
          setState(() {
            _loadingMessage = 'ప్రొఫైల్ ఫోటో అప్‌లోడ్ అవుతోంది...';
          });
          final ref = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');

          final uploadTask = await ref.putFile(_selectedImage!);
          uploadedImageUrl = await uploadTask.ref.getDownloadURL();
        }

        final Map<String, dynamic> updateData = {
          'name': name,
          'phone': user.phoneNumber ?? '',
          'designation': 'Devotee',
          'created_at': FieldValue.serverTimestamp(),
        };

        if (uploadedImageUrl != null) {
          updateData['profile_image_url'] = uploadedImageUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InterestsScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      body: Stack(
        children: [
          // Bottom Golden Temple Sketch Landscape (from Reference Screen 3)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: Opacity(
              opacity: 0.85,
              child: Image.asset(
                'assets/images/auth/profile_bottom_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Circular Avatar with Golden Mandala & Yellow Camera Badge
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _showImagePickerOptions,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Golden Lotus / Mandala Background Frame
                          Image.asset(
                            'assets/images/auth/profile_name_avatar.png',
                            width: 175,
                            height: 175,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 150,
                              height: 150,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF0E3D0),
                              ),
                            ),
                          ),

                          // Profile Photo or User Silhouette inside Circular Maroon
                          if (_selectedImage != null)
                            ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            ),

                          // Golden Yellow Camera Badge at bottom right of the circle
                          Positioned(
                            bottom: 28,
                            right: 28,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5A93C), // Golden yellow
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.black87, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "మీ పేరు నమోదు చేయండి" Title
                  const Text(
                    "మీ పేరు నమోదు చేయండి",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A1B29),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // "ఇది మీ ప్రొఫైల్‌లో చూపబడుతుంది" Subtitle
                  Text(
                    "ఇది మీ ప్రొఫైల్‌లో చూపబడుతుంది",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Name Input Field with Person Icon
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2D6C5), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded, color: Colors.brown.shade400, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                            decoration: const InputDecoration(
                              hintText: "మీ పేరు",
                              hintStyle: TextStyle(
                                fontSize: 15,
                                color: Color(0xFFB0A294),
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // "కొనసాగించండి →" Wide Maroon Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _navigateToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7A1B29),
                        elevation: 4,
                        shadowColor: const Color(0x407A1B29),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ),
                                if (_loadingMessage.isNotEmpty) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    _loadingMessage,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "కొనసాగించండి",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
