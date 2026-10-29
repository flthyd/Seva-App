import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/katha_model.dart';

class KathaDetailScreen extends StatelessWidget {
  final KathaModel katha;

  const KathaDetailScreen({super.key, required this.katha});

  void _shareKatha(BuildContext context) {
    final text = '''✨ ${katha.title} ✨
${katha.shortSummary}

📖 పూర్తి కథ:
${katha.fullStory}

🌟 నీతి: ${katha.moral}

దివ్య మందిర్ యాప్ లో రోజుకో పరమ పవిత్ర ఆధ్యాత్మిక కథ చదవండి!''';
    Share.share(text, subject: katha.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          katha.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'షేర్ చేయండి',
            onPressed: () => _shareKatha(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HERO BANNER IMAGE
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6A1B29),
                  ),
                  child: _buildBannerImage(),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1C40F),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      katha.category,
                      style: const TextStyle(
                        color: Color(0xFF4A1A22),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (katha.date.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            katha.date,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // 2. STORY TITLE & SHORT SUMMARY
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    katha.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B29),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7EA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF1D8B4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote_rounded, color: Color(0xFFE67E22), size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            katha.shortSummary,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF5A141A),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. FULL STORY BODY
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF0DEC5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.menu_book_rounded, color: Color(0xFF6A1B29), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "పూర్తి ఆధ్యాత్మిక కథ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A1B29),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(
                          katha.fullStory,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. MORAL MESSAGE (నీతి)
                  if (katha.moral.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_rounded, color: Color(0xFFE65100), size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ఆధ్యాత్మిక సందేశం & నీతి:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFFBF360C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  katha.moral,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4E342E),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    if (katha.imageUrl.isNotEmpty && katha.imageUrl.startsWith('http')) {
      return Image.network(
        katha.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackBannerAsset(),
      );
    }
    return _buildFallbackBannerAsset();
  }

  Widget _buildFallbackBannerAsset() {
    if (katha.assetPath.isNotEmpty) {
      return Image.asset(
        katha.assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF6A1B29),
      child: const Center(
        child: Icon(Icons.auto_stories_rounded, color: Colors.white54, size: 60),
      ),
    );
  }
}
