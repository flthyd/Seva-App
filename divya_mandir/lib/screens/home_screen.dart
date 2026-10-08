import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'pooja_tools_sheet.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:math' as math;
import 'music_player_sheet.dart';

class FlowerDrop {
  final double x;
  final double speed;
  final double size;
  final double initialYOffset;
  FlowerDrop(this.x, this.speed, this.size, this.initialYOffset);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _harathiState = 3; // 0=idle, 1=rotating, 2=settling, 3=settled, 4=dragging, 5=snapping back
  bool _isBellRinging = false;
  bool _isSongPlaying = false;
  bool _isFlowerFalling = false;
  String? _activeDhandaImg;
  late AnimationController _dhandaController;
  late Animation<Offset> _dhandaAnimation;
  
  String? _selectedGodId;
  String? _selectedGodName;
  String? _currentFlowerIcon;
  List<String> _activeRainFlowers = [];
  Timer? _flowerTimer;
  
  double _dragX = 0;
  double _dragY = 0;
  final ValueNotifier<Offset> _dragNotifier = ValueNotifier(Offset.zero);
  double _settleStartX = 0;
  double _settleStartY = 0;

  List<String> _currentGodIds = [];

  final ScrollController _tabsScrollController = ScrollController();
  final PageController _bgPageController = PageController();

  void _scrollToSelectedTab(int index) {
    if (_tabsScrollController.hasClients) {
      // Approximate centering for the tab item (width ~ 52 + padding ~ 20 = 72)
      final offset = (index * 72.0) - (MediaQuery.of(context).size.width / 2) + 36;
      _tabsScrollController.animateTo(
        offset.clamp(0.0, _tabsScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _songPlayer = AudioPlayer();

  late Stream<QuerySnapshot> _godsStream;
  late Stream<QuerySnapshot> _framesStream;
  late Stream<QuerySnapshot> _flowersStream;
  late Stream<QuerySnapshot> _bellsStream;
  late Stream<QuerySnapshot> _longBellsStream;

  void _playLongBellSound(String audioUrl) async {
    final player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    if (kIsWeb) {
      player.play(UrlSource(audioUrl));
    } else {
      DefaultCacheManager().getSingleFile(audioUrl).then((file) {
        player.play(DeviceFileSource(file.path));
      }).catchError((e) {
        player.play(UrlSource(audioUrl));
      });
    }
    player.onPlayerComplete.listen((_) => player.dispose());
  }
  late Stream<QuerySnapshot> _harathisStream;
  late Stream<QuerySnapshot> _songsStream;

  late AnimationController _harathiRotController;
  late AnimationController _harathiMoveController;
  late AnimationController _flowersController;

  List<FlowerDrop> _flowerDrops = [];

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    ));
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _harathiRotController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _harathiMoveController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _flowersController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    
    _dhandaController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _dhandaAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(
      parent: _dhandaController,
      curve: Curves.easeOut,
    ));
    
    _godsStream = FirebaseFirestore.instance.collection('gods').orderBy('created_at', descending: true).snapshots();
    _framesStream = FirebaseFirestore.instance.collection('frames').snapshots();
    _flowersStream = FirebaseFirestore.instance.collection('flowers').orderBy('created_at', descending: true).snapshots();
    _bellsStream = FirebaseFirestore.instance.collection('bells').orderBy('created_at', descending: true).snapshots();
    _longBellsStream = FirebaseFirestore.instance.collection('long_bells').where('is_active', isEqualTo: true).snapshots();
    _harathisStream = FirebaseFirestore.instance.collection('harathis').orderBy('created_at', descending: true).snapshots();
    _songsStream = FirebaseFirestore.instance.collection('songs').orderBy('created_at', descending: true).snapshots();
    
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _flowerDrops.add(FlowerDrop(
        random.nextDouble(),
        0.5 + random.nextDouble(),
        25.0 + random.nextDouble() * 20.0,
        random.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _songPlayer.dispose();
    _harathiRotController.dispose();
    _harathiMoveController.dispose();
    _flowersController.dispose();
    _dhandaController.dispose();
    _tabsScrollController.dispose();
    _bgPageController.dispose();
    super.dispose();
  }

  void _showFeedback(String message) {
    // Disabled snackbars per user request
  }

  void _toggleBell(String? audioUrl) async {
    setState(() => _isBellRinging = true);
    _showFeedback("Temple Bell Ringing...");
    try {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await _audioPlayer.play(UrlSource(audioUrl));
      } else {
        await _audioPlayer.play(UrlSource('https://actions.google.com/sounds/v1/alarms/dinner_bell_triangle.ogg'));
      }
    } catch (e) {
      debugPrint("Audio error: $e");
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isBellRinging = false);
    });
  }

  void _toggleAarti() {
    if (_harathiState == 1 || _harathiState == 2 || _harathiState == 5) {
      setState(() => _harathiState = 3);
      _harathiRotController.stop();
      _harathiMoveController.stop();
      _showFeedback("Harathi Stopped");
      return;
    }
    
    setState(() => _harathiState = 1);
    _showFeedback("Harathi Started");
    _harathiRotController.forward(from: 0.0).then((_) {
      if (mounted && _harathiState == 1) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        _settleStartX = (screenWidth / 2) - 40;
        _settleStartY = (screenHeight * 0.65 - 40) - 100;
        
        setState(() => _harathiState = 2);
        _harathiMoveController.forward(from: 0.0).then((_) {
          if (mounted && _harathiState == 2) {
            setState(() => _harathiState = 3);
          }
        });
      }
    });
  }

  void _openMusicPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MusicPlayerSheet(audioPlayer: _songPlayer),
    );
  }

  void _handleFlowerSelected(String imageUrl) {
    setState(() {
      _currentFlowerIcon = imageUrl;
      if (!_activeRainFlowers.contains(imageUrl)) {
        _activeRainFlowers.add(imageUrl);
      }
      
      if (!_isFlowerFalling) {
        _isFlowerFalling = true;
        _flowersController.repeat();
        _showFeedback("Offering Flowers");
      } else {
        _showFeedback("Added more flowers to rain");
      }
      
      _flowerTimer?.cancel();
      _flowerTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isFlowerFalling = false;
            _flowersController.stop();
            _activeRainFlowers.clear();
          });
        }
      });
    });
  }

  void _handleDhandaSelected(String imageUrl) {
    if (_activeDhandaImg == imageUrl) return;
    
    setState(() {
      _activeDhandaImg = imageUrl;
    });
    _dhandaController.forward(from: 0.0);
    _showFeedback("Offering Garland...");
  }

  void _toggleFlowers() {
    setState(() {
      if (!_isFlowerFalling) {
        _isFlowerFalling = true;
        _flowersController.repeat();
        _showFeedback("Offering Flowers");
      }
      
      _flowerTimer?.cancel();
      _flowerTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isFlowerFalling = false;
            _flowersController.stop();
            _activeRainFlowers.clear();
          });
        }
      });
    });
  }

  Widget _buildPremiumButton({required IconData icon, String? imageUrl, required String label, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: 56, height: 56,
                padding: imageUrl != null ? EdgeInsets.zero : const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF1C40F).withOpacity(0.5) : const Color(0xFF6A1B29).withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.white : const Color(0xFFF1C40F),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF1C40F).withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                  ],
                ),
                child: imageUrl != null 
                  ? ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(icon, color: Colors.white, size: 24))) 
                  : Icon(icon, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
        ],
      ),
    );
  }

  Widget _buildDefaultBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B29), Color(0xFF3D0C14)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
  
  Map<String, dynamic>? _getFirstActive(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final activeDocs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['is_active'] != false;
    }).toList();
    if (activeDocs.isNotEmpty) {
      return activeDocs.first.data() as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic>? _getSelectedOrFirstData(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final activeDocs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['is_active'] != false;
    }).toList();
    if (activeDocs.isEmpty) return null;
    
    if (_selectedGodId != null) {
      try {
        return activeDocs.firstWhere((doc) => doc.id == _selectedGodId).data() as Map<String, dynamic>;
      } catch (e) {}
    }
    return activeDocs.first.data() as Map<String, dynamic>;
  }

  String? _getSelectedOrFirstId(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final activeDocs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['is_active'] != false;
    }).toList();
    if (activeDocs.isEmpty) return null;
    
    if (_selectedGodId != null) {
      try {
        final doc = activeDocs.firstWhere((doc) => doc.id == _selectedGodId);
        return doc.id;
      } catch (e) {}
    }
    return activeDocs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF6A1B29),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6A1B29),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.temple_hindu), label: "Pooja"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "My Devotion"),
        ],
      ),
      body: Column(
        children: [
          // 1. GOD SELECTION TABS (Top Header)
          Container(
            padding: EdgeInsets.only(top: safeAreaTop + 10, bottom: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF6A1B29),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: SizedBox(
              height: 80,
              child: StreamBuilder<QuerySnapshot>(
                stream: _godsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  final activeDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['is_active'] != false;
                  }).toList();
                  
                  if (activeDocs.isEmpty) return const SizedBox.shrink();

                  _currentGodIds = activeDocs.map((doc) => doc.id).toList();

                  return ListView.builder(
                    controller: _tabsScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeDocs.length,
                    itemBuilder: (context, index) {
                      final doc = activeDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;
                      final name = data['name'] as String? ?? 'God';
                      final imageUrl = data['image_url'] as String?;
                      
                      final isSelected = (_selectedGodId != null) 
                          ? (id == _selectedGodId) 
                          : (index == 0);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGodId = id;
                          });
                          _scrollToSelectedTab(index);
                          if (_bgPageController.hasClients) {
                            _bgPageController.animateToPage(
                              index, 
                              duration: const Duration(milliseconds: 400), 
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFF1C40F) : Colors.transparent, 
                                    width: 2.5
                                  ),
                                  boxShadow: isSelected 
                                    ? [BoxShadow(color: const Color(0xFFF1C40F).withOpacity(0.6), blurRadius: 10)]
                                    : [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                ),
                                child: ClipOval(
                                  child: imageUrl != null
                                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person, color: Colors.white))
                                    : const Icon(Icons.person, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFF1C40F) : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // 2. THE REST OF THE APP
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final localWidth = constraints.maxWidth;
                final localHeight = constraints.maxHeight;

                return Stack(
                  children: [
                    // 1. DYNAMIC BACKGROUND IMAGE (Gods)
                    StreamBuilder<QuerySnapshot>(
                      stream: _godsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return SizedBox.expand(child: _buildDefaultBg());
                        
                        final activeDocs = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return data['is_active'] != false;
                        }).toList();
                        
                        if (activeDocs.isEmpty) return SizedBox.expand(child: _buildDefaultBg());
                        
                        return SizedBox.expand(
                          child: PageView.builder(
                            controller: _bgPageController,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedGodId = activeDocs[index].id;
                              });
                              _scrollToSelectedTab(index);
                            },
                            itemCount: activeDocs.length,
                            itemBuilder: (context, index) {
                              final data = activeDocs[index].data() as Map<String, dynamic>;
                              final bgImageUrl = data['image_url'] as String?;
                              final childImagesList = data['child_images'] as List<dynamic>? ?? [];
                              
                              List<String> allImages = [];
                              if (bgImageUrl != null) allImages.add(bgImageUrl);
                              allImages.addAll(childImagesList.map((e) => e.toString()));
                              
                              if (allImages.isEmpty) return _buildDefaultBg();
                              
                              return PageView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: allImages.length,
                                itemBuilder: (context, childIndex) {
                                  return Image.network(
                                    allImages[childIndex],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildDefaultBg(),
                                  );
                                }
                              );
                            },
                          ),
                        );
                      },
                    ),
                      
                      // 2. DARK OVERLAY
                      IgnorePointer(child: Container(color: Colors.black.withOpacity(0.3))),

                      // 3. FLOWERS ANIMATION OVERLAY (Behind the frame!)
                      StreamBuilder<QuerySnapshot>(
                        stream: _flowersStream,
                        builder: (context, snapshot) {
                          if (!_isFlowerFalling) return const SizedBox.shrink();
                          
                          String? img;
                          if (snapshot.hasData) {
                            final data = _getFirstActive(snapshot.data!);
                            img = data?['image_url'] as String?;
                          }
                          return AnimatedBuilder(
                            animation: _flowersController,
                              builder: (context, child) {
                                return Stack(
                                  children: _flowerDrops.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final drop = entry.value;

                                    double rawY = (_flowersController.value * drop.speed) + drop.initialYOffset;
                                    double normalizedY = rawY % 1.0;
                                    double yPos = -50 + (normalizedY * (localHeight + 100));
                                    double xPos = drop.x * localWidth;

                                    String? currentImg = img;
                                    if (_activeRainFlowers.isNotEmpty) {
                                      currentImg = _activeRainFlowers[index % _activeRainFlowers.length];
                                    }

                                    return Positioned(
                                      top: yPos,
                                      left: xPos,
                                      child: currentImg != null
                                        ? Image.network(currentImg, width: drop.size, height: drop.size, fit: BoxFit.contain)
                                        : Icon(Icons.local_florist, color: Colors.pinkAccent.withOpacity(0.8), size: drop.size),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),

                      // DHANDA (GARLAND) OVERLAY
                      if (_activeDhandaImg != null)
                        Positioned(
                          top: 20,
                          left: -5,
                          right: -5,
                          child: IgnorePointer(
                            child: SlideTransition(
                              position: _dhandaAnimation,
                              child: Image.network(
                                _activeDhandaImg!,
                                width: MediaQuery.of(context).size.width + 10,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),

                      // 10. TEMPLE LONG BELLS OVERLAY (MOVED BEFORE FRAME SO IT'S BEHIND)
                      StreamBuilder<QuerySnapshot>(
                        stream: _longBellsStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
                          
                          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                          final leftImg = data['left_image_url'] as String?;
                          final rightImg = data['right_image_url'] as String?;
                          final audioUrl = data['audio_url'] as String?;
                          
                          return Stack(
                            children: [
                              if (leftImg != null)
                                Positioned(
                                  top: 0,
                                  left: 20,
                                  child: SwingingBell(
                                    imageUrl: leftImg,
                                    audioUrl: audioUrl,
                                    onPlaySound: (url) {
                                      _playLongBellSound(url);
                                      _showFeedback("Ringing Left Bell");
                                    },
                                  ),
                                ),
                              if (rightImg != null)
                                Positioned(
                                  top: 0,
                                  right: 20,
                                  child: SwingingBell(
                                    imageUrl: rightImg,
                                    audioUrl: audioUrl,
                                    onPlaySound: (url) {
                                      _playLongBellSound(url);
                                      _showFeedback("Ringing Right Bell");
                                    },
                                  ),
                                ),
                            ],
                          );
                        }
                      ),

                      // 4. TEMPLE WALL FRAME OVERLAY
                      StreamBuilder<QuerySnapshot>(
                        stream: _godsStream,
                        builder: (context, godSnapshot) {
                          String? activeGodId;
                          if (godSnapshot.hasData) {
                            activeGodId = _getSelectedOrFirstId(godSnapshot.data!);
                          }

                          if (activeGodId == null) return const SizedBox.shrink();

                          return StreamBuilder<QuerySnapshot>(
                            stream: _framesStream,
                            builder: (context, frameSnapshot) {
                              if (!frameSnapshot.hasData) return const SizedBox.shrink();
                              
                              final frameDocs = frameSnapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['is_active'] != false && data['god_id'] == activeGodId;
                              }).toList();

                              if (frameDocs.isEmpty) return const SizedBox.shrink();

                              // Sort to get the latest frame
                              frameDocs.sort((a, b) {
                                final timeA = (a.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
                                final timeB = (b.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
                                if (timeA == null || timeB == null) return 0;
                                return timeB.compareTo(timeA);
                              });

                              final frameUrl = (frameDocs.first.data() as Map<String, dynamic>)['image_url'] as String?;
                              if (frameUrl == null) return const SizedBox.shrink();

                              return Positioned.fill(
                                child: IgnorePointer(
                                  child: Image.network(
                                    frameUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // 6. SIDE BUTTONS (Left)
                      Positioned(
                        left: 16,
                        top: localHeight * 0.35,
                        child: Column(
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: _bellsStream,
                              builder: (context, snapshot) {
                                String? bellImageUrl;
                                String? bellAudioUrl;
                                if (snapshot.hasData) {
                                  final data = _getFirstActive(snapshot.data!);
                                  if (data != null) {
                                    bellImageUrl = data['image_url'] as String?;
                                    bellAudioUrl = data['audio_url'] as String?;
                                  }
                                }
                                return _buildPremiumButton(
                                  icon: Icons.notifications_active,
                                  imageUrl: bellImageUrl,
                                  label: "Bell",
                                  onTap: () => _toggleBell(bellAudioUrl),
                                  isActive: _isBellRinging,
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            StreamBuilder<QuerySnapshot>(
                              stream: _harathisStream,
                              builder: (context, snapshot) {
                                String? harathiImageUrl;
                                if (snapshot.hasData) {
                                  final data = _getFirstActive(snapshot.data!);
                                  harathiImageUrl = data?['image_url'] as String?;
                                }
                                return _buildPremiumButton(
                                  icon: Icons.fireplace,
                                  imageUrl: harathiImageUrl,
                                  label: "Harathi",
                                  onTap: _toggleAarti,
                                  isActive: _harathiState != 0,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // 7. SIDE BUTTONS (Right)
                      Positioned(
                        right: 16,
                        top: localHeight * 0.35,
                        child: Column(
                          children: [
                            _buildPremiumButton(
                              icon: Icons.music_note,
                              label: "Music",
                              onTap: _openMusicPlayer,
                              isActive: _isSongPlaying,
                            ),
                            const SizedBox(height: 30),
                            _buildPremiumButton(icon: Icons.share, label: "Share", onTap: () => _showFeedback("Sharing...")),
                          ],
                        ),
                      ),

                      // 8. BOTTOM ROW BUTTONS (Flowers - Prasad)
                      Positioned(
                        bottom: 30,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: _flowersStream,
                              builder: (context, snapshot) {
                                String? flowerImageUrl;
                                if (snapshot.hasData) {
                                  final data = _getFirstActive(snapshot.data!);
                                  flowerImageUrl = data?['image_url'] as String?;
                                }
                                return _buildPremiumButton(
                                  icon: Icons.local_florist,
                                  imageUrl: flowerImageUrl,
                                  label: "Flowers",
                                  onTap: _toggleFlowers,
                                  isActive: _isFlowerFalling,
                                );
                              },
                            ),
                            _buildPremiumButton(
                              icon: Icons.grid_view_rounded, 
                              label: "More", 
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => PoojaToolsSheet(
                                    audioPlayer: _audioPlayer,
                                    onFlowerSelected: _handleFlowerSelected,
                                    onDhandaSelected: _handleDhandaSelected,
                                    currentGodName: _selectedGodName,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // 9. AARTI ANIMATION OVERLAY
                      StreamBuilder<QuerySnapshot>(
                        stream: _harathisStream,
                        builder: (context, snapshot) {
                          if (_harathiState == 0) return const SizedBox.shrink();

                          String? img;
                          if (snapshot.hasData) {
                            final data = _getFirstActive(snapshot.data!);
                            img = data?['image_url'] as String?;
                          }
                          return AnimatedBuilder(
                            animation: Listenable.merge([_harathiRotController, _harathiMoveController, _dragNotifier]),
                            builder: (context, child) {
                                double hX = 0;
                                double hY = 0;
                                
                                double centerX = localWidth / 2;
                                double centerY = localHeight * 0.65 - 40;
                                
                                double targetX = (localWidth / 2) - 40;
                                double targetY = localHeight - 150;

                                if (_harathiState == 1) { // Rotating
                                  double angle = (_harathiRotController.value * 5 * 2 * math.pi) - (math.pi / 2);
                                  double radiusX = 120.0;
                                  double radiusY = 60.0;
                                  hX = centerX + (radiusX * math.cos(angle)) - 40;
                                  hY = centerY + (radiusY * math.sin(angle)) - 40;
                                } else if (_harathiState == 2 || _harathiState == 5) { // Settling or Snapping back
                                  double t = Curves.easeInOut.transform(_harathiMoveController.value);
                                  hX = _settleStartX + (targetX - _settleStartX) * t;
                                  hY = _settleStartY + (targetY - _settleStartY) * t;
                                } else if (_harathiState == 3) { // Settled
                                  hX = targetX;
                                  hY = targetY;
                                } else if (_harathiState == 4) { // Dragging
                                  hX = _dragX;
                                  hY = _dragY;
                                }

                                return Positioned(
                                  left: hX,
                                  top: hY,
                                  child: GestureDetector(
                                    onPanStart: (details) {
                                      if (_harathiState == 3 || _harathiState == 5) {
                                        _harathiMoveController.stop();
                                        int oldState = _harathiState;
                                        setState(() {
                                          _harathiState = 4;
                                          if (oldState == 3) {
                                            _dragX = (localWidth / 2) - 40;
                                            _dragY = localHeight - 150;
                                          } else if (oldState == 5) {
                                            double t = Curves.easeInOut.transform(_harathiMoveController.value);
                                            double tX = (localWidth / 2) - 40;
                                            double tY = localHeight - 150;
                                            _dragX = _settleStartX + (tX - _settleStartX) * t;
                                            _dragY = _settleStartY + (tY - _settleStartY) * t;
                                          }
                                        });
                                      }
                                    },
                                    onPanUpdate: (details) {
                                      if (_harathiState == 4) {
                                        setState(() {
                                          _dragX += details.delta.dx;
                                          _dragY += details.delta.dy;
                                        });
                                      }
                                    },
                                    onPanEnd: (details) {
                                      if (_harathiState == 4) {
                                        _settleStartX = _dragX;
                                        _settleStartY = _dragY;
                                        setState(() => _harathiState = 5);
                                        _harathiMoveController.forward(from: 0.0).then((_) {
                                          if (mounted && _harathiState == 5) {
                                            setState(() => _harathiState = 3);
                                          }
                                        });
                                      }
                                    },
                                    child: child!,
                                  ),
                                );
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 30, spreadRadius: 10),
                                  ],
                                ),
                                child: Center(
                                  child: img != null
                                    ? Image.network(img, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fireplace, size: 40, color: Colors.orange))
                                    : Image.network(
                                        'https://cdn-icons-png.flaticon.com/512/8207/8207172.png',
                                        color: Colors.orange,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.fireplace, size: 40, color: Colors.orange),
                                      ),
                                ),
                              ),
                            );
                          }
                        ),
                    ],
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SwingingBell extends StatefulWidget {
  final String imageUrl;
  final String? audioUrl;
  final Function(String) onPlaySound;

  const SwingingBell({
    Key? key,
    required this.imageUrl,
    this.audioUrl,
    required this.onPlaySound,
  }) : super(key: key);

  @override
  State<SwingingBell> createState() => _SwingingBellState();
}

class _SwingingBellState extends State<SwingingBell> with TickerProviderStateMixin {
  late AnimationController _swingController;
  late AnimationController _dropController;
  late Animation<Offset> _dropAnimation;

  @override
  void initState() {
    super.initState();
    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _dropAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dropController,
      curve: Curves.elasticOut,
    ));

    _dropController.forward();
  }

  @override
  void dispose() {
    _swingController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _ringBell() {
    if (_swingController.isAnimating) {
      _swingController.reset();
    }
    _swingController.forward(from: 0.0);
    if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
      widget.onPlaySound(widget.audioUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _dropAnimation,
      child: GestureDetector(
        onTap: _ringBell,
        child: AnimatedBuilder(
          animation: _swingController,
          builder: (context, child) {
            double t = _swingController.value;
            // math.sin for swing back and forth, 6*pi = 3 full swings
            // 0.35 rad amplitude dampening to 0
            double angle = math.sin(t * math.pi * 6) * 0.35 * (1.0 - t);
            return Transform.rotate(
              angle: angle,
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child: Image.network(widget.imageUrl, width: 70, height: 160, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

