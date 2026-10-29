import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRashiPalaluScreen extends StatefulWidget {
  const ManageRashiPalaluScreen({super.key});

  @override
  State<ManageRashiPalaluScreen> createState() => _ManageRashiPalaluScreenState();
}

class _ManageRashiPalaluScreenState extends State<ManageRashiPalaluScreen> with SingleTickerProviderStateMixin {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('daily_rashi_palalu');
  final DocumentReference _settingsDoc = FirebaseFirestore.instance.collection('app_settings').doc('rashi_palalu');

  late TabController _tabController;
  final TextEditingController _apiKeyCtrl = TextEditingController();
  final TextEditingController _apiEndpointCtrl = TextEditingController();
  final TextEditingController _jsonUploadCtrl = TextEditingController();

  bool _useProkeralaApi = false;
  bool _isSectionEnabled = true;
  bool _isLoading = true;

  final List<Map<String, String>> _rashis = const [
    {'id': 'mesha', 'name': 'మేష (Aries)'},
    {'id': 'vrushabha', 'name': 'వృషభ (Taurus)'},
    {'id': 'mithuna', 'name': 'మిథున (Gemini)'},
    {'id': 'karkataka', 'name': 'కర్కాటక (Cancer)'},
    {'id': 'simha', 'name': 'సింహ (Leo)'},
    {'id': 'kanya', 'name': 'కన్య (Virgo)'},
    {'id': 'tula', 'name': 'తులా (Libra)'},
    {'id': 'vruschika', 'name': 'వృశ్చిక (Scorpio)'},
    {'id': 'dhanussu', 'name': 'ధనుస్సు (Sagittarius)'},
    {'id': 'makara', 'name': 'మకర (Capricorn)'},
    {'id': 'kumbha', 'name': 'కుంభ (Aquarius)'},
    {'id': 'meena', 'name': 'మీన (Pisces)'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final snap = await _settingsDoc.get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>?;
        setState(() {
          _isSectionEnabled = data?['isEnabled'] ?? true;
          _useProkeralaApi = data?['useProkeralaApi'] ?? false;
          _apiKeyCtrl.text = data?['prokeralaApiKey'] ?? '';
          _apiEndpointCtrl.text = data?['prokeralaApiEndpoint'] ?? 'https://api.prokerala.com/v2/astrology/horoscope/daily';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _settingsDoc.set({
        'isEnabled': _isSectionEnabled,
        'useProkeralaApi': _useProkeralaApi,
        'prokeralaApiKey': _apiKeyCtrl.text.trim(),
        'prokeralaApiEndpoint': _apiEndpointCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API & రాశిఫలాల సెట్టింగ్స్ విజయవంతంగా సేవ్ అయ్యాయి!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _importJsonData() async {
    final text = _jsonUploadCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('దయచేసి JSON డేటాను ఎంటర్ చేయండి.')));
      return;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        final batch = FirebaseFirestore.instance.batch();
        decoded.forEach((key, val) {
          if (val is Map<String, dynamic>) {
            final doc = _collection.doc(key);
            batch.set(doc, val, SetOptions(merge: true));
          }
        });
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('JSON నుండి 12 రాశుల డేటా ఫైర్‌స్టోర్‌లో విజయవంతంగా అప్‌డేట్ అయింది!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('JSON Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiKeyCtrl.dispose();
    _apiEndpointCtrl.dispose();
    _jsonUploadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        title: const Text(
          "Rashi Palalu Management (రాశిఫలాల నియంత్రణ)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF1C40F),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.api_rounded), text: "Prokerala API సెట్టింగ్స్"),
            Tab(icon: Icon(Icons.edit_note_rounded), text: "12 రాశుల ఫలితాలు (Manual)"),
            Tab(icon: Icon(Icons.upload_file_rounded), text: "JSON డేటా అప్‌లోడ్"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: API SETTINGS
                _buildApiSettingsTab(),

                // TAB 2: MANUAL 12 RASHIS
                _buildManualRashisTab(),

                // TAB 3: JSON UPLOAD
                _buildJsonUploadTab(),
              ],
            ),
    );
  }

  // --- TAB 1: API SETTINGS ---
  Widget _buildApiSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SwitchListTile(
              title: const Text(
                "యూజర్ యాప్ హోమ్‌పేజీలో 'రాశిఫలాలు' సెక్షన్ చూపించాలా?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_isSectionEnabled ? "కనిపిస్తుంది (Active)" : "దాచబడింది (Hidden)"),
              value: _isSectionEnabled,
              activeColor: const Color(0xFF6A1B29),
              onChanged: (val) => setState(() => _isSectionEnabled = val),
            ),
          ),
          const SizedBox(height: 16),

          // Prokerala API Switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                    "Prokerala Horoscope API ని ఎనేబుల్ చేయాలా?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("ఆన్ చేస్తే Prokerala నుండి రియల్ టైమ్ డేటా వస్తుంది. ఆఫ్ చేస్తే మాన్యువల్ డేటా వస్తుంది."),
                  value: _useProkeralaApi,
                  activeColor: const Color(0xFF6A1B29),
                  onChanged: (val) => setState(() => _useProkeralaApi = val),
                ),
                const Divider(),
                const SizedBox(height: 10),
                TextField(
                  controller: _apiKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: "Prokerala Client ID / API Key",
                    hintText: "ఎంటర్ చేయండి...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _apiEndpointCtrl,
                  decoration: const InputDecoration(
                    labelText: "API Endpoint URL",
                    hintText: "https://api.prokerala.com/v2/astrology/horoscope/daily",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text("API సెట్టింగ్స్ సేవ్ చేయండి (Save)"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: MANUAL 12 RASHIS EDITING ---
  Widget _buildManualRashisTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rashis.length,
      itemBuilder: (context, i) {
        final r = _rashis[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFF0ED),
              child: Text("${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
            ),
            title: Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("రాశి ID: ${r['id']}"),
            trailing: const Icon(Icons.edit, color: Color(0xFF6A1B29)),
            onTap: () => _openEditRashiModal(context, r['id']!, r['name']!),
          ),
        );
      },
    );
  }

  void _openEditRashiModal(BuildContext context, String rashiId, String rashiName) {
    final genCtrl = TextEditingController();
    final careerCtrl = TextEditingController();
    final financeCtrl = TextEditingController();
    final luckyCtrl = TextEditingController(text: '9, 3');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("$rashiName - ఫలితాలు ఎడిట్ చేయండి", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: genCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "సాధారణ ఫలితం (General)", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: careerCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "ఉద్యోగం / వ్యాపారం (Career)", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: financeCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "ఆర్థికం (Finance)", border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: luckyCtrl, decoration: const InputDecoration(labelText: "అదృష్ట సంఖ్యలు", border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("రద్దు చేయి")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
              onPressed: () async {
                await _collection.doc(rashiId).set({
                  'general': genCtrl.text.trim(),
                  'career': careerCtrl.text.trim(),
                  'finance': financeCtrl.text.trim(),
                  'luckyNumber': luckyCtrl.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$rashiName డేటా సేవ్ అయింది!')),
                  );
                }
              },
              child: const Text("సేవ్ చేయి", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 3: JSON DATA UPLOAD ---
  Widget _buildJsonUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "12 రాశుల డేటాను JSON ఫార్మాట్‌లో ఒకేసారి అప్‌లోడ్ చేయండి:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _jsonUploadCtrl,
            maxLines: 12,
            decoration: InputDecoration(
              hintText: '{\n  "mesha": {\n    "general": "నేటి ఫలితం...",\n    "luckyNumber": "9, 3"\n  }\n}',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B29),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: _importJsonData,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text("JSON డేటా సేవ్ & అప్‌డేట్ చేయండి (Import)"),
          ),
        ],
      ),
    );
  }
}
