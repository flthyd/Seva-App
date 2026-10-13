import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:share_plus/share_plus.dart';

class StatusDetailScreen extends StatefulWidget {
  final String imageUrl;
  const StatusDetailScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<StatusDetailScreen> createState() => _StatusDetailScreenState();
}

class _StatusDetailScreenState extends State<StatusDetailScreen> {
  bool _isProcessing = false;

  Future<void> _downloadImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download is only available on Mobile.")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Dio().download(widget.imageUrl, savePath);
      final result = await GallerySaver.saveImage(savePath, albumName: 'Divya Mandir');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result == true ? "Saved to Gallery!" : "Failed to save image"),
          backgroundColor: result == true ? Colors.green : Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _shareImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Share is only available on Mobile.")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Dio().download(widget.imageUrl, savePath);
      await Share.shareXFiles([XFile(savePath)], text: "Check out this beautiful status from Divya Mandir app!");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sharing: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _setWallpaper() async {
    setState(() => _isProcessing = true);
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Dio().download(widget.imageUrl, savePath);
      
      String result = "Failed to set wallpaper.";
      if (!kIsWeb) {
        final wallpaperResult = await AsyncWallpaper.setWallpaper(
          WallpaperRequest(
            target: WallpaperTarget.both,
            sourceType: WallpaperSourceType.file,
            source: savePath,
            goToHome: false,
          ),
        );
        result = wallpaperResult.isSuccess ? "Wallpaper set successfully!" : "Failed to set wallpaper.";
      } else {
        result = "Setting wallpaper is not supported on Web.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result),
          backgroundColor: result.contains('Failed') ? Colors.red : Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error setting wallpaper: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: widget.imageUrl,
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
          ),
          
          // Gradient at bottom for better button visibility
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(Icons.download, "Download", _downloadImage),
                      if (!kIsWeb) _buildActionButton(Icons.wallpaper, "Set Wallpaper", _setWallpaper),
                      _buildActionButton(Icons.share, "Share", _shareImage),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
