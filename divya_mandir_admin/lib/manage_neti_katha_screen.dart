import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

class ManageNetiKathaScreen extends StatefulWidget {
  const ManageNetiKathaScreen({super.key});

  @override
  State<ManageNetiKathaScreen> createState() => _ManageNetiKathaScreenState();
}

class _ManageNetiKathaScreenState extends State<ManageNetiKathaScreen> with SingleTickerProviderStateMixin {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('neti_kathalu');
  final DocumentReference _settingsDoc = FirebaseFirestore.instance.collection('app_settings').doc('neti_katha');

  late TabController _tabController;
  final TextEditingController _jsonUploadCtrl = TextEditingController();

  bool _isSectionEnabled = true;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'అన్నీ';

  final List<String> _categories = ['అన్నీ', 'భాగవతం', 'రామాయణం', 'శివ పురాణం', 'గణేశ పురాణం', 'పురాణాలు'];

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
                ? 'నేటి కథ సెక్షన్ యూజర్ యాప్‌లో ఎనేబుల్ చేయబడింది.'
                : 'నేటి కథ సెక్షన్ యూజర్ యాప్‌లో డిజేబుల్ చేయబడింది.'),
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

  Future<void> _seed10DefaultKathalu() async {
    final list = [
      {
        'id': 'krishna_jananam',
        'title': 'శ్రీ కృష్ణ జనన కథ',
        'shortSummary': 'శ్రీ కృష్ణుడు జననం, గోకులం, బాలలీలలు, ఆధునిక జీవనంలో సందేశం.',
        'fullStory': 'ద్వాపర యుగంలో అధర్మం పెరిగిపోయి భూభారమైనప్పుడు, దుష్టుడైన కంసుడి చెరసాలలో దేవకీ వసుదేవులకు శ్రావణ బహుళ అష్టమి అర్ధరాత్రి వేళ శ్రీ మహావిష్ణువు శ్రీకృష్ణుడిగా శంఖు, చక్ర, గదా, పద్మములతో అవతరించాడు.\n\nఆ అద్భుత రాత్రి యమునా నది ఉప్పొంగుతున్నా, ఆదిశేషుడు గొడుగులా ఛత్రం పట్టగా వసుదేవుడు బుట్టలో బాలకృష్ణుడిని గోకులానికి చేర్చాడు. యశోదా నందుల గృహంలో పెరిగిన కృష్ణయ్య తన చిరునవ్వులు, చిలిపి అల్లర్లు మరియు మురళీ గానంతో గోకులాన్నంతా పరవశింపజేశాడు.\n\nపూతన, శకటాసురుడు, తృణావర్తుడు వంటి రాక్షసులను అలవోకగా సంహరించి ధర్మాన్ని రక్షించాడు.',
        'moral': 'ఎంతటి క్లిష్ట పరిస్థితుల్లోనైనా ధర్మాన్ని నమ్ముకుంటే భగవంతుడు అండగా నిలిచి మార్గం చూపిస్తాడు.',
        'category': 'భాగవతం',
        'assetPath': 'assets/images/neti_katha/krishna_janana_banner.png',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=1000&q=80',
        'date': '2026-10-26',
        'isFeaturedToday': true,
        'isActive': true,
        'order': 1,
      },
      {
        'id': 'shiva_parvathi_kalyanam',
        'title': 'శివ పార్వతుల కల్యాణం',
        'shortSummary': 'హిమవంతుని కుమార్తె గౌరీ దేవి ఘోర తపస్సు మరియు పరమేశ్వరుని వివాహం.',
        'fullStory': 'సతీదేవి దక్షయజ్ఞంలో శరీర త్యాగం చేసిన అనంతరం పర్వతరాజైన హిమవంతుని ఇంట పార్వతీ దేవిగా అవతరించింది. చిన్నతనం నుండే పరమశివుడినే భర్తగా పొందాలని ఆకాంక్షించింది.\n\nపరమేశ్వరుడు తపోదీక్షలో ఉండగా కామదేవుని భస్మం చేసినా, పార్వతీ దేవి పంచాగ్నుల మధ్య నిలబడి ఆకులు కూడా తినకుండా అపర్ణగా కఠోర తపస్సు చేసింది. శివుడు వటువు రూపంలో వచ్చి పరీక్షించినా ఆమె భక్తి చెక్కుచెదరలేదు. తుదకు పరమేశ్వరుడు ప్రసన్నుడై దేవతల సమక్షంలో పార్వతీ దేవిని పరిణయమాడాడు.',
        'moral': 'స్థిరమైన సంకల్పం, నిశ్చలమైన భక్తి ఉంటే భగవంతుని అనుగ్రహం తప్పక లభిస్తుంది.',
        'category': 'శివ పురాణం',
        'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1000&q=80',
        'date': '2026-10-25',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 2,
      },
      {
        'id': 'hanuman_bhakti',
        'title': 'హనుమంతుని నిరుపమాన భక్తి',
        'shortSummary': 'గుండె చీల్చి సీతారాములను చూపించిన మహాభక్తుడు ఆంజనేయుని విశిష్టత.',
        'fullStory': 'శ్రీరాముని పట్టాభిషేకానంతరం సీతాదేవి హనుమంతునికి అపురూపమైన ముత్యాల హారాన్ని బహూకరించింది. హనుమంతుడు ప్రతి ముత్యాన్ని కొరికి చూసి కింద పడేయడం ప్రారంభించాడు.\n\nసభలోని వారు ఆశ్చర్యపోయి ఎందుకు అలా చేస్తున్నావని ప్రశ్నించగా, ఏ వస్తువులోనైతే నా సీతారాముల నామం ఉండదో అది నాకు నిష్ప్రయోజనం అన్నాడు. మరి నీ శరీరంలో రాముడున్నాడా అని కొందరు అడగగా, హనుమంతుడు భక్తితో తన వక్షస్థలాన్ని చీల్చి చూపించగా, ఆయన గుండెల్లో శ్రీరాముడు, సీతాదేవి ప్రత్యక్షంగా దర్శనమిచ్చారు.',
        'moral': 'బాహ్య అలంకారాల కంటే హృదయంలో భగవంతుని నిలుపుకోవడమే నిజమైన భక్తి.',
        'category': 'రామాయణం',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1000&q=80',
        'date': '2026-10-24',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 3,
      },
      {
        'id': 'sudama_krishna',
        'title': 'సుదాముడు - శ్రీకృష్ణుని దివ్య మైత్రి',
        'shortSummary': 'గుప్పెడు అటుకులతో వైకుంఠనాథుని మెప్పించిన నిరుపేద స్నేహితుని గాథ.',
        'fullStory': 'శ్రీకృష్ణుని చిన్ననాటి సాందీపని ఆశ్రమ మిత్రుడు సుదాముడు (కుచేలుడు). నిరుపేదరికంతో అలమటిస్తున్నా ఎవరినీ యాచించని ధర్మమూర్తి. భార్య సూచనతో ద్వారకాధీశుడైన కృష్ణుడిని చూడటానికి పాత చిరిగిన వస్త్రంలో కానుకగా గుప్పెడు అటుకులు మూటగట్టుకుని వెళ్ళాడు.\n\nద్వారకలో కృష్ణుడు పరుగున వచ్చి మిత్రుడిని ఆలింగనం చేసుకుని, సింహాసనంపై కూర్చుండబెట్టి పాదాలు కడిగాడు. సిగ్గుపడుతున్న సుదాముడి చేతిలోని అటుకుల మూటను ప్రేమతో లాక్కుని ఆరగిస్తూ, అష్టైశ్వర్యాలను మిత్రునికి ప్రసాదించాడు.',
        'moral': 'స్నేహంలో హోదా, ధనం ముఖ్యం కాదు; స్వచ్ఛమైన ప్రేమ మరియు భక్తియే ముఖ్యం.',
        'category': 'భాగవతం',
        'imageUrl': 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=1000&q=80',
        'date': '2026-10-23',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 4,
      },
      {
        'id': 'ganesha_pradakshina',
        'title': 'గణపతి జ్ఞాన ఫలం - విశ్వ ప్రదక్షిణ',
        'shortSummary': 'తల్లిదండ్రులే సమస్త జగత్తు అని నిరూపించిన బుద్ధి కుశలత.',
        'fullStory': 'నారద మహర్షి పరమశివునికి ఒక దివ్య జ్ఞాన ఫలాన్ని సమర్పించాడు. దానిని పొందడానికి కుమారస్వామి, గణేశులలో ఎవరికి అర్హత ఉందో నిర్ణయించడానికి శివపార్వతులు ఒక పరీక్ష పెట్టారు: ఎవరైతే సమస్త భూమండలాన్ని మూడుసార్లు చుట్టి ముందుగా వస్తారో వారికే ఈ ఫలం దక్కుతుంది.\n\nకుమారస్వామి వెంటనే తన నెమలి వాహనమెక్కి వేగంగా బయలుదేరాడు. కానీ వినాయకుడు తల్లిదండ్రులైన పార్వతీ పరమేశ్వరుల చుట్టూ భక్తితో మూడు ప్రదక్షిణలు చేసి నిలిచాడు. తల్లిదండ్రులలోనే సమస్త సృష్టి ఇమిడి ఉందని తెలిపి ఆ జ్ఞాన ఫలాన్ని పొందాడు.',
        'moral': 'సమస్త తీర్థాలు, పుణ్యక్షేత్రాల కంటే తల్లిదండ్రుల సేవ మరియు గౌరవమే అత్యున్నతమైనది.',
        'category': 'గణేశ పురాణం',
        'imageUrl': 'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=1000&q=80',
        'date': '2026-10-22',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 5,
      },
      {
        'id': 'prahlada_charitra',
        'title': 'భక్త ప్రహ్లాద - హరి సర్వవ్యాపకత్వం',
        'shortSummary': 'హరి ఎందుగలడు అందుగలడు... స్తంభంలో నరసింహుని ఆవిర్భావం.',
        'fullStory': 'హిరణ్యకశిపుడు తపస్సు చేసి బ్రహ్మ నుండి చావు లేని వరాలు పొందాడు. కానీ అతని కుమారుడైన ప్రహ్లాదుడు పుట్టుకతోనే నారాయణ భక్తుడు. తండ్రి ఎన్ని చిత్రహింసలు పెట్టినా ఓం నమో నారాయణాయ జపాన్ని వీడలేదు.\n\nచివరకు ఆగ్రహించిన హిరణ్యకశిపుడు నీ హరి ఎక్కడున్నాడు? ఈ స్తంభంలో ఉన్నాడా? అని గదతో స్తంభాన్ని కొట్టగా, శ్రీహరి ఉగ్ర నరసింహ రూపంలో స్తంభాన్ని చీల్చుకుని ఆవిర్భవించి రాక్షసుడిని సంహరించి భక్తుడైన ప్రహ్లాదుడిని కాపాడాడు.',
        'moral': 'భగవంతుడు సర్వవ్యాపి; నిష్కల్మషమైన నమ్మకంతో పిలిస్తే ఏ రూపంలోనైనా ఆదుకుంటాడు.',
        'category': 'భాగవతం',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=1000&q=80',
        'date': '2026-10-21',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 6,
      },
      {
        'id': 'markandeya_mrutyunjaya',
        'title': 'మార్కండేయుని మృత్యుంజయ దీక్ష',
        'shortSummary': 'శివలింగాన్ని కౌగిలించుకుని యముడినే జయించిన చిరంజీవి కథ.',
        'fullStory': '16 ఏళ్ల అల్పాయుష్షు కలిగిన మార్కండేయుడు జన్మించాడు. 16వ ఏడు రాగానే యమధర్మరాజు స్వయంగా పాశం విసిరి ప్రాణాలు తీయడానికి వచ్చాడు.\n\nమార్కండేయుడు భయపడకుండా శివలింగాన్ని గట్టిగా ఆలింగనం చేసుకున్నాడు. శివుడు రౌద్ర రూపంతో ప్రత్యక్షమై యముడిని తరిమికొట్టి, నువ్వు సదా 16 ఏళ్ల చిరంజీవిగా ఉంటావు అని మార్కండేయుడికి అమరత్వాన్ని ప్రసాదించాడు.',
        'moral': 'మృత్యుంజయుడైన పరమేశ్వరుని శరణు వేడితే కాలం కూడా తలవంచక తప్పదు.',
        'category': 'శివ పురాణం',
        'imageUrl': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1000&q=80',
        'date': '2026-10-20',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 7,
      },
      {
        'id': 'gajendra_moksham',
        'title': 'గజేంద్ర మోక్షం - ఆపద్బాంధవ రక్షణ',
        'shortSummary': 'లావొక్కింతయు లేదు... గజేంద్రుని ఆర్తనాదం మరియు విష్ణువు రాక.',
        'fullStory': 'సరస్సులో నీరు తాగడానికి వెళ్లిన గజేంద్రుడనే ఏనుగు పాదాన్ని ఒక బలమైన మొసలి పట్టుకుంది. వెయ్యి సంవత్సరాల పాటు భీకర పోరాటం సాగింది. గజేంద్రుని బలం క్షీణించి ఇక ప్రాణాలు పోయే స్థితికి చేరింది.\n\nతన సొంత బలం పనిచేయదని గ్రహించిన గజేంద్రుడు తొండంతో ఒక కమలాన్ని పైకెత్తి నన్నేలవే కరుణాపూర్ణ లోకేశ్వరా అని ప్రార్థించాడు. శ్రీమహావిష్ణువు వెంటనే సుదర్శన చక్రాన్ని ప్రయోగించి మొసలిని సంహరించి గజేంద్రునికి మోక్షం ప్రసాదించాడు.',
        'moral': 'అహంకారం వీడి పూర్తిగా భగవంతునిపై భారం వేసినప్పుడు రక్షించడానికి ఆయన క్షణంలో వస్తాడు.',
        'category': 'భాగవతం',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=1000&q=80',
        'date': '2026-10-19',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 8,
      },
      {
        'id': 'bhagiratha_gangavataranam',
        'title': 'భగీరథుని పట్టుదల - గంగావతరణం',
        'shortSummary': 'పూర్వీకుల శాప విముక్తి కోసం గంగను భూమికి రప్పించిన తపస్సు.',
        'fullStory': 'సగర చక్రవర్తి కుమారులు కపిల మహర్షి శాపంతో బూడిదయ్యారు. వారికి ఉత్తమ గతులు కలగాలంటే స్వర్గలోకంలో ఉన్న గంగను భూమికి రప్పించాలి. ఎందరో ప్రయత్నించి విఫలమైనా, భగీరథుడు దృఢ నిశ్చయంతో ఘోర తపస్సు చేశాడు.\n\nగంగ ఉధృతిని తాళడానికి శివుడు తన జటాజూటంలో గంగను బంధించి ఒక పాయను మాత్రమే భూమిపైకి వదిలాడు. భగీరథుని రథం వెనుక గంగ ప్రవహించి సాగర కుమారులకు ముక్తి కలిగించింది.',
        'moral': 'ఎంతటి అసాధ్యమైన కార్యాన్నైనా నిరంతర పట్టుదల, ఓర్పుతో సాధించవచ్చు.',
        'category': 'పురాణాలు',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=1000&q=80',
        'date': '2026-10-18',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 9,
      },
      {
        'id': 'shabari_bhakti',
        'title': 'శబరి భక్తి - ఎంగిలి పండ్ల మాధుర్యం',
        'shortSummary': 'గురు వాక్యాన్ని నమ్మి రాముని కోసం ఏళ్ల తరబడి వేచి చూసిన శబరి.',
        'fullStory': 'శబరి అనే నిరుపేద వృద్ధురాలు మాతంగ మహర్షి ఆశ్రమంలో శ్రీరాముని రాక కోసం ఏళ్ల తరబడి నిరీక్షించింది. రాముడు వస్తాడనే గురువు మాటపై అచంచల విశ్వాసంతో ప్రతిరోజూ అడవిలో మధురమైన పండ్లను ఏరి రుచి చూసి భద్రపరిచేది.\n\nరాముడు ఆశ్రమానికి వచ్చినప్పుడు శబరి ఎంతో భక్తితో ఆ ఎంగిలి పండ్లను సమర్పించింది. శ్రీరాముడు ఆమె హృదయ నైర్మల్యాన్ని చూసి అమృతంలా ఆరగించి ఆమెకు దివ్య మోక్షాన్ని అనుగ్రహించాడు.',
        'moral': 'భగవంతుడు మన ఇచ్చే పదార్థాలను చూడడు; వాటి వెనుక ఉన్న నిష్కల్మషమైన ప్రేమానురాగాలను మాత్రమే చూస్తాడు.',
        'category': 'రామాయణం',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=1000&q=80',
        'date': '2026-10-17',
        'isFeaturedToday': false,
        'isActive': true,
        'order': 10,
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final k in list) {
        final docRef = _collection.doc(k['id'] as String);
        batch.set(docRef, k, SetOptions(merge: true));
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('10 నేటి కథలు విజయవంతంగా Firestore లోకి లోడ్ అయ్యాయి!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openKathaDialog(BuildContext context, [DocumentSnapshot? doc]) {
    final isEditing = doc != null;
    final data = isEditing ? doc.data() as Map<String, dynamic> : null;

    final titleCtrl = TextEditingController(text: data?['title'] ?? '');
    final shortSummaryCtrl = TextEditingController(text: data?['shortSummary'] ?? '');
    final fullStoryCtrl = TextEditingController(text: data?['fullStory'] ?? '');
    final moralCtrl = TextEditingController(text: data?['moral'] ?? '');
    final imageUrlCtrl = TextEditingController(text: data?['imageUrl'] ?? '');
    final dateCtrl = TextEditingController(text: data?['date'] ?? DateTime.now().toString().split(' ')[0]);
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());

    String selectedCategory = data?['category'] ?? 'భాగవతం';
    bool isFeaturedToday = data?['isFeaturedToday'] ?? false;
    bool isActive = data?['isActive'] ?? true;

    Uint8List? pickedImageBytes;
    String? pickedImageName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> pickImage() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                withData: true,
              );
              if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;
              final rawBytes = result.files.first.bytes!;
              Uint8List compressedBytes = rawBytes;

              try {
                final decoded = img.decodeImage(rawBytes);
                if (decoded != null) {
                  img.Image resized = decoded;
                  if (decoded.width > 1200) {
                    resized = img.copyResize(decoded, width: 1200);
                  }
                  compressedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 82));
                }
              } catch (_) {}

              setDialogState(() {
                pickedImageBytes = compressedBytes;
                pickedImageName = result.files.first.name;
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_note : Icons.add_circle_outline, color: const Color(0xFF6A1B29)),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? "కథను సవరించండి (Edit Story)" : "కొత్త కథను జోడించండి (Create Katha)",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SizedBox(
                width: 650,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: "కథ శీర్షిక (Title) *",
                          hintText: "ఉదా: శ్రీ కృష్ణ జనన కథ",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.auto_stories),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category & Date
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedCategory,
                              decoration: const InputDecoration(
                                labelText: "విభాగం (Category) *",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: ['భాగవతం', 'రామాయణం', 'శివ పురాణం', 'గణేశ పురాణం', 'పురాణాలు', 'భగవద్గీత', 'పంచతంత్రం']
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedCategory = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: dateCtrl,
                              readOnly: true,
                              onTap: () async {
                                DateTime initialDate = DateTime.now();
                                try {
                                  if (dateCtrl.text.isNotEmpty) {
                                    initialDate = DateTime.parse(dateCtrl.text.trim());
                                  }
                                } catch (_) {}
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  final y = picked.year.toString().padLeft(4, '0');
                                  final m = picked.month.toString().padLeft(2, '0');
                                  final d = picked.day.toString().padLeft(2, '0');
                                  setDialogState(() {
                                    dateCtrl.text = "$y-$m-$d";
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "ప్రదర్శించే తేదీ (Date - YYYY-MM-DD)",
                                hintText: "తేదీ ఎంచుకోండి (ఖాళీగా ఉంటే లేటెస్ట్)",
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                                suffixIcon: dateCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        tooltip: 'తేదీ తొలగించు (Clear Date)',
                                        onPressed: () {
                                          setDialogState(() {
                                            dateCtrl.clear();
                                          });
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Short Summary (Shown on Card)
                      TextField(
                        controller: shortSummaryCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "సంక్షిప్త వివరణ (Card Short Summary) *",
                          hintText: "హోమ్‌పేజీ కార్డుపై కనిపించే 2 లైన్ల సారాంశం...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Full Story
                      TextField(
                        controller: fullStoryCtrl,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: "పూర్తి కథ (Full Story) *",
                          hintText: "ఆధ్యాత్మిక కథ పూర్తి పాఠం నమోదు చేయండి...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Moral / Message
                      TextField(
                        controller: moralCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "నీతి / ఆధ్యాత్మిక సందేశం (Moral / Message)",
                          hintText: "ఈ కథ ద్వారా మానవాళికి అందే ముఖ్య సందేశం...",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lightbulb_outline),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Image picker row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: imageUrlCtrl,
                              decoration: const InputDecoration(
                                labelText: "చిత్రం వెబ్ లింక్ (Image URL)",
                                hintText: "https://images.unsplash.com/...",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.image_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B29),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            ),
                            onPressed: pickImage,
                            icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                            label: const Text("అప్‌లోడ్", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      if (pickedImageName != null) ...[
                        const SizedBox(height: 6),
                        Text("ఎంచుకున్న ఫోటో: $pickedImageName (Compressed & Ready)",
                            style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],

                      const SizedBox(height: 12),

                      // Switches: Featured Today & Active
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text("నేటి కథ (Featured Today)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: const Text("హోమ్‌పేజీ కార్డుపై నేడు ప్రదర్శించు", style: TextStyle(fontSize: 11)),
                              value: isFeaturedToday,
                              activeThumbColor: const Color(0xFFE65100),
                              onChanged: (val) => setDialogState(() => isFeaturedToday = val),
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text("యాక్టివ్ (Active)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: const Text("యూజర్లకు అందుబాటులో ఉంచు", style: TextStyle(fontSize: 11)),
                              value: isActive,
                              activeThumbColor: const Color(0xFF6A1B29),
                              onChanged: (val) => setDialogState(() => isActive = val),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                  onPressed: isUploading
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('దయచేసి శీర్షిక నమోదు చేయండి.')),
                            );
                            return;
                          }

                          setDialogState(() => isUploading = true);

                          String imgUrl = imageUrlCtrl.text.trim();
                          if (pickedImageBytes != null) {
                            try {
                              final fileName = "katha_${DateTime.now().millisecondsSinceEpoch}_$pickedImageName";
                              final ref = FirebaseStorage.instance.ref().child("kathalu/$fileName");
                              final task = await ref.putData(pickedImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
                              imgUrl = await task.ref.getDownloadURL();
                            } catch (_) {}
                          }

                          // If setting this story as Featured Today, unset any previous featured story
                          if (isFeaturedToday) {
                            final prev = await _collection.where('isFeaturedToday', isEqualTo: true).get();
                            for (var d in prev.docs) {
                              if (!isEditing || d.id != doc.id) {
                                await _collection.doc(d.id).update({'isFeaturedToday': false});
                              }
                            }
                          }

                          final kathaData = {
                            'title': title,
                            'shortSummary': shortSummaryCtrl.text.trim(),
                            'fullStory': fullStoryCtrl.text.trim(),
                            'moral': moralCtrl.text.trim(),
                            'category': selectedCategory,
                            'imageUrl': imgUrl,
                            'date': dateCtrl.text.trim(),
                            'isFeaturedToday': isFeaturedToday,
                            'isActive': isActive,
                            'order': int.tryParse(orderCtrl.text.trim()) ?? 0,
                            'updatedAt': FieldValue.serverTimestamp(),
                          };

                          try {
                            if (isEditing) {
                              await _collection.doc(doc.id).update(kathaData);
                            } else {
                              await _collection.add(kathaData);
                            }
                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing ? 'కథ వివరాలు అప్‌డేట్ అయ్యాయి!' : 'కొత్త కథ జోడించబడింది!'),
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
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? "సేవ్ చేయండి (Save)" : "క్రియేట్ చేయండి (Create)", style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteKatha(BuildContext context, DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("కథను తొలగించాలా? (Delete Story)"),
        content: const Text("ఈ కథను శాశ్వతంగా తొలగించాలనుకుంటున్నారా?"),
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
      await _collection.doc(doc.id).delete();
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('కథ విజయవంతంగా తొలగించబడింది!')),
        );
      }
    }
  }

  Future<void> _importJson() async {
    final text = _jsonUploadCtrl.text.trim();
    if (text.isEmpty) return;

    try {
      final decoded = jsonDecode(text);
      List<dynamic> items = decoded is List ? decoded : [decoded];
      final batch = FirebaseFirestore.instance.batch();

      for (var item in items) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString().isNotEmpty == true ? item['id'].toString() : _collection.doc().id;
          final ref = _collection.doc(id);
          batch.set(ref, {
            'title': item['title'] ?? '',
            'shortSummary': item['shortSummary'] ?? '',
            'fullStory': item['fullStory'] ?? '',
            'moral': item['moral'] ?? '',
            'category': item['category'] ?? 'పురాణాలు',
            'imageUrl': item['imageUrl'] ?? '',
            'assetPath': item['assetPath'] ?? '',
            'date': item['date'] ?? '',
            'isFeaturedToday': item['isFeaturedToday'] ?? false,
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
          const SnackBar(content: Text('కథలు విజయవంతంగా JSON నుండి ఇంపోర్ట్ అయ్యాయి!')),
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
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        title: const Text("నేటి కథ & పురాణ కథల నిర్వహణ (Manage Neti Katha)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 26),
            tooltip: 'కొత్త కథ జోడించండి',
            onPressed: () => _openKathaDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined, size: 24),
            tooltip: '10 కథలను లోడ్ చేయండి (Load 10 Kathalu)',
            onPressed: _seed10DefaultKathalu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF1C40F),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.auto_stories), text: "కథల జాబితా (Stories List)"),
            Tab(icon: Icon(Icons.code), text: "JSON బల్క్ అప్‌లోడ్ (JSON Upload)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1
          _buildStoriesListTab(),
          // TAB 2
          _buildJsonUploadTab(),
        ],
      ),
    );
  }

  Widget _buildStoriesListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GLOBAL SECTION TOGGLE BANNER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _isSectionEnabled ? Colors.green.shade200 : Colors.red.shade200, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories, color: _isSectionEnabled ? Colors.green.shade700 : Colors.red.shade700, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "హోమ్‌పేజీ 'నేటి కథ' సెక్షన్: ${_isSectionEnabled ? 'ఆన్ లో ఉంది (Active)' : 'డిసేబుల్ చేయబడింది (Disabled)'}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Text("ఈ స్విచ్ ద్వారా యాప్ హోమ్‌పేజీలో నేటి కథ సెక్షన్ ప్రదర్శనను నియంత్రించవచ్చు.", style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                Switch(value: _isSectionEnabled, activeThumbColor: Colors.green.shade700, onChanged: _toggleSectionEnabled),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Search & Filter Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "కథ పేరు లేదా విభాగం శోధించండి...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  underline: const SizedBox(),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                onPressed: () => _openKathaDialog(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("కొత్త కథ సృష్టించండి", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Stories Table
          StreamBuilder<QuerySnapshot>(
            stream: _collection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data?.docs ?? [];
              final filtered = docs.where((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final title = (d['title'] ?? '').toString().toLowerCase();
                final cat = (d['category'] ?? '').toString();
                final matchQuery = _searchQuery.isEmpty || title.contains(_searchQuery);
                final matchCat = _selectedCategory == 'అన్నీ' || cat == _selectedCategory;
                return matchQuery && matchCat;
              }).toList();

              if (filtered.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Icon(Icons.menu_book, size: 50, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text("కథల డేటా ఏదీ లేదు.", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                        onPressed: _seed10DefaultKathalu,
                        child: const Text("10 నేటి కథలను లోడ్ చేయండి", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, idx) {
                    final doc = filtered[idx];
                    final data = doc.data() as Map<String, dynamic>;
                    final isFeatured = data['isFeaturedToday'] ?? false;
                    final title = data['title'] ?? '';
                    final cat = data['category'] ?? '';
                    final date = data['date'] ?? '';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.auto_stories, color: Color(0xFFE65100)),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5))),
                          if (isFeatured)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFE53935), borderRadius: BorderRadius.circular(6)),
                              child: const Text("నేటి కథ (Today)", style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      subtitle: Text("విభాగం: $cat • తేదీ: $date"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle Today Featured
                          IconButton(
                            icon: Icon(isFeatured ? Icons.star_rounded : Icons.star_border_rounded, color: isFeatured ? Colors.amber.shade800 : Colors.grey),
                            tooltip: isFeatured ? 'నేటి కథగా ఉంది' : 'నేటి కథగా సెట్ చేయండి (Make Today Story)',
                            onPressed: () async {
                              // Unset previous
                              final prev = await _collection.where('isFeaturedToday', isEqualTo: true).get();
                              for (var d in prev.docs) {
                                await _collection.doc(d.id).update({'isFeaturedToday': false});
                              }
                              await _collection.doc(doc.id).update({'isFeaturedToday': !isFeatured});
                            },
                          ),
                          // Edit
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () => _openKathaDialog(context, doc),
                          ),
                          // Delete
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteKatha(context, doc),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("JSON ఫార్మాట్ ద్వారా బల్క్ కథల అప్‌లోడ్", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
                const SizedBox(height: 8),
                const Text("కథల జాబితాను JSON ద్వారా ఒకేసారి అప్‌డేట్ చేయండి.", style: TextStyle(color: Colors.black54, fontSize: 12.5)),
                const Divider(height: 20),
                TextField(
                  controller: _jsonUploadCtrl,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    hintText: '''[
  {
    "id": "krishna_story",
    "title": "శ్రీ కృష్ణ జనన కథ",
    "shortSummary": "కృష్ణావతార విశేషాలు...",
    "fullStory": "పూర్తి కథ...",
    "moral": "ధర్మ సంస్థాపన",
    "category": "భాగవతం",
    "isFeaturedToday": true
  }
]''',
                    filled: true,
                    fillColor: Color(0xFFF9FAFB),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                  onPressed: _importJson,
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: const Text("JSON డేటాను సేవ్ చేయండి", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
