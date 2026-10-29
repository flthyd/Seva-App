import re

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_class = '''class ManageCollectionScreen extends StatelessWidget {
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

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddItemDialog(
        collectionName: collectionName,
        hasImage: hasImage,
        hasAudio: hasAudio,
        hasGodDropdown: hasGodDropdown,
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
      await FirebaseFirestore.instance.collection(collectionName).doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted successfully.")));
    }
  }

  void _toggleActive(String docId, bool currentStatus) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).update({
      'is_active': !currentStatus,
    });
  }'''

new_class = '''class ManageCollectionScreen extends StatefulWidget {
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
  }'''

content = content.replace(old_class, new_class)

old_build = '''  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
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
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection(collectionName).orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No items found. Click 'Add New Item' to get started."));
                }

                final docs = snapshot.data!.docs;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
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
                      onTap: collectionName == 'gods' ? () {
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
                                if (hasGodDropdown && godName != null) 
                                  Text("God: \", style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Switch(
                                          value: isActive,
                                          onChanged: (val) => _toggleActive(docId, isActive),
                                          activeColor: const Color(0xFF6A1B29),
                                        ),
                                        Text(isActive ? "Active" : "Inactive", style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.red)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
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
}'''

new_build = '''  @override
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
                          subtitle: widget.hasGodDropdown && godName != null ? Text("God: \") : null,
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
                    crossAxisCount: 8,
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
                                  Text("God: \", style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Switch(
                                          value: isActive,
                                          onChanged: (val) => _toggleActive(docId, isActive),
                                          activeColor: const Color(0xFF6A1B29),
                                        ),
                                        Text(isActive ? "Active" : "Inactive", style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.red)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
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
}'''

content = content.replace(old_build, new_build)

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(content)
