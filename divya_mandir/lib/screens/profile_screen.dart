import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_screen.dart';
import 'naa_devudu_screen.dart';
import 'language_selection_screen.dart';
import 'legal_content_screen.dart';
import '../services/language_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  String? _name;
  String? _designation;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'];
            _designation = data['designation'] ?? 'Premium Devotee';
            _profileImageUrl = data['profile_image_url'];
          });
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickAndUploadImage() async {
    if (user == null) return;
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      // Crop the image before uploading
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF6A1B29),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (cropped == null) return; // User cancelled cropping
      
      final File file = File(cropped.path);
      setState(() => _isLoading = true);
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user!.uid}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'profile_image_url': url,
        }, SetOptions(merge: true));
        
        setState(() {
          _profileImageUrl = url;
        });
        
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated successfully!')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _removeProfileImage() async {
    if (user == null || _profileImageUrl == null) return;
    
    setState(() => _isLoading = true);
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('${user!.uid}.jpg');
      await ref.delete();
      
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'profile_image_url': FieldValue.delete(),
      });
      
      setState(() {
        _profileImageUrl = null;
      });
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture removed')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error removing image: $e')));
    }
    setState(() => _isLoading = false);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage();
              },
            ),
            if (_profileImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty
        ? user!.phoneNumber!
        : "Not provided";
    final displayName = _name ?? "Devotee";
    final displayDesignation = _designation ?? "Premium Member";

    return ListenableBuilder(
      listenable: LanguageService(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFBF7F0), // Divine cream background matching screenshot
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              LanguageService().isTelugu ? "నా ఖాతా (My Account)" : "My Account",
              style: const TextStyle(
                color: Color(0xFF6A1B29),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6A1B29), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Profile Picture Section with Camera Icon badge
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: const Color(0xFFE0E5E9),
                              backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                              child: _profileImageUrl == null
                                  ? const Icon(Icons.person, size: 68, color: Colors.white)
                                  : null,
                            ),
                            GestureDetector(
                              onTap: _showImageOptions,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6A1B29),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Name and Designation
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B29),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          displayDesignation,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6A1B29),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Phone Number Card
                      _buildProfileCard(
                        icon: Icons.phone_android_rounded,
                        title: "Phone Number",
                        subtitle: phone,
                        trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 22),
                      ),
                      const SizedBox(height: 14),
                  
                  // Naa Devudu (My God Photos) Button
                  _buildActionTile(
                    Icons.temple_hindu,
                    "నా దేవుడు (My God Photos)",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NaaDevuduScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Language Selection Option
                  _buildActionTile(
                    Icons.language_rounded,
                    "${AppStrings.language} : ${LanguageService().isTelugu ? 'తెలుగు' : 'English'}",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                      );
                    },
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        LanguageService().isTelugu ? "తెలుగు" : "English",
                        style: const TextStyle(
                          color: Color(0xFF6A1B29),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Support & Legal Pages matching uploaded screenshot (Support Section)
                  _buildActionTile(
                    Icons.share_outlined,
                    LanguageService().isTelugu ? "యాప్‌ని షేర్ చేయండి" : "Share App",
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('యాప్ షేర్ లింక్ కాపీ చేయబడింది!')),
                      );
                    },
                  ),
                  _buildActionTile(
                    Icons.business_outlined,
                    LanguageService().isTelugu ? "మమ్మల్ని గురించి" : "About Us",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: LanguageService().isTelugu ? "మమ్మల్ని గురించి" : "About Us",
                            documentKey: 'about_us',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    Icons.mail_outline_rounded,
                    LanguageService().isTelugu ? "మమ్మల్ని సంప్రదించండి" : "Contact Us",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: LanguageService().isTelugu ? "మమ్మల్ని సంప్రదించండి" : "Contact Us",
                            documentKey: 'contact_us',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    Icons.description_outlined,
                    LanguageService().isTelugu ? "నిబంధనలు & షరతులు" : "Terms & Conditions",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: LanguageService().isTelugu ? "నిబంధనలు & షరతులు" : "Terms & Conditions",
                            documentKey: 'terms_conditions',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    Icons.security_outlined,
                    LanguageService().isTelugu ? "గోప్యతా విధానం" : "Privacy Policy",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: LanguageService().isTelugu ? "గోప్యతా విధానం" : "Privacy Policy",
                            documentKey: 'privacy_policy',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    Icons.copyright_outlined,
                    LanguageService().isTelugu ? "కాపీరైట్ విధానం" : "Copyright Policy",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: LanguageService().isTelugu ? "కాపీరైట్ విధానం" : "Copyright Policy",
                            documentKey: 'copyright',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    Icons.help_outline_rounded,
                    LanguageService().isTelugu ? "తరచుగా అడిగే ప్రశ్నలు (FAQs)" : "FAQs",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: LanguageService().isTelugu ? "తరచుగా అడిగే ప్రశ్నలు (FAQs)" : "FAQs",
                            documentKey: 'faqs',
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Logo & Version Branding
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Seva App",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A1B29),
                          ),
                        ),
                        const Text(
                          "Version 1.0.0 • Sacred & Devotional",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
        );
      },
    );
  }

  Widget _buildProfileCard({required IconData icon, required String title, required String subtitle, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF8F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6A1B29)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
  
  Widget _buildActionTile(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 8),
              ],
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
