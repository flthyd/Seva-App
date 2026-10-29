import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rashi_models.dart';
import '../services/telugu_rashi_service.dart';

class RashiProfileFormDialog extends StatefulWidget {
  final UserAstrologyProfile? existingProfile;
  final Function(UserAstrologyProfile profile)? onProfileSaved;

  const RashiProfileFormDialog({
    super.key,
    this.existingProfile,
    this.onProfileSaved,
  });

  @override
  State<RashiProfileFormDialog> createState() => _RashiProfileFormDialogState();
}

class _RashiProfileFormDialogState extends State<RashiProfileFormDialog> {
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

    _selectedDate = p?.birthDate ?? DateTime(1996, 5, 15);
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

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
      // Save in Firestore under current user if logged in
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
        Navigator.pop(context, profile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.fullName} గారి రాశి వివరాలు విజయవంతంగా భద్రపరచబడ్డాయి!'),
            backgroundColor: const Color(0xFF6A1B29),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, profile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rashiObj = _service.getRashiById(_selectedRashi);

    return Dialog(
      backgroundColor: const Color(0xFFFFFDF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: Color(0xFFE53935), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingProfile == null ? "మీ రాశి & జన్మ వివరాలు" : "రాశి వివరాలు ఎడిట్ చేయండి",
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF5A141A)),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "వ్యక్తిగతీకరించిన దిన, వార, మాస రాశిఫలాల కొరకు",
                            style: TextStyle(fontSize: 11.5, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Name & Relation
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'పూర్తి పేరు (Name)*',
                          hintText: 'ఉదా: శివ శర్మ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'పేరు నమోదు చేయండి' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRelation,
                        decoration: InputDecoration(
                          labelText: 'సంబంధం',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _selectedRelation = v ?? 'నేను (Self)'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Birth Date & Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6A1B29)),
                              const SizedBox(width: 8),
                              Text(
                                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF6A1B29)),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Birth Place & Phone
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _placeCtrl,
                        decoration: InputDecoration(
                          labelText: 'జన్మ స్థలం (Place)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'ఫోన్ నంబర్ (Phone)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Nakshatram & Padam
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: DropdownButtonFormField<String>(
                        value: _selectedNakshatram,
                        decoration: InputDecoration(
                          labelText: 'జన్మ నక్షత్రం (Nakshatram)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        items: _nakshatrams.map((n) => DropdownMenuItem(value: n, child: Text(n, style: const TextStyle(fontSize: 13)))).toList(),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        ),
                        items: ['1వ పాదం', '2వ పాదం', '3వ పాదం', '4వ పాదం'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                        onChanged: (v) => setState(() => _selectedPadam = v ?? '1వ పాదం'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Auto Determined Rashi Highlight Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5E5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1D8B4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6A1B29),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          rashiObj.symbol,
                          style: const TextStyle(fontSize: 22, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "మీ రాశి: ${rashiObj.nameTelugu} రాశి (${rashiObj.englishName})",
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "అధిపతి: ${rashiObj.lordTelugu} • అదృష్ట సంఖ్య: ${rashiObj.luckyNumber}",
                              style: const TextStyle(fontSize: 11.5, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B29),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _saveProfile,
                    child: const Text(
                      "రాశి వివరాలు సేవ్ చేయండి (Save Details)",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
