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
  String _uploadStatus = "";

  Future<void> _uploadMedia({required bool isVideo}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: isVideo 
          ? ['mp4', 'mov', 'mkv', 'avi', 'webm'] 
          : ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    // Ask titles for each file or a batch title
    final titles = <String>[];
    for (int i = 0; i < result.files.length; i++) {
      final f = result.files[i];
      final titleController = TextEditingController(text: f.name.split('.').first);
      final enteredTitle = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text("Wallpaper Title (${i + 1}/${result.files.length})"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("File: ${f.name}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title (Displayed on Wallpaper)",
                  hintText: "e.g. Lord Shiva Morning Darshan",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
              onPressed: () => Navigator.pop(ctx, titleController.text.trim()),
              child: const Text("Next / Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      titles.add(enteredTitle ?? f.name.split('.').first);
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = "Preparing to upload ${result.files.length} ${isVideo ? 'video(s)' : 'image(s)'}...";
    });

    int successCount = 0;
    final folder = isVideo ? 'status_videos' : 'status_photos';

    for (int i = 0; i < result.files.length; i++) {
      final file = result.files[i];
      if (file.bytes == null) continue;

      setState(() {
        _uploadStatus = "Uploading ${i + 1}/${result.files.length}: ${file.name}";
      });

      try {
        final ext = file.extension ?? (isVideo ? 'mp4' : 'jpg');
        final fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}_${i}_${file.name}';
        final ref = FirebaseStorage.instance.ref().child(fileName);

        final SettableMetadata metadata = SettableMetadata(
          contentType: isVideo ? 'video/$ext' : 'image/$ext',
        );

        await ref.putData(file.bytes!, metadata);
        final downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('status_photos').add({
          'category_id': widget.categoryId,
          'title': titles[i],
          'media_type': isVideo ? 'video' : 'image',
          'image_url': downloadUrl,
          'video_url': isVideo ? downloadUrl : null,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
        successCount++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error uploading ${file.name}: $e", style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
        _uploadStatus = "";
      });
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully uploaded $successCount ${isVideo ? 'video(s)' : 'photo(s)'}",
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _editTitle(BuildContext context, String docId, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Wallpaper Title"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Title",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newTitle != null) {
      await FirebaseFirestore.instance.collection('status_photos').doc(docId).update({
        'title': newTitle,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title updated!")));
    }
  }

  Future<void> _deletePhoto(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Wallpaper?"),
        content: const Text("Are you sure you want to delete this wallpaper?"),
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
        title: Text("Status Wallpapers - ${widget.categoryName}"),
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : () => _uploadMedia(isVideo: false),
                      icon: const Icon(Icons.image),
                      label: const Text("Upload Images"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B29),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : () => _uploadMedia(isVideo: true),
                      icon: const Icon(Icons.videocam),
                      label: const Text("Upload Videos"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ],
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
            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(color: const Color(0xFF6A1B29), backgroundColor: Colors.grey.shade200),
              const SizedBox(height: 8),
              Text(_uploadStatus, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
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
                    return Center(child: Text("Error fetching data: ${snapshot.error}. \nNote: You may need to create a Firestore index for this query."));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No wallpapers found. Click upload to add some."));
                  }

                  final docs = snapshot.data!.docs;

                  if (!_isGridView) {
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id;
                        final isActive = data['is_active'] ?? true;
                        final isVideo = data['media_type'] == 'video';
                        final mediaUrl = data['image_url'] ?? data['video_url'] ?? '';
                        final title = data['title'] ?? 'No Title';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  isVideo
                                      ? Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.black87,
                                          child: const Icon(Icons.videocam, color: Colors.white, size: 28),
                                        )
                                      : Image.network(
                                          mediaUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey,
                                            child: const Icon(Icons.broken_image, color: Colors.white),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isVideo ? Colors.deepOrange.withOpacity(0.15) : Colors.blue.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isVideo ? "VIDEO" : "PHOTO",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isVideo ? Colors.deepOrange : Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "ID: $docId",
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editTitle(context, docId, title),
                                  tooltip: "Edit Title",
                                ),
                                Switch(
                                  value: isActive,
                                  onChanged: (val) => _toggleActive(docId, isActive),
                                  activeThumbColor: const Color(0xFF6A1B29),
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
                      childAspectRatio: 0.72,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final isActive = data['is_active'] ?? true;
                      final isVideo = data['media_type'] == 'video';
                      final mediaUrl = data['image_url'] ?? data['video_url'] ?? '';
                      final title = data['title'] ?? 'No Title';

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: isVideo
                                        ? Container(
                                            color: Colors.black87,
                                            child: const Center(
                                              child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white70),
                                            ),
                                          )
                                        : Image.network(
                                            mediaUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                          ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isVideo ? Colors.deepOrange : Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(isVideo ? Icons.videocam : Icons.photo, size: 12, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            isVideo ? "Video" : "Photo",
                                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.7),
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        title,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: isActive,
                                      onChanged: (val) => _toggleActive(docId, isActive),
                                      activeThumbColor: const Color(0xFF6A1B29),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                        onPressed: () => _editTitle(context, docId, title),
                                        tooltip: "Edit Title",
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                        onPressed: () => _deletePhoto(context, docId),
                                        tooltip: "Delete",
                                      ),
                                    ],
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
