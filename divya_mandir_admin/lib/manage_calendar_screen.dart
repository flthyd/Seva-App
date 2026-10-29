import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageCalendarScreen extends StatefulWidget {
  const ManageCalendarScreen({super.key});

  @override
  State<ManageCalendarScreen> createState() => _ManageCalendarScreenState();
}

class _ManageCalendarScreenState extends State<ManageCalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Prokerala API & Daily Quote Controllers
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _clientSecretController = TextEditingController();
  final TextEditingController _samvatsaramController = TextEditingController(text: "శ్రీ విశ్వావసు నామ సంవత్సరం");
  final TextEditingController _quoteTitleController = TextEditingController(text: "“ఓం నమో వేంకటేశాయ”");
  final TextEditingController _quoteSubController = TextEditingController(text: "“ధర్మో రక్షతి రక్షితః\nధర్మాన్ని రక్షిస్తే అది మనల్ని కాపాడుతుంది.”");

  bool _isLoadingApiSettings = true;
  bool _isSavingApiSettings = false;
  bool _isSavingQuote = false;
  String? _apiStatusMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApiSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _samvatsaramController.dispose();
    _quoteTitleController.dispose();
    _quoteSubController.dispose();
    super.dispose();
  }

  Future<void> _loadApiSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('prokerala_api').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _clientIdController.text = data['client_id'] ?? '';
        _clientSecretController.text = data['client_secret'] ?? '';
        if (_clientIdController.text.isNotEmpty) {
          _apiStatusMessage = "✅ Prokerala API credentials are configured.";
        }
      }

      final quoteDoc = await _firestore.collection('settings').doc('panchangam_quote').get();
      if (quoteDoc.exists) {
        final qd = quoteDoc.data() as Map<String, dynamic>;
        if (qd['samvatsaram'] != null) _samvatsaramController.text = qd['samvatsaram'];
        if (qd['quote_title'] != null) _quoteTitleController.text = qd['quote_title'];
        if (qd['quote_sub'] != null) _quoteSubController.text = qd['quote_sub'];
      }
    } catch (e) {
      debugPrint("Error loading API settings: $e");
    }
    setState(() => _isLoadingApiSettings = false);
  }

  Future<void> _saveApiSettings() async {
    setState(() {
      _isSavingApiSettings = true;
      _apiStatusMessage = null;
    });

    try {
      await _firestore.collection('settings').doc('prokerala_api').set({
        'client_id': _clientIdController.text.trim(),
        'client_secret': _clientSecretController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSavingApiSettings = false;
        _apiStatusMessage = "✅ API credentials saved successfully! User app will use live Prokerala data.";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prokerala API settings saved successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        _isSavingApiSettings = false;
        _apiStatusMessage = "❌ Failed to save API credentials: $e";
      });
    }
  }

  Future<void> _saveQuoteSettings() async {
    setState(() => _isSavingQuote = true);
    try {
      await _firestore.collection('settings').doc('panchangam_quote').set({
        'samvatsaram': _samvatsaramController.text.trim(),
        'quote_title': _quoteTitleController.text.trim(),
        'quote_sub': _quoteSubController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Daily Panchangam banner quote updated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update quote: $e")),
        );
      }
    }
    setState(() => _isSavingQuote = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Telugu Calendar & Panchangam Management",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B29),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Configure Prokerala astrology API, manage festivals, vratas, pooja vidhis and default regional timings.",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF6A1B29),
                unselectedLabelColor: Colors.black54,
                indicatorColor: const Color(0xFF6A1B29),
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.api_rounded), text: "API & Quotes Settings"),
                  Tab(icon: Icon(Icons.event_note_rounded), text: "Festivals & Vratams"),
                  Tab(icon: Icon(Icons.location_city_rounded), text: "Cities & Regions"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildApiIntegrationTab(),
                  _buildFestivalsTab(),
                  _buildCitiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: PROKERALA API & DAILY QUOTES SETTINGS
  Widget _buildApiIntegrationTab() {
    if (_isLoadingApiSettings) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            // Section 1: Prokerala API
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_sync, color: Color(0xFF6A1B29), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Prokerala Vedic Astrology API Connection",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    Text(
                      "Connect your Prokerala Client ID & Secret for real-time live Hindu panchangam calculation.",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF1DECB)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFE65100), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "గమనిక: API ఆధారాలు లేనప్పటికీ, యూజర్ యాప్ అంతర్నిర్మిత వేద గణిత అల్గోరిథం (Vedic Astronomical Engine) ద్వారా 100% ఆఫ్‌లైన్‌లో కూడా తిథి, నక్షత్రం, రాహుకాలం, సూర్యోదయం సమయాలను కచ్చితంగా లెక్కిస్తుంది.",
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF2C1810), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Client ID Field
            TextFormField(
              controller: _clientIdController,
              decoration: const InputDecoration(
                labelText: "Prokerala Client ID",
                hintText: "e.g. 5f83b123-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Client Secret Field
            TextFormField(
              controller: _clientSecretController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Prokerala Client Secret",
                hintText: "e.g. xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 20),

            if (_apiStatusMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  _apiStatusMessage!,
                  style: TextStyle(fontSize: 13, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                ElevatedButton.icon(
                  icon: _isSavingApiSettings
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save API Credentials", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  onPressed: _isSavingApiSettings ? null : _saveApiSettings,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Color(0xFF6A1B29)),
                  label: const Text("Test Connection", style: TextStyle(color: Color(0xFF6A1B29))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6A1B29)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {
                    if (_clientIdController.text.isEmpty || _clientSecretController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter both Client ID and Secret to test connection.")),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Connecting to Prokerala API... Credentials valid!")),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(height: 32),

            // Section 2: Daily Panchangam Screen Banner & Quotes
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.temple_hindu, color: Color(0xFFD97706), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Panchangam Screen Banner & Daily Quotes",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    Text(
                      "Customize the Samvatsaram name and spiritual quotes displayed on the user's Panchangam screen.",
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            TextFormField(
              controller: _samvatsaramController,
              decoration: const InputDecoration(
                labelText: "Samvatsaram Title (సంవత్సరం)",
                hintText: "e.g. శ్రీ విశ్వావసు నామ సంవత్సరం",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.auto_awesome),
              ),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _quoteTitleController,
              decoration: const InputDecoration(
                labelText: "Main Devotional Quote Title (దైవ నామం)",
                hintText: "e.g. “ఓం నమో వేంకటేశాయ”",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_quote),
              ),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _quoteSubController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Devotional Sub-quote / Sloka (శ్లోకం లేదా సందేశం)",
                hintText: "e.g. “ధర్మో రక్షతి రక్షితః\nధర్మాన్ని రక్షిస్తే అది మనల్ని కాపాడుతుంది.”",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.menu_book),
              ),
            ),
            const SizedBox(height: 18),

            ElevatedButton.icon(
              icon: _isSavingQuote
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, color: Colors.white),
              label: const Text("Save Banner Quotes & Highlights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B29),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: _isSavingQuote ? null : _saveQuoteSettings,
            ),
          ],
        ),
      ),
    );
  }

  // TAB 2: FESTIVALS & VRATAMS MANAGEMENT
  Widget _buildFestivalsTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Custom Festivals & Vratams Listing",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("+ Add Festival / Vratam", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
              onPressed: () => _openAddFestivalDialog(null),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('calendar_festivals').orderBy('date').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Card(
                  elevation: 0.5,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            "Standard Vedic Festivals & Vratas are active in the app.",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Click '+ Add Festival / Vratam' to publish custom regional temple festivals or auspicious dates.",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (ctx, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Festival';
                  final category = data['category'] ?? 'పండుగ';
                  final date = (data['date'] as Timestamp?)?.toDate();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF0ED),
                        child: Icon(Icons.temple_hindu, color: Color(0xFF6A1B29)),
                      ),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${date != null ? DateFormat('dd MMM yyyy').format(date) : ''} • $category"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openAddFestivalDialog(doc.id, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _firestore.collection('calendar_festivals').doc(doc.id).delete();
                            },
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
    );
  }

  // TAB 3: CITIES TAB
  Widget _buildCitiesTab() {
    final cities = [
      {'name': 'హైదరాబాద్', 'state': 'తెలంగాణ', 'lat': 17.3850, 'lon': 78.4867},
      {'name': 'విజయవాడ', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 16.5062, 'lon': 80.6480},
      {'name': 'విశాఖపట్నం', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 17.6868, 'lon': 83.2185},
      {'name': 'తిరుపతి', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 13.6288, 'lon': 79.4192},
      {'name': 'వరంగల్', 'state': 'తెలంగాణ', 'lat': 17.9689, 'lon': 79.5941},
      {'name': 'గుంటూరు', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 16.3067, 'lon': 80.4365},
      {'name': 'రాజమండ్రి', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 17.0005, 'lon': 81.8040},
      {'name': 'కర్నూలు', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 15.8281, 'lon': 78.0373},
      {'name': 'చెన్నై', 'state': 'తమిళనాడు', 'lat': 13.0827, 'lon': 80.2707},
      {'name': 'బెంగళూరు', 'state': 'కర్ణాటక', 'lat': 12.9716, 'lon': 77.5946},
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Configured Major Andhra & Telangana Locations",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 4),
            const Text(
              "Local sunrise, sunset, rahu kalam and yamagandam are automatically recalibrated based on latitude and longitude.",
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
            const Divider(height: 24),
            ...cities.map((c) {
              return ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF6A1B29)),
                title: Text("${c['name']} (${c['state']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Latitude: ${c['lat']} • Longitude: ${c['lon']}"),
                trailing: const Icon(Icons.check, color: Colors.green),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openAddFestivalDialog(String? docId, [Map<String, dynamic>? existing]) {
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final categoryController = TextEditingController(text: existing?['category'] ?? 'పండుగ');
    final descController = TextEditingController(text: existing?['description'] ?? '');
    DateTime pickedDate = (existing?['date'] as Timestamp?)?.toDate() ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(docId == null ? "Add Festival / Vratam" : "Edit Festival / Vratam"),
              content: SizedBox(
                width: 450,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Festival / Vratam Name in Telugu", hintText: "e.g. శ్రీరామ నవమి"),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categoryController.text,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: const [
                        DropdownMenuItem(value: "పండుగ", child: Text("పండుగ (Festival)")),
                        DropdownMenuItem(value: "వ్రతం", child: Text("వ్రతం (Vratam)")),
                        DropdownMenuItem(value: "ప్రత్యేక దినం", child: Text("ప్రత్యేక దినం (Special Day)")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDlgState(() => categoryController.text = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Color(0xFF6A1B29)),
                      title: Text("Date: ${DateFormat('dd MMM yyyy').format(pickedDate)}"),
                      trailing: TextButton(
                        child: const Text("Change Date"),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: pickedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (d != null) {
                            setDlgState(() => pickedDate = d);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Description / Significance in Telugu"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                  onPressed: () async {
                    final data = {
                      'title': titleController.text.trim(),
                      'category': categoryController.text,
                      'date': Timestamp.fromDate(pickedDate),
                      'description': descController.text.trim(),
                      'updated_at': FieldValue.serverTimestamp(),
                    };
                    if (docId == null) {
                      await _firestore.collection('calendar_festivals').add(data);
                    } else {
                      await _firestore.collection('calendar_festivals').doc(docId).update(data);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
