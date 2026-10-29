import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalContentScreen extends StatelessWidget {
  final String title;
  final String documentKey; // 'privacy_policy', 'terms_conditions', 'about_us', 'contact_us', 'copyright', 'faqs'

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.documentKey,
  });

  // Default fallback contents matching divine mandir theme
  static Map<String, Map<String, dynamic>> get _defaults => {
        'privacy_policy': {
          'title': 'గోప్యతా విధానం (Privacy Policy)',
          'lastUpdated': '27 అక్టోబర్ 2026',
          'externalUrl': 'https://divyamandir.app/privacy-policy',
          'content': '''
దివ్య మందిరం (Divya Mandir) మీ వ్యక్తిగత సమాచార భద్రతను అత్యంత గౌరవిస్తుంది.

1. సేకరించబడే సమాచారం:
- పేరు, మొబైల్ నంబర్ మరియు ప్రొఫైల్ వివరాలు (యూజర్ సైన్-ఇన్ కొరకు).
- పూజా సామగ్రి లేదా ఆధ్యాత్మిక పుస్తకాల డెలివరీ కొరకు చిరునామా మరియు పిన్‌కోడ్.
- నోటిఫికేషన్‌లు మరియు రోజువారీ పంచాంగం అలర్ట్స్ కోసం డివైజ్ టోకెన్.

2. సమాచార వినియోగం:
- మీ భక్తి ప్రయాణాన్ని వ్యక్తిగతీకరించడం (దైవ దర్శనాలు, పూజా విధానాలు, జపం కౌంటర్).
- ఆర్డర్ చేసిన సామాగ్రిని మీ చిరునామాకు సకాలంలో డెలివరీ చేయడం.
- మీ సమాచారాన్ని ఎటువంటి థర్డ్ పార్టీ సంస్థలకు విక్రయించము లేదా దుర్వినియోగం చేయము.

3. పేమెంట్ భద్రత:
- అన్ని లావాదేవీలు 100% ఎన్‌క్రిప్ట్ చేయబడిన సెక్యూర్ గేట్‌వేల ద్వారా సురక్షితంగా నిర్వహించబడతాయి.

4. సంప్రదించండి:
ఏదైనా సందేహం ఉంటే privacy@divyamandir.app ద్వారా మమ్మల్ని సంప్రదించవచ్చు.
''',
        },
        'terms_conditions': {
          'title': 'నిబంధనలు & షరతులు (Terms & Conditions)',
          'lastUpdated': '27 అక్టోబర్ 2026',
          'externalUrl': 'https://divyamandir.app/terms',
          'content': '''
దివ్య మందిరం యాప్‌ను ఉపయోగించే ప్రతి భక్తుడు ఈ క్రింది నిబంధనలకు కట్టుబడి ఉండాలి:

1. యాప్ వినియోగం:
- ఈ యాప్ కేవలం ఆధ్యాత్మిక, పూజా మరియు భక్తి ప్రయోజనాల కొరకు మాత్రమే ఉద్దేశించబడింది.
- యాప్‌లోని మంత్రాలు, శ్లోకాలు, క్యాలెండర్ మరియు పూజా వివరాలు నిపుణులైన వేద పండితుల సలహాలతో రూపొందించబడ్డాయి.

2. స్టోర్ & డెలివరీ నిబంధనలు:
- ఆర్డర్ చేసిన పూజా సామాగ్రి 3-5 పనిదినాల్లో సురక్షితంగా డెలివరీ చేయబడుతుంది.
- చెడిపోయిన లేదా దెబ్బతిన్న వస్తువులు అందినట్లయితే 48 గంటల్లో రీప్లేస్‌మెంట్ సౌకర్యం కలదు.

3. ఖాతా భద్రత:
- మీ లాగిన్ వివరాలు మరియు ఖాతా సమాచారాన్ని భద్రంగా ఉంచుకోవడం మీ బాధ్యత.

4. కాపీరైట్ హక్కులు:
- యాప్‌లోని కంటెంట్, డిజైన్ మరియు ఆడియోలు కాపీరైట్ చట్టాల ద్వారా రక్షించబడ్డాయి.
''',
        },
        'about_us': {
          'title': 'మమ్మల్ని గురించి (About Us)',
          'lastUpdated': '2026',
          'externalUrl': 'https://divyamandir.app/about',
          'content': '''
దివ్య మందిరం – మీ అరచేతిలో నిత్య దైవ సాన్నిధ్యం! 🙏

మా లక్ష్యం:
సనాతన ధర్మం, వేద సంస్కృతి, దేవాలయాల చరిత్ర మరియు నిత్య పూజా విశేషాలను ఆధునిక సాంకేతిక పరిజ్ఞానంతో ప్రతి ఇంటా ప్రతి ఒక్కరికీ సులభంగా చేరవేయడమే మా ముఖ్య లక్ష్యం.

మా సేవలు:
• ప్రత్యక్ష దేవాలయ దర్శనాలు (Live Darshan)
• ఖచ్చితమైన తెలుగు తిథి, నక్షత్ర పంచాంగం
• 30+ దైవాల సంపూర్ణ షోడశోపచార పూజా విధానాలు
• నిరంతర ఆడియోతో కూడిన మంత్ర జపం
• స్వచ్ఛమైన పూజా సామాగ్రి మరియు ఆధ్యాత్మిక గ్రంథాల స్టోర్

హరిః ఓం తత్ సత్! 🙏
''',
        },
        'contact_us': {
          'title': 'మమ్మల్ని సంప్రదించండి (Contact Us)',
          'lastUpdated': '2026',
          'externalUrl': 'https://divyamandir.app/contact',
          'content': '''
మీకు ఏవైనా ప్రశ్నలు, సూచనలు లేదా ఫీడ్‌బ్యాక్ ఉన్నాయా? మమ్మల్ని సంప్రదించండి:

📧 ఇమెయిల్: support@divyamandir.app
📞 ఫోన్ నంబర్: +91 98765 43210
🕒 పనివేళలు: ఉదయం 9:00 నుండి సాయంత్రం 7:00 వరకు
📍 చిరునామా: దివ్య మందిరం ట్రస్ట్, హైదరాబాదు, తెలంగాణ - 500001
''',
        },
        'copyright': {
          'title': 'కాపీరైట్ విధానం (Copyright Policy)',
          'lastUpdated': '2026',
          'externalUrl': 'https://divyamandir.app/copyright',
          'content': '''
దివ్య మందిరం యాప్‌లో ప్రదర్శించబడే అన్ని కంటెంట్, ఇమేజ్‌లు, వీడియోలు, శ్లోకాలు, పూజా విధానాలు మరియు గ్రాఫిక్స్ కాపీరైట్ చట్టాల ప్రకారం రక్షించబడ్డాయి. అనుమతి లేకుండా వాణిజ్య ప్రయోజనాల కోసం పునర్ముద్రించడం లేదా పంపిణీ చేయడం చట్టరీత్యా నేరం.
''',
        },
        'faqs': {
          'title': 'తరచుగా అడిగే ప్రశ్నలు (FAQs)',
          'lastUpdated': '2026',
          'externalUrl': 'https://divyamandir.app/faqs',
          'content': '''
1. ప్రశ్న: పంచాంగం సమయాలు ఎంతవరకు ఖచ్చితమైనవి?
సమాధానం: మా పంచాంగం ఖచ్చితమైన ఖగోళ లెక్కల ఆధారంగా మరియు ప్రఖ్యాత సిద్ధాంతుల సూచనల ప్రకారం రోజువారీగా లైవ్‌గా లెక్కించబడుతుంది.

2. ప్రశ్న: స్టోర్ నుండి ఆర్డర్ చేసిన వస్తువులు ఎప్పుడు అందుతాయి?
సమాధానం: సాధారణ డెలివరీలో 3-5 రోజుల్లో, ఎక్స్‌ప్రెస్ డెలివరీలో 1-2 రోజుల్లో నేరుగా మీ ఇంటికి డెలివరీ చేయబడతాయి.

3. ప్రశ్న: మంత్ర జపం కౌంటర్ ఎలా పనిచేస్తుంది?
సమాధానం: మీరు జపం స్క్రీన్‌లో స్క్రీన్‌ను ట్యాప్ చేసినా లేదా వాల్యూమ్ బటన్ ద్వారా అయినా కౌంట్ చేయవచ్చు. ఆడియోతో పాటు 108 సార్లు కౌంట్ పూర్తి కాగానే వైబ్రేషన్ అలర్ట్ వస్తుంది.
''',
        },
      };

  Future<void> _openExternalLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('లింక్ ఓపెన్ చేయలేకపోయాము: $url')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('లింక్ ఓపెన్ చేయడంలో లోపం: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultData = _defaults[documentKey] ?? {
      'title': title,
      'lastUpdated': '2026',
      'externalUrl': 'https://divyamandir.app',
      'content': 'వివరాలు త్వరలో...',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE), // Divine warm cream theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29), // Rich divine maroon
        elevation: 1,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20),
            tooltip: 'వెబ్‌సైట్‌లో చూడండి',
            onPressed: () {
              final url = defaultData['externalUrl'] ?? 'https://divyamandir.app';
              _openExternalLink(context, url);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Fetch Real-time Content from Firebase Firestore (app_legal_pages)
        stream: FirebaseFirestore.instance
            .collection('app_legal_pages')
            .doc(documentKey)
            .snapshots(),
        builder: (context, snapshot) {
          String displayTitle = defaultData['title'] ?? title;
          String displayContent = defaultData['content'] ?? '';
          String lastUpdated = defaultData['lastUpdated'] ?? '2026';
          String externalUrl = defaultData['externalUrl'] ?? 'https://divyamandir.app';

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              displayTitle = data['title'] ?? displayTitle;
              displayContent = data['content'] ?? displayContent;
              lastUpdated = data['lastUpdated'] ?? lastUpdated;
              externalUrl = data['externalUrl'] ?? externalUrl;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1E4CE)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A1B29).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEFD9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_user_rounded, color: Color(0xFF8A1E2B), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A1B29),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'చివరిగా నవీకరించబడింది: $lastUpdated',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main Content Body Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1E4CE)),
                  ),
                  child: Text(
                    displayContent,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // External Link Button (as requested by user)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _openExternalLink(context, externalUrl),
                    icon: const Icon(Icons.language, color: Color(0xFF6A1B29)),
                    label: const Text(
                      'అధికారిక వెబ్‌సైట్ ద్వారా చదవండి ➔',
                      style: TextStyle(
                        color: Color(0xFF6A1B29),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6A1B29), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
