class DailyPanchangam {
  final DateTime date;
  final String dayName; // e.g. బుధవారం
  final String teluguMonth; // e.g. ఆశ్వయుజ మాసం
  final String samvatsaram; // e.g. శ్రీ క్రోధినామ సంవత్సరం
  final String ayanam; // e.g. దక్షిణాయనం
  final String ruthuvu; // e.g. శరదృతువు
  
  // పంచాంగ భాగాలు
  final String paksham; // e.g. శుక్ల పక్షం
  final String tithi; // e.g. ఏకాదశి
  final String tithiEndTime; // e.g. (04:20 PM వరకు)
  final String? nextTithi; // e.g. ద్వాదశి (తరువాత)
  
  final String nakshatram; // e.g. మృగశిర
  final String nakshatramEndTime; // e.g. (06:12 PM వరకు)
  final String? nextNakshatram; // e.g. ఆరుద్ర (తరువాత)
  
  final String yogam; // e.g. శోభన
  final String yogamEndTime; // e.g. (08:45 PM వరకు)
  final String? nextYogam; // e.g. అతిగండ
  
  final String karanam; // e.g. బవ
  final String karanamEndTime; // e.g. (11:23 AM వరకు)
  final String? nextKaranam; // e.g. బాలవ (తరువాత)
  
  // దిన సమయాలు
  final String suryodayam; // e.g. 06:12 AM
  final String suryastamayam; // e.g. 05:52 PM
  final String chandrodayam; // e.g. 10:24 AM
  final String chandrastamayam; // e.g. 08:48 PM
  final String rahukalam; // e.g. 09:00 AM – 10:30 AM
  final String yamagandam; // e.g. 12:00 PM – 01:30 PM
  final String gulikakalam; // e.g. 03:00 PM – 04:30 PM
  final String abhijitMuhurtham; // e.g. 11:48 AM – 12:36 PM
  final String amruthaKalam; // e.g. 05:12 AM – 06:42 AM
  final String nishiVaaram; // e.g. 08:24 PM – 09:48 PM
  final String varjyam; // e.g. 02:36 PM – 04:12 PM
  final String durmuhurtham; // e.g. 08:24 AM – 09:12 AM
  
  // శుభ సమయాలు
  final String vivahaMuhurtham; // e.g. 07:12 AM – 08:24 AM
  final String gruhaPravesham; // e.g. 10:36 AM – 11:48 AM
  final String vahanaKonugolu; // e.g. 01:12 PM – 02:24 PM
  final String vyaparaPrarambham; // e.g. 04:36 PM – 05:48 PM

  // ప్రత్యేక వివరాలు
  final String? vratamName; // e.g. పాశాంకుశ ఏకాదశి
  final String? festivalName; // e.g. శ్రీవారి బ్రహ్మోత్సవం (దినం 3)
  final String? specialNote; // e.g. ఉపవాసం చేయుట మంచిది.
  final String cityName; // e.g. హైదరాబాద్

  DailyPanchangam({
    required this.date,
    required this.dayName,
    required this.teluguMonth,
    required this.samvatsaram,
    required this.ayanam,
    required this.ruthuvu,
    required this.paksham,
    required this.tithi,
    required this.tithiEndTime,
    this.nextTithi,
    required this.nakshatram,
    required this.nakshatramEndTime,
    this.nextNakshatram,
    required this.yogam,
    required this.yogamEndTime,
    this.nextYogam,
    required this.karanam,
    required this.karanamEndTime,
    this.nextKaranam,
    required this.suryodayam,
    required this.suryastamayam,
    required this.chandrodayam,
    required this.chandrastamayam,
    required this.rahukalam,
    required this.yamagandam,
    required this.gulikakalam,
    required this.abhijitMuhurtham,
    required this.amruthaKalam,
    required this.nishiVaaram,
    required this.varjyam,
    required this.durmuhurtham,
    required this.vivahaMuhurtham,
    required this.gruhaPravesham,
    required this.vahanaKonugolu,
    required this.vyaparaPrarambham,
    this.vratamName,
    this.festivalName,
    this.specialNote,
    required this.cityName,
  });
}

class FestivalItem {
  final String id;
  final String title;
  final DateTime date;
  final String teluguDate; // e.g. 21 అక్టోబర్ 2026, బుధవారం
  final String category; // 'పండుగ', 'వ్రతం', 'ప్రత్యేక దినం'
  final String deityImageUrl;
  final String description;
  final String poojaVidhanam;
  final String mantram;
  final String significance;
  final String tithi;
  final String nakshatram;
  final String vrataType; // e.g. ఉపవాసం
  bool isBookmarked;

  FestivalItem({
    required this.id,
    required this.title,
    required this.date,
    required this.teluguDate,
    required this.category,
    required this.deityImageUrl,
    required this.description,
    required this.poojaVidhanam,
    required this.mantram,
    required this.significance,
    required this.tithi,
    required this.nakshatram,
    this.vrataType = 'ఉపవాసం',
    this.isBookmarked = false,
  });
}

class CityLocation {
  final String name; // e.g. హైదరాబాద్
  final String state; // e.g. తెలంగాణ
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
  });
}

class CalendarReminder {
  final String id;
  final String title;
  final String time;
  final String description;
  bool isEnabled;

  CalendarReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.description,
    this.isEnabled = true,
  });
}
