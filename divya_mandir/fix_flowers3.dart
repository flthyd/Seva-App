import 'dart:io';

void main() {
  final file = File('lib/screens/home_screen.dart');
  String content = file.readAsStringSync();
  
  String searchStart = 'return AnimatedBuilder(\r\n                            animation: _flowersController,';
  int startIdx = content.indexOf(searchStart);
  if (startIdx == -1) {
    searchStart = 'return AnimatedBuilder(\n                            animation: _flowersController,';
    startIdx = content.indexOf(searchStart);
  }
  
  if (startIdx == -1) {
    print("Start index not found!");
    return;
  }
  
  String searchEnd = '                          );';
  int endIdx = content.indexOf(searchEnd, startIdx);
  if (endIdx == -1) {
    print("End index not found!");
    return;
  }
  
  // Actually, there are multiple `);` so we have to be careful. 
  // Let's replace the whole string up to the `// 4. TEMPLE WALL FRAME OVERLAY` minus some characters.
  
  int tempEndIdx = content.indexOf('// 4. TEMPLE WALL FRAME OVERLAY', startIdx);
  if (tempEndIdx == -1) {
    print("Temple wall frame overlay not found!");
    return;
  }
  
  String oldBlock = content.substring(startIdx, tempEndIdx);
  
  // We need to keep the closing brackets for the StreamBuilder and LayoutBuilder.
  // The old block looks like:
  // return AnimatedBuilder( ... ); }, ); }, ), // 4. TEMPLE WALL FRAME
  // We will just replace the `return AnimatedBuilder( ... );` part.
  
  String exactOldAnimatedBuilder = '''return AnimatedBuilder(
                            animation: _flowersController,
                            builder: (context, child) {
                              return Stack(
                                children: _flowerDrops.map((drop) {
                                  double rawY = (_flowersController.value * drop.speed) + drop.initialYOffset;
                                  double normalizedY = rawY % 1.0;
                                  double yPos = -50 + (normalizedY * (localHeight + 100));
                                  double xPos = drop.x * localWidth;
  
                                  return Positioned(
                                    top: yPos,
                                    left: xPos,
                                    child: img != null
                                      ? Image.network(img, width: drop.size, height: drop.size, fit: BoxFit.contain)
                                      : Icon(Icons.local_florist, color: Colors.pinkAccent.withOpacity(0.8), size: drop.size),
                                  );
                                }).toList(),
                              );
                            },
                          );''';

  // Normalize line endings for replacement to work smoothly
  String normalizedContent = content.replaceAll('\r\n', '\n');
  String normalizedOld = exactOldAnimatedBuilder.replaceAll('\r\n', '\n');
  
  String newBlock = '''return AnimatedBuilder(
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
                          );''';

  if (normalizedContent.contains(normalizedOld)) {
    normalizedContent = normalizedContent.replaceAll(normalizedOld, newBlock);
    file.writeAsStringSync(normalizedContent);
    print("REPLACED SUCCESSFULLY!");
  } else {
    print("Exact old block not found. Checking if it was partially matched...");
  }
}
