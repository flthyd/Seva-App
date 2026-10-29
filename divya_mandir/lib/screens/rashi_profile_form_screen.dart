import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rashi_models.dart';
import '../services/telugu_rashi_service.dart';

class RashiProfileFormScreen extends StatefulWidget {
  final UserAstrologyProfile? existingProfile;
  final Function(UserAstrologyProfile profile)? onProfileSaved;

  const RashiProfileFormScreen({
    super.key,
    this.existingProfile,
    this.onProfileSaved,
  });

  @override
  State<RashiProfileFormScreen> createState() => _RashiProfileFormScreenState();
}

class _RashiProfileFormScreenState extends State<RashiProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TeluguRashiService();

  late TextEditingController _nameCtrl;
  late TextEditingController _placeCtrl;
  late TextEditingController _phoneCtrl;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  String _selectedRelation = 'నేను (Self)';
  String _selectedRashi = 'mesha';
  String _selectedNakshatram = 'అశ్విని';
  String _selectedPadam = '1వ పాదం';
  bool _isAutoCalculated = true;
  bool _isSaving = false;

  // Prominent Locations
  final List<Map<String, dynamic>> _popularLocations = [
    {'name': 'హైదరాబాద్', 'state': 'తెలంగాణ', 'lat': 17.3850, 'lng': 78.4867},
    {'name': 'విజయవాడ', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 16.5062, 'lng': 80.6480},
    {'name': 'విశాఖపట్నం', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 17.6868, 'lng': 83.2185},
    {'name': 'తిరుపతి', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 13.6288, 'lng': 79.4192},
    {'name': 'వరంగల్', 'state': 'తెలంగాణ', 'lat': 17.9689, 'lng': 79.5941},
    {'name': 'గుంటూరు', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 16.3067, 'lng': 80.4365},
    {'name': 'రాజమండ్రి', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 17.0005, 'lng': 81.8040},
    {'name': 'కర్నూలు', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 15.8281, 'lng': 78.0373},
    {'name': 'కరీంనగర్', 'state': 'తెలంగాణ', 'lat': 18.4386, 'lng': 79.1288},
    {'name': 'నెల్లూరు', 'state': 'ఆంధ్రప్రదేశ్', 'lat': 14.4426, 'lng': 79.9865},
    {'name': 'బెంగళూరు', 'state': 'కర్ణాటక', 'lat': 12.9716, 'lng': 77.5946},
    {'name': 'చెన్నై', 'state': 'తమిళనాడు', 'lat': 13.0827, 'lng': 80.2707},
  ];

  final List<String> _relations = [
    'నేను (Self)',
    'భార్య (Wife)',
    'భర్త (Husband)',
    'కుమారుడు (Son)',
    'కుమార్తె (Daughter)',
    'తండ్రి (Father)',
    'తల్లి (Mother)',
    'సోదరుడు / సోదరి',
    'ఇతరులు (Other)',
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
    final p = widget.existingProfile;
    _nameCtrl = TextEditingController(text: p?.fullName ?? '');
    _placeCtrl = TextEditingController(text: p?.birthPlace ?? 'హైదరాబాద్');
    _phoneCtrl = TextEditingController(text: p?.phoneNumber ?? FirebaseAuth.instance.currentUser?.phoneNumber ?? '');

    _selectedDate = p?.birthDate ?? DateTime.now(); // Real-time default date
    _selectedTime = const TimeOfDay(hour: 8, minute: 30);
    _selectedRelation = p?.relation ?? 'నేను (Self)';
    _selectedRashi = p?.rashiId ?? 'mesha';
    _selectedNakshatram = p?.nakshatram ?? 'అశ్విని';
    _selectedPadam = p?.padam ?? '1వ పాదం';

    if (p == null) {
      _recalculateRashi();
    }
  }

  void _recalculateRashi() {
    if (_isAutoCalculated) {
      final calculated = _service.calculateRashiFromNakshatram(_selectedNakshatram);
      setState(() {
        _selectedRashi = calculated;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6A1B29)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF6A1B29)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _openLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFCF8F2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_rounded, color: Color(0xFF6A1B29)),
                  SizedBox(width: 8),
                  Text(
                    "జన్మ స్థలం / ఖచ్చితమైన నగరం ఎంచుకోండి",
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                  ),
                ],
              ),
              const Divider(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _popularLocations.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final loc = _popularLocations[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.place_outlined, color: Color(0xFFE53935)),
                      title: Text(loc['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${loc['state']} (Lat: ${loc['lat']}, Lng: ${loc['lng']})"),
                      onTap: () {
                        setState(() {
                          _placeCtrl.text = loc['name'] as String;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;
    final docId = widget.existingProfile?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final profile = UserAstrologyProfile(
      id: docId,
      fullName: _nameCtrl.text.trim(),
      relation: _selectedRelation,
      birthDate: _selectedDate,
      birthTime: _selectedTime.format(context),
      birthPlace: _placeCtrl.text.trim(),
      rashiId: _selectedRashi,
      nakshatram: _selectedNakshatram,
      padam: _selectedPadam,
      phoneNumber: _phoneCtrl.text.trim(),
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

      if (widget.onProfileSaved != null) {
        widget.onProfileSaved!(profile);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, profile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.fullName} గారి రాశి వివరాలు విజయవంతంగా సేవ్ అయ్యాయి!'),
            backgroundColor: const Color(0xFF6A1B29),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context, profile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rashiObj = _service.getRashiById(_selectedRashi);

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
        title: Text(
          widget.existingProfile == null ? "మీ రాశి & జన్మ వివరాలు" : "రాశి వివరాలు ఎడిట్ చేయండి",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER BANNER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFECD8B8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: Color(0xFFE53935), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "వ్యక్తిగతీకరించిన రాశిఫలాలు",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5A141A)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "మీ లేదా మీ కుటుంబ సభ్యుల జన్మ వివరాలు నమోదు చేయండి.",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. NAME & RELATION
              const Text("వ్యక్తిగత వివరాలు (Personal Details):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'పూర్తి పేరు (Full Name)*',
                  hintText: 'ఉదా: శివ శర్మ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6A1B29)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'దయచేసి పేరు నమోదు చేయండి' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedRelation,
                decoration: InputDecoration(
                  labelText: 'సంబంధం (Relation)*',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.people_outline, color: Color(0xFF6A1B29)),
                ),
                items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _selectedRelation = v ?? 'నేను (Self)'),
              ),

              const SizedBox(height: 18),

              // 3. DATE & TIME (LIVE DATE PICKER)
              const Text("జన్మ తేదీ & సమయం (Birth Date & Time):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF6A1B29)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("తేదీ (Date)", style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                                Text(
                                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFF6A1B29)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("సమయం (Time)", style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 4. LOCATION (GOOGLE MAPS / CITY PICKER) & PHONE
              const Text("జన్మ స్థలం & సంప్రదింపు (Location & Phone):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              InkWell(
                onTap: _openLocationPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFFE53935)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("జన్మ స్థలం (ఖచ్చితమైన ప్రదేశం)", style: TextStyle(fontSize: 11, color: Colors.black54)),
                            Text(
                              _placeCtrl.text.isEmpty ? "స్థలాన్ని ఎంచుకోండి" : _placeCtrl.text,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1B2028)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'మొబైల్ నంబర్ (Phone Number)',
                  hintText: 'ఈ నంబర్‌తో ప్రొఫైల్ సేవ్ చేయబడుతుంది',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF6A1B29)),
                ),
              ),

              const SizedBox(height: 18),

              // 5. NAKSHATRAM & PADAM
              const Text("జ్యోతిష్య వివరాలు (Astrology Nakshatram):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: DropdownButtonFormField<String>(
                      value: _selectedNakshatram,
                      decoration: InputDecoration(
                        labelText: 'నక్షత్రం (Nakshatram)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                      ),
                      items: _nakshatrams.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedNakshatram = v;
                            _recalculateRashi();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPadam,
                      decoration: InputDecoration(
                        labelText: 'పాదం',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['1వ పాదం', '2వ పాదం', '3వ పాదం', '4వ పాదం'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _selectedPadam = v ?? '1వ పాదం'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 6. AUTO DETERMINED RASHI RESULT CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF7EA), Color(0xFFFFF0ED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF1D8B4), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6A1B29),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        rashiObj.symbol,
                        style: const TextStyle(fontSize: 26, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "నిర్ణయించిన రాశి: ${rashiObj.nameTelugu} రాశి (${rashiObj.englishName})",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "అధిపతి: ${rashiObj.lordTelugu} • అదృష్ట సంఖ్య: ${rashiObj.luckyNumber}",
                            style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 7. SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "రాశి వివరాలు సేవ్ చేయండి (Save Details)",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
