import 'dart:io';

void main() {
  final file = File('lib/screens/home_screen.dart');
  String content = file.readAsStringSync();
  
  // Find the exact block by searching for key parts
  int startIdx = content.indexOf('String? img;\n                                if (snapshot.hasData) {');
  if (startIdx == -1) startIdx = content.indexOf('String? img;\r\n                                if (snapshot.hasData) {');
  
  if (startIdx == -1) {
    print("Start index not found!");
    return;
  }
  
  int endIdx = content.indexOf('return Positioned(', startIdx);
  endIdx = content.indexOf(');', endIdx); // End of Positioned
  endIdx = content.indexOf('}).toList(),', endIdx);
  endIdx = content.indexOf(');', endIdx); // End of Stack
  endIdx = content.indexOf('},', endIdx); // End of builder
  endIdx = content.indexOf(');', endIdx) + 2; // End of AnimatedBuilder
  
  if (endIdx < startIdx) {
     print("End index error!");
     return;
  }
  
  String oldBlock = content.substring(startIdx, endIdx);
  print("Found block of length ${oldBlock.length}");
  
  String newBlock = '''String? defaultImg;
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
                                
  content = content.replaceFirst(oldBlock, newBlock);
  file.writeAsStringSync(content);
  print("REPLACED EXACT BLOCK SUCCESSFULLY!");
}
