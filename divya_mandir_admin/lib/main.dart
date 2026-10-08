import 'manage_long_bells_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'manage_music_screen.dart';
import 'manage_pooja_tools_screen.dart';
import 'manage_god_photos_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBL0ucvw6HiBr0N7QqdfJprZG_qQ2VNLnY",
      authDomain: "sevaapp-af368.firebaseapp.com",
      projectId: "sevaapp-af368",
      storageBucket: "sevaapp-af368.firebasestorage.app",
      messagingSenderId: "11804332615",
      appId: "1:11804332615:web:a38c1eefe4531b84d6d762",
    ),
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divya Mandir Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6A1B29),
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  Widget _buildMenuItem(String title, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF6A1B29) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFF1C40F).withOpacity(0.2),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divya Mandir - Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B29),
      ),
      body: Row(
        children: [
          Container(
            width: 280,
            color: Colors.white,
            child: Material(
              color: Colors.transparent,
              child: ListView(
                children: [
                  _buildMenuItem("Dashboard Overview", 0),
                  _buildMenuItem("Manage Songs (Music)", 1),
                  ExpansionTile(
                    initiallyExpanded: true,
                    title: const Text("Pooja", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
                    leading: const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29)),
                    children: [
                      _buildMenuItem("Manage Harathi", 2),
                      _buildMenuItem("Manage Temple Bells", 3),
                      _buildMenuItem("Manage Flowers", 4),
                      _buildMenuItem("Manage Pooja Gods", 5),
                      _buildMenuItem("Manage Temple Wall Frame", 6),
                      _buildMenuItem("Manage Temple Long Bells", 8),
                      _buildMenuItem("Manage Pooja Tools (More)", 7),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_selectedIndex) {
      case 1:
        return const ManageMusicScreen();
      case 2:
        return const ManageCollectionScreen(
          key: ValueKey("harathis"),
          title: "Manage Harathi Designs",
          collectionName: "harathis",
          hasImage: true,
          hasAudio: false,
        );
      case 3:
        return const ManageCollectionScreen(
          key: ValueKey("bells"),
          title: "Manage Temple Bells",
          collectionName: "bells",
          hasImage: true,
          hasAudio: true,
        );
      case 4:
        return const ManageCollectionScreen(
          key: ValueKey("flowers"),
          title: "Manage Flowers",
          collectionName: "flowers",
          hasImage: true,
          hasAudio: false,
        );
      case 5:
        return const ManageCollectionScreen(
          key: ValueKey("gods"),
          title: "Manage Pooja Gods",
          collectionName: "gods",
          hasImage: true,
          hasAudio: false,
        );
      case 6:
        return const ManageCollectionScreen(
          key: ValueKey("frames"),
          title: "Manage Temple Wall Frames",
          collectionName: "frames",
          hasImage: true,
          hasAudio: false,
          hasGodDropdown: true,
        );
      case 7:
        return const ManagePoojaToolsScreen();
      case 8:
        return const ManageLongBellsScreen();
      default:
        return const Center(
          child: Text(
            "Welcome to Divya Mandir Admin Panel\nSelect an option from the menu to manage content.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.black54),
          ),
        );
    }
  }
}

class ManageCollectionScreen extends StatefulWidget {
  final String title;
  final String collectionName;
  final bool hasImage;
  final bool hasAudio;
  final bool hasGodDropdown;

  const ManageCollectionScreen({
    Key? key,
    required this.title,
    required this.collectionName,
    required this.hasImage,
    required this.hasAudio,
    this.hasGodDropdown = false,
  }) : super(key: key);

  @override
  State<ManageCollectionScreen> createState() => _ManageCollectionScreenState();
}

class _ManageCollectionScreenState extends State<ManageCollectionScreen> {
  bool _isGridView = true;

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddItemDialog(
        collectionName: widget.collectionName,
        hasImage: widget.hasImage,
        hasAudio: widget.hasAudio,
        hasGodDropdown: widget.hasGodDropdown,
      ),
    );
  }

  Future<void> _deleteItem(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: const Text("Are you sure you want to delete this?"),
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
      await FirebaseFirestore.instance.collection(widget.collectionName).doc(docId).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully.")));
    }
  }

  void _toggleActive(String docId, bool currentStatus) async {
    await FirebaseFirestore.instance.collection(widget.collectionName).doc(docId).update({
      'is_active': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: const Color(0xFF6A1B29)),
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    tooltip: _isGridView ? "List View" : "Grid View",
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add New Item", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B29),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(widget.collectionName).orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No items found. Click 'Add New Item' to get started."));
                }

                final docs = snapshot.data!.docs;
                if (!_isGridView) {
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final isActive = data['is_active'] ?? true;
                      final name = data['name'] ?? 'Unnamed';
                      final imageUrl = data['image_url'];
                      final godName = data['god_name'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: widget.collectionName == 'gods' ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageGodPhotosScreen(
                                  godId: docId,
                                  godName: name,
                                ),
                              ),
                            );
                          } : null,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl != null
                                ? Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                                : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: widget.hasGodDropdown && godName != null ? Text("God: $godName") : null,
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
                                onPressed: () => _deleteItem(context, docId),
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
                    childAspectRatio: 1.0,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final isActive = data['is_active'] ?? true;
                    final name = data['name'] ?? 'Unnamed';
                    final imageUrl = data['image_url'];
                    final godName = data['god_name']; // Display linked god name

                    return GestureDetector(
                      onTap: widget.collectionName == 'gods' ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageGodPhotosScreen(
                              godId: docId,
                              godName: name,
                            ),
                          ),
                        );
                      } : null,
                      child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: imageUrl != null
                                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey))
                                  : Container(color: Colors.grey.shade200, child: const Icon(Icons.audiotrack, size: 50, color: Colors.grey)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (widget.hasGodDropdown && godName != null) 
                                  Text("God: $godName", style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
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
                                        Text(isActive ? "Active" : "Inactive", style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.red)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteItem(context, docId),
                                          tooltip: "Delete",
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  final String collectionName;
  final bool hasImage;
  final bool hasAudio;
  final bool hasGodDropdown;

  const AddItemDialog({Key? key, required this.collectionName, required this.hasImage, required this.hasAudio, this.hasGodDropdown = false}) : super(key: key);

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  PlatformFile? _pickedImage;
  PlatformFile? _pickedAudio;
  final TextEditingController _nameController = TextEditingController();
  bool _isUploading = false;
  
  String? _selectedGodId;
  String? _selectedGodName;
  List<QueryDocumentSnapshot> _godsList = [];
  bool _isLoadingGods = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasGodDropdown) {
      _fetchGods();
    }
  }

  Future<void> _fetchGods() async {
    setState(() => _isLoadingGods = true);
    final snapshot = await FirebaseFirestore.instance.collection('gods').orderBy('created_at', descending: true).get();
    setState(() {
      _godsList = snapshot.docs;
      if (_godsList.isNotEmpty) {
        _selectedGodId = _godsList.first.id;
        _selectedGodName = (_godsList.first.data() as Map<String, dynamic>)['name'];
      }
      _isLoadingGods = false;
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'], withData: true);
    if (result != null) setState(() => _pickedImage = result.files.first);
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3', 'wav', 'ogg'], withData: true);
    if (result != null) setState(() => _pickedAudio = result.files.first);
  }

  Future<void> _uploadAndSave() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a name")));
      return;
    }
    if (widget.hasImage && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an image")));
      return;
    }
    if (widget.hasAudio && _pickedAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload an audio file")));
      return;
    }
    if (widget.hasGodDropdown && _selectedGodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a God for this frame")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      String? audioUrl;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (widget.hasImage && _pickedImage != null) {
        final ref = FirebaseStorage.instance.ref().child('${widget.collectionName}/image_${timestamp}.${_pickedImage!.extension}');
        await ref.putData(_pickedImage!.bytes!);
        imageUrl = await ref.getDownloadURL();
      }

      if (widget.hasAudio && _pickedAudio != null) {
        final ref = FirebaseStorage.instance.ref().child('${widget.collectionName}/audio_${timestamp}.${_pickedAudio!.extension}');
        await ref.putData(_pickedAudio!.bytes!);
        audioUrl = await ref.getDownloadURL();
      }

      Map<String, dynamic> data = {
        'name': _nameController.text,
        'created_at': FieldValue.serverTimestamp(),
        'is_active': true,
      };
      
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (audioUrl != null) data['audio_url'] = audioUrl;
      if (widget.hasGodDropdown && _selectedGodId != null) {
        data['god_id'] = _selectedGodId;
        data['god_name'] = _selectedGodName;
      }

      await FirebaseFirestore.instance.collection(widget.collectionName).add(data);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Saved!"), backgroundColor: Colors.green));
      Navigator.pop(context); // Close dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Item to ${widget.collectionName.toUpperCase()}"),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (widget.hasGodDropdown) ...[
                const Text("Link to Pooja God:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _isLoadingGods 
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedGodId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: _godsList.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Unknown God';
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedGodId = val;
                          // Find name
                          final doc = _godsList.firstWhere((d) => d.id == val);
                          _selectedGodName = (doc.data() as Map)['name'];
                        });
                      },
                    ),
                const SizedBox(height: 16),
              ],
              if (widget.hasImage) _buildFilePickerBox("Upload Image", _pickedImage, _pickImage, () => setState(() => _pickedImage = null), true),
              if (widget.hasAudio) ...[
                const SizedBox(height: 16),
                _buildFilePickerBox("Upload Audio", _pickedAudio, _pickAudio, () => setState(() => _pickedAudio = null), false),
              ]
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isUploading ? null : () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadAndSave,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
          child: _isUploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Upload & Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildFilePickerBox(String label, PlatformFile? pickedFile, VoidCallback onPick, VoidCallback onRemove, bool isImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (pickedFile == null)
          InkWell(
            onTap: onPick,
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8), color: Colors.grey.shade100),
              child: Center(child: Text("Click to Browse File", style: TextStyle(color: Colors.grey.shade700))),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(8), color: Colors.green.shade50),
            child: Row(
              children: [
                Expanded(child: Text(pickedFile.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onRemove),
              ],
            ),
          ),
      ],
    );
  }
}













