import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rashi_models.dart';
import '../services/telugu_rashi_service.dart';
import 'rashi_palalu_detail_screen.dart';

class KnowYourRashiScreen extends StatefulWidget {
  final Function(UserAstrologyProfile profile)? onRashiConfirmed;

  const KnowYourRashiScreen({super.key, this.onRashiConfirmed});

  @override
  State<KnowYourRashiScreen> createState() => _KnowYourRashiScreenState();
}

class _KnowYourRashiScreenState extends State<KnowYourRashiScreen> with SingleTickerProviderStateMixin {
  final _service = TeluguRashiService();
  late TabController _methodTabController;

  // Method 1: By Name First Letter (పేరు మొదటి అక్షరం ప్రకారం)
  String? _selectedNameLetter;
  // Method 2: By Date of Birth (పుట్టిన తేదీ ప్రకారం)
  DateTime _selectedDob = DateTime(1998, 5, 15);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 08, minute: 30);
  bool _isBirthTimeUnknown = false; // "సమయం తెలియదు" (Birth Time Unknown option)

  // Method 3: By Nakshatram & Padam (నక్షత్రం & పాదం ప్రకారం)
  String _selectedNakshatram = 'అశ్విని';
  String _selectedPadam = '1వ పాదం';
  bool _isNakshatramUnknown = false; // "నక్షత్రం తెలియదు" (Nakshatram Unknown option)

  // Common User Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController(text: 'హైదరాబాద్');
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRelation = 'నేను (Self)';

  // Confirmed Result
  RashiDataModel? _confirmedRashi;
  bool _isSaving = false;

  // Saved Family & User Profiles List
  List<UserAstrologyProfile> _savedProfilesList = [];
  bool _isLoadingSaved = true;

  // Telugu Name Initial Letters mapped to Rashis
  final List<Map<String, dynamic>> _nameLetterGroups = [
    {'letters': ['చు', 'చే', 'చో', 'లా', 'లీ', 'లూ', 'లే', 'లో', 'ఆ'], 'rashiId': 'mesha', 'name': 'మేష'},
    {'letters': ['ఇ', 'ఉ', 'ఏ', 'ఓ', 'వా', 'వీ', 'వూ', 'వే', 'వో'], 'rashiId': 'vrushabha', 'name': 'వృషభ'},
    {'letters': ['కా', 'కీ', 'కూ', 'ఘ', 'ఙ', 'ఛ', 'కే', 'కో', 'హా'], 'rashiId': 'mithuna', 'name': 'మిథున'},
    {'letters': ['హి', 'హూ', 'హే', 'హో', 'డా', 'డీ', 'డూ', 'డే', 'డో'], 'rashiId': 'karkataka', 'name': 'కర్కాటక'},
    {'letters': ['మా', 'మీ', 'మూ', 'మే', 'మో', 'టా', 'టీ', 'టూ', 'టే'], 'rashiId': 'simha', 'name': 'సింహ'},
    {'letters': ['టో', 'పా', 'పీ', 'పూ', 'ష', 'ణ', 'ఠ', 'పే', 'పో'], 'rashiId': 'kanya', 'name': 'కన్య'},
    {'letters': ['రా', 'రీ', 'రూ', 'రే', 'రో', 'తా', 'తీ', 'తూ', 'తే'], 'rashiId': 'tula', 'name': 'తులా'},
    {'letters': ['తో', 'నా', 'నీ', 'నూ', 'నే', 'నో', 'యా', 'యీ', 'యూ'], 'rashiId': 'vruschika', 'name': 'వృశ్చిక'},
    {'letters': ['యే', 'యో', 'భా', 'భీ', 'భూ', 'ధా', 'ఫా', 'ఢా', 'భే'], 'rashiId': 'dhanussu', 'name': 'ధనుస్సు'},
    {'letters': ['భో', 'జా', 'జీ', 'ఖీ', 'ఖూ', 'ఖే', 'ఖో', 'గా', 'గీ'], 'rashiId': 'makara', 'name': 'మకర'},
    {'letters': ['గూ', 'గే', 'గో', 'సా', 'సీ', 'సూ', 'సే', 'సో', 'దా'], 'rashiId': 'kumbha', 'name': 'కుంభ'},
    {'letters': ['దీ', 'దూ', 'థ', 'ఝ', 'ఞ', 'దే', 'దో', 'చా', 'చీ'], 'rashiId': 'meena', 'name': 'మీన'},
  ];

  final List<String> _nakshatrams = [
    'అశ్విని', 'భరణి', 'కృత్తిక', 'రోహిణి', 'మృగశిర', 'ఆరుద్ర',
    'పునర్వసు', 'పుష్యమి', 'ఆశ్లేష', 'మఖ', 'పుబ్బ', 'ఉత్తర',
    'హస్త', 'చిత్త', 'స్వాతి', 'విశాఖ', 'అనూరాధ', 'జ్యేష్ఠ',
    'మూల', 'పూర్వాషాఢ', 'ఉత్తరాషాఢ', 'శ్రవణం', 'ధనిష్ఠ', 'శతభిషం',
    'పూర్వాభాద్ర', 'ఉత్తరాభాద్ర', 'రేవతి',
  ];

  @override
  void initState() {
    super.initState();
    _methodTabController = TabController(length: 3, vsync: this);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _phoneController.text = user.phoneNumber ?? '';
    }
    _loadSavedProfiles();
  }

  Future<void> _loadSavedProfiles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rashi_profiles')
            .get();

        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map((d) => UserAstrologyProfile.fromMap(d.data())).toList();
          setState(() {
            _savedProfilesList = list;
            _isLoadingSaved = false;
          });
          return;
        }
      } catch (_) {}
    }
    setState(() => _isLoadingSaved = false);
  }

  @override
  void dispose() {
    _methodTabController.dispose();
    _nameController.dispose();
    _placeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Calculate Rashi based on the active tab method
  void _calculateAndShowRashi() {
    String foundRashiId = 'mesha';

    if (_methodTabController.index == 0) {
      // By Name Letter
      if (_selectedNameLetter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('దయచేసి మీ పేరులోని మొదటి అక్షరాన్ని ఎంచుకోండి.')),
        );
        return;
      }
      for (final grp in _nameLetterGroups) {
        final list = grp['letters'] as List<String>;
        if (list.contains(_selectedNameLetter)) {
          foundRashiId = grp['rashiId'] as String;
          break;
        }
      }
    } else if (_methodTabController.index == 1) {
      // By Date of Birth (If time unknown, standard transit date is used)
      foundRashiId = _service.calculateRashiFromDate(_selectedDob);
    } else {
      // By Nakshatram
      if (_isNakshatramUnknown) {
        // If Nakshatram is unknown, fallback to DOB or Name Letter
        foundRashiId = _service.calculateRashiFromDate(_selectedDob);
      } else {
        foundRashiId = _service.calculateRashiFromNakshatram(_selectedNakshatram);
      }
    }

    setState(() {
      _confirmedRashi = _service.getRashiById(foundRashiId);
    });
  }

  // SAVE TO PERSON'S RASHI LIST
  Future<void> _saveAndAddToList() async {
    if (_confirmedRashi == null) return;

    final userName = _nameController.text.trim().isEmpty ? 'భక్తుడు' : _nameController.text.trim();
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    final docId = DateTime.now().millisecondsSinceEpoch.toString();

    final profile = UserAstrologyProfile(
      id: docId,
      fullName: userName,
      relation: _selectedRelation,
      birthDate: _selectedDob,
      birthTime: _isBirthTimeUnknown ? 'సమయం తెలియదు' : _selectedTime.format(context),
      birthPlace: _placeController.text.trim(),
      rashiId: _confirmedRashi!.id,
      nakshatram: _isNakshatramUnknown ? 'తెలియదు' : _selectedNakshatram,
      padam: _isNakshatramUnknown ? 'తెలియదు' : _selectedPadam,
      phoneNumber: _phoneController.text.trim(),
    );

    try {
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('rashi_profiles')
            .doc(docId)
            .set(profile.toMap(), SetOptions(merge: true));
      }
    } catch (_) {}

    setState(() {
      _savedProfilesList.removeWhere((e) => e.id == docId);
      _savedProfilesList.insert(0, profile);
      _isSaving = false;
    });

    if (widget.onRashiConfirmed != null) {
      widget.onRashiConfirmed!(profile);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName గారి రాశి (${_confirmedRashi!.nameTelugu}) లిస్ట్‌లో విజయవంతంగా సేవ్ చేయబడింది!'),
          backgroundColor: const Color(0xFF6A1B29),
        ),
      );
    }
  }

  void _openProfileDirect(UserAstrologyProfile p) {
    if (widget.onRashiConfirmed != null) {
      widget.onRashiConfirmed!(p);
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RashiPalaluDetailScreen(
          initialRashiId: p.rashiId,
          userConfirmedProfile: p,
        ),
      ),
    );
  }

  Future<void> _deleteProfile(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('rashi_profiles')
          .doc(id)
          .delete();
    }
    setState(() {
      _savedProfilesList.removeWhere((p) => p.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "మీ రాశిని తెలుసుకోండి",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DIVINE INFO BANNER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF861B2E), Color(0xFF5A101C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: Color(0xFFF1C40F), size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "మీ జన్మ రాశిని కనుగొనండి ✨",
                          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 3),
                        Text(
                          "మీ పేరు, పుట్టిన తేదీ లేదా నక్షత్రం ఆధారంగా మీ రాశిని నిర్ణయించండి. సమయం లేదా నక్షత్రం తెలియకపోయినా తేలికగా తెలుసుకోవచ్చు.",
                          style: TextStyle(fontSize: 12, color: Color(0xFFFDE8C7), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. SAVED PROFILES LIST SECTION (వ్యక్తుల రాశుల లిస్ట్)
            if (_savedProfilesList.isNotEmpty) _buildSavedProfilesListSection(),

            const SizedBox(height: 14),

            // 3. NAME & RELATION DETAILS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEDBBF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("వ్యక్తిగత వివరాలు నమోదు చేయండి:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B29))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'పూర్తి పేరు (Name)*',
                            hintText: 'ఉదా: సాయి కృష్ణ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<String>(
                          value: _selectedRelation,
                          decoration: InputDecoration(
                            labelText: 'సంబంధం',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          items: ['నేను (Self)', 'జీవిత భాగస్వామి', 'కుమారుడు', 'కుమార్తె', 'తల్లిదండ్రులు', 'ఇతరులు']
                              .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12))))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedRelation = v ?? 'నేను (Self)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'మొబైల్ నంబర్ (ఐచ్ఛికం)',
                      hintText: 'ప్రొఫైల్ సేవ్ కొరకు',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      prefixIcon: const Icon(Icons.phone_android_rounded, size: 20, color: Color(0xFF6A1B29)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 4. SELECTION METHOD TABS: [పేరు మొదటి అక్షరం] | [పుట్టిన తేదీ] | [నక్షత్రం]
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDE2D2),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _methodTabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF6A1B29),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF4A1A22),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "పేరు మొదటి అక్షరం"),
                  Tab(text: "పుట్టిన తేదీ"),
                  Tab(text: "జన్మ నక్షత్రం"),
                ],
                onTap: (_) => setState(() {
                  _confirmedRashi = null;
                }),
              ),
            ),

            const SizedBox(height: 14),

            // 5. TAB VIEWS CONTENT
            SizedBox(
              height: 270,
              child: TabBarView(
                controller: _methodTabController,
                children: [
                  // TAB 1: By Name First Letter
                  _buildNameLetterGrid(),

                  // TAB 2: By Date of Birth & Time (WITH "సమయం తెలియదు" OPTION)
                  _buildDobSelector(),

                  // TAB 3: By Nakshatram & Padam (WITH "నక్షత్రం తెలియదు" OPTION)
                  _buildNakshatramSelector(),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 6. CALCULATE / FIND RASHI BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _calculateAndShowRashi,
                icon: const Icon(Icons.auto_awesome, size: 20, color: Color(0xFFF1C40F)),
                label: const Text(
                  "నా రాశిని నిర్ణయించండి (Find My Rashi)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 7. CONFIRMED RASHI CARD WITH "SAVE TO LIST" & "VIEW HOROSCOPE" BUTTONS
            if (_confirmedRashi != null) _buildConfirmedRashiCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // SAVED PERSONS RASHI LIST SECTION
  Widget _buildSavedProfilesListSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group_rounded, color: Color(0xFF6A1B29), size: 20),
              const SizedBox(width: 8),
              Text(
                "సేవ్ చేసిన వ్యక్తుల రాశుల జాబితా (${_savedProfilesList.length})",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savedProfilesList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final p = _savedProfilesList[idx];
              final r = _service.getRashiById(p.rashiId);

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFFF0ED),
                  child: Text(r.symbol, style: const TextStyle(color: Color(0xFF6A1B29), fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                title: Text(
                  "${p.fullName} (${p.relation})",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Text(
                  "${r.nameTelugu} రాశి • ${p.nakshatram} (${p.birthTime})",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF6A1B29)),
                      onPressed: () => _openProfileDirect(p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                      onPressed: () => _deleteProfile(p.id),
                    ),
                  ],
                ),
                onTap: () => _openProfileDirect(p),
              );
            },
          ),
        ],
      ),
    );
  }

  // METHOD 1: Name Letter Grid
  Widget _buildNameLetterGrid() {
    final allLetters = [
      'చు', 'చే', 'చో', 'లా', 'లీ', 'లూ', 'లే', 'లో', 'ఆ',
      'ఇ', 'ఉ', 'ఏ', 'ఓ', 'వా', 'వీ', 'వూ', 'వే', 'వో',
      'కా', 'కీ', 'కూ', 'కే', 'కో', 'హా', 'హి', 'హూ', 'హే',
      'మా', 'మీ', 'మూ', 'మే', 'మో', 'టా', 'పా', 'పీ', 'పూ',
      'రా', 'రీ', 'రూ', 'రే', 'రో', 'తా', 'తీ', 'తూ', 'తే',
      'తో', 'నా', 'నీ', 'నూ', 'నే', 'నో', 'యా', 'యో', 'భా',
      'గూ', 'గే', 'గో', 'సా', 'సీ', 'సూ', 'సే', 'సో', 'దీ',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "మీ పేరు ప్రారంభమయ్యే తెలుగు అక్షరాన్ని ఎంచుకోండి:",
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allLetters.map((l) {
                  final isSel = _selectedNameLetter == l;
                  return ChoiceChip(
                    label: Text(l, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black87)),
                    selected: isSel,
                    selectedColor: const Color(0xFF6A1B29),
                    backgroundColor: const Color(0xFFFFF9EE),
                    onSelected: (val) {
                      setState(() {
                        _selectedNameLetter = val ? l : null;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // METHOD 2: DOB Selector (WITH "సమయం తెలియదు" OPTION)
  Widget _buildDobSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("పుట్టిన తేదీ & సమయం నమోదు చేయండి:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6A1B29))),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDob,
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _selectedDob = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF6A1B29), size: 18),
                  const SizedBox(width: 10),
                  Text("తేదీ: ${_selectedDob.day}/${_selectedDob.month}/${_selectedDob.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Spacer(),
                  const Text("మార్చండి", style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Birth Time Picker with "సమయం తెలియదు" Checkbox
          if (!_isBirthTimeUnknown)
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                if (picked != null) setState(() => _selectedTime = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Color(0xFF6A1B29), size: 18),
                    const SizedBox(width: 10),
                    Text("సమయం: ${_selectedTime.format(context)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    const Text("మార్చండి", style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),

          // "సమయం తెలియదు" (Birth Time Unknown Option)
          Row(
            children: [
              Checkbox(
                value: _isBirthTimeUnknown,
                activeColor: const Color(0xFF6A1B29),
                onChanged: (val) {
                  setState(() {
                    _isBirthTimeUnknown = val ?? false;
                  });
                },
              ),
              const Text(
                "పుట్టిన సమయం తెలియదు (Time Unknown)",
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF5A141A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // METHOD 3: Nakshatram Selector (WITH "నక్షత్రం తెలియదు" OPTION)
  Widget _buildNakshatramSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("జన్మ నక్షత్రం మరియు పాదం:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6A1B29))),
              // "నక్షత్రం తెలియదు" Switch/Checkbox
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _isNakshatramUnknown,
                    activeColor: const Color(0xFF6A1B29),
                    onChanged: (val) {
                      setState(() {
                        _isNakshatramUnknown = val ?? false;
                      });
                    },
                  ),
                  const Text("తెలియదు", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (!_isNakshatramUnknown) ...[
            DropdownButtonFormField<String>(
              value: _selectedNakshatram,
              decoration: InputDecoration(
                labelText: 'నక్షత్రం (Nakshatram)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: _nakshatrams.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
              onChanged: (v) => setState(() => _selectedNakshatram = v ?? 'అశ్విని'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedPadam,
              decoration: InputDecoration(
                labelText: 'పాదం (Padam)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              items: ['1వ పాదం', '2వ పాదం', '3వ పాదం', '4వ పాదం'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedPadam = v ?? '1వ పాదం'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB74D)),
              ),
              child: const Text(
                "నక్షత్రం తెలియకపోతే, మీరు పేరు మొదటి అక్షరం లేదా పుట్టిన తేదీ ఆధారంగా కూడా మీ రాశిని సులభంగా తెలుసుకోవచ్చు.",
                style: TextStyle(fontSize: 12, color: Color(0xFF752408), height: 1.35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Confirmed Rashi Banner Card with Save to List & View Options
  Widget _buildConfirmedRashiCard() {
    final r = _confirmedRashi!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7EA), Color(0xFFFFF0ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1D8B4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: Colors.green, size: 22),
              const SizedBox(width: 6),
              const Text(
                "మీ రాశి నిర్ధారణ పూర్తయింది!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF6A1B29),
            child: Text(r.symbol, style: const TextStyle(fontSize: 40, color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text(
            "${r.nameTelugu} రాశి (${r.englishName})",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 4),
          Text(
            "అధిపతి: ${r.lordTelugu} • తత్త్వం: ${r.element}",
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            "అదృష్ట సంఖ్య: ${r.luckyNumber} • అదృష్ట రంగు: ${r.luckyColor}",
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A141A), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // TWO ACTION BUTTONS: 1. SAVE TO PERSONS LIST, 2. VIEW HOROSCOPE
          Row(
            children: [
              // Button 1: Save to List
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6A1B29), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveAndAddToList,
                  icon: const Icon(Icons.bookmark_add_outlined, color: Color(0xFF6A1B29)),
                  label: const Text(
                    "రాశిని సేవ్ చేయి",
                    style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Button 2: View Horoscope
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF861B2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveAndProceedToHoroscope,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    "ఫలితాలు చూడు",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndProceedToHoroscope() async {
    await _saveAndAddToList();
    if (mounted && _savedProfilesList.isNotEmpty) {
      _openProfileDirect(_savedProfilesList.first);
    }
  }
}
