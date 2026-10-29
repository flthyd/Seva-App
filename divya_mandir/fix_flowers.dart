import 'dart:io';

void main() {
  final file = File('lib/screens/home_screen.dart');
  String content = file.readAsStringSync();
  
  final regex = RegExp(r'(if \(!_isFlowerFalling\) return const SizedBox\.shrink\(\);\s*)String\? img;\s*if \(snapshot\.hasData\) \{\s*final data = _getFirstActive\(snapshot\.data!\);\s*img = data\?\[\x27image_url\x27\] as String\?;\s*\}\s*return AnimatedBuilder\(\s*animation: _flowersController,\s*builder: \(context, child\) \{\s*return Stack\(\s*children: _flowerDrops\.map\(\(drop\) \{\s*double rawY = \(_flowersController\.value \* drop\.speed\) \+ drop\.initialYOffset;\s*double normalizedY = rawY % 1\.0;\s*double yPos = -50 \+ \(normalizedY \* \(localHeight \+ 100\)\);\s*double xPos = drop\.x \* localWidth;\s*return Positioned\(\s*top: yPos,\s*left: xPos,\s*child: img != null\s*\? Image\.network\(img, width: drop\.size, height: drop\.size, fit: BoxFit\.contain\)\s*: Icon\(Icons\.local_florist, color: Colors\.pinkAccent\.withOpacity\(0\.8\), size: drop\.size\),\s*\);\s*\}\)\.toList\(\),\s*\);\s*\},\s*\);');

  final replacement = r'''$1String? defaultImg;
                              if (snapshot.hasData) {
                                final data = _getFirstActive(snapshot.data!);
                                defaultImg = data?['image_url'] as String?;
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

                                      String? currentImg;
                                      if (_activeRainFlowers.isNotEmpty) {
                                        currentImg = _activeRainFlowers[index % _activeRainFlowers.length];
                                      } else {
                                        currentImg = defaultImg;
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
                              );''';

  if (regex.hasMatch(content)) {
    content = content.replaceFirst(regex, replacement);
    file.writeAsStringSync(content);
    print("Replaced successfully");
  } else {
    print("Match not found!");
  }
}
