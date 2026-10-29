import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rashi_models.dart';
import '../services/telugu_rashi_service.dart';
import 'know_your_rashi_screen.dart';

class RashiPalaluDetailScreen extends StatefulWidget {
  final String initialRashiId;
  final UserAstrologyProfile? userConfirmedProfile;

  const RashiPalaluDetailScreen({
    super.key,
    this.initialRashiId = 'mesha',
    this.userConfirmedProfile,
  });

  @override
  State<RashiPalaluDetailScreen> createState() => _RashiPalaluDetailScreenState();
}

class _RashiPalaluDetailScreenState extends State<RashiPalaluDetailScreen> with SingleTickerProviderStateMixin {
  final _service = TeluguRashiService();
  late TabController _tabController;

  late String _selectedRashiId;
  int _activePeriodTab = 0; // 0: నేడు, 1: వారం, 2: మాసం, 3: సంవత్సరం
  late DateTime _currentDate;

  UserAstrologyProfile? _activeProfile;
  List<UserAstrologyProfile> _savedProfiles = [];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedRashiId = widget.initialRashiId;
    _activeProfile = widget.userConfirmedProfile;
    _tabController = TabController(length: 4, vsync: this);
    _loadUserProfiles();
  }

  Future<void> _loadUserProfiles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('rashi_profiles')
          .get();

      if (snap.docs.isNotEmpty) {
        final list = snap.docs.map((d) => UserAstrologyProfile.fromMap(d.data())).toList();
        setState(() {
          _savedProfiles = list;
          if (_activeProfile == null) {
            _activeProfile = list.first;
            _selectedRashiId = _activeProfile!.rashiId;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchProfile(UserAstrologyProfile p) {
    setState(() {
      _activeProfile = p;
      _selectedRashiId = p.rashiId;
    });
  }

  void _openKnowYourRashi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KnowYourRashiScreen(
          onRashiConfirmed: (p) {
            setState(() {
              _savedProfiles.removeWhere((e) => e.id == p.id);
              _savedProfiles.add(p);
              _activeProfile = p;
              _selectedRashiId = p.rashiId;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rashi = _service.getRashiById(_selectedRashiId);
    final hasConfirmedRashi = _activeProfile != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29), // Deep divine maroon
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${rashi.nameTelugu} రాశి",
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_rounded, size: 22),
            tooltip: 'కుటుంబ సభ్యుల రాశులు (Family Profiles)',
            onPressed: () => _openFamilyProfilesModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            tooltip: 'మీ రాశిని తెలుసుకోండి (Know Your Rashi)',
            onPressed: _openKnowYourRashi,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            tooltip: 'షేర్ చేయండి',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. LIVE DATE SELECTOR HEADER (Live Real-Time Date & Weekday)
            _buildLiveDateBannerRow(),

            // 2. 12 RASHI CIRCULAR HORIZONTAL SCROLLER (Screen 1 & 2)
            _build12RashiHorizontalScroller(),

            const SizedBox(height: 10),

            // 3. FIRST TIME / UNCONFIRMED USER NOTICE (If user has not confirmed their Rashi yet)
            if (!hasConfirmedRashi) _buildUnconfirmedRashiNoticeBanner(),

            // 4. PERIOD TABS: [నేడు] [వారం] [మాసం] [సంవత్సరం] (Exact matching Screen 2)
            _buildPeriodTabsRow(),

            const SizedBox(height: 12),

            // 5. RASHI HOROSCOPE CONTENT (Conditional: Basic overview if unconfirmed, Full In-Depth once confirmed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: hasConfirmedRashi ? _buildDetailedTabContent(rashi) : _buildBasicPreviewTabContent(rashi),
            ),

            const SizedBox(height: 16),

            // 6. LUCKY DETAILS SUMMARY CARD (Screen 10 - అదృష్ట వివరాలు)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: _buildLuckyDetailsCard(rashi),
            ),

            const SizedBox(height: 16),

            // 7. REMEDIES & UPAYALU (Screen 9 - రాశి పరిహారాలు & ఉపాయాలు)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: _buildRemediesCard(rashi),
            ),

            const SizedBox(height: 16),

            // 8. RASHI COMPATIBILITY (Screen 6 - రాశి అనుకూలత)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: _buildCompatibilityCard(rashi),
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  // --- 1. LIVE DATE BANNER ROW ---
  Widget _buildLiveDateBannerRow() {
    final dayNameTelugu = _getTeluguDayName(_currentDate.weekday);
    final monthNameTelugu = _getTeluguMonthName(_currentDate.month);

    return Container(
      color: const Color(0xFF6A1B29),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _currentDate = _currentDate.subtract(const Duration(days: 1));
              });
            },
          ),
          const SizedBox(width: 8),
          const Icon(Icons.calendar_month_rounded, color: Color(0xFFF1C40F), size: 18),
          const SizedBox(width: 8),
          Text(
            "${_currentDate.day} $monthNameTelugu ${_currentDate.year}, $dayNameTelugu",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _currentDate = _currentDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  // --- 2. 12 RASHI CIRCULAR HORIZONTAL SCROLLER ---
  Widget _build12RashiHorizontalScroller() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 78,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: TeluguRashiService.allRashis.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, idx) {
            final r = TeluguRashiService.allRashis[idx];
            final isSelected = r.id == _selectedRashiId;

            return GestureDetector(
              onTap: () => setState(() => _selectedRashiId = r.id),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF1C40F).withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Image.asset(
                      'assets/images/rashi_gold/${r.id}.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6A1B29),
                        ),
                        child: Center(
                          child: Text(
                            r.symbol,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    r.nameTelugu,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFF4B5565),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 3. UNCONFIRMED RASHI NOTICE BANNER ---
  Widget _buildUnconfirmedRashiNoticeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1D8B4), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "మీ రాశిని ఖచ్చితంగా తెలుసుకోండి!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF6A1B29)),
                ),
                SizedBox(height: 2),
                Text(
                  "మీ పూర్తి వ్యక్తిగత రాశిఫలం, ఉద్యోగం & ఆర్థిక వివరాల కోసం మీ రాశిని నిర్ణయించండి.",
                  style: TextStyle(fontSize: 11.5, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B29),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _openKnowYourRashi,
            child: const Text("నిర్ణయించండి", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 4. PERIOD TABS: [నేడు] [వారం] [మాసం] [సంవత్సరం] (Screen 2) ---
  Widget _buildPeriodTabsRow() {
    final tabs = ['నేడు', 'వారం', 'మాసం', 'సంవత్సరం'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _activePeriodTab == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activePeriodTab = idx),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFF4ECE1),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[idx],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF4A1A22),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- 5A. BASIC PREVIEW CONTENT (Shown before confirming user Rashi) ---
  Widget _buildBasicPreviewTabContent(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${rashi.nameTelugu} రాశి ప్రాథమిక సమాచారం",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rashi.datesSpan,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAspectTile("సంక్షిప్త ఫలితం (Overview)", rashi.dailyGeneral, Icons.lightbulb_outline),
          _buildAspectTile("అధిపతి & తత్త్వం", "${rashi.lordTelugu} • ${rashi.element}", Icons.shield_outlined),
          _buildAspectTile("ఉపాయం / ఆరాధన", rashi.dailySpiritual, Icons.self_improvement),
          const SizedBox(height: 14),

          // Call to action button to unlock all 8 in-depth sections
          InkWell(
            onTap: _openKnowYourRashi,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB74D)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_open_rounded, color: Color(0xFFD84315), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "పూర్తి ఉద్యోగం, ఆర్థిక, కుటుంబ & వ్యాపార ఫలితాల కొరకు మీ వివరాలను నిర్ధారించండి.",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5A141A)),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF5A141A)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5B. DETAILED TAB CONTENT (Shown after user confirms Rashi) ---
  Widget _buildDetailedTabContent(RashiDataModel rashi) {
    if (_activePeriodTab == 0) {
      return _buildDailyDetailedView(rashi);
    } else if (_activePeriodTab == 1) {
      return _buildWeeklyDetailedView(rashi);
    } else if (_activePeriodTab == 2) {
      return _buildMonthlyDetailedView(rashi);
    } else {
      return _buildYearlyDetailedView(rashi);
    }
  }

  // DAILY VIEW
  Widget _buildDailyDetailedView(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${rashi.nameTelugu} రాశి నేటి సమగ్ర ఫలితాలు",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              const Spacer(),
              const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFF9800), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          _buildAspectTile("సాధారణ ఫలితం & దినచర్య", rashi.dailyGeneral, Icons.lightbulb_outline),
          _buildAspectTile("ఆర్థిక పరిస్థితి (Finance)", rashi.dailyFinance, Icons.account_balance_wallet_outlined),
          _buildAspectTile("ఉద్యోగం, వృత్తి & కెరీర్ (Job & Career)", rashi.dailyCareer, Icons.work_outline),
          _buildAspectTile("వ్యాపారం & స్వయం ఉపాధి (Business)", rashi.dailyBusiness, Icons.storefront_outlined),
          _buildAspectTile("ఆరోగ్యం & దినచర్య (Health & Wellness)", rashi.dailyHealth, Icons.favorite_border),
          _buildAspectTile("కుటుంబం & సంబంధాలు (Family & Relationships)", rashi.dailyFamily, Icons.people_outline),
          _buildAspectTile("పిల్లలు & వారి పురోగతి (Children's Growth)", rashi.dailyChildren, Icons.child_care_rounded),
          _buildAspectTile("విద్య & పోటీ పరీక్షలు (Education & Exams)", rashi.dailyEducation, Icons.school_outlined),
          _buildAspectTile("ఆధ్యాత్మికం & సాధన (Spiritual)", rashi.dailySpiritual, Icons.self_improvement),
        ],
      ),
    );
  }

  // WEEKLY VIEW
  Widget _buildWeeklyDetailedView(RashiDataModel rashi) {
    final days = ['సోమవారం', 'మంగళవారం', 'బుధవారం', 'గురువారం', 'శుక్రవారం', 'శనివారం', 'ఆదివారం'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "సమగ్ర వార ఫలాలు (ఈ వారం అంచనా)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 8),
          Text(rashi.weeklyOverview, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          const Divider(height: 24),
          const Text("వారం రోజుల అనుకూలత (Daily Rating):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...List.generate(days.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(days[i], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(rashi.weeklyDaysRating[i], style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // MONTHLY VIEW
  Widget _buildMonthlyDetailedView(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "సమగ్ర మాస ఫలాలు (నెలవారీ ఫలితాలు)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 8),
          Text(rashi.monthlyOverview, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          const Divider(height: 20),
          _buildAspectTile("ఆర్థిక పరిస్థితి", rashi.monthlyFinance, Icons.account_balance_wallet_outlined),
          _buildAspectTile("ఉద్యోగం & వృత్తి", rashi.monthlyCareer, Icons.work_outline),
          _buildAspectTile("వ్యాపారం & స్వయం ఉపాధి", rashi.monthlyBusiness, Icons.storefront_outlined),
          _buildAspectTile("ఆరోగ్యం", rashi.monthlyHealth, Icons.favorite_border),
          _buildAspectTile("కుటుంబం & సంబంధాలు", rashi.monthlyFamily, Icons.people_outline),
          _buildAspectTile("పిల్లలు & వారి పురోగతి", rashi.monthlyChildren, Icons.child_care_rounded),
          _buildAspectTile("విద్య & పోటీ పరీక్షలు", rashi.monthlyEducation, Icons.school_outlined),
          const Divider(height: 24),
          const Text("వివిధ రంగాల్లో బలం (Aspect Scores):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildScoreBar("ఆరోగ్యం (Health)", rashi.healthScore, Colors.green),
          _buildScoreBar("ఉద్యోగం (Career)", rashi.careerScore, Colors.blue),
          _buildScoreBar("వ్యాపారం & ధనం (Finance)", rashi.financeScore, Colors.amber.shade800),
          _buildScoreBar("కుటుంబం (Family)", rashi.familyScore, Colors.orange),
          _buildScoreBar("ఆధ్యాత్మికం (Spiritual)", rashi.spiritualScore, Colors.purple),
        ],
      ),
    );
  }

  // YEARLY VIEW
  Widget _buildYearlyDetailedView(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "సంవత్సర సమగ్ర ఫలితాలు",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 8),
          Text(rashi.yearlyOverview, style: const TextStyle(fontSize: 13.5, height: 1.4)),
          const Divider(height: 20),
          _buildAspectTile("ఆర్థిక పరిస్థితి", rashi.yearlyFinance, Icons.account_balance_wallet_outlined),
          _buildAspectTile("ఉద్యోగం, వృత్తి & వ్యాపారం", rashi.yearlyCareer, Icons.work_outline),
          _buildAspectTile("స్వయం ఉపాధి & వాణిజ్యం", rashi.yearlyBusiness, Icons.storefront_outlined),
          _buildAspectTile("ఆరోగ్యం", rashi.yearlyHealth, Icons.favorite_border),
          _buildAspectTile("కుటుంబం & సంబంధాలు", rashi.yearlyFamily, Icons.people_outline),
          _buildAspectTile("పిల్లలు & వారి పురోగతి", rashi.yearlyChildren, Icons.child_care_rounded),
          _buildAspectTile("విద్య & పోటీ పరీక్షలు", rashi.yearlyEducation, Icons.school_outlined),
          const Divider(height: 20),
          _buildAspectTile("గురు ప్రభావం (Jupiter)", rashi.guruImpact, Icons.brightness_high),
          _buildAspectTile("శని ప్రభావం (Saturn)", rashi.shaniImpact, Icons.shield_moon),
          _buildAspectTile("రాహు-కేతు ప్రభావం (Nodes)", rashi.rahuKetuImpact, Icons.all_inclusive),
        ],
      ),
    );
  }

  Widget _buildAspectTile(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFFFF0ED),
            child: Icon(icon, size: 16, color: const Color(0xFF6A1B29)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12.5, color: Color(0xFF374151), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              Text("$score%", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  // --- 6. LUCKY DETAILS SUMMARY CARD ---
  Widget _buildLuckyDetailsCard(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                "అదృష్ట వివరాలు (Lucky Details)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildLuckyItem("అదృష్ట సంఖ్య", rashi.luckyNumber, Icons.tag)),
              Expanded(child: _buildLuckyItem("అదృష్ట రంగు", rashi.luckyColor, Icons.palette_outlined)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildLuckyItem("అదృష్ట వారం", rashi.luckyDay, Icons.today)),
              Expanded(child: _buildLuckyItem("అదృష్ట రత్నం", rashi.luckyGem, Icons.diamond_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1E4CE)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6A1B29)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.black54)),
                Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1B2028))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. REMEDIES & UPAYALU ---
  Widget _buildRemediesCard(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 20),
              SizedBox(width: 8),
              Text(
                "పరిహారాలు & ఉపాయాలు (Remedies)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...rashi.remedies.map((rem) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🕉️ ", style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(rem, style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF333333))),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 8. RASHI COMPATIBILITY ---
  Widget _buildCompatibilityCard(RashiDataModel rashi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEDBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite_rounded, color: Colors.pink, size: 20),
              SizedBox(width: 8),
              Text(
                "రాశి కలయిక & పొంతన (Compatibility)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(rashi.nameTelugu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/rashi_gold/${rashi.id}.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF6A1B29),
                          child: Text(rashi.symbol, style: const TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.favorite, color: Colors.red, size: 28),
              Column(
                children: [
                  const Text("సింహ / ధనుస్సు", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/rashi_gold/simha.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFFF6D00),
                          child: Text("♌", style: TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                SizedBox(width: 6),
                Text(
                  "కలయిక ఫలితం: 85% చాలా మంచి అనుకూలత!",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FAMILY PROFILES MODAL ---
  void _openFamilyProfilesModal(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "కుటుంబ సభ్యుల రాశులు (Family Profiles)",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF6A1B29)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openKnowYourRashi();
                    },
                  ),
                ],
              ),
              const Divider(height: 16),
              _savedProfiles.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            const Text("ఇంకా కుటుంబ సభ్యుల ప్రొఫైల్స్ సేవ్ చేయలేదు."),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _openKnowYourRashi();
                              },
                              child: const Text("కొత్త ప్రొఫైల్ జోడించండి", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _savedProfiles.length,
                        itemBuilder: (_, idx) {
                          final p = _savedProfiles[idx];
                          final isCurrent = _activeProfile?.id == p.id;
                          final rashiObj = _service.getRashiById(p.rashiId);

                          return ListTile(
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrent ? const Color(0xFFF1C40F) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/rashi_gold/${rashiObj.id}.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                    backgroundColor: isCurrent ? const Color(0xFF6A1B29) : Colors.grey.shade300,
                                    child: Text(rashiObj.symbol, style: TextStyle(color: isCurrent ? Colors.white : Colors.black87)),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(p.fullName, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600)),
                            subtitle: Text("${p.relation} • ${rashiObj.nameTelugu} రాశి (${p.nakshatram})"),
                            trailing: isCurrent ? const Icon(Icons.check_circle, color: Colors.green) : null,
                            onTap: () {
                              _switchProfile(p);
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

  static String _getTeluguMonthName(int month) {
    const months = [
      'జనవరి', 'ఫిబ్రవరి', 'మార్చి', 'ఏప్రిల్', 'మే', 'జూన్',
      'జూలై', 'ఆగస్టు', 'సెప్టెంబర్', 'అక్టోబర్', 'నవంబర్', 'డిసెంబర్'
    ];
    return months[month - 1];
  }

  static String _getTeluguDayName(int weekday) {
    const days = [
      'సోమవారం', 'మంగళవారం', 'బుధవారం', 'గురువారం',
      'శుక్రవారం', 'శనివారం', 'ఆదివారం'
    ];
    return days[weekday - 1];
  }
}
