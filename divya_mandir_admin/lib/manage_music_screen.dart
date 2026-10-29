import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class ManageMusicScreen extends StatefulWidget {
  const ManageMusicScreen({Key? key}) : super(key: key);

  @override
  _ManageMusicScreenState createState() => _ManageMusicScreenState();
}

class _ManageMusicScreenState extends State<ManageMusicScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Manage Music (Premium)", style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: const TabBar(
            labelColor: Color(0xFF6A1B29),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6A1B29),
            tabs: [
              Tab(text: "Playlists (Categories)"),
              Tab(text: "Songs"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PlaylistsTab(),
            SongsTab(),
          ],
        ),
      ),
    );
  }
}

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B29),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddPlaylistDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('music_categories').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No playlists added yet."));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(data['image_url'] ?? '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.music_note, size: 50)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => FirebaseFirestore.instance.collection('music_categories').doc(docs[index].id).delete(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddPlaylistDialog(),
    );
  }
}

class AddPlaylistDialog extends StatefulWidget {
  const AddPlaylistDialog({Key? key}) : super(key: key);
  @override
  _AddPlaylistDialogState createState() => _AddPlaylistDialogState();
}
class _AddPlaylistDialogState extends State<AddPlaylistDialog> {
  final _nameController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageExt;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageExt = result.files.first.extension ?? 'png';
      });
    }
  }

  Future<void> _upload() async {
    if (_nameController.text.isEmpty || _imageBytes == null) return;
    setState(() => _isUploading = true);
    try {
      final fileName = 'playlist_${DateTime.now().millisecondsSinceEpoch}.$_imageExt';
      final ref = FirebaseStorage.instance.ref().child('music_categories/$fileName');
      await ref.putData(_imageBytes!);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('music_categories').add({
        'name': _nameController.text,
        'image_url': url,
        'created_at': FieldValue.serverTimestamp(),
        'is_active': true,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Playlist (Category)"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Playlist Name (e.g. Mantra)')),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Select Icon/Image")),
            if (_imageBytes != null) const Padding(padding: EdgeInsets.all(8.0), child: Text("Image selected!")),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _isUploading ? null : _upload, child: _isUploading ? const CircularProgressIndicator() : const Text("Upload")),
      ],
    );
  }
}

class SongsTab extends StatelessWidget {
  const SongsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A1B29),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddSongDialog(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('songs').orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No songs added yet."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: data['image_url'] != null ? Image.network(data['image_url'], width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.music_note),
                  title: Text(data['title'] ?? 'Unknown'),
                  subtitle: Text(data['artist'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => FirebaseFirestore.instance.collection('songs').doc(docs[index].id).delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSongDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddSongDialog(),
    );
  }
}

class AddSongDialog extends StatefulWidget {
  const AddSongDialog({Key? key}) : super(key: key);
  @override
  _AddSongDialogState createState() => _AddSongDialogState();
}
class _AddSongDialogState extends State<AddSongDialog> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  
  String? _selectedCategoryId;
  
  Uint8List? _imageBytes;
  String? _imageExt;
  Uint8List? _audioBytes;
  String? _audioExt;
  
  bool _isUploading = false;
  List<QueryDocumentSnapshot> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snap = await FirebaseFirestore.instance.collection('music_categories').get();
    setState(() {
      _categories = snap.docs;
      if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _imageExt = result.files.first.extension ?? 'png';
      });
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _audioBytes = result.files.first.bytes;
        _audioExt = result.files.first.extension ?? 'mp3';
      });
    }
  }

  Future<void> _upload() async {
    if (_titleController.text.isEmpty || _audioBytes == null || _selectedCategoryId == null) return;
    setState(() => _isUploading = true);
    
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      
      String? imageUrl;
      if (_imageBytes != null) {
        final imgRef = FirebaseStorage.instance.ref().child('songs/img_$ts.$_imageExt');
        await imgRef.putData(_imageBytes!);
        imageUrl = await imgRef.getDownloadURL();
      } else {
        // If no image uploaded, default to empty or category/app logo placeholder
        imageUrl = '';
      }

      final audioRef = FirebaseStorage.instance.ref().child('songs/audio_$ts.$_audioExt');
      await audioRef.putData(_audioBytes!);
      final audioUrl = await audioRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('songs').add({
        'title': _titleController.text,
        'artist': _artistController.text,
        'image_url': imageUrl,
        'audio_url': audioUrl,
        'category_id': _selectedCategoryId,
        'created_at': FieldValue.serverTimestamp(),
        'is_active': true,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Song"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Song Title')),
            TextField(controller: _artistController, decoration: const InputDecoration(labelText: 'Artist / Singer')),
            const SizedBox(height: 16),
            if (_categories.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Select Playlist/Category'),
                items: _categories.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(data['name'] ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Thumb")),
                ElevatedButton.icon(onPressed: _pickAudio, icon: const Icon(Icons.audiotrack), label: const Text("Audio")),
              ],
            ),
            const SizedBox(height: 8),
            Text(_imageBytes != null ? "Image selected" : "No image"),
            Text(_audioBytes != null ? "Audio selected" : "No audio"),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _isUploading ? null : _upload, child: _isUploading ? const CircularProgressIndicator() : const Text("Upload Song")),
      ],
    );
  }
}
