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

  // Show bottom sheet to choose Camera or Gallery
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
                    color: Color(0xFF6A1B29),
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
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF8F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6A1B29).withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF6A1B29).withValues(alpha: 0.1),
              child: Icon(icon, color: const Color(0xFF6A1B29), size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A1B29),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image and compress below 200 KB automatically
  Future<void> _pickAndCompressImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) return;

      File fileToCompress = File(pickedFile.path);
      int originalSize = await fileToCompress.length();

      // Target: strictly below 200 KB (200 * 1024 bytes)
      const int targetBytes = 200 * 1024;

      if (originalSize > targetBytes) {
        setState(() {
          _isLoading = true;
          _loadingMessage = 'ఫోటో పరిమాణం తగ్గిస్తున్నాము (<200KB)...';
        });

        int quality = 80;
        int minWidth = 800;
        int minHeight = 800;
        File currentFile = fileToCompress;

        while (await currentFile.length() > targetBytes && quality > 15) {
          final targetPath = '${fileToCompress.parent.path}/profile_cmp_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final compressedXFile = await FlutterImageCompress.compressAndGetFile(
            currentFile.absolute.path,
            targetPath,
            quality: quality,
            minWidth: minWidth,
            minHeight: minHeight,
            format: CompressFormat.jpeg,
          );

          if (compressedXFile != null) {
            currentFile = File(compressedXFile.path);
          } else {
            break;
          }

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
        const SnackBar(content: Text('దయచేసి మీ పేరును నమోదు చేయండి (Please enter your name)')),
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
        // Upload compressed profile image if selected
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
          'designation': 'Premium Devotee',
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
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A1B29), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Profile Circle Avatar + Camera Icon
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _showImagePickerOptions,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6A1B29).withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? const Icon(Icons.person, size: 64, color: Colors.grey)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B29),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isLoading ? null : _showImagePickerOptions,
                child: const Text(
                  'ఫోటో జోడించండి (Add Photo)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6A1B29),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "What's Your Name?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B29),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This helps us personalize your experience",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: "Enter your name",
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              if (_loadingMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  _loadingMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6A1B29),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
