import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class ManageStatusPhotosScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ManageStatusPhotosScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ManageStatusPhotosScreen> createState() => _ManageStatusPhotosScreenState();
}

class _ManageStatusPhotosScreenState extends State<ManageStatusPhotosScreen> {
  bool _isUploading = false;
  bool _isGridView = true;

  Future<void> _uploadPhotos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null) return;

    setState(() => _isUploading = true);
    int successCount = 0;
    
    for (var file in result.files) {
      try {
        final fileName = 'status_photos/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putData(file.bytes!);
        final downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('status_photos').add({
          'category_id': widget.categoryId,
          'image_url': downloadUrl,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
        successCount++;
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error uploading ${file.name}: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully uploaded $successCount photos", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
      }
    }
  }

  Future<void> _deletePhoto(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Photo?"),
        content: const Text("Are you sure you want to delete this photo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('status_photos').doc(docId).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully.")));
    }
  }

  void _toggleActive(String docId, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('status_photos').doc(docId).update({
      'is_active': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Status Photos - ${widget.categoryName}"),
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadPhotos,
                  icon: _isUploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload),
                  label: Text(_isUploading ? "Uploading..." : "Upload New Photos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: const Color(0xFF6A1B29)),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  tooltip: _isGridView ? "List View" : "Grid View",
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('status_photos')
                    .where('category_id', isEqualTo: widget.categoryId)
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                     // Sometimes requiring an index for where + orderBy
                     return Center(child: Text("Error fetching data: ${snapshot.error}. \nNote: You may need to create a Firestore index for this query."));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No photos found. Click upload to add some."));
                  }

                  final docs = snapshot.data!.docs;
                  
                  if (!_isGridView) {
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final isActive = data['is_active'] ?? true;
                        final imageUrl = data['image_url'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                            ),
                            title: Text("Photo ID: $docId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: isActive,
                                  onChanged: (val) => _toggleActive(docId, isActive),
                                  activeColor: const Color(0xFF6A1B29),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePhoto(context, docId),
                                  tooltip: "Delete",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final isActive = data['is_active'] ?? true;
                      final imageUrl = data['image_url'];

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: isActive,
                                          onChanged: (val) => _toggleActive(docId, isActive),
                                          activeColor: const Color(0xFF6A1B29),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deletePhoto(context, docId),
                                    tooltip: "Delete",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
