import '../models/puja_vidhanam_model.dart';

class TeluguPujaVidhanamData {
  static List<PujaVidhanamModel> get30DefaultPujas() {
    return const [
      // 1. Ganapati Puja
      PujaVidhanamModel(
        id: 'ganapati_puja',
        title: 'గణపతి పూజ',
        deity: 'గణపతి',
        shortDesc: 'విఘ్నాలను తొలగించి శుభకార్యాలకు సిద్ధి ప్రసాదించే పూజ',
        tag: 'విఘ్న నివారణ కోసం',
        countText: 5,
        duration: 'సుమారు 20-30 నిమిషాలు',
        targetAudience: 'ఎవరైనా చేయవచ్చు',
        parichayam: 'గణపతి అనగా విఘ్నాలను తొలగించే దేవుడు. ఏ శుభకార్యాన్ని ప్రారంభించేముందు గణపతి పూజ చేయడం సంప్రదాయం. ఆయన అనుగ్రహంతో విద్య, బుద్ధి, ఆయుష్షు, సంపద, విజయము, శాంతి లభిస్తాయి.',
        favorableTimes: [
          'చవితి తిథి (ప్రత్యేక ఫలితం)',
          'ప్రతి రోజు ఉదయం శుభ సమయం',
          'శుభకార్యాల ప్రారంభంలో',
          'గృహప్రవేశం, విద్యారంభం, వాహన పూజ మొదలైనప్పుడు',
        ],
        subVidhanalu: [
          SubVidhanamItem(
            number: 1,
            title: 'సాధారణ గణపతి పూజ',
            subtitle: 'ఇంట్లో ప్రతి రోజు చేసే సరళమైన పూజ',
            localImage: 'assets/images/puja_vidhanam/sub_vidhanam_1.png',
          ),
          SubVidhanamItem(
            number: 2,
            title: 'సంకటహర చతుర్థీ పూజ',
            subtitle: 'విఘ్న నివారణ కోసం చేసే పూజ',
            localImage: 'assets/images/puja_vidhanam/sub_vidhanam_2.png',
          ),
          SubVidhanamItem(
            number: 3,
            title: 'వినాయక అష్టోత్తర శతనామ పూజ',
            subtitle: '108 నామాలతో చేసే విశిష్ట పూజ',
            localImage: 'assets/images/puja_vidhanam/sub_vidhanam_3.png',
          ),
          SubVidhanamItem(
            number: 4,
            title: 'దుర్వా గణపతి పూజ',
            subtitle: 'దుర్వా గంధంతో చేసే ప్రత్యేక పూజ',
            localImage: 'assets/images/puja_vidhanam/sub_vidhanam_4.png',
          ),
          SubVidhanamItem(
            number: 5,
            title: 'విఘ్నేశ్వర హోమ విధానం',
            subtitle: 'గణపతి హోమం చేసే విధానం',
            localImage: 'assets/images/puja_vidhanam/sub_vidhanam_5.png',
          ),
        ],
        samagri: 'పసుపు, కుంకుమ, అక్షతలు, తమలపాకులు, వక్కలు, కొబ్బరికాయ, గరిక, మోదకాలు, దీపారాధన కుందులు, అగరువత్తులు.',
        fullVidhanam: '1. ఆచమనం: ఓం కేశవాయ స్వాహా, ఓం నారాయణాయ స్వాహా, ఓం మాధవాయ స్వాహా అంటూ జలము స్వీకరించాలి.\n2. గణపతి ప్రార్థన: శుక్లాంబరధరం విష్ణుం శశివర్ణం చతుర్భుజం ప్రసన్నవదనం ధ్యాయేత్ సర్వవిఘ్నోపశాంతయే.\n3. ప్రాణాయామం & సంకల్పం: దేశకాల సంకీర్తన చేసి కార్యం నిర్విఘ్నంగా జరగాలని సంకల్పించాలి.\n4. షోడశోపచారాలు: ధ్యానం, ఆవాహనం, ఆసనం, పాద్యం, అర్ఘ్యం, ఆచమనీయం, స్నానం, వస్త్రం, యజ్ఞోపవీతం, గంధం, పుష్పం, ధూపం, దీపం, నైవేద్యం, తాంబూలం, నీరాజనం సమర్పించాలి.\n5. ఉత్తర పూజ & ప్రదక్షిణ: ఏకదంతునికి నమస్కరిస్తూ 3 సార్లు ఆత్మప్రదక్షిణ చేయాలి.',
        mantralu: 'ఓం గం గణపతయే నమః\nవక్రతుండ మహాకాయ సూర్యకోటి సమప్రభ | నిర్విఘ్నం కురు మే దేవ సర్వకార్యేషు సర్వదా ||\nగణానాం త్వా గణపతిగ్ం హవామహే కవిం కవీనాముపమశ్రవస్తమమ్ |',
        prayojanalu: '1. ప్రారంభించే ప్రతి పనిలోనూ ఎదురయ్యే ఆటంకాలు మరియు విఘ్నాలు తొలగిపోతాయి.\n2. విద్యార్థులకు ఏకాగ్రత, జ్ఞాపకశక్తి మరియు ఉన్నత విద్యా ప్రాప్తి కలుగుతాయి.\n3. గృహంలో నెగెటివ్ ఎనర్జీ తొలగి శాంతి, శుభం, మంగళకర వాతావరణం నెలకొంటుంది.\n4. వ్యాపార, ఉద్యోగ రంగాల్లో నిరంతర అభివృద్ధి మరియు ఆర్థిక స్థిరత్వం లభిస్తాయి.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/ganapati_puja.png',
        heroBannerAsset: 'assets/images/puja_vidhanam/ganapati_hero.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'ప్రతిరోజూ, చవితి, బుధవారం',
        order: 1,
      ),

      // 2. Shiva Puja
      PujaVidhanamModel(
        id: 'shiva_puja',
        title: 'శివ పూజ',
        deity: 'మహాశివుడు',
        shortDesc: 'ఆరోగ్యం, ఆయుష్షు, శాంతి కోసం శివ పూజ విధానం.',
        tag: 'ఓం నమః శివాయ',
        countText: 6,
        samagri: 'విభూతి, మారేడు దళాలు (బిల్వపత్రాలు), పాలు, తేనె, నెయ్యి, పెరుగు, పంచదార (పంచామృతాలు), గంధం, పుష్పాలు.',
        fullVidhanam: '1. శివ ధ్యానం: ధ్యాయేన్నిత్యం మహేశం రజతగిరినిభం చారుచంద్రావతంసం.\n2. బిల్వాష్టకం & అభిషేకం: పంచామృతాలతో, శుద్ధ జలంతో శివలింగానికి రుద్రాధ్యాయం లేదా "ఓం నమః శివాయ" జపిస్తూ అభిషేకం చేయాలి.\n3. బిల్వార్చన: త్రిదళం త్రిగుణాకారం త్రినేత్రం చ త్రియాయుషం అంటూ మారేడు దళాలతో పూజించాలి.\n4. విభూతి ధారణ & ధూప దీపాలు: భస్మాన్ని సమర్పించి సాంబ్రాణి ధూపం వేయాలి.\n5. నైవేద్యం & హారతి: పండ్లు సమర్పించి కర్పూర నీరాజనం అందించాలి.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/shiva_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'సోమవారం, ప్రదోషం, మాస శివరాత్రి',
        order: 2,
      ),

      // 3. Lakshmi Puja
      PujaVidhanamModel(
        id: 'lakshmi_puja',
        title: 'లక్ష్మీ పూజ',
        deity: 'శ్రీ మహాలక్ష్మి',
        shortDesc: 'ధనలాభం, ఐశ్వర్యం, అష్టైశ్వర్య కరుణకు లక్ష్మీ పూజ విధానం.',
        tag: 'ధన సంపద కోసం',
        countText: 5,
        samagri: 'కలశం, పసుపు కుంకుమ, తామర పువ్వులు, గులాబీలు, నాణేలు, పాయసం, తమలపాకులు, నెయ్యి దీపాలు.',
        fullVidhanam: '1. లక్ష్మీ ధ్యానం: నమస్తేస్తు మహామాయే శ్రీపీఠే సురపూజితే.\n2. కలశ స్థాపన: కలశంలో పవిత్ర జలం, నవధాన్యాలు లేదా నాణేలు ఉంచి కొబ్బరికాయతో అలంకరించాలి.\n3. అష్టోత్తర శతనామావళి: 108 నామాలతో కుంకుమార్చన లేదా పుష్పార్చన చేయాలి.\n4. కనకధారా స్తోత్ర పఠనం.\n5. నైవేద్యం: తీపి నైవేద్యం సమర్పించి నేతి దీపాలతో నీరాజనం ఇవ్వాలి.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/lakshmi_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'శుక్రవారం, పౌర్ణమి, వరలక్ష్మీ వ్రతం',
        order: 3,
      ),

      // 4. Sai Baba Puja
      PujaVidhanamModel(
        id: 'sai_puja',
        title: 'సాయి పూజ',
        deity: 'శిరిడీ సాయిబాబా',
        shortDesc: 'శాంతి, కష్టాల నివారణ, మనశ్శాంతి కోసం సాయి పూజ విధానం.',
        tag: 'శ్రద్ధా - సబూరి',
        countText: 4,
        samagri: 'చందనం, పసుపు లేదా గులాబీ పువ్వులు, ధూపం, నైవేద్యానికి కిచిడీ లేదా తీపి పదార్థాలు, కర్పూరం.',
        fullVidhanam: '1. సాయి ధ్యానం: ఓం శ్రీ సాయినాథాయ నమః.\n2. కాకడ హారతి / బాబా అష్టోత్తరం పఠనం.\n3. విభూతి ప్రసాదం స్వీకరణ.\n4. బాబా బోధనల స్మరణ మరియు నైవేద్య సమర్పణ.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/sai_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'గురువారం',
        order: 4,
      ),

      // 5. Hanuman Puja
      PujaVidhanamModel(
        id: 'hanuman_puja',
        title: 'హనుమాన్ పూజ',
        deity: 'ఆంజనేయ స్వామి',
        shortDesc: 'శక్తి, ధైర్యం, రక్షణ కోసం హనుమాన్ పూజ విధానం.',
        tag: 'బలం, రక్షణ కోసం',
        countText: 5,
        samagri: 'సిందూరం, తమలపాకుల మాల, జిల్లేడు పూలు, అరటి పండ్లు, వడపప్పు, బెల్లం.',
        fullVidhanam: '1. హనుమాన్ ధ్యానం: మనోజవం మారుతతుల్యవేగం జితేంద్రియం బుద్ధిమతాం వరిష్టం.\n2. తమలపాకుల పూజ: శ్రీరామ జయం రాసిన ఆకులతో మాల సమర్పణ.\n3. హనుమాన్ చాలీసా / సుందరకాండ పఠనం.\n4. సిందూర తిలక ధారణ.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/hanuman_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'మంగళవారం, శనివారం',
        order: 5,
      ),

      // 6. Venkateswara Puja
      PujaVidhanamModel(
        id: 'venkateswara_puja',
        title: 'వేంకటేశ్వర పూజ',
        deity: 'శ్రీ వేంకటేశ్వర స్వామి',
        shortDesc: 'సంపద, శ్రేయస్సు, కోరికల సాఫల్యం కోసం శ్రీవారి పూజ విధానం.',
        tag: 'శ్రీవారి కటాక్షం కోసం',
        countText: 6,
        samagri: 'తులసీ దళాలు, పచ్చకర్పూరం, చందనం, అష్టగంధం, లడ్డూలు లేదా పొంగలి నైవేద్యం.',
        fullVidhanam: '1. వేంకటేశ్వర సుప్రభాతం మరియు ధ్యానం.\n2. తులసి అర్చన: గోవింద నామాలు పఠిస్తూ తులసితో పూజ.\n3. వేంకటేశ్వర వజ్రకవచం పఠనం.\n4. హారతి మరియు తీర్థప్రసాదాలు.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/venkateswara_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'శనివారం, ఏకాదశి',
        order: 6,
      ),

      // 7. Subrahmanya Swamy Puja
      PujaVidhanamModel(
        id: 'subrahmanya_puja',
        title: 'సుబ్రహ్మణ్య పూజ',
        deity: 'సుబ్రహ్మణ్యేశ్వర స్వామి',
        shortDesc: 'విద్య, జ్ఞానం, శక్తి కోసం సుబ్రహ్మణ్య పూజ విధానం.',
        tag: 'జ్ఞానం, విజయం కోసం',
        countText: 4,
        samagri: 'ఎర్ర చందనం, ఎర్ర పూలు, పాలు, తేనె, పచ్చి ఆవుపాలు, కొబ్బరికాయ.',
        fullVidhanam: '1. సుబ్రహ్మణ్య కవచం & ధ్యానం.\n2. పంచామృత క్షీరాభిషేకం.\n3. కుజదోష నివారణకు ప్రార్థన.\n4. ప్రసాదం సమర్పణ.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/subrahmanya_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'మంగళవారం, షష్ఠి',
        order: 7,
      ),

      // 8. Durga Puja
      PujaVidhanamModel(
        id: 'durga_puja',
        title: 'దుర్గా పూజ',
        deity: 'కనకదుర్గమ్మ',
        shortDesc: 'శక్తి, ధైర్యం, గ్రహ దోషాల నివారణకు దుర్గా పూజ విధానం.',
        tag: 'శక్తి, రక్షణ కోసం',
        countText: 6,
        samagri: 'ఎర్రని మందార పూలు, కుంకుమ, నిమ్మకాయల హారం, నేతి దీపాలు, క్షీరాన్నం.',
        fullVidhanam: '1. దుర్గా సప్తశ్లోకీ లేదా అష్టకం పఠనం.\n2. ఎరుపు పుష్పాలతో కుంకుమార్చన.\n3. రాహుకాల దీపారాధన (మంగళవారం).\n4. దుర్గా కవచం పఠనం.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        localAssetPath: 'assets/images/puja_vidhanam/durga_puja.png',
        category: 'నిత్య పూజ',
        auspiciousDays: 'మంగళవారం, శుక్రవారం, అష్టమి, నవరాత్రులు',
        order: 8,
      ),

      // 9. Saraswati Puja
      PujaVidhanamModel(
        id: 'saraswati_puja',
        title: 'సరస్వతీ పూజ',
        deity: 'సరస్వతీ దేవి',
        shortDesc: 'విద్యాబుద్ధులు, జ్ఞాపకశక్తి, వాక్చాతుర్యం మరియు జ్ఞాన సిద్ధి.',
        tag: 'విద్యా, జ్ఞానం కోసం',
        countText: 5,
        samagri: 'తెల్లని వస్త్రం, తెల్లని పూలు, పుస్తకాలు/పెన్నులు, తేనె, అరటి పండ్లు, అక్షతలు.',
        fullVidhanam: '1. సరస్వతీ నమస్తుభ్యం వరదే కామరూపిణి.\n2. పుస్తకాలపై పసుపు కుంకుమలు ఉంచి సరస్వతీ అష్టోత్తర శతనామాలతో పూజ.\n3. విద్యార్థుల చేత మంత్ర పఠనం.\n4. పాలు మరియు తేనె నైవేద్యం.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'వసంత పంచమి, మూలా నక్షత్రం',
        order: 9,
      ),

      // 10. Sri Rama Puja
      PujaVidhanamModel(
        id: 'rama_puja',
        title: 'శ్రీరామ పూజ',
        deity: 'శ్రీరామచంద్రుడు',
        shortDesc: 'ధర్మ రక్షణ, కుటుంబ ఐక్యత, సకల భయ నివారణ మరియు మనశ్శాంతి.',
        samagri: 'తులసి, పసుపు పూలు, పానకం, వడపప్పు, చలిమిడి, కొబ్బరికాయ.',
        fullVidhanam: '1. శ్రీరామ రక్షా స్తోత్రం పఠనం.\n2. సీతారామ లక్ష్మణ భరత శత్రుఘ్న హనుమత్ సహిత పట్టాభిషేక ధ్యానం.\n3. పానకం, వడపప్పు నైవేద్యం.\n4. మంగళ హారతి.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'శ్రీరామనవమి, పునర్వసు నక్షత్రం',
        order: 10,
      ),

      // 11. Krishna Puja
      PujaVidhanamModel(
        id: 'krishna_puja',
        title: 'శ్రీ కృష్ణ పూజ',
        deity: 'శ్రీకృష్ణుడు',
        shortDesc: 'ప్రేమ, ఆనందం, గోసంరక్షణ మరియు గీతా జ్ఞాన సిద్ధి.',
        samagri: 'వెన్న, పాలు, నెయ్యి, తులసి దళాలు, నెమలి పించం, పసుపు పూలు, తీపి అటుకులు.',
        fullVidhanam: '1. కృష్ణాయ వాసుదేవాయ హరయే పరమాత్మనే.\n2. గోపాల సహస్రనామ లేదా అష్టోత్తర పూజ.\n3. వెన్న, అటుకుల నైవేద్యం.\n4. గీతా శ్లోక పఠనం.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'అష్టమి, రోహిణి నక్షత్రం, జన్మాష్టమి',
        order: 11,
      ),

      // 12. Surya Bhagavan Puja
      PujaVidhanamModel(
        id: 'surya_puja',
        title: 'సూర్య భగవాన్ పూజ (అర్ఘ్య ప్రదానం)',
        deity: 'సూర్యనారాయణ స్వామి',
        shortDesc: 'ఆరోగ్యం, నేత్రకాంతి, తేజస్సు మరియు పితృదోష నివారణ.',
        samagri: 'రాగి పాత్ర, శుద్ధ జలం, ఎర్ర చందనం, ఎర్ర పూలు, అక్షతలు.',
        fullVidhanam: '1. ఉదయపు సూర్యునికి అభిముఖంగా నిలబడడం.\n2. రాగి పాత్రతో "ఓం సూర్యాయ నమః" అంటూ మూడు మార్లు అర్ఘ్యం ఇవ్వడం.\n3. ఆదిత్య హృదయ స్తోత్ర పఠనం.\n4. సూర్య నమస్కారాలు.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'ఆదివారం, రథసప్తమి',
        order: 12,
      ),

      // 13. Dattatreya Puja
      PujaVidhanamModel(
        id: 'dattatreya_puja',
        title: 'దత్తాత్రేయ స్వామి పూజ',
        deity: 'శ్రీ గురు దత్తాత్రేయుడు',
        shortDesc: 'త్రిమూర్తుల అనుగ్రహం, గురుకృప, మోక్ష ప్రాప్తి.',
        samagri: 'పసుపు పూలు, చందనం, ఉదుంబర (మేడి) ఆకులు, తీపి రోటీలు లేదా పండ్లు.',
        fullVidhanam: '1. గురు బ్రహ్మ గురుర్విష్ణుః గురుర్దేవో మహేశ్వరః.\n2. దత్తాత్రేయ స్తోత్రం మరియు అష్టోత్తరం.\n3. గురు చరిత్ర పారాయణ.\n4. హారతి & ప్రసాదం.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'గురువారం, దత్త జయంతి',
        order: 13,
      ),

      // 14. Ayyappa Swamy Puja
      PujaVidhanamModel(
        id: 'ayyappa_puja',
        title: 'అయ్యప్ప స్వామి పూజ (పడి పూజ)',
        deity: 'శ్రీ ధర్మశాస్తా అయ్యప్ప',
        shortDesc: 'మండల దీక్షా ఫలితం, సంయమనం, భయ నివారణ మరియు శని దోష పరిహారం.',
        samagri: 'తులసి మాల, పన్నీరు, భస్మం, నేతి దీపాలు, అప్పం, పాయసం.',
        fullVidhanam: '1. స్వామియే శరణమయ్యప్ప నినాదాలు.\n2. 18 మెట్ల పడి పూజ మరియు శరణు ఘోష.\n3. హరివరాసనం గానం.\n4. కర్పూర ఆరతి.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'శనివారం, మండల కాలం',
        order: 14,
      ),

      // 15. Narasimha Swamy Puja
      PujaVidhanamModel(
        id: 'narasimha_puja',
        title: 'నరసింహ స్వామి పూజ',
        deity: 'లక్ష్మీ నరసింహ స్వామి',
        shortDesc: 'శత్రు భయం, రుణబాధలు, రోగపీడల నివారణకు ప్రచండ రక్షణ.',
        samagri: 'పానకం, వడపప్పు, తులసి, ఎర్ర పూలు, నేతి దీపాలు.',
        fullVidhanam: '1. రుణవిమోచన నరసింహ స్తోత్రం.\n2. ఉగ్రం వీరం మహావిష్ణుం జ్వలంతం సర్వతోముఖం.\n3. తీపి పానకం సమర్పణ.\n4. హారతి.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'స్వాతి నక్షత్రం, నరసింహ జయంతి, మంగళవారం',
        order: 15,
      ),

      // 16. Gayatri Devi Puja
      PujaVidhanamModel(
        id: 'gayatri_puja',
        title: 'గాయత్రీ దేవి పూజ',
        deity: 'వేదమాత గాయత్రి',
        shortDesc: 'సకల పాపక్షయం, ఆధ్యాత్మిక ఉన్నతి, సద్బుద్ధి మరియు ప్రజ్ఞ.',
        samagri: 'నెయ్యి దీపాలు, చందనం, అక్షతలు, తాజా పండ్లు, శ్వేత పుష్పాలు.',
        fullVidhanam: '1. గాయత్రీ ధ్యానం: ముక్తా విద్రుమ హేమనీల ధవళచ్ఛాయైర్ముఖైస్త్రీక్షణైః.\n2. గాయత్రీ మంత్ర జపం (కనీసం 108 సార్లు).\n3. సూర్యోదయ లేదా సూర్యాస్తమయ సమయాల్లో సంధ్యావందనం.\n4. నమస్కారం.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'నిత్యమూ, త్రికాల సంధ్యలు',
        order: 16,
      ),

      // 17. Satyanarayana Swamy Puja
      PujaVidhanamModel(
        id: 'satyanarayana_puja',
        title: 'సత్యనారాయణ స్వామి పూజ (వ్రత కథ)',
        deity: 'శ్రీ సత్యనారాయణ స్వామి',
        shortDesc: 'ఇంటిలో ఐశ్వర్యం, శాంతి, సకల మనోరథ సిద్ధికి ప్రసిద్ధ వ్రతం.',
        samagri: 'గోధుమ రవ్వ ప్రసాదం (సపాద భక్ష్యం), కలశం, అరటి చెట్లు, పంచామృతం, తులసి.',
        fullVidhanam: '1. గణపతి, నవగ్రహ, దిక్పాలక పూజ.\n2. సత్యనారాయణ స్వామి ప్రాణప్రతిష్ఠ & షోడశోపచారాలు.\n3. 5 అధ్యాయాల వ్రత కథా శ్రవణం.\n4. సపాద ప్రసాద వితరణ.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        category: 'వ్రతం',
        auspiciousDays: 'పౌర్ణమి, ఏకాదశి',
        order: 17,
      ),

      // 18. Varalakshmi Vratham
      PujaVidhanamModel(
        id: 'varalakshmi_vratham',
        title: 'వరలక్ష్మీ వ్రత విధానం',
        deity: 'వరలక్ష్మీ దేవి',
        shortDesc: 'సౌభాగ్యం, వంశాభివృద్ధి, కుటుంబ క్షేమం కోసం స్త్రీలు ఆచరించే దివ్య వ్రతం.',
        samagri: 'నోము దారాలు, కలశం, చీర రవిక, పిండివంటలు (బూరెలు, గారెలు), పువ్వులు, పండ్లు.',
        fullVidhanam: '1. గణపతి పూజ, కలశ ఆవాహన.\n2. అంగపూజ, లక్ష్మీ అష్టోత్తర పూజ.\n3. నోము దారం కట్టుకొనుట.\n4. కథా శ్రవణం & వాయిన దానం.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        category: 'వ్రతం',
        auspiciousDays: 'శ్రావణ మాస శుక్రవారాలు',
        order: 18,
      ),

      // 19. Kedareshwara Vratham
      PujaVidhanamModel(
        id: 'kedareshwara_vratham',
        title: 'కేదారేశ్వర వ్రతం',
        deity: 'కేదారేశ్వరుడు (శివుడు)',
        shortDesc: 'అర్ధనారీశ్వర తత్వ రూపం, దాంపత్య అనుకూలత, ముక్తి ప్రదాయకం.',
        samagri: '21 పోగుల దారం, 21 పండ్లు, 21 బక్ష్యాలు, మారేడు దళాలు, కలశం.',
        fullVidhanam: '1. శివ పార్వతుల సంయుక్త పూజ.\n2. కేదారేశ్వర 21 నామాలు & తోర గ్రంథి పూజ.\n3. వ్రత కథాపఠనం.\n4. తోరం ధారణ.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        category: 'వ్రతం',
        auspiciousDays: 'దీపావళి అమావాస్య',
        order: 19,
      ),

      // 20. Navagraha Puja
      PujaVidhanamModel(
        id: 'navagraha_puja',
        title: 'నవగ్రహ పూజ & శాంతి విధానం',
        deity: 'సూర్యాది నవగ్రహములు',
        shortDesc: 'గ్రహ దోష నివారణ, శని, రాహు-కేతు శాంతి, ఆరోగ్య రక్షణ.',
        samagri: 'నవధాన్యాలు, 9 రంగుల వస్త్రాలు, నువ్వుల నూనె దీపాలు, అర్క/సమిధలు.',
        fullVidhanam: '1. నవగ్రహ మండలం లేదా నవగ్రహాల వద్ద ప్రార్థన.\n2. ఆదిత్యాయ చ సోమాయ మంగళాయ బుధాయ చ...\n3. నవగ్రహ స్తోత్ర పఠనం.\n4. 9 ప్రదక్షిణలు.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        category: 'గ్రహ శాంతి',
        auspiciousDays: 'శనివారం, అమావాస్య, గ్రహణ కాలం',
        order: 20,
      ),

      // 21. Shani Dev Puja
      PujaVidhanamModel(
        id: 'shani_puja',
        title: 'శనీశ్వర పూజ (తైలాభిషేకం)',
        deity: 'శని భగవానుడు',
        shortDesc: 'ఏలినాటి శని, అర్ధాష్టమ శని బాధల నివారణ మరియు కర్మ దోష శాంతి.',
        samagri: 'నువ్వుల నూనె, నల్ల నువ్వులు, నీలి రంగు పువ్వులు, నల్లని వస్త్రం, ఇనుప ప్రమిద.',
        fullVidhanam: '1. శని గాయత్రీ & స్తోత్ర పఠనం: నీలాంజన సమాభాసం రవిపుత్రం యమాగ్రజం.\n2. నువ్వుల నూనెతో తైలాభిషేకం లేదా దీపారాధన.\n3. కాకులకు ఆహారం పెట్టడం, పేదలకు దానం.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        category: 'గ్రహ శాంతి',
        auspiciousDays: 'శని త్రయోదశి, శనివారం',
        order: 21,
      ),

      // 22. Rahu Ketu Puja
      PujaVidhanamModel(
        id: 'rahu_ketu_puja',
        title: 'రాహు-కేతు సర్ప దోష నివారణ పూజ',
        deity: 'రాహువు & కేతువు',
        shortDesc: 'కాలసర్ప దోష పరిహారం, వ్యాపార నష్టాలు, వివాహ ఆలస్యాల నివారణ.',
        samagri: 'మినుములు, ఉలవలు, నిమ్మకాయ దీపం, నల్ల వస్త్రం, వెండి నాగుల ప్రతిమ.',
        fullVidhanam: '1. రాహు కాలంలో దుర్గా లేదా సుబ్రహ్మణ్య స్వామి సన్నిధిలో దీపారాధన.\n2. రాహు కేతువుల బీజాక్షర మంత్ర జపం.\n3. సర్ప సూక్తం లేదా నాగ దేవత అర్చన.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        category: 'గ్రహ శాంతి',
        auspiciousDays: 'నాగపంచమి, రాహుకాలం',
        order: 22,
      ),

      // 23. Annapurna Devi Puja
      PujaVidhanamModel(
        id: 'annapurna_puja',
        title: 'అన్నపూర్ణా దేవి పూజ',
        deity: 'శ్రీ అన్నపూర్ణా దేవి',
        shortDesc: 'ఇంట్లో ఆహార కొరత రాకుండా, అన్నదాన మహిమ, అక్షయ సంపదలు.',
        samagri: 'బియ్యం, పసుపు, కుంకుమ, గరిటె, బెల్లం అన్నం, పూలు.',
        fullVidhanam: '1. అన్నపూర్ణే సదాపూర్ణే శంకర ప్రాణవల్లభే.\n2. వంటగదిలో అన్నపూర్ణమ్మ ఫోటోకు గంధ పుష్పాలతో పూజ.\n3. మొదటి ముద్ద లేదా ప్రసాదాన్ని దైవానికి సమర్పించి భోజనం చేయడం.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'ధనుర్మాసం, అక్షయ తృతీయ',
        order: 23,
      ),

      // 24. Tulasi Puja
      PujaVidhanamModel(
        id: 'tulasi_puja',
        title: 'తులసి కోట పూజ (బృందావన పూజ)',
        deity: 'తులసి మాత (బృందా దేవి)',
        shortDesc: 'ఇంటికి లక్ష్మీ కటాక్షం, వాస్తు దోష నివారణ, పవిత్రత.',
        samagri: 'పసుపు, కుంకుమ, గంగాజలం, నేతి దీపం, అగరువత్తులు, తెల్లని అక్షతలు.',
        fullVidhanam: '1. ఉదయాన్నే తులసి చెట్టు మొదట్లో నీరు పోయడం.\n2. "తులసీ కళ్యాణీ నమస్తే విశ్వపావనీ" శ్లోకంతో ప్రదక్షిణ (కనీసం 3 సార్లు).\n3. సాయంత్రం వేళ నేతి దీపం వెలిగించి నమస్కరించడం.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'ప్రతిరోజూ, కార్తీక మాసం',
        order: 24,
      ),

      // 25. Govinda Puja & Harathi
      PujaVidhanamModel(
        id: 'govinda_puja',
        title: 'గోవింద నామార్చన & నిత్య హారతి',
        deity: 'శ్రీనివాసుడు',
        shortDesc: 'నిత్యం గృహంలో శ్రీవారి దివ్య నామ సంకీర్తన, సకల పాపక్షయం.',
        samagri: 'కర్పూరం, హారతి పళ్లెం, తులసి తీర్థం, కొబ్బరికాయ.',
        fullVidhanam: '1. శ్రీనివాస గోవిందా శ్రీ వేంకటేశ గోవిందా నామోచ్ఛారణ.\n2. కర్పూర నీరాజనం & తులసి జల ప్రోక్షణ.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'ప్రతి శనివారం, ఏకాదశి',
        order: 25,
      ),

      // 26. Sankashtahara Chaturthi Puja
      PujaVidhanamModel(
        id: 'sankashtahara_chaturthi',
        title: 'సంకష్టహర చవితి వ్రతం',
        deity: 'సంకట హరణ గణపతి',
        shortDesc: 'ఎలాంటి పెద్ద ఆపదలైనా, ఆర్థిక సమస్యలైనా పరిష్కరించే శక్తివంతమైన వ్రతం.',
        samagri: 'గరిక, 21 మోదకాలు లేదా కుడుములు, బెల్లం, ఎర్రని పూలు, చంద్ర దర్శన పూజా సామగ్రి.',
        fullVidhanam: '1. రోజంతా ఉపవాసం లేదా అల్పాహారం.\n2. సాయంత్రం సంకటనాశన గణేశ స్తోత్రం పఠనం.\n3. చంద్రోదయానంతరం అర్ఘ్యం ఇచ్చి పూజ ముగించి ప్రసాదం స్వీకరించడం.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        category: 'వ్రతం',
        auspiciousDays: 'కృష్ణపక్ష చవితి',
        order: 26,
      ),

      // 27. Pradosha Shiva Puja
      PujaVidhanamModel(
        id: 'pradosha_puja',
        title: 'ప్రదోష కాల శివార్చన',
        deity: 'పరమశివుడు & నందీశ్వరుడు',
        shortDesc: 'సూర్యాస్తమయ సంధ్యావేళ దారిద్య్ర నాశనం మరియు శివానుగ్రహం.',
        samagri: 'పంచామృతం, బిల్వపత్రాలు, సాంబ్రాణి ధూపం, నందికి గరిక.',
        fullVidhanam: '1. సూర్యాస్తమయానికి ముందు స్నానం చేసి ప్రదోష వ్రత సంకల్పం.\n2. శివలింగానికి, నందీశ్వరునికి బిల్వార్చన & అభిషేకం.\n3. రుద్ర జపం & నిశ్శబ్ద ధ్యానం.',
        imageUrl: 'https://images.unsplash.com/photo-1567591370504-209afb969e06?w=800&q=80',
        category: 'నిత్య పూజ',
        auspiciousDays: 'త్రయోదశి తిథి సంధ్యా సమయం',
        order: 27,
      ),

      // 28. Vinayaka Chavithi Puja
      PujaVidhanamModel(
        id: 'vinayaka_chavithi_puja',
        title: 'వినాయక చవితి మహోత్సవ పూజ',
        deity: 'వరసిద్ధి వినాయకుడు',
        shortDesc: '21 రకాల పత్రితో సమగ్ర వినాయక వ్రత కల్పం మరియు కథ.',
        samagri: 'ఏకవింశతి పత్రాలు (21 ఆకులు), మట్టి వినాయకుడు, ఉండ్రాళ్ళు, పత్రి, పండ్లు.',
        fullVidhanam: '1. మట్టి గణపతి ప్రతిష్ఠ & ప్రాణప్రతిష్ఠ.\n2. 21 పత్రాలతో ఏకవింశతి పత్ర పూజ.\n3. ఉండ్రాళ్ళు, కుడుములు నైవేద్యం.\n4. శమంతకోపాఖ్యానం కథా శ్రవణం & అక్షతల సమర్పణ.',
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80',
        category: 'పండుగ పూజ',
        auspiciousDays: 'భాద్రపద శుద్ధ చవితి',
        order: 28,
      ),

      // 29. Diwali Lakshmi Kuber Puja
      PujaVidhanamModel(
        id: 'diwali_kuber_puja',
        title: 'దీపావళి లక్ష్మీ-కుబేర పూజ',
        deity: 'మహాలక్ష్మి & కుబేరుడు',
        shortDesc: 'నిరంతర సంపదలు, వ్యాపార లాభాలు మరియు దరిద్ర విముక్తి.',
        samagri: 'మట్టి దీపాలు, కుబేర యంత్రం లేదా నాణేలు, తామర పువ్వులు, లడ్డూలు, ఖీర్.',
        fullVidhanam: '1. ఇల్లంతా దీపాలతో అలంకరణ.\n2. లక్ష్మీ సూక్తం & కుబేర మంత్ర పఠనం.\n3. ధన ధాన్య కలశ పూజ.\n4. రాత్రి వేళ దీప ప్రజ్వలన.',
        imageUrl: 'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=800&q=80',
        category: 'పండుగ పూజ',
        auspiciousDays: 'ఆశ్వయుజ అమావాస్య (దీపావళి)',
        order: 29,
      ),

      // 30. Maha Shivaratri Jagaran Puja
      PujaVidhanamModel(
        id: 'maha_shivaratri_puja',
        title: 'మహాశివరాత్రి చతుర్యామ పూజ',
        deity: 'లింగోద్భవ మూర్తి (శివుడు)',
        shortDesc: 'జాగరణ, 4 జాముల ప్రత్యేక అభిషేకం, మోక్ష ప్రాప్తి.',
        samagri: 'పాలు, పెరుగు, తేనె, కొబ్బరినీరు, మారేడు దళాలు, భస్మం, ఉమ్మెత్త పువ్వులు.',
        fullVidhanam: '1. ప్రథమ యామం: పాలతో అభిషేకం & ఋగ్వేద మంత్రాలు.\n2. ద్వితీయ యామం: పెరుగుతో అభిషేకం & యజుర్వేదం.\n3. తృతీయ యామం: నెయ్యితో అభిషేకం & సామవేదం.\n4. చతుర్థ యామం: తేనెతో అభిషేకం & అధర్వణ వేదం.\n5. శివ రాత్రి జాగరణ & హారతి.',
        imageUrl: 'https://images.unsplash.com/photo-1590073844006-33379778ae09?w=800&q=80',
        category: 'పండుగ పూజ',
        auspiciousDays: 'మాఘ బహుళ చతుర్దశి',
        order: 30,
      ),
    ];
  }
}
