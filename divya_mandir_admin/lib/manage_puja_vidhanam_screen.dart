import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

class ManagePujaVidhanamScreen extends StatefulWidget {
  const ManagePujaVidhanamScreen({super.key});

  @override
  State<ManagePujaVidhanamScreen> createState() => _ManagePujaVidhanamScreenState();
}

class _ManagePujaVidhanamScreenState extends State<ManagePujaVidhanamScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _collection = FirebaseFirestore.instance.collection('puja_vidhanam');
  final _settingsDoc = FirebaseFirestore.instance.collection('app_settings').doc('puja_vidhanam');

  bool _isSectionEnabled = true;
  bool _isLoading = true;
  String _searchQuery = '';
  final String _selectedCategory = 'అన్నీ';

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
        SnackBar(content: Text(val ? 'పూజా విధానం సెక్షన్ యూజర్ యాప్‌లో ఆన్ అయింది' : 'పూజా విధానం సెక్షన్ ఆఫ్ అయింది')),
      );
    }
  }

  Future<void> _seed30DefaultPujas() async {
    final list = [
      {
        'id': 'ganapati_puja',
        'title': 'గణపతి పూజ',
        'deity': 'గణపతి',
        'tag': 'విఘ్న నివారణ కోసం',
        'countText': 5,
        'shortDesc': 'సమస్త కార్య విజయం, విఘ్నాల నివారణకు గణపతి పూజ విధానం.',
        'samagri': 'పసుపు, కుంకుమ, అక్షతలు, తమలపాకులు, వక్కలు, కొబ్బరికాయ, గరిక, మోదకాలు, దీపారాధన కుందులు, అగరువత్తులు.',
        'fullVidhanam': '1. ఆచమనం: ఓం కేశవాయ స్వాహా, ఓం నారాయణాయ స్వాహా, ఓం మాధవాయ స్వాహా అంటూ జలము స్వీకరించాలి.\n2. గణపతి ప్రార్థన: శుక్లాంబరధరం విష్ణుం శశివర్ణం చతుర్భుజం ప్రసన్నవదనం ధ్యాయేత్ సర్వవిఘ్నోపశాంతయే.\n3. ప్రాణాయామం & సంకల్పం: దేశకాల సంకీర్తన చేసి కార్యం నిర్విఘ్నంగా జరగాలని సంకల్పించాలి.\n4. షోడశోపచారాలు: ధ్యానం, ఆవాహనం, ఆసనం, పాద్యం, అర్ఘ్యం, ఆచమనీయం, స్నానం, వస్త్రం, యజ్ఞోపవీతం, గంధం, పుష్పం, ధూపం, దీపం, నైవేద్యం, తాంబూలం, నీరాజనం సమర్పించాలి.\n5. ఉత్తర పూజ & ప్రదక్షిణ: ఏకదంతునికి నమస్కరిస్తూ 3 సార్లు ఆత్మప్రదక్షిణ చేయాలి.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/ganapati_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'ప్రతిరోజూ, చవితి, బుధవారం',
        'isActive': true,
        'order': 1,
      },
      {
        'id': 'shiva_puja',
        'title': 'శివ పూజ',
        'deity': 'మహాశివుడు',
        'tag': 'ఓం నమః శివాయ',
        'countText': 6,
        'shortDesc': 'ఆరోగ్యం, ఆయుష్షు, శాంతి కోసం శివ పూజ విధానం.',
        'samagri': 'విభూతి, మారేడు దళాలు (బిల్వపత్రాలు), పాలు, తేనె, నెయ్యి, పెరుగు, పంచదార (పంచామృతాలు), గంధం, పుష్పాలు.',
        'fullVidhanam': '1. శివ ధ్యానం: ధ్యాయేన్నిత్యం మహేశం రజతగిరినిభం చారుచంద్రావతంసం.\n2. బిల్వాష్టకం & అభిషేకం: పంచామృతాలతో, శుద్ధ జలంతో శివలింగానికి రుద్రాధ్యాయం లేదా "ఓం నమః శివాయ" జపిస్తూ అభిషేకం చేయాలి.\n3. బిల్వార్చన: త్రిదళం త్రిగుణాకారం త్రినేత్రం చ త్రియాయుషం అంటూ మారేడు దళాలతో పూజించాలి.\n4. విభూతి ధారణ & ధూప దీపాలు: భస్మాన్ని సమర్పించి సాంబ్రాణి ధూపం వేయాలి.\n5. నైవేద్యం & హారతి: పండ్లు సమర్పించి కర్పూర నీరాజనం అందించాలి.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/shiva_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'సోమవారం, ప్రదోషం, మాస శివరాత్రి',
        'isActive': true,
        'order': 2,
      },
      {
        'id': 'lakshmi_puja',
        'title': 'లక్ష్మీ పూజ',
        'deity': 'శ్రీ మహాలక్ష్మి',
        'tag': 'ధన సంపద కోసం',
        'countText': 5,
        'shortDesc': 'ధనలాభం, ఐశ్వర్యం, అష్టైశ్వర్య కరుణకు లక్ష్మీ పూజ విధానం.',
        'samagri': 'కలశం, పసుపు కుంకుమ, తామర పువ్వులు, గులాబీలు, నాణేలు, పాయసం, తమలపాకులు, నెయ్యి దీపాలు.',
        'fullVidhanam': '1. లక్ష్మీ ధ్యానం: నమస్తేస్తు మహామాయే శ్రీపీఠే సురపూజితే.\n2. కలశ స్థాపన: కలశంలో పవిత్ర జలం, నవధాన్యాలు లేదా నాణేలు ఉంచి కొబ్బరికాయతో అలంకరించాలి.\n3. అష్టోత్తర శతనామావళి: 108 నామాలతో కుంకుమార్చన లేదా పుష్పార్చన చేయాలి.\n4. కనకధారా స్తోత్ర పఠనం.\n5. నైవేద్యం: తీపి నైవేద్యం సమర్పించి నేతి దీపాలతో నీరాజనం ఇవ్వాలి.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/lakshmi_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'శుక్రవారం, పౌర్ణమి, వరలక్ష్మీ వ్రతం',
        'isActive': true,
        'order': 3,
      },
      {
        'id': 'sai_puja',
        'title': 'సాయి పూజ',
        'deity': 'శిరిడీ సాయిబాబా',
        'tag': 'శ్రద్ధా - సబూరి',
        'countText': 4,
        'shortDesc': 'శాంతి, కష్టాల నివారణ, మనశ్శాంతి కోసం సాయి పూజ విధానం.',
        'samagri': 'చందనం, పసుపు లేదా గులాబీ పువ్వులు, ధూపం, నైవేద్యానికి కిచిడీ లేదా తీపి పదార్థాలు, కర్పూరం.',
        'fullVidhanam': '1. సాయి ధ్యానం: ఓం శ్రీ సాయినాథాయ నమః.\n2. కాకడ హారతి / బాబా అష్టోత్తరం పఠనం.\n3. విభూతి ప్రసాదం స్వీకరణ.\n4. బాబా బోధనల స్మరణ మరియు నైవేద్య సమర్పణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/sai_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'గురువారం',
        'isActive': true,
        'order': 4,
      },
      {
        'id': 'hanuman_puja',
        'title': 'హనుమాన్ పూజ',
        'deity': 'ఆంజనేయ స్వామి',
        'tag': 'బలం, రక్షణ కోసం',
        'countText': 5,
        'shortDesc': 'శక్తి, ధైర్యం, రక్షణ కోసం హనుమాన్ పూజ విధానం.',
        'samagri': 'సిందూరం, తమలపాకుల మాల, జిల్లేడు పూలు, అరటి పండ్లు, వడపప్పు, బెల్లం.',
        'fullVidhanam': '1. హనుమాన్ ధ్యానం: మనోజవం మారుతతుల్యవేగం జితేంద్రియం బుద్ధిమతాం వరిష్టం.\n2. తమలపాకుల పూజ: శ్రీరామ జయం రాసిన ఆకులతో మాల సమర్పణ.\n3. హనుమాన్ చాలీసా / సుందరకాండ పఠనం.\n4. సిందూర తిలక ధారణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/hanuman_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'మంగళవారం, శనివారం',
        'isActive': true,
        'order': 5,
      },
      {
        'id': 'venkateswara_puja',
        'title': 'వేంకటేశ్వర పూజ',
        'deity': 'శ్రీ వేంకటేశ్వర స్వామి',
        'tag': 'శ్రీవారి కటాక్షం కోసం',
        'countText': 6,
        'shortDesc': 'సంపద, శ్రేయస్సు, కోరికల సాఫల్యం కోసం శ్రీవారి పూజ విధానం.',
        'samagri': 'తులసీ దళాలు, పచ్చకర్పూరం, చందనం, అష్టగంధం, లడ్డూలు లేదా పొంగలి నైవేద్యం.',
        'fullVidhanam': '1. వేంకటేశ్వర సుప్రభాతం మరియు ధ్యానం.\n2. తులసి అర్చన: గోవింద నామాలు పఠిస్తూ తులసితో పూజ.\n3. వేంకటేశ్వర వజ్రకవచం పఠనం.\n4. హారతి మరియు తీర్థప్రసాదాలు.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/venkateswara_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'శనివారం, ఏకాదశి',
        'isActive': true,
        'order': 6,
      },
      {
        'id': 'subrahmanya_puja',
        'title': 'సుబ్రహ్మణ్య పూజ',
        'deity': 'సుబ్రహ్మణ్యేశ్వర స్వామి',
        'tag': 'జ్ఞానం, విజయం కోసం',
        'countText': 4,
        'shortDesc': 'విద్య, జ్ఞానం, శక్తి కోసం సుబ్రహ్మణ్య పూజ విధానం.',
        'samagri': 'ఎర్ర చందనం, ఎర్ర పూలు, పాలు, తేనె, పచ్చి ఆవుపాలు, కొబ్బరికాయ.',
        'fullVidhanam': '1. సుబ్రహ్మణ్య కవచం & ధ్యానం.\n2. పంచామృత క్షీరాభిషేకం.\n3. కుజదోష నివారణకు ప్రార్థన.\n4. ప్రసాదం సమర్పణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/subrahmanya_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'మంగళవారం, షష్ఠి',
        'isActive': true,
        'order': 7,
      },
      {
        'id': 'durga_puja',
        'title': 'దుర్గా పూజ',
        'deity': 'కనకదుర్గమ్మ',
        'tag': 'శక్తి, రక్షణ కోసం',
        'countText': 6,
        'shortDesc': 'శక్తి, ధైర్యం, గ్రహ దోషాల నివారణకు దుర్గా పూజ విధానం.',
        'samagri': 'ఎర్రని మందార పూలు, కుంకుమ, నిమ్మకాయల హారం, నేతి దీపాలు, క్షీరాన్నం.',
        'fullVidhanam': '1. దుర్గా సప్తశ్లోకీ లేదా అష్టకం పఠనం.\n2. ఎరుపు పుష్పాలతో కుంకుమార్చన.\n3. రాహుకాల దీపారాధన (మంగళవారం).\n4. దుర్గా కవచం పఠనం.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/durga_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'మంగళవారం, శుక్రవారం, అష్టమి, నవరాత్రులు',
        'isActive': true,
        'order': 8,
      },
      {
        'id': 'sai_puja',
        'title': 'సాయి పూజ',
        'deity': 'శిరిడీ సాయిబాబా',
        'shortDesc': 'శ్రద్ధా సబూరీలతో బాబా అనుగ్రహం, సకల కష్ట నివారణ.',
        'samagri': 'చందనం, పసుపు లేదా గులాబీ పువ్వులు, ధూపం, నైవేద్యానికి కిచిడీ లేదా తీపి పదార్థాలు, కర్పూరం.',
        'fullVidhanam': '1. సాయి ధ్యానం: ఓం శ్రీ సాయినాథాయ నమః.\n2. కాకడ హారతి / బాబా అష్టోత్తరం పఠనం.\n3. విభూతి ప్రసాదం స్వీకరణ.\n4. బాబా బోధనల స్మరణ మరియు నైవేద్య సమర్పణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'localAssetPath': 'assets/images/puja_vidhanam/sai_puja.png',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'గురువారం',
        'isActive': true,
        'order': 4,
      },
      {
        'id': 'hanuman_puja',
        'title': 'హనుమాన్ పూజ',
        'deity': 'ఆంజనేయ స్వామి',
        'shortDesc': 'భయ నివారణ, ధైర్యం, ఆత్మవిశ్వాసం మరియు గ్రహ దోష నివారణ.',
        'samagri': 'సిందూరం, తమలపాకుల మాల, జిల్లేడు పూలు, అరటి పండ్లు, వడపప్పు, బెల్లం.',
        'fullVidhanam': '1. హనుమాన్ ధ్యానం: మనోజవం మారుతతుల్యవేగం జితేంద్రియం బుద్ధిమతాం వరిష్టం.\n2. తమలపాకుల పూజ: శ్రీరామ జయం రాసిన ఆకులతో మాల సమర్పణ.\n3. హనుమాన్ చాలీసా / సుందరకాండ పఠనం.\n4. సిందూర తిలక ధారణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'మంగళవారం, శనివారం',
        'isActive': true,
        'order': 5,
      },
      {
        'id': 'venkateswara_puja',
        'title': 'వేంకటేశ్వర పూజ',
        'deity': 'శ్రీ వేంకటేశ్వర స్వామి',
        'shortDesc': 'కలియుగ వైకుంఠనాథుని పూజ, సర్వ కార్యసిద్ధి, ఐశ్వర్య ప్రాప్తి.',
        'samagri': 'తులసీ దళాలు, పచ్చకర్పూరం, చందనం, అష్టగంధం, లడ్డూలు లేదా పొంగలి నైవేద్యం.',
        'fullVidhanam': '1. వేంకటేశ్వర సుప్రభాతం మరియు ధ్యానం.\n2. తులసి అర్చన: గోవింద నామాలు పఠిస్తూ తులసితో పూజ.\n3. వేంకటేశ్వర వజ్రకవచం పఠనం.\n4. హారతి మరియు తీర్థప్రసాదాలు.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'శనివారం, ఏకాదశి',
        'isActive': true,
        'order': 6,
      },
      {
        'id': 'saraswati_puja',
        'title': 'సరస్వతీ పూజ',
        'deity': 'సరస్వతీ దేవి',
        'shortDesc': 'విద్యాబుద్ధులు, జ్ఞాపకశక్తి, వాక్చాతుర్యం మరియు జ్ఞాన సిద్ధి.',
        'samagri': 'తెల్లని వస్త్రం, తెల్లని పూలు, పుస్తకాలు/పెన్నులు, తేనె, అరటి పండ్లు, అక్షతలు.',
        'fullVidhanam': '1. సరస్వతీ నమస్తుభ్యం వరదే కామరూపిణి.\n2. పుస్తకాలపై పసుపు కుంకుమలు ఉంచి సరస్వతీ అష్టోత్తర శతనామాలతో పూజ.\n3. విద్యార్థుల చేత మంత్ర పఠనం.\n4. పాలు మరియు తేనె నైవేద్యం.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'వసంత పంచమి, మూలా నక్షత్రం',
        'isActive': true,
        'order': 7,
      },
      {
        'id': 'durga_puja',
        'title': 'దుర్గా దేవి పూజ',
        'deity': 'కనకదుర్గమ్మ',
        'shortDesc': 'శత్రు నివారణ, ఆత్మరక్షణ, ధైర్యం మరియు దుష్ట శక్తుల భంజనం.',
        'samagri': 'ఎర్రని మందార పూలు, కుంకుమ, నిమ్మకాయల హారం, నేతి దీపాలు, క్షీరాన్నం.',
        'fullVidhanam': '1. దుర్గా సప్తశ్లోకీ లేదా అష్టకం పఠనం.\n2. ఎరుపు పుష్పాలతో కుంకుమార్చన.\n3. రాహుకాల దీపారాధన (మంగళవారం).\n4. దుర్గా కవచం పఠనం.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'మంగళవారం, శుక్రవారం, అష్టమి, నవరాత్రులు',
        'isActive': true,
        'order': 8,
      },
      {
        'id': 'subrahmanya_puja',
        'title': 'సుబ్రహ్మణ్య స్వామి పూజ',
        'deity': 'సుబ్రహ్మణ్యేశ్వర స్వామి',
        'shortDesc': 'సంతాన ప్రాప్తి, కుజదోష నివారణ, వివాహ ప్రతిబంధకాల తొలగింపు.',
        'samagri': 'ఎర్ర చందనం, ఎర్ర పూలు, పాలు, తేనె, పచ్చి ఆవుపాలు, కొబ్బరికాయ.',
        'fullVidhanam': '1. సుబ్రహ్మణ్య కవచం & ధ్యానం.\n2. పంచామృత క్షీరాభిషేకం.\n3. కుజదోష నివారణకు ప్రార్థన.\n4. ప్రసాదం సమర్పణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'మంగళవారం, షష్ఠి',
        'isActive': true,
        'order': 9,
      },
      {
        'id': 'rama_puja',
        'title': 'శ్రీరామ పూజ',
        'deity': 'శ్రీరామచంద్రుడు',
        'shortDesc': 'ధర్మ రక్షణ, కుటుంబ ఐక్యత, సకల భయ నివారణ మరియు మనశ్శాంతి.',
        'samagri': 'తులసి, పసుపు పూలు, పానకం, వడపప్పు, చలిమిడి, కొబ్బరికాయ.',
        'fullVidhanam': '1. శ్రీరామ రక్షా స్తోత్రం పఠనం.\n2. సీతారామ లక్ష్మణ భరత శత్రుఘ్న హనుమత్ సహిత పట్టాభిషేక ధ్యానం.\n3. పానకం, వడపప్పు నైవేద్యం.\n4. మంగళ హారతి.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'శ్రీరామనవమి, పునర్వసు నక్షత్రం',
        'isActive': true,
        'order': 10,
      },
      {
        'id': 'krishna_puja',
        'title': 'శ్రీ కృష్ణ పూజ',
        'deity': 'శ్రీకృష్ణుడు',
        'shortDesc': 'ప్రేమ, ఆనందం, గోసంరక్షణ మరియు గీతా జ్ఞాన సిద్ధి.',
        'samagri': 'వెన్న, పాలు, నెయ్యి, తులసి దళాలు, నెమలి పించం, పసుపు పూలు, తీపి అటుకులు.',
        'fullVidhanam': '1. కృష్ణాయ వాసుదేవాయ హరయే పరమాత్మనే.\n2. గోపాల సహస్రనామ లేదా అష్టోత్తర పూజ.\n3. వెన్న, అటుకుల నైవేద్యం.\n4. గీతా శ్లోక పఠనం.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'అష్టమి, రోహిణి నక్షత్రం, జన్మాష్టమి',
        'isActive': true,
        'order': 11,
      },
      {
        'id': 'surya_puja',
        'title': 'సూర్య భగవాన్ పూజ (అర్ఘ్య ప్రదానం)',
        'deity': 'సూర్యనారాయణ స్వామి',
        'shortDesc': 'ఆరోగ్యం, నేత్రకాంతి, తేజస్సు మరియు పితృదోష నివారణ.',
        'samagri': 'రాగి పాత్ర, శుద్ధ జలం, ఎర్ర చందనం, ఎర్ర పూలు, అక్షతలు.',
        'fullVidhanam': '1. ఉదయపు సూర్యునికి అభిముఖంగా నిలబడడం.\n2. రాగి పాత్రతో "ఓం సూర్యాయ నమః" అంటూ మూడు మార్లు అర్ఘ్యం ఇవ్వడం.\n3. ఆదిత్య హృదయ స్తోత్ర పఠనం.\n4. సూర్య నమస్కారాలు.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'ఆదివారం, రథసప్తమి',
        'isActive': true,
        'order': 12,
      },
      {
        'id': 'dattatreya_puja',
        'title': 'దత్తాత్రేయ స్వామి పూజ',
        'deity': 'శ్రీ గురు దత్తాత్రేయుడు',
        'shortDesc': 'త్రిమూర్తుల అనుగ్రహం, గురుకృప, మోక్ష ప్రాప్తి.',
        'samagri': 'పసుపు పూలు, చందనం, ఉదుంబర (మేడి) ఆకులు, తీపి రోటీలు లేదా పండ్లు.',
        'fullVidhanam': '1. గురు బ్రహ్మ గురుర్విష్ణుః గురుర్దేవో మహేశ్వరః.\n2. దత్తాత్రేయ స్తోత్రం మరియు అష్టోత్తరం.\n3. గురు చరిత్ర పారాయణ.\n4. హారతి & ప్రసాదం.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'గురువారం, దత్త జయంతి',
        'isActive': true,
        'order': 13,
      },
      {
        'id': 'ayyappa_puja',
        'title': 'అయ్యప్ప స్వామి పూజ (పడి పూజ)',
        'deity': 'శ్రీ ధర్మశాస్తా అయ్యప్ప',
        'shortDesc': 'మండల దీక్షా ఫలితం, సంయమనం, భయ నివారణ మరియు శని దోష పరిహారం.',
        'samagri': 'తులసి మాల, పన్నీరు, భస్మం, నేతి దీపాలు, అప్పం, పాయసం.',
        'fullVidhanam': '1. స్వామియే శరణమయ్యప్ప నినాదాలు.\n2. 18 మెట్ల పడి పూజ మరియు శరణు ఘోష.\n3. హరివరాసనం గానం.\n4. కర్పూర ఆరతి.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'శనివారం, మండల కాలం',
        'isActive': true,
        'order': 14,
      },
      {
        'id': 'narasimha_puja',
        'title': 'నరసింహ స్వామి పూజ',
        'deity': 'లక్ష్మీ నరసింహ స్వామి',
        'shortDesc': 'శత్రు భయం, రుణబాధలు, రోగపీడల నివారణకు ప్రచండ రక్షణ.',
        'samagri': 'పానకం, వడపప్పు, తులసి, ఎర్ర పూలు, నేతి దీపాలు.',
        'fullVidhanam': '1. రుణవిమోచన నరసింహ స్తోత్రం.\n2. ఉగ్రం వీరం మహావిష్ణుం జ్వలంతం సర్వతోముఖం.\n3. తీపి పానకం సమర్పణ.\n4. హారతి.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'స్వాతి నక్షత్రం, నరసింహ జయంతి, మంగళవారం',
        'isActive': true,
        'order': 15,
      },
      {
        'id': 'gayatri_puja',
        'title': 'గాయత్రీ దేవి పూజ',
        'deity': 'వేదమాత గాయత్రి',
        'shortDesc': 'సకల పాపక్షయం, ఆధ్యాత్మిక ఉన్నతి, సద్బుద్ధి మరియు ప్రజ్ఞ.',
        'samagri': 'నెయ్యి దీపాలు, చందనం, అక్షతలు, తాజా పండ్లు, శ్వేత పుష్పాలు.',
        'fullVidhanam': '1. గాయత్రీ ధ్యానం: ముక్తా విద్రుమ హేమనీల ధవళచ్ఛాయైర్ముఖైస్త్రీక్షణైః.\n2. గాయత్రీ మంత్ర జపం (కనీసం 108 సార్లు).\n3. సూర్యోదయ లేదా సూర్యాస్తమయ సమయాల్లో సంధ్యావందనం.\n4. నమస్కారం.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'నిత్యమూ, త్రికాల సంధ్యలు',
        'isActive': true,
        'order': 16,
      },
      {
        'id': 'satyanarayana_puja',
        'title': 'సత్యనారాయణ స్వామి పూజ (వ్రత కథ)',
        'deity': 'శ్రీ సత్యనారాయణ స్వామి',
        'shortDesc': 'ఇంటిలో ఐశ్వర్యం, శాంతి, సకల మనోరథ సిద్ధికి ప్రసిద్ధ వ్రతం.',
        'samagri': 'గోధుమ రవ్వ ప్రసాదం (సపాద భక్ష్యం), కలశం, అరటి చెట్లు, పంచామృతం, తులసి.',
        'fullVidhanam': '1. గణపతి, నవగ్రహ, దిక్పాలక పూజ.\n2. సత్యనారాయణ స్వామి ప్రాణప్రతిష్ఠ & షోడశోపచారాలు.\n3. 5 అధ్యాయాల వ్రత కథా శ్రవణం.\n4. సపాద ప్రసాద వితరణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'వ్రతం',
        'auspiciousDays': 'పౌర్ణమి, ఏకాదశి',
        'isActive': true,
        'order': 17,
      },
      {
        'id': 'varalakshmi_vratham',
        'title': 'వరలక్ష్మీ వ్రత విధానం',
        'deity': 'వరలక్ష్మీ దేవి',
        'shortDesc': 'సౌభాగ్యం, వంశాభివృద్ధి, కుటుంబ క్షేమం కోసం స్త్రీలు ఆచరించే దివ్య వ్రతం.',
        'samagri': 'నోము దారాలు, కలశం, చీర రవిక, పిండివంటలు (బూరెలు, గారెలు), పువ్వులు, పండ్లు.',
        'fullVidhanam': '1. గణపతి పూజ, కలశ ఆవాహన.\n2. అంగపూజ, లక్ష్మీ అష్టోత్తర పూజ.\n3. నోము దారం కట్టుకొనుట.\n4. కథా శ్రవణం & వాయిన దానం.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'వ్రతం',
        'auspiciousDays': 'శ్రావణ మాస శుక్రవారాలు',
        'isActive': true,
        'order': 18,
      },
      {
        'id': 'kedareshwara_vratham',
        'title': 'కేదారేశ్వర వ్రతం',
        'deity': 'కేదారేశ్వరుడు (శివుడు)',
        'shortDesc': 'అర్ధనారీశ్వర తత్వ రూపం, దాంపత్య అనుకూలత, ముక్తి ప్రదాయకం.',
        'samagri': '21 పోగుల దారం, 21 పండ్లు, 21 బక్ష్యాలు, మారేడు దళాలు, కలశం.',
        'fullVidhanam': '1. శివ పార్వతుల సంయుక్త పూజ.\n2. కేదారేశ్వర 21 నామాలు & తోర గ్రంథి పూజ.\n3. వ్రత కథాపఠనం.\n4. తోరం ధారణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'category': 'వ్రతం',
        'auspiciousDays': 'దీపావళి అమావాస్య',
        'isActive': true,
        'order': 19,
      },
      {
        'id': 'navagraha_puja',
        'title': 'నవగ్రహ పూజ & శాంతి విధానం',
        'deity': 'సూర్యాది నవగ్రహములు',
        'shortDesc': 'గ్రహ దోష నివారణ, శని, రాహు-కేతు శాంతి, ఆరోగ్య రక్షణ.',
        'samagri': 'నవధాన్యాలు, 9 రంగుల వస్త్రాలు, నువ్వుల నూనె దీపాలు, అర్క/సమిధలు.',
        'fullVidhanam': '1. నవగ్రహ మండలం లేదా నవగ్రహాల వద్ద ప్రార్థన.\n2. ఆదిత్యాయ చ సోమాయ మంగళాయ బుధాయ చ...\n3. నవగ్రహ స్తోత్ర పఠనం.\n4. 9 ప్రదక్షిణలు.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'category': 'గ్రహ శాంతి',
        'auspiciousDays': 'శనివారం, అమావాస్య, గ్రహణ కాలం',
        'isActive': true,
        'order': 20,
      },
      {
        'id': 'shani_puja',
        'title': 'శనీశ్వర పూజ (తైలాభిషేకం)',
        'deity': 'శని భగవానుడు',
        'shortDesc': 'ఏలినాటి శని, అర్ధాష్టమ శని బాధల నివారణ మరియు కర్మ దోష శాంతి.',
        'samagri': 'నువ్వుల నూనె, నల్ల నువ్వులు, నీలి రంగు పువ్వులు, నల్లని వస్త్రం, ఇనుప ప్రమిద.',
        'fullVidhanam': '1. శని గాయత్రీ & స్తోత్ర పఠనం: నీలాంజన సమాభాసం రవిపుత్రం యమాగ్రజం.\n2. నువ్వుల నూనెతో తైలాభిషేకం లేదా దీపారాధన.\n3. కాకులకు ఆహారం పెట్టడం, పేదలకు దానం.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'గ్రహ శాంతి',
        'auspiciousDays': 'శని త్రయోదశి, శనివారం',
        'isActive': true,
        'order': 21,
      },
      {
        'id': 'rahu_ketu_puja',
        'title': 'రాహు-కేతు సర్ప దోష నివారణ పూజ',
        'deity': 'రాహువు & కేతువు',
        'shortDesc': 'కాలసర్ప దోష పరిహారం, వ్యాపార నష్టాలు, వివాహ ఆలస్యాల నివారణ.',
        'samagri': 'మినుములు, ఉలవలు, నిమ్మకాయ దీపం, నల్ల వస్త్రం, వెండి నాగుల ప్రతిమ.',
        'fullVidhanam': '1. రాహు కాలంలో దుర్గా లేదా సుబ్రహ్మణ్య స్వామి సన్నిధిలో దీపారాధన.\n2. రాహు కేతువుల బీజాక్షర మంత్ర జపం.\n3. సర్ప సూక్తం లేదా నాగ దేవత అర్చన.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'గ్రహ శాంతి',
        'auspiciousDays': 'నాగపంచమి, రాహుకాలం',
        'isActive': true,
        'order': 22,
      },
      {
        'id': 'annapurna_puja',
        'title': 'అన్నపూర్ణా దేవి పూజ',
        'deity': 'శ్రీ అన్నపూర్ణా దేవి',
        'shortDesc': 'ఇంట్లో ఆహార కొరత రాకుండా, అన్నదాన మహిమ, అక్షయ సంపదలు.',
        'samagri': 'బియ్యం, పసుపు, కుంకుమ, గరిటె, బెల్లం అన్నం, పూలు.',
        'fullVidhanam': '1. అన్నపూర్ణే సదాపూర్ణే శంకర ప్రాణవల్లభే.\n2. వంటగదిలో అన్నపూర్ణమ్మ ఫోటోకు గంధ పుష్పాలతో పూజ.\n3. మొదటి ముద్ద లేదా ప్రసాదాన్ని దైవానికి సమర్పించి భోజనం చేయడం.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'ధనుర్మాసం, అక్షయ తృతీయ',
        'isActive': true,
        'order': 23,
      },
      {
        'id': 'tulasi_puja',
        'title': 'తులసి కోట పూజ (బృందావన పూజ)',
        'deity': 'తులసి మాత (బృందా దేవి)',
        'shortDesc': 'ఇంటికి లక్ష్మీ కటాక్షం, వాస్తు దోష నివారణ, పవిత్రత.',
        'samagri': 'పసుపు, కుంకుమ, గంగాజలం, నేతి దీపం, అగరువత్తులు, తెల్లని అక్షతలు.',
        'fullVidhanam': '1. ఉదయాన్నే తులసి చెట్టు మొదట్లో నీరు పోయడం.\n2. "తులసీ కళ్యాణీ నమస్తే విశ్వపావనీ" శ్లోకంతో ప్రదక్షిణ (కనీసం 3 సార్లు).\n3. సాయంత్రం వేళ నేతి దీపం వెలిగించి నమస్కరించడం.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'ప్రతిరోజూ, కార్తీక మాసం',
        'isActive': true,
        'order': 24,
      },
      {
        'id': 'govinda_puja',
        'title': 'గోవింద నామార్చన & నిత్య హారతి',
        'deity': 'శ్రీనివాసుడు',
        'shortDesc': 'నిత్యం గృహంలో శ్రీవారి దివ్య నామ సంకీర్తన, సకల పాపక్షయం.',
        'samagri': 'కర్పూరం, హారతి పళ్లెం, తులసి తీర్థం, కొబ్బరికాయ.',
        'fullVidhanam': '1. శ్రీనివాస గోవిందా శ్రీ వేంకటేశ గోవిందా నామోచ్ఛారణ.\n2. కర్పూర నీరాజనం & తులసి జల ప్రోక్షణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'ప్రతి శనివారం, ఏకాదశి',
        'isActive': true,
        'order': 25,
      },
      {
        'id': 'sankashtahara_chaturthi',
        'title': 'సంకష్టహర చవితి వ్రతం',
        'deity': 'సంకట హరణ గణపతి',
        'shortDesc': 'ఎలాంటి పెద్ద ఆపదలైనా, ఆర్థిక సమస్యలైనా పరిష్కరించే శక్తివంతమైన వ్రతం.',
        'samagri': 'గరిక, 21 మోదకాలు లేదా కుడుములు, బెల్లం, ఎర్రని పూలు, చంద్ర దర్శన పూజా సామగ్రి.',
        'fullVidhanam': '1. రోజంతా ఉపవాసం లేదా అల్పాహారం.\n2. సాయంత్రం సంకటనాశన గణేశ స్తోత్రం పఠనం.\n3. చంద్రోదయానంతరం అర్ఘ్యం ఇచ్చి పూజ ముగించి ప్రసాదం స్వీకరించడం.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'వ్రతం',
        'auspiciousDays': 'కృష్ణపక్ష చవితి',
        'isActive': true,
        'order': 26,
      },
      {
        'id': 'pradosha_puja',
        'title': 'ప్రదోష కాల శివార్చన',
        'deity': 'పరమశివుడు & నందీశ్వరుడు',
        'shortDesc': 'సూర్యాస్తమయ సంధ్యావేళ దారిద్య్ర నాశనం మరియు శివానుగ్రహం.',
        'samagri': 'పంచామృతం, బిల్వపత్రాలు, సాంబ్రాణి ధూపం, నందికి గరిక.',
        'fullVidhanam': '1. సూర్యాస్తమయానికి ముందు స్నానం చేసి ప్రదోష వ్రత సంకల్పం.\n2. శివలింగానికి, నందీశ్వరునికి బిల్వార్చన & అభిషేకం.\n3. రుద్ర జపం & నిశ్శబ్ద ధ్యానం.',
        'imageUrl': 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        'category': 'నిత్య పూజ',
        'auspiciousDays': 'త్రయోదశి తిథి సంధ్యా సమయం',
        'isActive': true,
        'order': 27,
      },
      {
        'id': 'vinayaka_chavithi_puja',
        'title': 'వినాయక చవితి మహోత్సవ పూజ',
        'deity': 'వరసిద్ధి వినాయకుడు',
        'shortDesc': '21 రకాల పత్రితో సమగ్ర వినాయక వ్రత కల్పం మరియు కథ.',
        'samagri': 'ఏకవింశతి పత్రాలు (21 ఆకులు), మట్టి వినాయకుడు, ఉండ్రాళ్ళు, పత్రి, పండ్లు.',
        'fullVidhanam': '1. మట్టి గణపతి ప్రతిష్ఠ & ప్రాణప్రతిష్ఠ.\n2. 21 పత్రాలతో ఏకవింశతి పత్ర పూజ.\n3. ఉండ్రాళ్ళు, కుడుములు నైవేద్యం.\n4. శమంతకోపాఖ్యానం కథా శ్రవణం & అక్షతల సమర్పణ.',
        'imageUrl': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        'category': 'పండుగ పూజ',
        'auspiciousDays': 'భాద్రపద శుద్ధ చవితి',
        'isActive': true,
        'order': 28,
      },
      {
        'id': 'diwali_kuber_puja',
        'title': 'దీపావళి లక్ష్మీ-కుబేర పూజ',
        'deity': 'మహాలక్ష్మి & కుబేరుడు',
        'shortDesc': 'నిరంతర సంపదలు, వ్యాపార లాభాలు మరియు దరిద్ర విముక్తి.',
        'samagri': 'మట్టి దీపాలు, కుబేర యంత్రం లేదా నాణేలు, తామర పువ్వులు, లడ్డూలు, ఖీర్.',
        'fullVidhanam': '1. ఇల్లంతా దీపాలతో అలంకరణ.\n2. లక్ష్మీ సూక్తం & కుబేర మంత్ర పఠనం.\n3. ధన ధాన్య కలశ పూజ.\n4. రాత్రి వేళ దీప ప్రజ్వలన.',
        'imageUrl': 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        'category': 'పండుగ పూజ',
        'auspiciousDays': 'ఆశ్వయుజ అమావాస్య (దీపావళి)',
        'isActive': true,
        'order': 29,
      },
      {
        'id': 'maha_shivaratri_puja',
        'title': 'మహాశివరాత్రి చతుర్యామ పూజ',
        'deity': 'లింగోద్భవ మూర్తి (శివుడు)',
        'shortDesc': 'జాగరణ, 4 జాముల ప్రత్యేక అభిషేకం, మోక్ష ప్రాప్తి.',
        'samagri': 'పాలు, పెరుగు, తేనె, కొబ్బరినీరు, మారేడు దళాలు, భస్మం, ఉమ్మెత్త పువ్వులు.',
        'fullVidhanam': '1. ప్రథమ యామం: పాలతో అభిషేకం & ఋగ్వేద మంత్రాలు.\n2. ద్వితీయ యామం: పెరుగుతో అభిషేకం & యజుర్వేదం.\n3. తృతీయ యామం: నెయ్యితో అభిషేకం & సామవేదం.\n4. చతుర్థ యామం: తేనెతో అభిషేకం & అధర్వణ వేదం.\n5. శివ రాత్రి జాగరణ & హారతి.',
        'imageUrl': 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        'category': 'పండుగ పూజ',
        'auspiciousDays': 'మాఘ బహుళ చతుర్దశి',
        'isActive': true,
        'order': 30,
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final p in list) {
        final docRef = _collection.doc(p['id'] as String);
        batch.set(docRef, p, SetOptions(merge: true));
      }
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('30 పూజా విధానాలు Firestore లోకి విజయవంతంగా లోడ్ అయ్యాయి!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openPujaDialog(BuildContext context, [DocumentSnapshot? doc]) {
    final isEditing = doc != null;
    final data = isEditing ? doc.data() as Map<String, dynamic> : null;

    final titleCtrl = TextEditingController(text: data?['title'] ?? '');
    final deityCtrl = TextEditingController(text: data?['deity'] ?? 'గణపతి');
    final tagCtrl = TextEditingController(text: data?['tag'] ?? 'విఘ్న నివారణ కోసం');
    final countTextCtrl = TextEditingController(text: (data?['countText'] ?? 5).toString());
    final shortDescCtrl = TextEditingController(text: data?['shortDesc'] ?? '');
    final samagriCtrl = TextEditingController(text: data?['samagri'] ?? '');
    final fullVidhanamCtrl = TextEditingController(text: data?['fullVidhanam'] ?? '');
    final imageUrlCtrl = TextEditingController(text: data?['imageUrl'] ?? '');
    final auspiciousDaysCtrl = TextEditingController(text: data?['auspiciousDays'] ?? 'ప్రతిరోజూ చేయవచ్చు');
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());

    String selectedCategory = data?['category'] ?? 'నిత్య పూజ';
    bool isActive = data?['isActive'] ?? true;
    Uint8List? pickedImageBytes;
    String? pickedImageName;
    String? imageCompressionStatus;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> pickImage() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                withData: true,
              );
              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;
                if (file.bytes != null) {
                  final rawBytes = file.bytes!;
                  final originalKb = (rawBytes.lengthInBytes / 1024).toStringAsFixed(1);
                  Uint8List compressedBytes = rawBytes;
                  String info = "$originalKb KB";

                  try {
                    final decoded = img.decodeImage(rawBytes);
                    if (decoded != null) {
                      img.Image resized = decoded;
                      if (decoded.width > 800 || decoded.height > 800) {
                        if (decoded.width >= decoded.height) {
                          resized = img.copyResize(decoded, width: 800);
                        } else {
                          resized = img.copyResize(decoded, height: 800);
                        }
                      }
                      final encoded = img.encodeJpg(resized, quality: 85);
                      compressedBytes = Uint8List.fromList(encoded);
                      final compKb = (compressedBytes.lengthInBytes / 1024).toStringAsFixed(1);
                      info = "$originalKb KB ➔ $compKb KB (Compressed)";
                    }
                  } catch (e) {
                    debugPrint("Compression fallback: $e");
                  }

                  setDialogState(() {
                    pickedImageBytes = compressedBytes;
                    pickedImageName = file.name;
                    imageCompressionStatus = info;
                  });
                }
              }
            } catch (e) {
              if (dialogCtx.mounted) {
                ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text('Image Pick Error: $e')));
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
                  isEditing ? "పూజా విధానం సవరణ (Edit Puja)" : "కొత్త పూజా విధానం (Add Puja)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title & Deity
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: titleCtrl,
                            decoration: const InputDecoration(
                              labelText: "పూజ పేరు (Puja Title) *",
                              hintText: "ఉదా: గణపతి పూజ / శివ పూజ",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.temple_hindu_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: deityCtrl,
                            decoration: const InputDecoration(
                              labelText: "దేవత (Deity / God) *",
                              hintText: "ఉదా: గణపతి / శివుడు / లక్ష్మి",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.wb_sunny_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category & Auspicious Days
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
                            items: ['నిత్య పూజ', 'వ్రతం', 'పండుగ పూజ', 'గ్రహ శాంతి', 'హోమం']
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
                            controller: auspiciousDaysCtrl,
                            decoration: const InputDecoration(
                              labelText: "ఉత్తమ దినములు / సమయం",
                              hintText: "ఉదా: శుక్రవారం, పౌర్ణమి",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tag & Puja Count
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagCtrl,
                            decoration: const InputDecoration(
                              labelText: "ట్యాగ్ (Tag / Purpose)",
                              hintText: "ఉదా: విఘ్న నివారణ కోసం / ఓం నమః శివాయ",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.label_important_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: countTextCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "పూజా విధానాల సంఖ్య (Count)",
                              hintText: "ఉదా: 5 (5 పూజా విధానాలు)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.menu_book_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Short Description
                    TextField(
                      controller: shortDescCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "క్లుప్త వివరణ (Short Summary) *",
                        hintText: "కార్డుపై కనిపించే వివరణ...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Samagri
                    TextField(
                      controller: samagriCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "కావలసిన పూజా సామాగ్రి (Puja Samagri) *",
                        hintText: "పసుపు, కుంకుమ, అక్షతలు, కొబ్బరికాయ...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Full Vidhanam
                    TextField(
                      controller: fullVidhanamCtrl,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: "పూర్తి పూజా విధానం & మంత్రాలు (Full Procedure) *",
                        hintText: "1. ఆచమనం, 2. సంకల్పం, 3. షోడశోపచారాలు...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Image URL or Upload with Live Preview
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: imageUrlCtrl,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: const InputDecoration(
                              labelText: "థంబ్‌నైల్ చిత్రం లింక్ (Image URL)",
                              hintText: "https://.../ganapati.png",
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
                          label: const Text("ఫోటో అప్‌లోడ్", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    if (pickedImageBytes != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              pickedImageBytes!,
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("ఎంచుకున్న చిత్రం: $pickedImageName",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(imageCompressionStatus ?? "Compressed & Ready",
                                    style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else if (imageUrlCtrl.text.isNotEmpty && imageUrlCtrl.text.startsWith('http')) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrlCtrl.text,
                              width: 80,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 80,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("ప్రస్తుత థంబ్‌నైల్ ప్రివ్యూ", style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Order / Index & Active Status
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: orderCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "కార్డ్ ఇండెక్స్ / క్రమ సంఖ్య (Index / Order)",
                              hintText: "1, 2, 3... (0 = లేటెస్ట్ మొదట)",
                              helperText: "ఇండెక్స్ ఇచ్చి కార్డుల వరుస క్రమం సెట్ చేయవచ్చు",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.format_list_numbered_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("యాక్టివ్ (Active Status)", style: TextStyle(fontWeight: FontWeight.bold)),
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
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('దయచేసి పూజ పేరు నమోదు చేయండి.')),
                          );
                          return;
                        }

                        setDialogState(() => isUploading = true);

                        String imgUrl = imageUrlCtrl.text.trim();
                        if (pickedImageBytes != null) {
                          try {
                            final fileName = "puja_${DateTime.now().millisecondsSinceEpoch}_$pickedImageName";
                            final ref = FirebaseStorage.instance.ref().child("puja_vidhanam/$fileName");
                            final task = await ref.putData(
                              pickedImageBytes!,
                              SettableMetadata(contentType: 'image/jpeg'),
                            );
                            imgUrl = await task.ref.getDownloadURL();
                          } catch (e) {
                            debugPrint("Storage error: $e");
                          }
                        }

                        final pujaData = {
                          'title': title,
                          'deity': deityCtrl.text.trim(),
                          'tag': tagCtrl.text.trim(),
                          'countText': int.tryParse(countTextCtrl.text) ?? 5,
                          'category': selectedCategory,
                          'shortDesc': shortDescCtrl.text.trim(),
                          'samagri': samagriCtrl.text.trim(),
                          'fullVidhanam': fullVidhanamCtrl.text.trim(),
                          'imageUrl': imgUrl,
                          'auspiciousDays': auspiciousDaysCtrl.text.trim(),
                          'order': int.tryParse(orderCtrl.text) ?? 0,
                          'isActive': isActive,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };

                        try {
                          if (isEditing) {
                            await _collection.doc(doc.id).update(pujaData);
                          } else {
                            pujaData['createdAt'] = FieldValue.serverTimestamp();
                            await _collection.add(pujaData);
                          }
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(isEditing ? 'పూజా విధానం సవరించబడింది!' : 'కొత్త పూజా విధానం జోడించబడింది!')),
                          );
                        } catch (e) {
                          if (dialogCtx.mounted) {
                            ScaffoldMessenger.of(dialogCtx).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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

  Future<void> _deletePuja(BuildContext context, DocumentSnapshot doc) async {
    final title = (doc.data() as Map<String, dynamic>?)?['title'] ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('తొలగించాలా? (Delete)'),
        content: Text("మీరు '$title' పూజా విధానాన్ని ఖచ్చితంగా తొలగించాలనుకుంటున్నారా?"),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('పూజా విధానం తొలగించబడింది.')));
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
            'title': item['title'] ?? '',
            'deity': item['deity'] ?? '',
            'category': item['category'] ?? 'నిత్య పూజ',
            'shortDesc': item['shortDesc'] ?? '',
            'samagri': item['samagri'] ?? '',
            'fullVidhanam': item['fullVidhanam'] ?? '',
            'imageUrl': item['imageUrl'] ?? '',
            'auspiciousDays': item['auspiciousDays'] ?? '',
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
          const SnackBar(content: Text('పూజలు విజయవంతంగా JSON నుండి ఇంపోర్ట్ అయ్యాయి!')),
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
        title: const Text('Manage Puja Vidhanam (పూజా విధానం నిర్వహణ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF6A1B29),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.format_list_bulleted), text: "పూజల జాబితా (Puja List)"),
            Tab(icon: Icon(Icons.code), text: "JSON బల్క్ అప్‌లోడ్ (Bulk Import)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPujaListTab(),
          _buildJsonUploadTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A1B29),
        onPressed: () => _openPujaDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("కొత్త పూజ (Add Puja)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPujaListTab() {
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
                      color: const Color(0xFFFFF3DE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "యూజర్ యాప్ హోమ్‌పేజీలో పూజా విధానం సెక్షన్",
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

          // Action Toolbar: Search + Seed 30 Default Pujas
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "పూజ లేదా దేవుని పేరుతో వెతకండి...",
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
                onPressed: _seed30DefaultPujas,
                icon: const Icon(Icons.auto_fix_high, color: Colors.white, size: 18),
                label: const Text("30 పూజా విధానాలు లోడ్ చేయండి", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                final title = (data['title'] ?? '').toString().toLowerCase();
                final deity = (data['deity'] ?? '').toString().toLowerCase();
                final q = _searchQuery.toLowerCase().trim();
                final matchesSearch = q.isEmpty || title.contains(q) || deity.contains(q);
                final matchesCategory = (_selectedCategory == 'అన్నీ' || data['category'] == _selectedCategory);
                return matchesSearch && matchesCategory;
              }).toList();

              if (filtered.isEmpty) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        "పూజా విధానాలు ఏవీ లేవు. '30 పూజా విధానాలు లోడ్ చేయండి' పై క్లిక్ చేయండి లేదా '+' బటన్ నొక్కండి.",
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
                    final title = data['title'] ?? '';
                    final deity = data['deity'] ?? '';
                    final cat = data['category'] ?? '';
                    final tag = data['tag'] ?? '';
                    final imgUrl = data['imageUrl'] as String? ?? '';
                    final days = data['auspiciousDays'] ?? '';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 54,
                          height: 54,
                          color: const Color(0xFFFFF3DE),
                          child: imgUrl.isNotEmpty && imgUrl.startsWith('http')
                              ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.temple_hindu_rounded,
                                    color: Color(0xFF8A1E2B),
                                    size: 28,
                                  ),
                                )
                              : const Icon(
                                  Icons.temple_hindu_rounded,
                                  color: Color(0xFF8A1E2B),
                                  size: 28,
                                ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                          if (tag.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDEEE3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(fontSize: 10, color: Color(0xFFB84500), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text("ఇండెక్స్: ${data['order'] ?? 0} • దేవత: $deity • విభాగం: $cat • సమయం: $days"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            tooltip: "సవరించు (Edit)",
                            onPressed: () => _openPujaDialog(context, doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: "తొలగించు (Delete)",
                            onPressed: () => _deletePuja(context, doc),
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
            "పూజా విధానాల బల్క్ ఇంపోర్ట్ (Bulk JSON Import)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "క్రింది ఫార్మాట్‌లో JSON లిస్ట్ పేస్ట్ చేసి ఒకేసారి అనేక పూజలు Firestore లోకి అప్‌లోడ్ చేయవచ్చు:",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jsonUploadCtrl,
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '[\n  {\n    "id": "ganapati_puja",\n    "title": "గణపతి పూజ",\n    "deity": "గణపతి",\n    "category": "నిత్య పూజ",\n    "shortDesc": "...",\n    "samagri": "...",\n    "fullVidhanam": "...",\n    "imageUrl": "https://...",\n    "auspiciousDays": "...",\n    "isActive": true,\n    "order": 1\n  }\n]',
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
