import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;

  final List<Map<String, String>> songs = [
    {
      "title": "Ganesha Chalisa",
      "singer": "Anuradha Paudwal",
      "duration": "05:40",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Ganesha_Basohli_miniature_circa_1730_Dubost_p73.jpg/256px-Ganesha_Basohli_miniature_circa_1730_Dubost_p73.jpg",
      "url": "https://actions.google.com/sounds/v1/water/waves_crashing_on_rock_beach.ogg" // CORS-friendly placeholder
    },
    {
      "title": "Om Namah Shivaya",
      "singer": "Hariharan",
      "duration": "10:15",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Shiva_with_Parvati.jpg/256px-Shiva_with_Parvati.jpg",
      "url": "https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg"
    },
    {
      "title": "Hanuman Chalisa",
      "singer": "Gulshan Kumar",
      "duration": "09:45",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Hanuman_by_Raja_Ravi_Varma.jpg/256px-Hanuman_by_Raja_Ravi_Varma.jpg",
      "url": "https://actions.google.com/sounds/v1/water/waves_crashing_on_rock_beach.ogg"
    },
    {
      "title": "Gayatri Mantra",
      "singer": "Suresh Wadkar",
      "duration": "24:00",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Gayatri_Devi.jpg/256px-Gayatri_Devi.jpg",
      "url": "https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg"
    },
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playSong(int index) async {
    try {
      if (_currentlyPlayingIndex == index) {
        // Toggle play/pause for the same song
        if (_isPlaying) {
          await _audioPlayer.pause();
          setState(() => _isPlaying = false);
        } else {
          await _audioPlayer.resume();
          setState(() => _isPlaying = true);
        }
      } else {
        // Play a new song
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingIndex = index;
          _isPlaying = true;
        });
        await _audioPlayer.play(UrlSource(songs[index]['url']!));
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFDF8),
        appBar: AppBar(
          title: const Text('Divine Music', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6A1B29),
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Color(0xFFF1C40F),
            indicatorWeight: 3,
            labelColor: Color(0xFFF1C40F),
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Bhajans'),
              Tab(text: 'Mantras'),
              Tab(text: 'Aarti'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSongList(),
            _buildSongList(), // Dummy replication for categories
            _buildSongList(),
            _buildSongList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isThisSongPlaying = _currentlyPlayingIndex == index && _isPlaying;

        return Card(
          elevation: isThisSongPlaying ? 6 : 2,
          shadowColor: isThisSongPlaying ? const Color(0xFFF1C40F).withOpacity(0.5) : Colors.black12,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isThisSongPlaying ? const Color(0xFFF1C40F) : Colors.transparent, width: 1.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                song['image']!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.music_note, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              song['title']!,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: isThisSongPlaying ? const Color(0xFFD35400) : const Color(0xFF6A1B29),
              ),
            ),
            subtitle: Text(
              "${song['singer']} • ${song['duration']}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: isThisSongPlaying ? const Color(0xFFD35400) : const Color(0xFFF1C40F).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isThisSongPlaying ? Icons.pause : Icons.play_arrow, 
                  color: isThisSongPlaying ? Colors.white : const Color(0xFF6A1B29),
                ),
                onPressed: () => _playSong(index),
              ),
            ),
          ),
        );
      },
    );
  }
}
