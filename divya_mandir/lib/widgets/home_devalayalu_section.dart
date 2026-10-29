import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/temple_model.dart';
import '../screens/devalayalu_list_screen.dart';
import '../screens/temple_detail_screen.dart';
import '../services/language_service.dart';

/// "దేవాలయాలు" (Temples) Home Page Section matching user UI screenshot:
/// - Header: [Golden Temple Crest Icon] "దేవాలయాలు" ----------------- [మరిన్ని →]
/// - Horizontal scrolling row of Temple cards:
///   - Rounded image card with glowing temple gopuram
///   - Temple Name (e.g., తిరుమల, శ్రీశైలం, భద్రాచలం, కాళేశ్వరం)
///   - State Name (e.g., ఆంధ్రప్రదేశ్, తెలంగాణ)
/// - Tap card opens TempleDetailScreen with full story, darshan timings, online booking link!
/// - Tap "మరిన్ని →" opens full DevalayaluListScreen (All temples directory, search, state filters)
class HomeDevalayaluSection extends StatelessWidget {
  const HomeDevalayaluSection({super.key});

  static List<TempleModel> get defaultTemples => [
        TempleModel(
          id: 'tirumala',
          nameTelugu: 'తిరుమల',
          nameEnglish: 'Tirumala Tirupati',
          state: 'ఆంధ్రప్రదేశ్',
          district: 'తిరుపతి',
          deity: 'శ్రీ వేంకటేశ్వర స్వామి',
          assetPath: 'assets/images/temples/tirumala.png',
          historyStory:
              'కలియుగ ప్రత్యక్ష దైవమైన శ్రీ వేంకటేశ్వర స్వామి కొలువై ఉన్న పరమ పవిత్ర పుణ్యక్షేత్రం తిరుమల. సప్తగిరులపై వెలసిన స్వామి వారిని దర్శించుకోవడం వల్ల సకల పాపాలు హరించి ఇష్టార్థ సిద్ధి కలుగుతుందని భక్తుల ప్రగాఢ విశ్వాసం. ఇక్కడి లడ్డూ ప్రసాదం ప్రపంచ ప్రఖ్యాతి గాంచింది.',
          timings: 'ఉదయం 3:00 నుండి రాత్రి 11:30 వరకు (సుప్రభాతం నుండి ఏకాంతసేవ వరకు)',
          specialSevas: 'సుప్రభాత సేవ, తోమాల సేవ, అర్చన, కల్యాణోత్సవం, ఊంజల్ సేవ, సహస్ర దీపాలంకార సేవ',
          onlineBookingUrl: 'https://ttdevasthanams.ap.gov.in',
          googleMapsUrl: 'https://maps.google.com/?q=Tirumala+Temple',
          isPopular: true,
          order: 1,
        ),
        TempleModel(
          id: 'srisailam',
          nameTelugu: 'శ్రీశైలం',
          nameEnglish: 'Srisailam Mallikarjuna',
          state: 'తెలంగాణ',
          district: 'నంద్యాల / కర్నూలు సరిహద్దు',
          deity: 'శ్రీ మల్లికార్జున స్వామి & భ్రమరాంబికా దేవి',
          assetPath: 'assets/images/temples/srisailam.png',
          historyStory:
              'ద్వాదశ జ్యోతిర్లింగాలలో రెండవది, అష్టాదశ శక్తిపీఠాలలో ఒకటైన దివ్య క్షేత్రం శ్రీశైలం. కృష్ణా నదీ తీరాన నల్లమల అరణ్యాలలో వెలసిన ఈ క్షేత్రంలో భక్తులు స్వయంగా మల్లికార్జున లింగాన్ని స్పర్శించి పూజించుకునే అరుదైన భాగ్యం ఉంటుంది.',
          timings: 'ఉదయం 4:30 నుండి రాత్రి 10:00 వరకు',
          specialSevas: 'రుద్రాభిషేకం, గర్భాలయ స్పర్శ దర్శనం, చండీ హోమం, కల్యాణోత్సవం',
          onlineBookingUrl: 'https://srisailadevasthanam.org',
          googleMapsUrl: 'https://maps.google.com/?q=Srisailam+Temple',
          isPopular: true,
          order: 2,
        ),
        TempleModel(
          id: 'bhadrachalam',
          nameTelugu: 'భద్రాచలం',
          nameEnglish: 'Bhadrachalam Rama Temple',
          state: 'ఆంధ్రప్రదేశ్',
          district: 'భద్రాద్రి కొత్తగూడెం',
          deity: 'శ్రీ సీతారామచంద్ర స్వామి',
          assetPath: 'assets/images/temples/bhadrachalam.png',
          historyStory:
              'గోదావరి నదీ తీరాన వెలసిన దక్షిణ అయోధ్య శ్రీ భద్రాచలం. భక్త రామదాసు నిర్మించిన ఈ దివ్య మందిరంలో రామయ్య చతుర్భుజాలతో శంఖు చక్ర ధనుర్బాణాలతో సీతా లక్ష్మణ సమేతుడై కొలువై ఉన్నాడు. శ్రీరామనవమి తిరుకల్యాణ మహోత్సవం ఇక్కడ అత్యంత వైభవోపేతంగా జరుగుతుంది.',
          timings: 'ఉదయం 4:00 నుండి రాత్రి 9:00 వరకు',
          specialSevas: 'సుప్రభాతం, నిత్య కల్యాణం, సహస్రనామార్చన, పవళింపు సేవ',
          onlineBookingUrl: 'https://bhadrachalam.org',
          googleMapsUrl: 'https://maps.google.com/?q=Bhadrachalam+Temple',
          isPopular: true,
          order: 3,
        ),
        TempleModel(
          id: 'kaleshwaram',
          nameTelugu: 'కాళేశ్వరం',
          nameEnglish: 'Kaleshwara Mukteshwara',
          state: 'ఆంధ్రప్రదేశ్',
          district: 'జయశంకర్ భూపాలపల్లి',
          deity: 'శ్రీ కాళేశ్వర ముక్తేశ్వర స్వామి',
          assetPath: 'assets/images/temples/kaleshwaram.png',
          historyStory:
              'ఒకే పానవట్టంపై రెండు లింగాలు (శివుడు & యముడు - కాళేశ్వరుడు, ముక్తేశ్వరుడు) దర్శనమిచ్చే అత్యంత విశిష్టమైన త్రివేణి సంగమ క్షేత్రం కాళేశ్వరం. దక్షిణ కాశీగా ప్రసిద్ధి చెందిన ఈ క్షేత్రంలో కాళేశ్వర లింగం ద్వారా పోసిన నీరు అదృశ్యమవడం ఇక్కడి అద్భుత ఆధ్యాత్మిక రహస్యం.',
          timings: 'ఉదయం 4:30 నుండి మధ్యాహ్నం 1:00 వరకు, సాయంత్రం 3:30 నుండి రాత్రి 8:30 వరకు',
          specialSevas: 'మహాన్యాసపూర్వక రుద్రాభిషేకం, సహస్ర ఘటాభిషేకం, లక్ష బిల్వార్చన',
          onlineBookingUrl: 'https://kaleshwaram.telangana.gov.in',
          googleMapsUrl: 'https://maps.google.com/?q=Kaleshwaram+Temple',
          isPopular: true,
          order: 4,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // 1. Check if section is enabled/disabled by Admin
      stream: FirebaseFirestore.instance.collection('app_settings').doc('devalayalu').snapshots(),
      builder: (context, settingsSnap) {
        if (settingsSnap.hasData && settingsSnap.data != null && settingsSnap.data!.exists) {
          final settings = settingsSnap.data!.data() as Map<String, dynamic>?;
          final isEnabled = settings?['isEnabled'] ?? true;
          if (!isEnabled) {
            return const SizedBox.shrink(); // Section disabled by Admin
          }
        }

        // 2. Fetch Active Temples from Firestore
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('devalayalu')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            List<TempleModel> temples = [];

            if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
              temples = snap.data!.docs.map((doc) {
                return TempleModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();
              // Sort by order
              temples.sort((a, b) => a.order.compareTo(b.order));
            }

            // Fallback to defaults if Firestore has no data yet
            if (temples.isEmpty) {
              temples = defaultTemples;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF4), // Warm divine cream container
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF1E4CE),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A5A20).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER: [Icon] దేవాలయాలు ------------ [మరిన్ని →]
                    Row(
                      children: [
                        // Divine Temple Gopuram Crest Icon
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/temples/temple_header_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.temple_hindu_rounded,
                              color: Color(0xFFC0392B),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.devalayalu,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B111D),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        // Warm Pill: "మరిన్ని →"
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DevalayaluListScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDEFD9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF0D5AC),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.seeMore,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A1B29),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: Color(0xFF6A1B29),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 2. HORIZONTAL SCROLLER OF TEMPLE CARDS
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: temples.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final temple = temples[index];
                          return _buildTempleCard(context, temple);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTempleCard(BuildContext context, TempleModel temple) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TempleDetailScreen(temple: temple),
          ),
        );
      },
      child: SizedBox(
        width: 88,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Temple Gopuram Card Image
            Container(
              width: 88,
              height: 98,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildTempleImage(temple),
              ),
            ),
            const SizedBox(height: 6),
            // Temple Name
            Text(
              LanguageService().isTelugu
                  ? temple.nameTelugu
                  : (temple.nameEnglish.isNotEmpty ? temple.nameEnglish : temple.nameTelugu),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2028),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1),
            // State Name (e.g. Andhra Pradesh, Telangana)
            Text(
              LanguageService().isTelugu
                  ? temple.state
                  : (temple.state.contains('ఆంధ్ర') ? 'Andhra Pradesh' : 'Telangana'),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5A6E85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleImage(TempleModel temple) {
    // 1. Network image if custom provided
    if (temple.imageUrl.isNotEmpty && temple.imageUrl.startsWith('http')) {
      return Image.network(
        temple.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAsset(temple),
      );
    }
    // 2. Asset image fallback
    return _buildFallbackAsset(temple);
  }

  Widget _buildFallbackAsset(TempleModel temple) {
    if (temple.assetPath.isNotEmpty) {
      return Image.asset(
        temple.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8D7C3),
      child: const Center(
        child: Icon(
          Icons.temple_hindu_rounded,
          color: Color(0xFF6A1B29),
          size: 36,
        ),
      ),
    );
  }
}
