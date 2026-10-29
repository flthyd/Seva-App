import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

class ManageDevalayaluScreen extends StatefulWidget {
  const ManageDevalayaluScreen({super.key});

  @override
  State<ManageDevalayaluScreen> createState() => _ManageDevalayaluScreenState();
}

class _ManageDevalayaluScreenState extends State<ManageDevalayaluScreen> with SingleTickerProviderStateMixin {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('devalayalu');
  final DocumentReference _settingsDoc = FirebaseFirestore.instance.collection('app_settings').doc('devalayalu');

  late TabController _tabController;
  final TextEditingController _jsonUploadCtrl = TextEditingController();

  bool _isSectionEnabled = true;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStateFilter = 'అన్నీ';

  final List<String> _states = [
    'అన్నీ',
    'ఆంధ్రప్రదేశ్',
    'తెలంగాణ',
    'కర్ణాటక',
    'తమిళనాడు',
    'కేరళ',
    'మహారాష్ట్ర',
    'ఒడిశా',
    'ఉత్తర ప్రదేశ్',
    'ఉత్తరాఖండ్',
    'గుజరాత్',
    'రాజస్థాన్',
    'జమ్మూ & కాశ్మీర్',
    'ఇతర దివ్య క్షేత్రాలు'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jsonUploadCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await _settingsDoc.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        setState(() {
          _isSectionEnabled = data?['isEnabled'] ?? true;
          _isLoading = false;
        });
      } else {
        await _settingsDoc.set({'isEnabled': true});
        setState(() {
          _isSectionEnabled = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleSectionEnabled(bool value) async {
    setState(() => _isSectionEnabled = value);
    try {
      await _settingsDoc.set({'isEnabled': value}, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'దేవాలయాల సెక్షన్ యూజర్ యాప్‌లో ఎనేబుల్ చేయబడింది.'
                : 'దేవాలయాల సెక్షన్ యూజర్ యాప్‌లో డిజేబుల్ చేయబడింది.'),
            backgroundColor: value ? Colors.green.shade800 : Colors.red.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _seedDefaultTemples() async {
    final defaults = [
      {
        'id': 'tirumala',
        'nameTelugu': 'తిరుమల',
        'nameEnglish': 'Tirumala Tirupati',
        'state': 'ఆంధ్రప్రదేశ్',
        'district': 'తిరుపతి',
        'deity': 'శ్రీ వేంకటేశ్వర స్వామి',
        'imageUrl': '',
        'images': <String>[],
        'assetPath': 'assets/images/temples/tirumala.png',
        'historyStory':
            'కలియుగ ప్రత్యక్ష దైవమైన శ్రీ వేంకటేశ్వర స్వామి కొలువై ఉన్న పరమ పవిత్ర పుణ్యక్షేత్రం తిరుమల. సప్తగిరులపై వెలసిన స్వామి వారిని దర్శించుకోవడం వల్ల సకల పాపాలు హరించి ఇష్టార్థ సిద్ధి కలుగుతుందని భక్తుల ప్రగాఢ విశ్వాసం. ఇక్కడి లడ్డూ ప్రసాదం ప్రపంచ ప్రఖ్యాతి గాంచింది.',
        'timings': 'ఉదయం 3:00 నుండి రాత్రి 11:30 వరకు (సుప్రభాతం నుండి ఏకాంతసేవ వరకు)',
        'specialSevas': 'సుప్రభాత సేవ, తోమాల సేవ, అర్చన, కల్యాణోత్సవం, ఊంజల్ సేవ, సహస్ర దీపాలంకార సేవ',
        'onlineBookingUrl': 'https://ttdevasthanams.ap.gov.in',
        'googleMapsUrl': 'https://maps.google.com/?q=Tirumala+Temple',
        'isPopular': true,
        'isActive': true,
        'order': 1,
      },
      {
        'id': 'srisailam',
        'nameTelugu': 'శ్రీశైలం',
        'nameEnglish': 'Srisailam Mallikarjuna',
        'state': 'తెలంగాణ',
        'district': 'నంద్యాల / కర్నూలు సరిహద్దు',
        'deity': 'శ్రీ మల్లికార్జున స్వామి & భ్రమరాంబికా దేవి',
        'imageUrl': '',
        'images': <String>[],
        'assetPath': 'assets/images/temples/srisailam.png',
        'historyStory':
            'ద్వాదశ జ్యోతిర్లింగాలలో రెండవది, అష్టాదశ శక్తిపీఠాలలో ఒకటైన దివ్య క్షేత్రం శ్రీశైలం. కృష్ణా నదీ తీరాన నల్లమల అరణ్యాలలో వెలసిన ఈ క్షేత్రంలో భక్తులు స్వయంగా మల్లికార్జున లింగాన్ని స్పర్శించి పూజించుకునే అరుదైన భాగ్యం ఉంటుంది.',
        'timings': 'ఉదయం 4:30 నుండి రాత్రి 10:00 వరకు',
        'specialSevas': 'రుద్రాభిషేకం, గర్భాలయ స్పర్శ దర్శనం, చండీ హోమం, కల్యాణోత్సవం',
        'onlineBookingUrl': 'https://srisailadevasthanam.org',
        'googleMapsUrl': 'https://maps.google.com/?q=Srisailam+Temple',
        'isPopular': true,
        'isActive': true,
        'order': 2,
      },
      {
        'id': 'bhadrachalam',
        'nameTelugu': 'భద్రాచలం',
        'nameEnglish': 'Bhadrachalam Rama Temple',
        'state': 'ఆంధ్రప్రదేశ్',
        'district': 'భద్రాద్రి కొత్తగూడెం',
        'deity': 'శ్రీ సీతారామచంద్ర స్వామి',
        'imageUrl': '',
        'images': <String>[],
        'assetPath': 'assets/images/temples/bhadrachalam.png',
        'historyStory':
            'గోదావరి నదీ తీరాన వెలసిన దక్షిణ అయోధ్య శ్రీ భద్రాచలం. భక్త రామదాసు నిర్మించిన ఈ దివ్య మందిరంలో రామయ్య చతుర్భుజాలతో శంఖు చక్ర ధనుర్బాణాలతో సీతా లక్ష్మణ సమేతుడై కొలువై ఉన్నాడు. శ్రీరామనవమి తిరుకల్యాణ మహోత్సవం ఇక్కడ అత్యంత వైభవోపేతంగా జరుగుతుంది.',
        'timings': 'ఉదయం 4:00 నుండి రాత్రి 9:00 వరకు',
        'specialSevas': 'సుప్రభాతం, నిత్య కల్యాణం, సహస్రనామార్చన, పవళింపు సేవ',
        'onlineBookingUrl': 'https://bhadrachalam.org',
        'googleMapsUrl': 'https://maps.google.com/?q=Bhadrachalam+Temple',
        'isPopular': true,
        'isActive': true,
        'order': 3,
      },
      {
        'id': 'kaleshwaram',
        'nameTelugu': 'కాళేశ్వరం',
        'nameEnglish': 'Kaleshwara Mukteshwara',
        'state': 'ఆంధ్రప్రదేశ్',
        'district': 'జయశంకర్ భూపాలపల్లి',
        'deity': 'శ్రీ కాళేశ్వర ముక్తేశ్వర స్వామి',
        'imageUrl': '',
        'images': <String>[],
        'assetPath': 'assets/images/temples/kaleshwaram.png',
        'historyStory':
            'ఒకే పానవట్టంపై రెండు లింగాలు (శివుడు & యముడు - కాళేశ్వరుడు, ముక్తేశ్వరుడు) దర్శనమిచ్చే అత్యంత విశిష్టమైన త్రివేణి సంగమ క్షేత్రం కాళేశ్వరం. దక్షిణ కాశీగా ప్రసిద్ధి చెందిన ఈ క్షేత్రంలో కాళేశ్వర లింగం ద్వారా పోసిన నీరు అదృశ్యమవడం ఇక్కడి అద్భుత ఆధ్యాత్మిక రహస్యం.',
        'timings': 'ఉదయం 4:30 నుండి మధ్యాహ్నం 1:00 వరకు, సాయంత్రం 3:30 నుండి రాత్రి 8:30 వరకు',
        'specialSevas': 'మహాన్యాసపూర్వక రుద్రాభిషేకం, సహస్ర ఘటాభిషేకం, లక్ష బిల్వార్చన',
        'onlineBookingUrl': 'https://kaleshwaram.telangana.gov.in',
        'googleMapsUrl': 'https://maps.google.com/?q=Kaleshwaram+Temple',
        'isPopular': true,
        'isActive': true,
        'order': 4,
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final t in defaults) {
        final docRef = _collection.doc(t['id'] as String);
        batch.set(docRef, t, SetOptions(merge: true));
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ప్రధాన 4 ప్రముఖ దేవాలయాలు Firestore లోకి విజయవంతంగా లోడ్ అయ్యాయి!')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('దయచేసి JSON డేటాను ఎంటర్ చేయండి.')),
      );
      return;
    }

    try {
      final decoded = jsonDecode(text);
      List<dynamic> items = [];
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('temples') && decoded['temples'] is List) {
          items = decoded['temples'];
        } else {
          items = [decoded];
        }
      }

      final batch = FirebaseFirestore.instance.batch();
      int count = 0;

      for (var item in items) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString().trim().isNotEmpty == true
              ? item['id'].toString().trim()
              : _collection.doc().id;
          final docRef = _collection.doc(id);

          List<String> images = [];
          if (item['images'] != null && item['images'] is List) {
            images = List<String>.from(item['images'].map((x) => x.toString()));
          } else if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) {
            images = [item['imageUrl'].toString()];
          }

          batch.set(docRef, {
            'nameTelugu': item['nameTelugu'] ?? '',
            'nameEnglish': item['nameEnglish'] ?? '',
            'state': item['state'] ?? 'ఆంధ్రప్రదేశ్',
            'district': item['district'] ?? '',
            'deity': item['deity'] ?? '',
            'imageUrl': item['imageUrl'] ?? (images.isNotEmpty ? images.first : ''),
            'images': images,
            'assetPath': item['assetPath'] ?? '',
            'historyStory': item['historyStory'] ?? '',
            'timings': item['timings'] ?? 'ఉదయం 6:00 నుండి రాత్రి 9:00 వరకు',
            'specialSevas': item['specialSevas'] ?? '',
            'onlineBookingUrl': item['onlineBookingUrl'] ?? '',
            'googleMapsUrl': item['googleMapsUrl'] ?? '',
            'isPopular': item['isPopular'] ?? true,
            'isActive': item['isActive'] ?? true,
            'order': item['order'] ?? 0,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          count++;
        }
      }

      await batch.commit();
      _jsonUploadCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count దేవాలయాలు విజయవంతంగా JSON నుండి ఇంపోర్ట్ అయ్యాయి!'),
            backgroundColor: Colors.green.shade800,
          ),
        );
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('JSON పార్సింగ్ లోపం: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }

  void _openTempleDialog(BuildContext context, [DocumentSnapshot? doc]) {
    final isEditing = doc != null;
    final data = isEditing ? doc.data() as Map<String, dynamic> : null;

    final nameTeluguCtrl = TextEditingController(text: data?['nameTelugu'] ?? '');
    final nameEnglishCtrl = TextEditingController(text: data?['nameEnglish'] ?? '');
    final districtCtrl = TextEditingController(text: data?['district'] ?? '');
    final deityCtrl = TextEditingController(text: data?['deity'] ?? '');
    final historyStoryCtrl = TextEditingController(text: data?['historyStory'] ?? '');
    final timingsCtrl = TextEditingController(text: data?['timings'] ?? 'ఉదయం 6:00 నుండి రాత్రి 9:00 వరకు');
    final specialSevasCtrl = TextEditingController(text: data?['specialSevas'] ?? '');
    final onlineBookingCtrl = TextEditingController(text: data?['onlineBookingUrl'] ?? '');
    final mapsUrlCtrl = TextEditingController(text: data?['googleMapsUrl'] ?? '');
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());
    final hashtagsCtrl = TextEditingController(text: data?['hashtags'] != null && data?['hashtags'] is List ? (data!['hashtags'] as List).join(', ') : (data?['hashtags'] ?? ''));

    // Multiple Images List (Existing URLs)
    List<String> currentImageUrls = [];
    if (data != null) {
      if (data['images'] != null && data['images'] is List) {
        currentImageUrls = List<String>.from(data['images'].map((x) => x.toString()));
      } else if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
        currentImageUrls = [data['imageUrl'].toString()];
      }
    }

    // New Images Picked for Upload with compressed bytes
    List<Map<String, dynamic>> newPickedFiles = []; // { 'name': String, 'bytes': Uint8List, 'sizeInfo': String }

    String selectedState = data?['state'] ?? 'ఆంధ్రప్రదేశ్';
    bool isActive = data?['isActive'] ?? true;
    bool isPopular = data?['isPopular'] ?? true;
    bool isUploading = false;
    String uploadStatus = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            // Function to pick multiple images and auto-compress them
            Future<void> pickMultipleImages() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                  allowMultiple: true,
                  withData: true,
                );

                if (result == null || result.files.isEmpty) return;

                setDialogState(() {
                  uploadStatus = "ఫోటోలను కంప్రెస్ చేస్తోంది (Compressing)...";
                });

                for (var file in result.files) {
                  if (file.bytes == null) continue;
                  final rawBytes = file.bytes!;
                  final originalKb = (rawBytes.lengthInBytes / 1024).toStringAsFixed(1);

                  Uint8List finalBytes = rawBytes;
                  String compressionInfo = "$originalKb KB";

                  try {
                    final decoded = img.decodeImage(rawBytes);
                    if (decoded != null) {
                      img.Image resized = decoded;
                      // Optimal mobile image slide max dimension: 1280px
                      if (decoded.width > 1280 || decoded.height > 1280) {
                        if (decoded.width >= decoded.height) {
                          resized = img.copyResize(decoded, width: 1280);
                        } else {
                          resized = img.copyResize(decoded, height: 1280);
                        }
                      }
                      // Compress to high-quality lightweight JPG (quality: 82)
                      final compressed = img.encodeJpg(resized, quality: 82);
                      finalBytes = Uint8List.fromList(compressed);
                      final compressedKb = (finalBytes.lengthInBytes / 1024).toStringAsFixed(1);
                      compressionInfo = "$originalKb KB ➔ $compressedKb KB (Compressed)";
                    }
                  } catch (e) {
                    debugPrint("Compression fallback: $e");
                  }

                  newPickedFiles.add({
                    'name': file.name,
                    'bytes': finalBytes,
                    'sizeInfo': compressionInfo,
                  });
                }

                setDialogState(() {
                  uploadStatus = "${newPickedFiles.length} కొత్త చిత్రాలు సిద్ధంగా ఉన్నాయి.";
                });
              } catch (e) {
                setDialogState(() {
                  uploadStatus = "Error selecting images: $e";
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline,
                    color: const Color(0xFF6A1B29),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? "దేవాలయం వివరాలను సవరించండి" : "కొత్త దేవాలయం జోడించండి (Create Temple)",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SizedBox(
                width: 700,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name Telugu & English
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: nameTeluguCtrl,
                              decoration: const InputDecoration(
                                labelText: "ఆలయం పేరు (తెలుగు) *",
                                hintText: "ఉదా: తిరుమల / అన్నవరం",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.temple_hindu),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: nameEnglishCtrl,
                              decoration: const InputDecoration(
                                labelText: "Temple Name (English)",
                                hintText: "e.g. Tirumala / Annavaram",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 2: State & District
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedState,
                              decoration: const InputDecoration(
                                labelText: "రాష్ట్రం (State) *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.map_outlined),
                              ),
                              items: [
                                  'ఆంధ్రప్రదేశ్',
                                  'తెలంగాణ',
                                  'కర్ణాటక',
                                  'తమిళనాడు',
                                  'కేరళ',
                                  'మహారాష్ట్ర',
                                  'ఒడిశా',
                                  'ఉత్తర ప్రదేశ్',
                                  'ఉత్తరాఖండ్',
                                  'గుజరాత్',
                                  'రాజస్థాన్',
                                  'జమ్మూ & కాశ్మీర్',
                                  'ఇతర దివ్య క్షేత్రాలు'
                                ]
                                  .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedState = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: districtCtrl,
                              decoration: const InputDecoration(
                                labelText: "జిల్లా / నగరం (District / City)",
                                hintText: "ఉదా: తిరుపతి / కాకినాడ",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Deity & Order
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: deityCtrl,
                              decoration: const InputDecoration(
                                labelText: "ప్రధాన దైవం (Presiding Deity)",
                                hintText: "ఉదా: శ్రీ వేంకటేశ్వర స్వామి",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.spa_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: orderCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "డిస్ప్లే క్రమం (Display Order)",
                                hintText: "1, 2, 3...",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.format_list_numbered),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // MULTIPLE IMAGES UPLOAD & SLIDER MANAGEMENT SECTION
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1E4CE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.photo_library_rounded, color: Color(0xFF6A1B29), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "ఆలయ చిత్రాల స్లైడ్స్ (Multiple Slide Images)",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B29)),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6A1B29),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: isUploading ? null : pickMultipleImages,
                                  icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                                  label: const Text("ఫోటోలు ఎంచుకోండి (Multiple)", style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "యూజర్ వివరాల పేజీలో ఈ చిత్రాలు స్లైడ్స్ (Image Carousel) లాగా కనిపిస్తాయి. ఫోటోలను అప్‌లోడ్ చేసేటప్పుడే ఆటోమేటిక్‌గా సైజ్ కంప్రెస్ అవుతుంది.",
                              style: TextStyle(fontSize: 11.5, color: Colors.black54),
                            ),
                            if (uploadStatus.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(uploadStatus, style: const TextStyle(fontSize: 11.5, color: Colors.indigo, fontWeight: FontWeight.w600)),
                            ],
                            const SizedBox(height: 10),

                            // PREVIEW OF EXISTING & NEW IMAGES
                            if (currentImageUrls.isEmpty && newPickedFiles.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Center(
                                  child: Text("ఇంకా చిత్రాలు ఏవీ జోడించలేదు. పైన ఉన్న బటన్ క్లిక్ చేసి ఒకేసారి అనేక ఫోటోలు జోడించవచ్చు.",
                                      style: TextStyle(fontSize: 12, color: Colors.black45)),
                                ),
                              )
                            else
                              SizedBox(
                                height: 115,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    // 1. Existing Saved URLs
                                    ...List.generate(currentImageUrls.length, (i) {
                                      final url = currentImageUrls[i];
                                      return Container(
                                        width: 105,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(11),
                                              child: url.startsWith('http')
                                                  ? Image.network(url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image))
                                                  : Image.asset(url, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image)),
                                            ),
                                            // Primary Badge on first item
                                            if (i == 0)
                                              Positioned(
                                                bottom: 4,
                                                left: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(color: Colors.amber.shade800, borderRadius: BorderRadius.circular(4)),
                                                  child: const Text("కవర్ ఫోటో", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            // Delete / Remove button
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    currentImageUrls.removeAt(i);
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    // 2. Newly Picked Local Files (Compressed)
                                    ...List.generate(newPickedFiles.length, (i) {
                                      final file = newPickedFiles[i];
                                      return Container(
                                        width: 110,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.green.shade400, width: 1.5),
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(11),
                                              child: Image.memory(file['bytes'] as Uint8List, fit: BoxFit.cover),
                                            ),
                                            // Size badge
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              right: 4,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                                                child: Text(
                                                  file['sizeInfo'] as String,
                                                  style: const TextStyle(color: Colors.white, fontSize: 8.5),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            // Remove button
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    newPickedFiles.removeAt(i);
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(3),
                                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ONLINE BOOKING & GOOGLE MAPS
                      TextField(
                        controller: onlineBookingCtrl,
                        decoration: const InputDecoration(
                          labelText: "ఆన్‌లైన్ బుకింగ్ లింక్ (Online Darshan / Seva URL)",
                          hintText: "https://ttdevasthanams.ap.gov.in...",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: mapsUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: "గూగుల్ మ్యాప్స్ లొకేషన్ లింక్ (Google Maps URL)",
                          hintText: "https://maps.google.com/?q=...",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.directions_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Timings & Special Sevas
                      TextField(
                        controller: timingsCtrl,
                        decoration: const InputDecoration(
                          labelText: "దర్శన వేళలు (Darshan Timings)",
                          hintText: "ఉదా: ఉదయం 6:00 నుండి రాత్రి 9:00 వరకు",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: specialSevasCtrl,
                        decoration: const InputDecoration(
                          labelText: "ప్రత్యేక సేవలు / ఉత్సవాలు (Special Sevas & Festivals)",
                          hintText: "ఉదా: అభిషేకం, కల్యాణోత్సవం, బ్రహ్మోత్సవాలు",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.celebration_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Temple Story / History
                      TextField(
                        controller: historyStoryCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: "ఆలయ చరిత్ర & స్థల పురాణం (Temple Story & History)",
                          hintText: "ఆలయం గురించి విశేషాలు, పురాణ గాథ, విశిష్టత...",
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Search Hashtags / Keywords
                      TextField(
                        controller: hashtagsCtrl,
                        decoration: const InputDecoration(
                          labelText: "సెర్చ్ హ్యాష్‌ట్యాగ్స్ (Search Hashtags / Keywords) *",
                          hintText: "ఉదా: #tirupati, #balaji, #govinda, తిరుమల, tirupathi (comma separated)",
                          helperText: "యూజర్లు English, Telugu, Hinglish లో సెర్చ్ చేసినప్పుడు ఈ ఆలయం కనిపించేలా కీవర్డ్స్ నమోదు చేయండి",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag_rounded, color: Color(0xFF6A1B29)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Toggles: Active & Popular
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text("యాక్టివ్ స్టేటస్ (Active)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: const Text("యూజర్ యాప్‌లో ప్రదర్శించు", style: TextStyle(fontSize: 11)),
                              value: isActive,
                              activeThumbColor: const Color(0xFF6A1B29),
                              onChanged: (val) => setDialogState(() => isActive = val),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text("పాపులర్ ఆలయం (Popular)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: const Text("హోమ్‌పేజీ దేవాలయాల సెక్షన్‌లో చూపించు", style: TextStyle(fontSize: 11)),
                              value: isPopular,
                              activeThumbColor: const Color(0xFFE67E22),
                              onChanged: (val) => setDialogState(() => isPopular = val),
                            ),
                          ),
                        ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isUploading
                      ? null
                      : () async {
                          final name = nameTeluguCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('దయచేసి ఆలయం పేరు నమోదు చేయండి.')),
                            );
                            return;
                          }

                          setDialogState(() {
                            isUploading = true;
                            uploadStatus = "చిత్రాలను క్లౌడ్‌లోకి అప్‌లోడ్ చేస్తోంది...";
                          });

                          List<String> finalImagesList = List.from(currentImageUrls);

                          // Upload any new picked compressed files to Firebase Storage
                          try {
                            for (var newFile in newPickedFiles) {
                              final fileName = "temple_${DateTime.now().millisecondsSinceEpoch}_${newFile['name']}";
                              final storageRef = FirebaseStorage.instance.ref().child("temples/$fileName");
                              final uploadTask = await storageRef.putData(
                                newFile['bytes'] as Uint8List,
                                SettableMetadata(contentType: 'image/jpeg'),
                              );
                              final downloadUrl = await uploadTask.ref.getDownloadURL();
                              finalImagesList.add(downloadUrl);
                            }
                          } catch (e) {
                            debugPrint("Storage upload error: $e");
                          }

                          final primaryImageUrl = finalImagesList.isNotEmpty ? finalImagesList.first : '';

                          final templeData = {
                            'nameTelugu': name,
                            'nameEnglish': nameEnglishCtrl.text.trim(),
                            'state': selectedState,
                            'district': districtCtrl.text.trim(),
                            'deity': deityCtrl.text.trim(),
                            'imageUrl': primaryImageUrl,
                            'images': finalImagesList,
                            'historyStory': historyStoryCtrl.text.trim(),
                            'timings': timingsCtrl.text.trim(),
                            'specialSevas': specialSevasCtrl.text.trim(),
                            'onlineBookingUrl': onlineBookingCtrl.text.trim(),
                            'googleMapsUrl': mapsUrlCtrl.text.trim(),
                            'hashtags': hashtagsCtrl.text.trim().split(RegExp(r'[,#\s]+')).where((s) => s.trim().isNotEmpty).map((s) => s.trim().toLowerCase()).toList(),
                            'order': int.tryParse(orderCtrl.text.trim()) ?? 0,
                            'isActive': isActive,
                            'isPopular': isPopular,
                            'updatedAt': FieldValue.serverTimestamp(),
                          };

                          try {
                            if (isEditing) {
                              await _collection.doc(doc.id).update(templeData);
                            } else {
                              await _collection.add(templeData);
                            }
                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing
                                      ? 'దేవాలయం వివరాలు విజయవంతంగా అప్‌డేట్ అయ్యాయి!'
                                      : 'కొత్త దేవాలయం విజయవంతంగా జోడించబడింది!'),
                                  backgroundColor: Colors.green.shade800,
                                ),
                              );
                            }
                          } catch (e) {
                            if (dialogCtx.mounted) {
                              ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          }
                        },
                  child: isUploading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEditing ? "సేవ్ చేయండి (Save)" : "క్రియేట్ చేయండి (Create)"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTemple(BuildContext context, DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("దేవాలయం తొలగించాలా? (Delete Temple)"),
        content: const Text("ఈ దేవాలయాన్ని డేటాబేస్ నుండి శాశ్వతంగా తొలగించాలనుకుంటున్నారా?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("రద్దు చేయండి")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("తొలగించండి", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _collection.doc(doc.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('దేవాలయం విజయవంతంగా తొలగించబడింది!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        title: const Text(
          "దేవాలయాల నిర్వహణ (Temples & Pilgrimage Management)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'కొత్త దేవాలయం సృష్టించండి (Create Temple)',
            onPressed: () => _openTempleDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined, size: 24),
            tooltip: 'ప్రధాన 4 ఆలయాలను రీలోడ్ చేయండి (Load Default Temples)',
            onPressed: _seedDefaultTemples,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF1C40F),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.temple_hindu), text: "దేవాలయాల జాబితా (Temples List)"),
            Tab(icon: Icon(Icons.code_rounded), text: "JSON ఫైల్ / బల్క్ ఇంపోర్ట్ (JSON Upload)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: TEMPLE LIST & CONTROLS
          _buildTempleListTab(),

          // TAB 2: JSON BULK UPLOAD TAB
          _buildJsonUploadTab(),
        ],
      ),
    );
  }

  Widget _buildTempleListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. GLOBAL SECTION TOGGLE BANNER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSectionEnabled ? Colors.green.shade200 : Colors.red.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isSectionEnabled ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.temple_hindu_rounded,
                    color: _isSectionEnabled ? Colors.green.shade700 : Colors.red.shade700,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "హోమ్‌పేజీ 'దేవాలయాలు' సెక్షన్ స్థితి: ${_isSectionEnabled ? 'ప్రస్తుతం ఆన్ లో ఉంది (Active)' : 'డిసేబుల్ చేయబడింది (Disabled)'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "ఈ స్విచ్ ద్వారా యాప్ హోమ్‌పేజీలో దేవాలయాల హారిజాంటల్ గ్రిడ్ సెక్షన్‌ను ఆన్/ఆఫ్ చేయవచ్చు.",
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isSectionEnabled,
                  activeThumbColor: Colors.green.shade700,
                  onChanged: _toggleSectionEnabled,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. SEARCH BAR & STATE FILTER & CREATE BUTTON
          Row(
            children: [
              // Search input
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "ఆలయం పేరు, జిల్లా లేదా ప్రధాన దైవం శోధించండి...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // State Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<String>(
                  value: _selectedStateFilter,
                  underline: const SizedBox(),
                  items: _states.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStateFilter = val);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Create Temple Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _openTempleDialog(context),
                icon: const Icon(Icons.add, size: 20),
                label: const Text("కొత్త ఆలయం సృష్టించండి", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 3. FIRESTORE DATA TABLE
          StreamBuilder<QuerySnapshot>(
            stream: _collection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
              }

              final docs = snapshot.data?.docs ?? [];
              final filtered = docs.where((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final name = (d['nameTelugu'] ?? '').toString().toLowerCase();
                final nameEn = (d['nameEnglish'] ?? '').toString().toLowerCase();
                final deity = (d['deity'] ?? '').toString().toLowerCase();
                final district = (d['district'] ?? '').toString().toLowerCase();
                final st = (d['state'] ?? 'ఆంధ్రప్రదేశ్').toString();

                final tags = d['hashtags'] != null && d['hashtags'] is List ? (d['hashtags'] as List).join(' ').toLowerCase() : '';
                final matchQuery = _searchQuery.isEmpty ||
                    name.contains(_searchQuery) ||
                    nameEn.contains(_searchQuery) ||
                    deity.contains(_searchQuery) ||
                    district.contains(_searchQuery) ||
                    tags.contains(_searchQuery);

                final matchState = _selectedStateFilter == 'అన్నీ' || st == _selectedStateFilter;

                return matchQuery && matchState;
              }).toList();

              if (filtered.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.temple_hindu_outlined, size: 54, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        "దేవాలయాల డేటా ఏదీ లభించలేదు.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "పైన ఉన్న 'Load Default Temples' బటన్ క్లిక్ చేసి లేదా 'కొత్త ఆలయం సృష్టించండి' ద్వారా జోడించవచ్చు.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                        onPressed: _seedDefaultTemples,
                        icon: const Icon(Icons.cloud_download, color: Colors.white),
                        label: const Text("ప్రధాన 4 దేవాలయాలను లోడ్ చేయండి", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, idx) {
                    final doc = filtered[idx];
                    final data = doc.data() as Map<String, dynamic>;
                    final isActive = data['isActive'] ?? true;
                    final isPopular = data['isPopular'] ?? true;
                    final name = data['nameTelugu'] ?? 'ఆలయం';
                    final state = data['state'] ?? 'ఆంధ్రప్రదేశ్';
                    final deity = data['deity'] ?? '';
                    final district = data['district'] ?? '';
                    final onlineBooking = data['onlineBookingUrl'] ?? '';

                    List<String> images = [];
                    if (data['images'] != null && data['images'] is List) {
                      images = List<String>.from(data['images'].map((x) => x.toString()));
                    } else if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
                      images = [data['imageUrl'].toString()];
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      leading: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: images.isNotEmpty
                              ? (images.first.startsWith('http')
                                  ? Image.network(images.first, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29)))
                                  : Image.asset(images.first, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29))))
                              : const Icon(Icons.temple_hindu, color: Color(0xFF6A1B29), size: 28),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0E8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              state,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text("Popular", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                            ),
                          ],
                          if (images.length > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.indigo.shade200, width: 0.8),
                              ),
                              child: Text("${images.length} Slides", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo.shade800)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("దైవం: $deity • ప్రాంతం: $district", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                          if (onlineBooking.isNotEmpty)
                            Text("బుకింగ్ లింక్: $onlineBooking", style: const TextStyle(fontSize: 11.5, color: Colors.blueAccent)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Active toggle
                          IconButton(
                            icon: Icon(
                              isActive ? Icons.check_circle : Icons.pause_circle_outline,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                            tooltip: isActive ? 'యాక్టివ్ (క్లిక్ చేసి పాజ్ చేయండి)' : 'డీయాక్టివ్ (క్లిక్ చేసి యాక్టివేట్ చేయండి)',
                            onPressed: () {
                              _collection.doc(doc.id).update({'isActive': !isActive});
                            },
                          ),
                          // Edit Button
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            tooltip: 'సవరించండి (Edit)',
                            onPressed: () => _openTempleDialog(context, doc),
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'తొలగించండి (Delete)',
                            onPressed: () => _deleteTemple(context, doc),
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.data_object_rounded, color: Color(0xFF6A1B29), size: 26),
                    SizedBox(width: 10),
                    Text(
                      "JSON ఫార్మాట్ ఫైల్ లేదా బల్క్ డేటా అప్‌లోడ్",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "ఒకేసారి అనేక దేవాలయాల వివరాలను (పేరు, కథ, బుకింగ్ లింక్స్, సమయాలు, చిత్రాల లిస్ట్) సులభంగా JSON ద్వారా అప్‌డేట్ చేసుకోండి.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const Divider(height: 24),
                TextField(
                  controller: _jsonUploadCtrl,
                  maxLines: 14,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '''[
  {
    "id": "yadadri",
    "nameTelugu": "యాదాద్రి",
    "nameEnglish": "Yadadri Lakshmi Narasimha",
    "state": "తెలంగాణ",
    "district": "యాదాద్రి భువనగిరి",
    "deity": "శ్రీ లక్ష్మీ నరసింహ స్వామి",
    "imageUrl": "https://example.com/yadadri1.jpg",
    "images": [
      "https://example.com/yadadri1.jpg",
      "https://example.com/yadadri2.jpg",
      "https://example.com/yadadri3.jpg"
    ],
    "historyStory": "పంచ నారసింహ క్షేత్రమైన యాదాద్రి...",
    "timings": "ఉదయం 4:00 నుండి రాత్రి 9:45 వరకు",
    "specialSevas": "సువర్ణ పుష్పార్చన, నిత్య కల్యాణం",
    "onlineBookingUrl": "https://yadadritemple.telangana.gov.in",
    "googleMapsUrl": "https://maps.google.com/?q=Yadadri+Temple",
    "isPopular": true,
    "isActive": true,
    "order": 5
  }
]''',
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _jsonUploadCtrl.clear(),
                      icon: const Icon(Icons.clear_all),
                      label: const Text("క్లియర్ చేయండి"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B29),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _importJsonData,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text("JSON డేటాను సేవ్ & అప్‌డేట్ చేయండి", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
