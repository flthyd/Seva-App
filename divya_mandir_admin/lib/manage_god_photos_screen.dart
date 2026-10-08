import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class ManageGodPhotosScreen extends StatefulWidget {
  final String godId;
  final String godName;
  const ManageGodPhotosScreen({Key? key, required this.godId, required this.godName}) : super(key: key);

  @override
  State<ManageGodPhotosScreen> createState() => _ManageGodPhotosScreenState();
}

class _ManageGodPhotosScreenState extends State<ManageGodPhotosScreen> {
  bool _isUploading = false;

  Future<void> _uploadChildPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'], withData: true);
    if (result == null) return;

    setState(() => _isUploading = true);
    try {
      final file = result.files.first;
      final fileName = 'god_child_photos/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(file.bytes!);
      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('gods').doc(widget.godId).update({
        'child_images': FieldValue.arrayUnion([downloadUrl])
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded successfully", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteChildPhoto(String url) async {
    try {
      await FirebaseFirestore.instance.collection('gods').doc(widget.godId).update({
        'child_images': FieldValue.arrayRemove([url])
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attached Photos - ${widget.godName}"),
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadChildPhoto,
              icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
              label: Text(_isUploading ? "Uploading..." : "Upload New Attached Photo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B29),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('gods').doc(widget.godId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data == null) return const SizedBox();
                  final List<dynamic> childImages = data['child_images'] ?? [];
                  if (childImages.isEmpty) return const Center(child: Text("No attached photos found. Click upload to add some."));

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: childImages.length,
                    itemBuilder: (context, index) {
                      final url = childImages[index] as String;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(url, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.white70,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteChildPhoto(url),
                              ),
                            ),
                          ),
                        ],
                      );
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
}

