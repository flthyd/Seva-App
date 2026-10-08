import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManageLongBellsScreen extends StatefulWidget {
  const ManageLongBellsScreen({Key? key}) : super(key: key);
  @override
  State<ManageLongBellsScreen> createState() => _ManageLongBellsScreenState();
}

class _ManageLongBellsScreenState extends State<ManageLongBellsScreen> {
  final TextEditingController _nameController = TextEditingController();
  PlatformFile? _leftImage;
  PlatformFile? _rightImage;
  PlatformFile? _audioFile;
  bool _isUploading = false;

  Future<void> _pickFile(int type) async {
    FileType fType = type == 3 ? FileType.audio : FileType.image;
    final res = await FilePicker.platform.pickFiles(type: fType, withData: true);
    if (res != null) {
      setState(() {
        if (type == 1) _leftImage = res.files.first;
        if (type == 2) _rightImage = res.files.first;
        if (type == 3) _audioFile = res.files.first;
      });
    }
  }

  Future<void> _uploadAndSave() async {
    if (_nameController.text.isEmpty || _leftImage == null || _rightImage == null || _audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name, Both Images, and Audio are required!")));
      return;
    }
    setState(() => _isUploading = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final leftRef = FirebaseStorage.instance.ref().child('long_bells/left_${timestamp}.${_leftImage!.extension}');
      await leftRef.putData(_leftImage!.bytes!);
      final leftUrl = await leftRef.getDownloadURL();

      final rightRef = FirebaseStorage.instance.ref().child('long_bells/right_${timestamp}.${_rightImage!.extension}');
      await rightRef.putData(_rightImage!.bytes!);
      final rightUrl = await rightRef.getDownloadURL();

      final audRef = FirebaseStorage.instance.ref().child('long_bells/audio_${timestamp}.${_audioFile!.extension}');
      await audRef.putData(_audioFile!.bytes!);
      final audioUrl = await audRef.getDownloadURL();

      final existing = await FirebaseFirestore.instance.collection('long_bells').get();
      for (var doc in existing.docs) {
        await doc.reference.update({'is_active': false});
      }

      await FirebaseFirestore.instance.collection('long_bells').add({
        'name': _nameController.text.trim(),
        'left_image_url': leftUrl,
        'right_image_url': rightUrl,
        'audio_url': audioUrl,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      setState(() {
        _leftImage = null;
        _rightImage = null;
        _audioFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Temple Long Bells Added!")));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _toggleActive(DocumentSnapshot doc, bool currentStatus) async {
    if (!currentStatus) {
      final existing = await FirebaseFirestore.instance.collection('long_bells').get();
      for (var d in existing.docs) {
        if (d.id != doc.id) await d.reference.update({'is_active': false});
      }
    }
    await doc.reference.update({'is_active': !currentStatus});
  }

  void _editBell(BuildContext context, DocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditLongBellScreen(doc: doc)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Temple Long Bells")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add New Long Bells Pair", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Bells Pair Name", border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFileBox("Left Bell Image", _leftImage, () => _pickFile(1)),
                        _buildFileBox("Right Bell Image", _rightImage, () => _pickFile(2)),
                        _buildFileBox("Bell Sound Audio", _audioFile, () => _pickFile(3), isAudio: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _isUploading 
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _uploadAndSave,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                            child: const Text("Upload & Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Added Temple Long Bells:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('long_bells').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text("No temple long bells added yet."));
                  
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final isActive = data['is_active'] ?? false;
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isActive ? Colors.green : Colors.transparent, width: 2)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(child: Padding(padding: const EdgeInsets.all(4.0), child: Image.network(data['left_image_url'], fit: BoxFit.contain))),
                                      Expanded(child: Padding(padding: const EdgeInsets.all(4.0), child: Image.network(data['right_image_url'], fit: BoxFit.contain))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(isActive ? "Active" : "Inactive", style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.audiotrack, size: 14, color: Colors.green),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Switch(
                                value: isActive,
                                activeColor: Colors.green,
                                onChanged: (val) => _toggleActive(doc, isActive),
                              ),
                              const Divider(height: 1, thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                    onPressed: () => _editBell(context, doc),
                                    tooltip: "Edit",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                    onPressed: () => doc.reference.delete(),
                                    tooltip: "Delete",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFileBox(String label, PlatformFile? file, VoidCallback onTap, {bool isAudio = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 120, height: 100,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100),
            child: file == null 
              ? Center(child: Icon(isAudio ? Icons.audiotrack : Icons.image, color: Colors.grey, size: 40))
              : (isAudio 
                  ? Center(child: Text(file.name, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: Colors.green, fontSize: 10)))
                  : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(file.bytes!, fit: BoxFit.cover))),
          ),
        ),
      ],
    );
  }
}

class EditLongBellScreen extends StatefulWidget {
  final DocumentSnapshot doc;
  const EditLongBellScreen({Key? key, required this.doc}) : super(key: key);

  @override
  State<EditLongBellScreen> createState() => _EditLongBellScreenState();
}

class _EditLongBellScreenState extends State<EditLongBellScreen> {
  late TextEditingController _nameController;
  PlatformFile? _leftImage;
  PlatformFile? _rightImage;
  PlatformFile? _audioFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name'] ?? '');
  }

  Future<void> _pickFile(int type) async {
    FileType fType = type == 3 ? FileType.audio : FileType.image;
    final res = await FilePicker.platform.pickFiles(type: fType, withData: true);
    if (res != null) {
      setState(() {
        if (type == 1) _leftImage = res.files.first;
        if (type == 2) _rightImage = res.files.first;
        if (type == 3) _audioFile = res.files.first;
      });
    }
  }

  Future<void> _updateItem() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name is required!")));
      return;
    }
    setState(() => _isUploading = true);

    try {
      final data = widget.doc.data() as Map<String, dynamic>;
      String leftUrl = data['left_image_url'];
      String rightUrl = data['right_image_url'];
      String audioUrl = data['audio_url'];

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (_leftImage != null) {
        final ref = FirebaseStorage.instance.ref().child('long_bells/left_${timestamp}.${_leftImage!.extension}');
        await ref.putData(_leftImage!.bytes!);
        leftUrl = await ref.getDownloadURL();
      }
      if (_rightImage != null) {
        final ref = FirebaseStorage.instance.ref().child('long_bells/right_${timestamp}.${_rightImage!.extension}');
        await ref.putData(_rightImage!.bytes!);
        rightUrl = await ref.getDownloadURL();
      }
      if (_audioFile != null) {
        final ref = FirebaseStorage.instance.ref().child('long_bells/audio_${timestamp}.${_audioFile!.extension}');
        await ref.putData(_audioFile!.bytes!);
        audioUrl = await ref.getDownloadURL();
      }

      await widget.doc.reference.update({
        'name': _nameController.text.trim(),
        'left_image_url': leftUrl,
        'right_image_url': rightUrl,
        'audio_url': audioUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bells Updated Successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Temple Long Bells")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Bells Pair Name", border: OutlineInputBorder())),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditBox("Left Bell", data['left_image_url'], _leftImage, () => _pickFile(1)),
                _buildEditBox("Right Bell", data['right_image_url'], _rightImage, () => _pickFile(2)),
                _buildEditBox("Audio", data['audio_url'], _audioFile, () => _pickFile(3), isAudio: true),
              ],
            ),
            const SizedBox(height: 32),
            _isUploading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(
                  onPressed: _updateItem, 
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditBox(String label, String currentUrl, PlatformFile? newFile, VoidCallback onTap, {bool isAudio = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!isAudio) Image.network(currentUrl, width: 60, height: 60, fit: BoxFit.contain)
        else const Icon(Icons.audiotrack, color: Colors.green, size: 40),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: Icon(isAudio ? Icons.audiotrack : Icons.image, size: 16),
          label: const Text("Replace"),
          onPressed: onTap,
        ),
        if (newFile != null)
          Text("New file selected", style: const TextStyle(color: Colors.green, fontSize: 10)),
      ],
    );
  }
}
