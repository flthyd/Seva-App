import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AudioLoopMode { off, all, one }

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? imageUrl;
  final String audioUrl; // Can be a remote URL or local file path
  final bool isLocal;
  final String? categoryId;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.imageUrl,
    required this.audioUrl,
    this.isLocal = false,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isLocal': isLocal,
      'categoryId': categoryId,
    };
  }
}

class AudioPlayerService extends ChangeNotifier {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  List<SongModel> _playlist = [];
  int _currentIndex = -1;

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isShuffle = false;
  AudioLoopMode _repeatMode = AudioLoopMode.off;
  bool _isLoading = false;

  // Favorites tracking
  final Set<String> _favoriteIds = {};

  // Local user songs list
  final List<SongModel> _userLocalSongs = [];

  // Getters
  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;
  PlayerState get playerState => _playerState;
  bool get isPlaying => _playerState == PlayerState.playing;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isShuffle => _isShuffle;
  AudioLoopMode get repeatMode => _repeatMode;
  bool get isLoading => _isLoading;
  Set<String> get favoriteIds => _favoriteIds;
  List<SongModel> get userLocalSongs => _userLocalSongs;

  AudioPlayerService._internal() {
    _initAudioListeners();
    _loadUserFavorites();
  }

  void _loadUserFavorites() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            final favs = data['favorite_songs'];
            if (favs is List) {
              _favoriteIds.clear();
              _favoriteIds.addAll(favs.map((e) => e.toString()));
              notifyListeners();
            }
          }
        });
      }
    });
  }

  void _initAudioListeners() {
    _player.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _player.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });

    _player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((event) {
      _handleSongCompletion();
    });
  }

  Future<void> toggleFavorite(String songId) async {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'favorite_songs': _favoriteIds.toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error syncing favorites: $e');
      }
    }
  }

  bool isFavorite(String songId) => _favoriteIds.contains(songId);

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    if (_repeatMode == AudioLoopMode.off) {
      _repeatMode = AudioLoopMode.all;
    } else if (_repeatMode == AudioLoopMode.all) {
      _repeatMode = AudioLoopMode.one;
    } else {
      _repeatMode = AudioLoopMode.off;
    }
    notifyListeners();
  }

  void _handleSongCompletion() {
    if (_repeatMode == AudioLoopMode.one) {
      seek(Duration.zero);
      resume();
    } else {
      playNext();
    }
  }

  /// Play a specific song and optionally update the active playlist
  Future<void> playSong(SongModel song, {List<SongModel>? newPlaylist}) async {
    if (newPlaylist != null) {
      _playlist = List.from(newPlaylist);
      _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
    } else {
      _currentIndex = _playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _playlist.add(song);
        _currentIndex = _playlist.length - 1;
      }
    }

    await _startPlayingCurrent();
  }

  Future<void> _startPlayingCurrent() async {
    if (currentSong == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _player.stop();
      final song = currentSong!;

      if (song.isLocal) {
        // Local phone storage file - zero network delay, no upload to Firebase
        await _player.play(DeviceFileSource(song.audioUrl));
      } else {
        // Cloud song - uses CacheManager for instant offline local playback & zero wait time!
        try {
          final fileInfo = await DefaultCacheManager().getFileFromCache(song.audioUrl);
          if (fileInfo != null) {
            await _player.play(DeviceFileSource(fileInfo.file.path));
          } else {
            // Start caching in background and play cached or stream immediately
            DefaultCacheManager().downloadFile(song.audioUrl);
            final cachedFile = await DefaultCacheManager().getSingleFile(song.audioUrl);
            await _player.play(DeviceFileSource(cachedFile.path));
          }
        } catch (e) {
          debugPrint("Cache fallback to UrlSource: $e");
          await _player.play(UrlSource(song.audioUrl));
        }
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else if (_playerState == PlayerState.paused) {
      await _player.resume();
    } else if (currentSong != null) {
      await _startPlayingCurrent();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    if (_isShuffle && _playlist.length > 1) {
      int nextIdx = _currentIndex;
      while (nextIdx == _currentIndex) {
        nextIdx = (DateTime.now().microsecondsSinceEpoch) % _playlist.length;
      }
      _currentIndex = nextIdx;
    } else {
      if (_currentIndex < _playlist.length - 1) {
        _currentIndex++;
      } else {
        if (_repeatMode == AudioLoopMode.all) {
          _currentIndex = 0;
        } else {
          return;
        }
      }
    }
    await _startPlayingCurrent();
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    if (_position.inSeconds > 4) {
      await seek(Duration.zero);
      return;
    }
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist.length - 1;
    }
    await _startPlayingCurrent();
  }

  /// Add a song from the user's phone local storage
  void addUserLocalSong(SongModel song) {
    // Avoid duplicate paths
    if (!_userLocalSongs.any((s) => s.audioUrl == song.audioUrl)) {
      _userLocalSongs.insert(0, song);
      notifyListeners();
    }
  }

  void removeUserLocalSong(String songId) {
    _userLocalSongs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }
}
