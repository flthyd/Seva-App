import re

with open('lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the block for flowers overlay
pattern = r'(if \(!_isFlowerFalling\) return const SizedBox\.shrink\(\);\s*)String\? img;\s*if \(snapshot\.hasData\) \{\s*final data = _getFirstActive\(snapshot\.data!\);\s*img = data\?\[\'image_url\'\] as String\?;\s*\}\s*return AnimatedBuilder\(\s*animation: _flowersController,\s*builder: \(context, child\) \{\s*return Stack\(\s*children: _flowerDrops\.map\(\(drop\) \{\s*double rawY = \(_flowersController\.value \* drop\.speed\) \+ drop\.initialYOffset;\s*double normalizedY = rawY % 1\.0;\s*double yPos = -50 \+ \(normalizedY \* \(localHeight \+ 100\)\);\s*double xPos = drop\.x \* localWidth;\s*return Positioned\(\s*top: yPos,\s*left: xPos,\s*child: img != null\s*\? Image\.network\(img, width: drop\.size, height: drop\.size, fit: BoxFit\.contain\)\s*: Icon\(Icons\.local_florist, color: Colors\.pinkAccent\.withOpacity\(0\.8\), size: drop\.size\),\s*\);\s*\}\)\.toList\(\),\s*\);\s*\},\s*\);'

replacement = r'''\1String? defaultImg;
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
                              );'''

new_content, count = re.subn(pattern, replacement, content)

if count > 0:
    with open('lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Successfully replaced.")
else:
    print("Could not find the pattern to replace.")
