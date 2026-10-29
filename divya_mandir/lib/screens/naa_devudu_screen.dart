import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class NaaDevuduScreen extends StatefulWidget {
  const NaaDevuduScreen({super.key});

  @override
  State<NaaDevuduScreen> createState() => _NaaDevuduScreenState();
}

class _NaaDevuduScreenState extends State<NaaDevuduScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  void _showInstructionModal(VoidCallback onProceed) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCF8F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF6A1B29)),
            SizedBox(width: 8),
            Text("ఫోటో నిబంధనలు (Instructions)", style: TextStyle(color: Color(0xFF6A1B29), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("1. ఫోటో 9:16 నిలువు నిష్పత్తిలో (Full Portrait) ఉండాలి.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            SizedBox(height: 8),
            Text("2. ఫోటో సైజు 1 MB కంటే ఎక్కువ ఉంటే ఆటోమేటిక్‌గా కంప్రెస్ చేయబడుతుంది.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            SizedBox(height: 8),
            Text("3. మీరు 'నా దేవుడు' కేటగిరీలో గరిష్టంగా 3 ఫోటోలు మాత్రమే జోడించవచ్చు.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            SizedBox(height: 8),
            Text("4. తదుపరి స్క్రీన్‌లో ఫోటోను 9:16 క్రాప్ చేసుకోండి.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("రద్దు (Cancel)", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () {
              Navigator.pop(ctx);
              onProceed();
            },
            child: const Text("సరే (Proceed)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage({int? replaceIndex, List<dynamic>? currentList}) async {
    if (user == null) return;

    final existing = currentList ?? [];
    if (replaceIndex == null && existing.length >= 3) {
      _showLimitExceededDialog();
      return;
    }

    _showInstructionModal(() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      // Crop with 9:16 aspect ratio
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop 9:16 (నా దేవుడు)',
            toolbarColor: const Color(0xFF6A1B29),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop 9:16 (నా దేవుడు)',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (cropped == null) return;

      setState(() => _isLoading = true);
      try {
        File uploadFile = File(cropped.path);
        int finalBytes = await uploadFile.length();

        // If file is larger than 1 MB (1024 * 1024 bytes), automatically compress it
        if (finalBytes > 1024 * 1024) {
          final tempDir = await getTemporaryDirectory();
          int quality = 85;
          String targetPath = '${tempDir.path}/devudu_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
          
          XFile? compressed = await FlutterImageCompress.compressAndGetFile(
            uploadFile.path,
            targetPath,
            quality: quality,
            format: CompressFormat.jpeg,
          );

          // If still > 1MB, progressively compress until < 1MB
          while (compressed != null && (await compressed.length()) > 1024 * 1024 && quality > 40) {
            quality -= 15;
            targetPath = '${tempDir.path}/devudu_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
            compressed = await FlutterImageCompress.compressAndGetFile(
              uploadFile.path,
              targetPath,
              quality: quality,
              format: CompressFormat.jpeg,
            );
          }

          if (compressed != null) {
            uploadFile = File(compressed.path);
          }
        }

        final fileName = 'naa_devudu/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(uploadFile);
        final downloadUrl = await ref.getDownloadURL();

        List<dynamic> updated = List.from(existing);
        if (replaceIndex != null && replaceIndex < updated.length) {
          updated[replaceIndex] = downloadUrl;
        } else {
          updated.add(downloadUrl);
        }

        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'naa_devudu_images': updated,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ఫోటో విజయవంతంగా అప్‌లోడ్ చేయబడింది!"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  void _showLimitExceededDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("గరిష్ట పరిమితి (Limit Reached)"),
        content: const Text(
          "మీరు ఇప్పటికే గరిష్టంగా 3 ఫోటోలను అప్‌లోడ్ చేశారు. కొత్త ఫోటో పెట్టాలనుకుంటే ఇప్పటికే ఉన్న ఏదైనా ఒక ఫోటోను తొలగించండి (Delete) లేదా మార్చండి (Replace).",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("సరే (OK)", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(int index, List<dynamic> currentList) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("ఫోటో తొలగించాలా?"),
        content: const Text("మీరు ఖచ్చితంగా ఈ ఫోటోను తొలగించాలనుకుంటున్నారా?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || user == null) return;

    setState(() => _isLoading = true);
    try {
      List<dynamic> updated = List.from(currentList);
      updated.removeAt(index);

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'naa_devudu_images': updated,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ఫోటో తొలగించబడింది."), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("నా దేవుడు")),
        body: const Center(child: Text("దయచేసి ముందుగా లాగిన్ అవ్వండి.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        title: const Text("నా దేవుడు (My God Photos)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final List<dynamic> images = data['naa_devudu_images'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "గరిష్టంగా 3 ఫోటోలు (Max 3 Images) | 9:16 Ratio | Below 1MB\nఇక్కడ జోడించిన ఫోటోలు పూజా పేజీలో 'నా దేవుడు' కేటగిరీలో కనిపిస్తాయి.",
                          style: TextStyle(fontSize: 12, color: Colors.brown.shade800, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ఫోటోలు (${images.length}/3)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _pickAndUploadImage(currentList: images),
                      icon: const Icon(Icons.add_photo_alternate, size: 18),
                      label: const Text("Add Photo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B29),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isLoading) const LinearProgressIndicator(color: Color(0xFF6A1B29)),
                const SizedBox(height: 8),

                // Photos List / Grid
                Expanded(
                  child: images.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.temple_hindu, size: 70, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text("మీరు ఇంకా మీ దేవుడి ఫోటోలను జోడించలేదు.", style: TextStyle(color: Colors.grey, fontSize: 15)),
                              const SizedBox(height: 6),
                              const Text("'Add Photo' క్లిక్ చేసి 9:16 రేషియోలో ఫోటోను అప్‌లోడ్ చేసుకోండి.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 9 / 16,
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final url = images[index] as String;
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                  ),
                                  // Bottom Gradient with action buttons
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [Colors.black87, Colors.transparent],
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Replace Button
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              backgroundColor: Colors.white24,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            ),
                                            onPressed: () => _pickAndUploadImage(replaceIndex: index, currentList: images),
                                            icon: const Icon(Icons.sync, color: Colors.white, size: 16),
                                            label: const Text("Replace", style: TextStyle(color: Colors.white, fontSize: 11)),
                                          ),
                                          // Delete Button
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            style: IconButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.7)),
                                            icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                                            onPressed: () => _deleteImage(index, images),
                                            tooltip: "Delete",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
