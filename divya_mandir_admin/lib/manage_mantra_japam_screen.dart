import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class ManageMantraJapamScreen extends StatefulWidget {
  const ManageMantraJapamScreen({super.key});

  @override
  State<ManageMantraJapamScreen> createState() => _ManageMantraJapamScreenState();
}

class _ManageMantraJapamScreenState extends State<ManageMantraJapamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _collection = FirebaseFirestore.instance.collection('mantralu');
  final _settingsDoc = FirebaseFirestore.instance.collection('app_settings').doc('mantra_japam');

  bool _isSectionEnabled = true;
  bool _isLoading = true;
  String _searchQuery = '';
  final String _selectedDeity = 'అన్నీ';

  final TextEditingController _jsonUploadCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSectionSettings();
  }

  Future<void> _loadSectionSettings() async {
    try {
      final snap = await _settingsDoc.get();
      if (snap.exists) {
        final data = snap.data();
        setState(() {
          _isSectionEnabled = data?['isEnabled'] ?? true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSection(bool val) async {
    setState(() => _isSectionEnabled = val);
    await _settingsDoc.set({'isEnabled': val}, SetOptions(merge: true));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(val ? 'మంత్ర జపం సెక్షన్ యూజర్ యాప్‌లో ఆన్ అయింది' : 'మంత్ర జపం సెక్షన్ ఆఫ్ అయింది')),
      );
    }
  }

  Future<void> _seedDefaultMantras() async {
    final list = [
      {
        'id': 'om_namah_shivaya',
        'name': 'ఓం నమః శివాయ',
        'deity': 'మహాశివుడు',
        'audioUrl': 'https://archive.org/download/OmNamahShivaya108_201602/Om%20Namah%20Shivaya%20108.mp3',
        'meaning': 'పంచాక్షరీ మంత్రం. మనస్సునకు ప్రశాంతత, సకల పాపహరణం, ఆయురారోగ్యములు చేకూరుస్తుంది.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 1,
      },
      {
        'id': 'gayatri_mantram',
        'name': 'గాయత్రీ మంత్రం',
        'deity': 'గాయత్రీ దేవి',
        'audioUrl': 'https://archive.org/download/GayatriMantra_201509/Gayatri%20Mantra.mp3',
        'meaning': 'ఓం భూర్భువః స్వః తత్సవితుర్వరేణ్యం భర్గో దేవస్య ధీమహి ధియో యో నః ప్రచోదయాత్. సకల జ్ఞాన ప్రదాయిని.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 2,
      },
      {
        'id': 'maha_mrityunjaya',
        'name': 'మహా మృత్యుంజయ మంత్రం',
        'deity': 'రుద్రుడు / శివుడు',
        'audioUrl': 'https://archive.org/download/MahaMrityunjayaMantra108Times/MahaMrityunjayaMantra108Times.mp3',
        'meaning': 'ఓం త్రయంబకం యజామహే సుగంధిం పుష్టివర్ధనం. అపమృత్యు నివారణ, దీర్ఘాయువు ప్రసాదించు దివ్య మంత్రం.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 3,
      },
      {
        'id': 'hare_krishna_maha_mantra',
        'name': 'హరే కృష్ణ మహా మంత్రం',
        'deity': 'శ్రీకృష్ణుడు',
        'audioUrl': 'https://archive.org/download/HareKrishnaMahaMantra108/Hare%20Krishna.mp3',
        'meaning': 'హరే కృష్ణ హరే కృష్ణ కృష్ణ కృష్ణ హరే హరే, హరే రామ హరే రామ రామ రామ హరే హరే. కలియుగంలో భక్తి ముక్తి ప్రదాయకం.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 4,
      },
      {
        'id': 'om_namo_venkateshaya',
        'name': 'ఓం నమో వేంకటేశాయ',
        'deity': 'శ్రీ వేంకటేశ్వర స్వామి',
        'audioUrl': 'https://archive.org/download/GovindaNamalu/Om%20Namo%20Venkateshaya.mp3',
        'meaning': 'కలియుగ వైకుంఠనాథుని దివ్య అష్టాక్షరీ నామ జపం. సర్వ సంపదలు, కష్ట నివారణ.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 5,
      },
      {
        'id': 'om_gam_ganapataye_namaha',
        'name': 'ఓం గం గణపతయే నమః',
        'deity': 'గణపతి స్వామి',
        'audioUrl': 'https://archive.org/download/GaneshMantra108/Om%20Gam%20Ganapataye.mp3',
        'meaning': 'సర్వ విఘ్న నివారక బీజాక్షర మంత్రం. సకల కార్యసిద్ధి, నూతన ప్రారంభములకు ఉత్తమం.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 6,
      },
      {
        'id': 'sri_rama_jaya_rama',
        'name': 'శ్రీరామ జయరామ జయ జయ రామ',
        'deity': 'శ్రీరామ చంద్రుడు',
        'audioUrl': 'https://archive.org/download/SriRamaJayaRama/Sri%20Rama.mp3',
        'meaning': 'రామ తారక మంత్ర జపం. మానసిక శాంతి, భయ నివారణ, దివ్య రక్షణ లభిస్తుంది.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 7,
      },
      {
        'id': 'om_dum_durgayai_namaha',
        'name': 'ఓం దుం దుర్గాయై నమః',
        'deity': 'దుర్గా దేవి',
        'audioUrl': 'https://archive.org/download/DurgaMantra/Durga%20Mantra.mp3',
        'meaning': 'దుర్గతి నాశిని నవదుర్గల ఆశీస్సులు, దైవ రక్షణ మరియు శత్రు భయ నివారణ.',
        'defaultTargetCount': 108,
        'loopDelayMs': 0,
        'isActive': true,
        'order': 8,
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final m in list) {
        final docRef = _collection.doc(m['id'] as String);
        batch.set(docRef, m, SetOptions(merge: true));
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('8 ప్రామాణిక మంత్రాలు Firestore లోకి విజయవంతంగా లోడ్ అయ్యాయి!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openMantraDialog(BuildContext context, [DocumentSnapshot? doc]) {
    final isEditing = doc != null;
    final data = isEditing ? doc.data() as Map<String, dynamic> : null;

    final nameCtrl = TextEditingController(text: data?['name'] ?? '');
    final deityCtrl = TextEditingController(text: data?['deity'] ?? 'మహాశివుడు');
    final audioUrlCtrl = TextEditingController(text: data?['audioUrl'] ?? '');
    final meaningCtrl = TextEditingController(text: data?['meaning'] ?? '');
    final targetCountCtrl = TextEditingController(text: (data?['defaultTargetCount'] ?? 108).toString());
    final delayCtrl = TextEditingController(text: (data?['loopDelayMs'] ?? 0).toString());
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());

    bool isActive = data?['isActive'] ?? true;
    Uint8List? pickedAudioBytes;
    String? pickedAudioName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> pickAudioFile() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
                withData: true,
              );
              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;
                if (file.bytes != null) {
                  setDialogState(() {
                    pickedAudioBytes = file.bytes;
                    pickedAudioName = file.name;
                  });
                }
              }
            } catch (e) {
              if (dialogCtx.mounted) {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(
                  SnackBar(content: Text('Audio Pick Error: $e')),
                );
              }
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(isEditing ? Icons.edit : Icons.add_circle, color: const Color(0xFF6A1B29)),
                const SizedBox(width: 8),
                Text(
                  isEditing ? "మంత్రం సవరించండి (Edit Mantra)" : "కొత్త మంత్రం జోడించండి (Add Mantra)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 580,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mantra Recitation Text
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "మంత్రం పాఠం (Mantra Text) *",
                        hintText: "ఉదా: ఓం నమః శివాయ",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.record_voice_over),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Deity & Target Count
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: deityCtrl,
                            decoration: const InputDecoration(
                              labelText: "దేవత (Deity / God) *",
                              hintText: "ఉదా: మహాశివుడు / గాయత్రీ దేవి",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.wb_sunny_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: targetCountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "లక్ష్య సంఖ్య (Target Count) *",
                              hintText: "108 / 11 / 21 / 1008",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.format_list_numbered),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Audio URL or File Picker
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: audioUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: "ఆడియో లింక్ (Audio URL)",
                              hintText: "https://.../om_namah_shivaya.mp3",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.audiotrack_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B29),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          ),
                          onPressed: pickAudioFile,
                          icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                          label: const Text("ఆడియో అప్‌లోడ్", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    if (pickedAudioName != null) ...[
                      const SizedBox(height: 6),
                      Text("ఎంచుకున్న ఆడియో ఫైల్: $pickedAudioName (సిద్ధంగా ఉంది)",
                          style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],

                    const SizedBox(height: 12),

                    // Delay between loops & Order
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: delayCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "లూప్ ఆలస్యం (Delay in Ms) - 0 = నో డిలే",
                              hintText: "0 ms for continuous seamless",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: orderCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "క్రమ సంఖ్య (Order)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.sort),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Meaning & Benefits
                    TextField(
                      controller: meaningCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "మంత్ర మహత్యం & ఫలం (Meaning & Benefits) *",
                        hintText: "ఈ మంత్ర జపం వలన కలిగే ఆధ్యాత్మిక మరియు మానసిక ఫలితాలు నమోదు చేయండి...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Active Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("యాక్టివ్ (Active Status)", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text("యూజర్ యాప్‌లో ప్రదర్శించు"),
                      value: isActive,
                      activeThumbColor: const Color(0xFF6A1B29),
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(dialogCtx),
                child: const Text("రద్దు చేయండి (Cancel)"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                onPressed: isUploading
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('దయచేసి మంత్రం పాఠం నమోదు చేయండి.')),
                          );
                          return;
                        }

                        setDialogState(() => isUploading = true);

                        String aUrl = audioUrlCtrl.text.trim();
                        if (pickedAudioBytes != null) {
                          try {
                            final fileName = "mantra_${DateTime.now().millisecondsSinceEpoch}_$pickedAudioName";
                            final ref = FirebaseStorage.instance.ref().child("mantralu/$fileName");
                            final task = await ref.putData(
                              pickedAudioBytes!,
                              SettableMetadata(contentType: 'audio/mpeg'),
                            );
                            aUrl = await task.ref.getDownloadURL();
                          } catch (e) {
                            debugPrint("Storage error: $e");
                          }
                        }

                        final mantraData = {
                          'name': name,
                          'deity': deityCtrl.text.trim(),
                          'audioUrl': aUrl,
                          'meaning': meaningCtrl.text.trim(),
                          'defaultTargetCount': int.tryParse(targetCountCtrl.text) ?? 108,
                          'loopDelayMs': int.tryParse(delayCtrl.text) ?? 0,
                          'order': int.tryParse(orderCtrl.text) ?? 0,
                          'isActive': isActive,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        try {
                          if (isEditing) {
                            await _collection.doc(doc.id).update(mantraData);
                          } else {
                            mantraData['createdAt'] = FieldValue.serverTimestamp();
                            await _collection.add(mantraData);
                          }
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'మంత్రం సవరించబడింది!' : 'కొత్త మంత్రం జోడించబడింది!'),
                            ),
                          );
                        } catch (e) {
                          if (dialogCtx.mounted) {
                            ScaffoldMessenger.of(dialogCtx).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (dialogCtx.mounted) setDialogState(() => isUploading = false);
                        }
                      },
                child: isUploading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEditing ? "సేవ్ చేయండి (Save)" : "జోడించండి (Add)", style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteMantra(BuildContext context, DocumentSnapshot doc) async {
    final name = (doc.data() as Map<String, dynamic>?)?['name'] ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('తొలగించాలా? (Delete)'),
        content: Text("మీరు '$name' మంత్రాన్ని ఖచ్చితంగా తొలగించాలనుకుంటున్నారా?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('రద్దు')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('తొలగించు', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _collection.doc(doc.id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('మంత్రం తొలగించబడింది.')));
      }
    }
  }

  Future<void> _handleJsonImport() async {
    final text = _jsonUploadCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('దయచేసి JSON డేటా నమోదు చేయండి.')));
      return;
    }

    try {
      final decoded = json.decode(text);
      if (decoded is! List) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON తప్పనిసరిగా List అయి ఉండాలి.')));
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString() ?? _collection.doc().id;
          final docRef = _collection.doc(id);
          batch.set(docRef, {
            'name': item['name'] ?? '',
            'deity': item['deity'] ?? '',
            'audioUrl': item['audioUrl'] ?? '',
            'meaning': item['meaning'] ?? '',
            'defaultTargetCount': item['defaultTargetCount'] ?? 108,
            'loopDelayMs': item['loopDelayMs'] ?? 0,
            'isActive': item['isActive'] ?? true,
            'order': item['order'] ?? 0,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      await batch.commit();
      _jsonUploadCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('మంత్రాలు విజయవంతంగా JSON నుండి ఇంపోర్ట్ అయ్యాయి!')),
        );
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('JSON Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manage Mantra Japam (మంత్ర జపం నిర్వహణ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B29),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.format_list_bulleted), text: "మంత్రాల జాబితా (Mantra List)"),
            Tab(icon: Icon(Icons.code), text: "JSON బల్క్ అప్‌లోడ్ (Bulk Import)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMantraListTab(),
          _buildJsonUploadTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A1B29),
        onPressed: () => _openMantraDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("కొత్త మంత్రం (Add Mantra)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMantraListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Switch Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEFD9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.self_improvement, color: Color(0xFF6A1B29), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "యూజర్ యాప్ హోమ్‌పేజీలో మంత్ర జపం సెక్షన్",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          _isSectionEnabled ? "ప్రస్తుతం హోమ్‌పేజీలో కనిపిస్తోంది (Active)" : "హోమ్‌పేజీ నుండి దాచబడింది (Hidden)",
                          style: TextStyle(fontSize: 12, color: _isSectionEnabled ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isSectionEnabled,
                    activeThumbColor: const Color(0xFF6A1B29),
                    onChanged: _toggleSection,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Toolbar: Search + Seed 8 Default Mantras
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "మంత్రం లేదా దేవుని పేరుతో వెతకండి...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A1E2B),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _seedDefaultMantras,
                icon: const Icon(Icons.auto_fix_high, color: Colors.white, size: 18),
                label: const Text("8 ప్రామాణిక మంత్రాలు లోడ్ చేయండి", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Live Firestore Stream List
          StreamBuilder<QuerySnapshot>(
            stream: _collection.orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
              }

              final docs = snapshot.data?.docs ?? [];
              final filtered = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final deity = (data['deity'] ?? '').toString().toLowerCase();
                final q = _searchQuery.toLowerCase().trim();
                final matchesSearch = q.isEmpty || name.contains(q) || deity.contains(q);
                final matchesDeity = (_selectedDeity == 'అన్నీ' || data['deity'] == _selectedDeity);
                return matchesSearch && matchesDeity;
              }).toList();

              if (filtered.isEmpty) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        "మంత్రాలు ఏవీ లేవు. '8 ప్రామాణిక మంత్రాలు లోడ్ చేయండి' పై క్లిక్ చేయండి లేదా '+' బటన్ నొక్కండి.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                );
              }

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, idx) {
                    final doc = filtered[idx];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] ?? '';
                    final deity = data['deity'] ?? '';
                    final target = data['defaultTargetCount'] ?? 108;
                    final audioUrl = data['audioUrl'] ?? '';
                    final delay = data['loopDelayMs'] ?? 0;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEFD9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF0C28A)),
                        ),
                        alignment: Alignment.center,
                        child: const Text("ॐ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8A1E2B))),
                      ),
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                      subtitle: Text("దేవత: $deity • లక్ష్యం: $target • లూప్ డిలే: ${delay}ms\nఆడియో: ${audioUrl.isEmpty ? 'ఆడియో లేదు' : 'లింక్ చేయబడింది'}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            tooltip: "సవరించు (Edit)",
                            onPressed: () => _openMantraDialog(context, doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: "తొలగించు (Delete)",
                            onPressed: () => _deleteMantra(context, doc),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJsonUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "మంత్రాల బల్క్ ఇంపోర్ట్ (Bulk JSON Import)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "క్రింది ఫార్మాట్‌లో JSON లిస్ట్ పేస్ట్ చేసి ఒకేసారి అనేక మంత్రాలు Firestore లోకి అప్‌లోడ్ చేయవచ్చు:",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jsonUploadCtrl,
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '[\n  {\n    "id": "om_namah_shivaya",\n    "name": "ఓం నమః శివాయ",\n    "deity": "శివుడు",\n    "audioUrl": "https://...",\n    "meaning": "...",\n    "defaultTargetCount": 108,\n    "loopDelayMs": 0,\n    "isActive": true,\n    "order": 1\n  }\n]',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B29),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: _handleJsonImport,
            icon: const Icon(Icons.upload, color: Colors.white),
            label: const Text("JSON డేటా ఇంపోర్ట్ చేయండి", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
