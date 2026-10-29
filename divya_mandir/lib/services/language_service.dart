import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;

  static const String _prefKey = 'selected_language';
  String _currentLanguage = 'te'; // 'te' for Telugu (Default), 'en' for English

  LanguageService._internal() {
    _loadLanguage();
  }

  String get currentLanguage => _currentLanguage;
  bool get isTelugu => _currentLanguage == 'te';
  bool get isEnglish => _currentLanguage == 'en';

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_prefKey);
      if (lang != null && (lang == 'te' || lang == 'en')) {
        _currentLanguage = lang;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> setLanguage(String langCode) async {
    if (langCode != 'te' && langCode != 'en') return;
    if (_currentLanguage == langCode) return;

    _currentLanguage = langCode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  /// Helper to get text based on current language
  String text({required String te, required String en}) {
    return _currentLanguage == 'te' ? te : en;
  }
}

/// Global extension or helper for cleaner translation access
class AppStrings {
  static LanguageService get _lang => LanguageService();

  // Navigation & Common
  static String get home => _lang.text(te: 'హోమ్', en: 'Home');
  static String get status => _lang.text(te: 'స్టేటస్', en: 'Status');
  static String get pooja => _lang.text(te: 'పూజ', en: 'Pooja');
  static String get music => _lang.text(te: 'సంగీతం', en: 'Music');
  static String get store => _lang.text(te: 'స్టోర్', en: 'Store');
  static String get seeMore => _lang.text(te: 'మరిన్ని', en: 'More');
  static String get myAccount => _lang.text(te: 'నా ఖాతా', en: 'My Account');
  static String get settings => _lang.text(te: 'సెట్టింగ్స్', en: 'Settings');
  static String get language => _lang.text(te: 'భాష (Language)', en: 'Language');
  static String get selectLanguage => _lang.text(te: 'భాషను ఎంచుకోండి', en: 'Select Language');
  static String get telugu => 'తెలుగు (Telugu)';
  static String get english => 'English';
  static String get logout => _lang.text(te: 'లాగౌట్', en: 'Logout');

  // Greetings & Subtitle
  static String get subhodayam => _lang.text(te: 'శుభోదయం 🙏', en: 'Good Morning 🙏');
  static String get subhaMadhyahnam => _lang.text(te: 'శుభ మధ్యాహ్నం 🙏', en: 'Good Afternoon 🙏');
  static String get subhaSayantram => _lang.text(te: 'శుభ సాయంత్రం 🙏', en: 'Good Evening 🙏');
  static String get subhaRatri => _lang.text(te: 'శుభ రాత్రి 🙏', en: 'Good Night 🙏');
  static String get startSpiritualJourney => _lang.text(
      te: 'మీ ఆధ్యాత్మిక ప్రయాణం ప్రారంభించండి',
      en: 'Begin your spiritual journey');

  // Home Sections Headers
  static String get auspiciousTimings => _lang.text(
      te: 'దిన సమయాలు & శుభ ముహూర్తాలు',
      en: 'Daily Timings & Auspicious Muhurtham');
  static String get liveDarshanHeader => _lang.text(te: 'ప్రత్యక్ష దర్శనం', en: 'Live Darshan');
  static String get rashiPalaluHeader => _lang.text(te: 'రాశిఫలాలు', en: 'Horoscope');
  static String get knowYourRashi => _lang.text(
      te: 'మీ రాశిని తెలుసుకోండి (Know Your Rashi)',
      en: 'Know Your Rashi (Zodiac Sign)');
  static String get todayRashiPalalu => _lang.text(
      te: 'ఈ రోజు రాశిఫలాలు చూడండి',
      en: 'View Today\'s Horoscope');
  static String get devalayaluHeader => _lang.text(te: 'ప్రముఖ దేవాలయాలు', en: 'Famous Temples');
  static String get netiKathaHeader => _lang.text(te: 'నేటి కథ', en: 'Today\'s Story');
  static String get mantraJapamHeader => _lang.text(te: 'మంత్ర జపం', en: 'Mantra Japam');
  static String get startJapam => _lang.text(te: 'జపం ప్రారంభించండి', en: 'Start Japam');
  static String get pujaVidhanamHeader => _lang.text(te: 'పూజా విధానం', en: 'Puja Vidhanam');
  static String get readStory => _lang.text(te: 'కథ చదవండి', en: 'Read Story');

  // Home Modules Grid
  static String get liveDarshanam => _lang.text(te: 'లైవ్ దర్శనం', en: 'Live Darshan');
  static String get panchangam => _lang.text(te: 'పంచాంగం', en: 'Panchangam');
  static String get pujaVidhanam => _lang.text(te: 'పూజా విధానం', en: 'Puja Vidhanam');
  static String get mantraJapam => _lang.text(te: 'మంత్ర జపం', en: 'Mantra Japam');
  static String get netiKatha => _lang.text(te: 'నేటి కథ', en: 'Today\'s Story');
  static String get devalayalu => _lang.text(te: 'దేవాలయాలు', en: 'Temples');
  static String get puranalu => _lang.text(te: 'పురాణాలు', en: 'Puranas');
  static String get calendar => _lang.text(te: 'క్యాలెండర్', en: 'Calendar');
  static String get rashiPalalu => _lang.text(te: 'రాశిఫలాలు', en: 'Horoscope');
  static String get dhyanam => _lang.text(te: 'ధ్యానం', en: 'Meditation');
  static String get spiritualKnowledge => _lang.text(te: 'ఆధ్యాత్మిక జ్ఞానం', en: 'Spiritual Knowledge');

  // Store
  static String get devotionalStore => _lang.text(te: 'దేవోషనల్ స్టోర్', en: 'Devotional Store');
  static String get storeSubtitle => _lang.text(
      te: 'పంచాంగ, పూజా సామగ్రి, విగ్రహాలు, ధార్మిక వస్తువులు',
      en: 'Panchang, Pooja Items, Idols, Spiritual Items');
  static String get searchStoreHint => _lang.text(te: 'ఏమి కావాలి వెతకండి...', en: 'Search what you need...');
  static String get specialOffers => _lang.text(te: 'ప్రత్యేక ఆఫర్లు', en: 'Special Offers');
  static String get addToCart => _lang.text(te: 'కార్ట్‌లో జోడించండి', en: 'Add to Cart');
  static String get buyNow => _lang.text(te: 'ఇప్పుడే కొనండి', en: 'Buy Now');
  static String get myCart => _lang.text(te: 'నా కార్ట్', en: 'My Cart');
  static String get checkout => _lang.text(te: 'చెక్‌అవుట్ చేయండి', en: 'Checkout');
  static String get deliveryAddress => _lang.text(te: 'డెలివరీ అడ్రస్', en: 'Delivery Address');
  static String get continueText => _lang.text(te: 'కొనసాగించండి', en: 'Continue');
  static String get paymentMethod => _lang.text(te: 'చెల్లింపు విధానం', en: 'Payment Method');
  static String get myOrders => _lang.text(te: 'నా ఆర్డర్లు', en: 'My Orders');
  static String get orderSuccessful => _lang.text(te: 'ఆర్డర్ విజయవంతం!', en: 'Order Successful!');

  // Store Categories
  static String get catPoojaSamagri => _lang.text(te: 'పూజా సామగ్రి', en: 'Pooja Samagri');
  static String get catPustakalu => _lang.text(te: 'పుస్తకాలు', en: 'Books');
  static String get catVigrahalu => _lang.text(te: 'విగ్రహాలు', en: 'Idols');
  static String get catRudrakshalu => _lang.text(te: 'రుద్రాక్షలు', en: 'Rudraksha');
}
