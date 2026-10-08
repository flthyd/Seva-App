import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ManagePoojaToolsScreen extends StatefulWidget {
  const ManagePoojaToolsScreen({Key? key}) : super(key: key);
  @override
  State<ManagePoojaToolsScreen> createState() => _ManagePoojaToolsScreenState();
}

class _ManagePoojaToolsScreenState extends State<ManagePoojaToolsScreen> {
  final TextEditingController _catNameCtrl = TextEditingController();

  Future<void> _addCategory() async {
    if (_catNameCtrl.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('pooja_tools_categories').add({
      'name': _catNameCtrl.text.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });
    _catNameCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Pooja Categories")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _catNameCtrl, decoration: const InputDecoration(labelText: "New Category (e.g. Pooja, Sounds)", border: OutlineInputBorder()))),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add), 
                  label: const Text("Add Category"),
                  onPressed: _addCategory,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('pooja_tools_categories').orderBy('created_at').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF6A1B29))),
                          subtitle: const Text("Tap to view & add tools"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => doc.reference.delete(),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => ManageToolsListScreen(categoryId: doc.id, categoryName: doc['name']),
                            ));
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ManageToolsListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const ManageToolsListScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  State<ManageToolsListScreen> createState() => _ManageToolsListScreenState();
}

class _ManageToolsListScreenState extends State<ManageToolsListScreen> {
  final TextEditingController _itemNameCtrl = TextEditingController();
  PlatformFile? _pickedImage;
  PlatformFile? _pickedAudio;
  bool _isUploading = false;
  String _selectedToolType = 'Flowers';

  final List<String> _toolTypes = ['Flowers', 'Dhanda', 'Tools'];

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null) setState(() => _pickedImage = res.files.first);
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio, withData: true);
    if (res != null) setState(() => _pickedAudio = res.files.first);
  }

  Future<void> _addItem() async {
    if (_itemNameCtrl.text.isEmpty || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Image are required!")));
      return;
    }
    setState(() => _isUploading = true);

    try {
      final imgRef = FirebaseStorage.instance.ref().child('pooja_tools/${DateTime.now().millisecondsSinceEpoch}.${_pickedImage!.extension ?? 'jpg'}');
      await imgRef.putData(_pickedImage!.bytes!);
      final imgUrl = await imgRef.getDownloadURL();

      String? audioUrl;
      if (_pickedAudio != null) {
        final audRef = FirebaseStorage.instance.ref().child('pooja_tools/${DateTime.now().millisecondsSinceEpoch}.${_pickedAudio!.extension ?? 'mp3'}');
        await audRef.putData(_pickedAudio!.bytes!);
        audioUrl = await audRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('pooja_tools_items').add({
        'name': _itemNameCtrl.text.trim(),
        'category_id': widget.categoryId,
        'tool_type': _selectedToolType,
        'image_url': imgUrl,
        'audio_url': audioUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      _itemNameCtrl.clear();
      setState(() {
        _pickedImage = null;
        _pickedAudio = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tool Added Successfully!")));
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _editTool(BuildContext context, DocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditToolScreen(doc: doc)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tools in ${widget.categoryName}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add New Tool", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(controller: _itemNameCtrl, decoration: const InputDecoration(labelText: "Tool Name", border: OutlineInputBorder())),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _selectedToolType,
                            decoration: const InputDecoration(labelText: "Tool Type", border: OutlineInputBorder()),
                            items: _toolTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (val) => setState(() => _selectedToolType = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.image),
                              label: const Text("Pick Image (Required)"),
                              onPressed: _pickImage,
                            ),
                            const SizedBox(height: 8),
                            if (_pickedImage != null && _pickedImage!.bytes != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_pickedImage!.bytes!, width: 80, height: 80, fit: BoxFit.cover),
                              )
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.audiotrack),
                              label: const Text("Pick Sound (Optional)"),
                              onPressed: _pickAudio,
                            ),
                            const SizedBox(height: 8),
                            if (_pickedAudio != null)
                              Text(_pickedAudio!.name, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _isUploading 
                        ? const CircularProgressIndicator() 
                        : ElevatedButton(
                            onPressed: _addItem, 
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                            child: const Text("Add Tool", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text("Added Tools:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('pooja_tools_items').where('category_id', isEqualTo: widget.categoryId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text("No tools added yet."));
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: data['image_url'] != null
                                      ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(data['image_url'], fit: BoxFit.contain))
                                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: Text(data['tool_type'] ?? 'Flowers', style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                  ),
                                  if (data['audio_url'] != null) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.audiotrack, size: 14, color: Colors.green),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(height: 1, thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                    onPressed: () => _editTool(context, doc),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    tooltip: "Edit Tool",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                    onPressed: () => doc.reference.delete(),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    tooltip: "Delete Tool",
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
}

class EditToolScreen extends StatefulWidget {
  final DocumentSnapshot doc;
  const EditToolScreen({Key? key, required this.doc}) : super(key: key);

  @override
  State<EditToolScreen> createState() => _EditToolScreenState();
}

class _EditToolScreenState extends State<EditToolScreen> {
  late TextEditingController _itemNameCtrl;
  String _selectedToolType = 'Flowers';
  PlatformFile? _pickedImage;
  PlatformFile? _pickedAudio;
  bool _isUploading = false;
  final List<String> _toolTypes = ['Flowers', 'Dhanda', 'Tools'];

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    _itemNameCtrl = TextEditingController(text: data['name'] ?? '');
    String currentType = data['tool_type'] ?? 'Flowers';
    if (!_toolTypes.contains(currentType)) currentType = 'Flowers';
    _selectedToolType = currentType;
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res != null) setState(() => _pickedImage = res.files.first);
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.audio, withData: true);
    if (res != null) setState(() => _pickedAudio = res.files.first);
  }

  Future<void> _updateItem() async {
    if (_itemNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name is required!")));
      return;
    }
    setState(() => _isUploading = true);

    try {
      final data = widget.doc.data() as Map<String, dynamic>;
      String? imgUrl = data['image_url'];
      String? audioUrl = data['audio_url'];

      if (_pickedImage != null) {
        final imgRef = FirebaseStorage.instance.ref().child('pooja_tools/${DateTime.now().millisecondsSinceEpoch}.${_pickedImage!.extension ?? 'jpg'}');
        await imgRef.putData(_pickedImage!.bytes!);
        imgUrl = await imgRef.getDownloadURL();
      }

      if (_pickedAudio != null) {
        final audRef = FirebaseStorage.instance.ref().child('pooja_tools/${DateTime.now().millisecondsSinceEpoch}.${_pickedAudio!.extension ?? 'mp3'}');
        await audRef.putData(_pickedAudio!.bytes!);
        audioUrl = await audRef.getDownloadURL();
      }

      await widget.doc.reference.update({
        'name': _itemNameCtrl.text.trim(),
        'tool_type': _selectedToolType,
        if (imgUrl != null) 'image_url': imgUrl,
        if (audioUrl != null) 'audio_url': audioUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tool Updated Successfully!")));
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
      appBar: AppBar(title: const Text("Edit Tool")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(controller: _itemNameCtrl, decoration: const InputDecoration(labelText: "Tool Name", border: OutlineInputBorder())),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedToolType,
                    decoration: const InputDecoration(labelText: "Tool Type", border: OutlineInputBorder()),
                    items: _toolTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _selectedToolType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Text("Current Image:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (data['image_url'] != null)
                      Image.network(data['image_url'], width: 80, height: 80, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Replace Image"),
                      onPressed: _pickImage,
                    ),
                    if (_pickedImage != null)
                      const Text("New image selected", style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    const Text("Current Audio:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(data['audio_url'] != null ? "Yes" : "No", style: TextStyle(color: data['audio_url'] != null ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.audiotrack),
                      label: const Text("Replace Audio"),
                      onPressed: _pickAudio,
                    ),
                    if (_pickedAudio != null)
                      const Text("New audio selected", style: TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
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
}

