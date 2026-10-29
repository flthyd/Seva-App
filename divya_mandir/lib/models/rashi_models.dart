class RashiDataModel {
  final String id; // e.g. mesha
  final String nameTelugu; // e.g. మేష
  final String englishName; // Aries
  final String datesSpan; // మార్చి 21 - ఏప్రిల్ 19
  final String lordTelugu; // అధిపతి: కుజుడు
  final String element; // తత్త్వం: అగ్ని
  final String luckyNumber; // అదృష్ట సంఖ్య: 9, 3
  final String luckyColor; // ఎరుపు, పసుపు
  final String luckyDay; // మంగళవారం
  final String luckyGem; // పగడం, పుష్యరాగం
  final String luckyDirection; // తూర్పు
  final String symbol; // ♈

  // 1. దిన ఫలితం (Daily Horoscope)
  final String dailyGeneral;
  final String dailyCareer; // ఉద్యోగం, వృత్తి
  final String dailyFinance; // ఆర్థిక పరిస్థితి
  final String dailyHealth; // ఆరోగ్యం, దినచర్య
  final String dailyFamily; // కుటుంబం, సంబంధాలు
  final String dailyChildren; // పిల్లలు, వారి పురోగతి
  final String dailyBusiness; // వ్యాపారం, స్వయం ఉపాధి
  final String dailyEducation; // విద్య, పోటీ పరీక్షలు
  final String dailySpiritual; // ఆధ్యాత్మికం

  // 2. వార ఫలాలు (Weekly Horoscope)
  final String weeklyOverview;
  final List<String> weeklyDaysRating; // Mon..Sun star ratings

  // 3. మాస ఫలాలు (Monthly Horoscope)
  final String monthlyOverview;
  final String monthlyFinance; // ఆర్థిక పరిస్థితి
  final String monthlyCareer; // ఉద్యోగం, వృత్తి
  final String monthlyHealth; // ఆరోగ్యం
  final String monthlyFamily; // కుటుంబం, సంబంధాలు
  final String monthlyChildren; // పిల్లలు, వారి పురోగతి
  final String monthlyBusiness; // వ్యాపారం, స్వయం ఉపాధి
  final String monthlyEducation; // విద్య, పోటీ పరీక్షలు
  final int healthScore;
  final int careerScore;
  final int financeScore;
  final int familyScore;
  final int loveScore;
  final int spiritualScore;

  // 4. సంవత్సర ఫలాలు (Yearly Horoscope)
  final String yearlyOverview;
  final String yearlyFinance; // ఆర్థిక పరిస్థితి
  final String yearlyCareer; // ఉద్యోగం, వృత్తి
  final String yearlyHealth; // ఆరోగ్యం
  final String yearlyFamily; // కుటుంబం, సంబంధాలు
  final String yearlyChildren; // పిల్లలు, వారి పురోగతి
  final String yearlyBusiness; // వ్యాపారం, స్వయం ఉపాధి
  final String yearlyEducation; // విద్య, పోటీ పరీక్షలు
  final String guruImpact;
  final String shaniImpact;
  final String rahuKetuImpact;

  // పరిహారాలు & ఉపాయాలు
  final List<String> remedies;

  const RashiDataModel({
    required this.id,
    required this.nameTelugu,
    required this.englishName,
    required this.datesSpan,
    required this.lordTelugu,
    required this.element,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyDay,
    required this.luckyGem,
    required this.luckyDirection,
    required this.symbol,
    required this.dailyGeneral,
    required this.dailyCareer,
    required this.dailyFinance,
    required this.dailyHealth,
    required this.dailyFamily,
    this.dailyChildren = 'సంతాన పురోగతి బాగుంటుంది. వారి విద్య మరియు ప్రవర్తన సంతృప్తికరంగా ఉంటుంది.',
    this.dailyBusiness = 'వ్యాపార విస్తరణ ప్రయత్నాలు సఫలమవుతాయి. నూతన పెట్టుబడులు అనుకూలిస్తాయి.',
    this.dailyEducation = 'విద్యార్థులకు ఏకాగ్రత పెరుగుతుంది. పోటీ పరీక్షలకు సిద్ధమయ్యే వారికి అనుకూల సమయం.',
    required this.dailySpiritual,
    required this.weeklyOverview,
    this.weeklyDaysRating = const ['⭐⭐⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐'],
    required this.monthlyOverview,
    this.monthlyFinance = 'ఆదాయం నిలకడగా ఉంటుంది. ధన ప్రవాహం పెరిగి పాత బాకీలు వసూలవుతాయి.',
    this.monthlyCareer = 'ఉద్యోగంలో నూతన బాధ్యతలు, పదోన్నతి అవకాశాలు మరియు ఉన్నతాధికారుల మన్ననలు.',
    this.monthlyHealth = 'ఆరోగ్యం మెరుగ్గా ఉంటుంది. కాలానుగుణ ఆహార నియమాలు పాటించడం మంచిది.',
    this.monthlyFamily = 'కుటుంబంలో శుభకార్య వాతావరణం, సభ్యుల మధ్య సఖ్యత మరియు ఆనందం.',
    this.monthlyChildren = 'పిల్లల చదువు, నూతన ఉద్యోగ అవకాశాలు లేదా ఉన్నత విద్యా ప్రవేశాల్లో పురోగతి.',
    this.monthlyBusiness = 'స్వయం ఉపాధి మరియు వాణిజ్య రంగాల వారికి లాభాల వృద్ధి.',
    this.monthlyEducation = 'విద్యార్థులు ఉన్నత ఫలితాలు సాధిస్తారు. పరీక్షలలో ప్రతిభ వెలుగులోకి వస్తుంది.',
    this.healthScore = 80,
    this.careerScore = 75,
    this.financeScore = 70,
    this.familyScore = 85,
    this.loveScore = 65,
    this.spiritualScore = 90,
    required this.yearlyOverview,
    this.yearlyFinance = 'ఆర్థిక పరిస్థితి బలపడుతుంది. స్థిరాస్తులు కొనుగోలు చేసే యోగం కలదు.',
    this.yearlyCareer = 'వృత్తి ఉద్యోగాల్లో కీలకమైన పురోగతి, స్థానచలనం లేదా గౌరవ ప్రదమైన మార్పులు.',
    this.yearlyHealth = 'ఆరోగ్యం పట్ల శ్రద్ధ వహించాలి. వ్యాయామం, యోగా జీవనశైలిలో భాగం చేసుకోవాలి.',
    this.yearlyFamily = 'బంధుమిత్రుల సహాయ సహకారాలు లభిస్తాయి. గృహంలో మంగళకరమైన వేడుకలు.',
    this.yearlyChildren = 'సంతానం వల్ల కుటుంబానికి కీర్తి ప్రతిష్టలు పెరుగుతాయి.',
    this.yearlyBusiness = 'స్వతంత్ర వ్యాపారాలు ప్రారంభించడానికి మరియు విస్తరించడానికి మంచి అవకాశాలు.',
    this.yearlyEducation = 'పోటీ పరీక్షలలో ఉత్తీర్ణత సాధించి నూతన ఉద్యోగాలలో స్థిరపడతారు.',
    required this.guruImpact,
    required this.shaniImpact,
    required this.rahuKetuImpact,
    this.remedies = const [
      'ప్రతి మంగళవారం హనుమాన్ చాలీసా పారాయణం చేయండి.',
      'సుబ్రహ్మణ్య స్వామికి ఎర్రని పూలతో పూజించడం శ్రేయస్కరం.',
      'పేదలకు లేదా విద్యార్థులకు సహాయం చేయడం వల్ల శుభ ఫలితాలు కలుగుతాయి.',
    ],
  });
}

/// User Profile or Family Member Astrology Profile Saved in Local / Firestore
class UserAstrologyProfile {
  final String id;
  final String fullName;
  final String relation; // నేను (Self), జీవిత భాగస్వామి, కొడుకు, కూతురు, తండ్రి, తల్లి, ఇతర
  final DateTime birthDate;
  final String birthTime; // e.g. 10:30 AM
  final String birthPlace; // e.g. హైదరాబాద్
  final double? latitude;
  final double? longitude;
  final String rashiId; // e.g. mesha
  final String nakshatram; // e.g. అశ్విని
  final String padam; // 1, 2, 3, 4
  final String? phoneNumber;

  UserAstrologyProfile({
    required this.id,
    required this.fullName,
    required this.relation,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    this.latitude,
    this.longitude,
    required this.rashiId,
    required this.nakshatram,
    required this.padam,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'relation': relation,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime,
      'birthPlace': birthPlace,
      'latitude': latitude,
      'longitude': longitude,
      'rashiId': rashiId,
      'nakshatram': nakshatram,
      'padam': padam,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserAstrologyProfile.fromMap(Map<String, dynamic> map) {
    return UserAstrologyProfile(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      relation: map['relation'] ?? 'నేను',
      birthDate: map['birthDate'] != null ? DateTime.tryParse(map['birthDate']) ?? DateTime(1995, 1, 1) : DateTime(1995, 1, 1),
      birthTime: map['birthTime'] ?? '10:00 AM',
      birthPlace: map['birthPlace'] ?? 'హైదరాబాద్',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      rashiId: map['rashiId'] ?? 'mesha',
      nakshatram: map['nakshatram'] ?? 'అశ్విని',
      padam: map['padam'] ?? '1',
      phoneNumber: map['phoneNumber'],
    );
  }
}
