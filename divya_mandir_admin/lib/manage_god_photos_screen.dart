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
  String _uploadStatus = "";

  Future<void> _uploadChildMedia({required bool isVideo}) async {
    bool isMutedDefault = true;

    if (isVideo) {
      final shouldMute = await showDialog<bool>(
        context: context,
        builder: (context) {
          bool tempMute = true;
          return StatefulBuilder(
            builder: (ctx, setDialogState) {
              return AlertDialog(
                title: const Text("Video Audio Settings"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Do you want this deity background video to play Muted or with Sound by default?"),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(tempMute ? "Muted (No Audio)" : "Unmuted (Play Audio)"),
                      subtitle: Text(tempMute ? "Video will play silently" : "Video background audio will play"),
                      value: tempMute,
                      activeColor: const Color(0xFF6A1B29),
                      onChanged: (val) {
                        setDialogState(() {
                          tempMute = val;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, null),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                    onPressed: () => Navigator.pop(ctx, tempMute),
                    child: const Text("Proceed & Pick Video", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        },
      );

      if (shouldMute == null) return;
      isMutedDefault = shouldMute;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: isVideo ? ['mp4', 'mov', 'webm', 'mkv', 'avi'] : ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = "Uploading ${result.files.length} ${isVideo ? 'video(s)' : 'photo(s)'}...";
    });

    int successCount = 0;
    final folder = isVideo ? 'god_child_videos' : 'god_child_photos';

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

        if (isVideo) {
          // Add to child_videos map array
          await FirebaseFirestore.instance.collection('gods').doc(widget.godId).update({
            'child_videos': FieldValue.arrayUnion([
              {
                'url': downloadUrl,
                'is_muted': isMutedDefault,
                'created_at': DateTime.now().toIso8601String(),
              }
            ])
          });
        } else {
          // Add to child_images list
          await FirebaseFirestore.instance.collection('gods').doc(widget.godId).update({
            'child_images': FieldValue.arrayUnion([downloadUrl])
          });
        }
        successCount++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error uploading ${file.name}: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
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
            content: Text("Successfully uploaded $successCount ${isVideo ? 'video(s)' : 'photo(s)'}", style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      }
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

  Future<void> _deleteChildVideo(Map<String, dynamic> videoMap) async {
    try {
      await FirebaseFirestore.instance.collection('gods').doc(widget.godId).update({
        'child_videos': FieldValue.arrayRemove([videoMap])
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _toggleVideoMute(Map<String, dynamic> videoMap, List<dynamic> currentVideos) async {
    try {
      final updatedList = currentVideos.map((v) {
        final map = Map<String, dynamic>.from(v as Map);
        if (map['url'] == videoMap['url']) {
          map['is_muted'] = !(map['is_muted'] ?? true);
        }
        return map;
      }).toList();

      await FirebaseFirestore.instance.collection('gods').doc(widget.godId).update({
        'child_videos': updatedList,
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating audio: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attached Photos & Videos - ${widget.godName}"),
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _uploadChildMedia(isVideo: false),
                  icon: const Icon(Icons.image),
                  label: const Text("Upload Photos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _uploadChildMedia(isVideo: true),
                  icon: const Icon(Icons.videocam),
                  label: const Text("Upload Videos (Mute/Unmute)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(color: const Color(0xFF6A1B29), backgroundColor: Colors.grey.shade200),
              const SizedBox(height: 6),
              Text(_uploadStatus, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('gods').doc(widget.godId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data == null) return const SizedBox();

                  final List<dynamic> childImages = data['child_images'] ?? [];
                  final List<dynamic> childVideos = data['child_videos'] ?? [];

                  if (childImages.isEmpty && childVideos.isEmpty) {
                    return const Center(child: Text("No attached photos or videos found. Click upload to add some."));
                  }

                  // Combine media items
                  final List<Map<String, dynamic>> combinedMedia = [];
                  for (var url in childImages) {
                    combinedMedia.add({
                      'type': 'image',
                      'url': url.toString(),
                    });
                  }
                  for (var v in childVideos) {
                    final map = Map<String, dynamic>.from(v as Map);
                    combinedMedia.add({
                      'type': 'video',
                      'url': map['url'] ?? '',
                      'is_muted': map['is_muted'] ?? true,
                      'raw': map,
                    });
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: combinedMedia.length,
                    itemBuilder: (context, index) {
                      final item = combinedMedia[index];
                      final isVideo = item['type'] == 'video';
                      final url = item['url'] as String;
                      final isMuted = item['is_muted'] == true;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: isVideo
                                    ? Container(
                                        color: Colors.black87,
                                        child: const Center(
                                          child: Icon(Icons.videocam, color: Colors.white70, size: 48),
                                        ),
                                      )
                                    : Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                              ),
                            ),

                            // Top Left Type Badge
                            Positioned(
                              left: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isVideo ? Colors.deepOrange : Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isVideo ? "VIDEO" : "PHOTO",
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            // Video Audio Mute Toggle Button
                            if (isVideo)
                              Positioned(
                                left: 8,
                                bottom: 8,
                                child: GestureDetector(
                                  onTap: () => _toggleVideoMute(item['raw'], childVideos),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isMuted ? Colors.red.shade700 : Colors.green.shade700,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          isMuted ? "Muted" : "Audio ON",
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Delete Button
                            Positioned(
                              right: 6,
                              top: 6,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                  onPressed: () {
                                    if (isVideo) {
                                      _deleteChildVideo(item['raw']);
                                    } else {
                                      _deleteChildPhoto(url);
                                    }
                                  },
                                ),
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
