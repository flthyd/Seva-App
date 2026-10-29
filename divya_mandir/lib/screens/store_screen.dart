import 'package:flutter/material.dart';
import '../services/store_data_service.dart';
import '../services/cart_provider.dart';
import 'store_category_listing_screen.dart';
import 'store_product_detail_screen.dart';
import 'store_cart_screen.dart';
import 'store_checkout_flow_screens.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String>> gridCategories = [
    {'title': 'పూజా సామగ్రి', 'image': 'assets/images/store/cat_grid_1.png', 'id': 'pooja_samagri'},
    {'title': 'పుస్తకాలు', 'image': 'assets/images/store/cat_grid_2.png', 'id': 'pustakalu'},
    {'title': 'విగ్రహాలు', 'image': 'assets/images/store/cat_grid_3.png', 'id': 'vigrahalu'},
    {'title': 'రుద్రాక్షలు', 'image': 'assets/images/store/cat_grid_4.png', 'id': 'rudrakshalu'},
    {'title': 'పసుపు కుంకుమలు', 'image': 'assets/images/store/cat_grid_5.png', 'id': 'pasupu_kunkuma'},
    {'title': 'ఘృత దీపాలు', 'image': 'assets/images/store/cat_grid_6.png', 'id': 'deepalu'},
    {'title': 'ఆరతి సామగ్రి', 'image': 'assets/images/store/cat_grid_7.png', 'id': 'arati'},
    {'title': 'ఉపవాస & ఉత్సవాలు', 'image': 'assets/images/store/cat_grid_8.png', 'id': 'upavasa'},
  ];

  @override
  void initState() {
    super.initState();
    CartProvider().addListener(_onCartUpdate);
  }

  @override
  void dispose() {
    CartProvider().removeListener(_onCartUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onCartUpdate() {
    if (mounted) setState(() {});
  }

  void _openCategory(String name, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreCategoryListingScreen(categoryName: name, categoryId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider();
    final products = StoreDataService.defaultProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF6A1B29), // Rich divine maroon header
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              child: Row(
                children: [
                  // Venkateswara Swami Divine Icon
                  Image.asset(
                    'assets/images/store/store_icon.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.temple_hindu, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 10),
                  // Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'దేవోషనల్ స్టోర్',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'పంచాంగ, పూజా సామగ్రి, విగ్రహాలు, ధార్మిక వస్తువులు',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Orders history icon button
                  IconButton(
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                    tooltip: 'నా ఆర్డర్లు',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyOrdersListScreen()),
                      );
                    },
                  ),

                  // Cart Icon with badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StoreCartScreen()),
                          );
                        },
                      ),
                      if (cart.items.isNotEmpty)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF9800),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cart.items.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input Row + Cart Icon matching user screenshot
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'ఏమి కావాలి వెతకండి...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              onSubmitted: (term) {
                                _openCategory('శోధన ఫలితాలు', 'search');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Hero Promotional Slider Banner ("శుభకార్యాలకు పూజా సామగ్రి - ఇప్పుడే చూడండి ➔")
            GestureDetector(
              onTap: () => _openCategory('పూజా సామగ్రి', 'pooja_samagri'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Banner Image
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/store/store_hero_banner.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF5D1320), Color(0xFF9E2A2B)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Text & CTA overlay if image doesn't embed text
                      Positioned(
                        left: 16,
                        top: 20,
                        bottom: 20,
                        width: 170,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'శుభకార్యాలకు\nపూజా సామగ్రి',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD54F),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ఇప్పుడే చూడండి',
                                    style: TextStyle(
                                      color: Color(0xFF6A1B29),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF6A1B29)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 8 Category Grid (2 rows x 4 columns) exactly matching user screenshot
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                ),
                itemCount: gridCategories.length,
                itemBuilder: (ctx, idx) {
                  final cat = gridCategories[idx];
                  return GestureDetector(
                    onTap: () => _openCategory(cat['title']!, cat['id']!),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F3EA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEFE4D2)),
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              cat['image']!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.category, color: Colors.orange, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          cat['title']!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // "ప్రత్యేక ఆఫర్లు" (Special Offers) Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ప్రత్యేక ఆఫర్లు',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B29),
                    ),
                  ),
                  InkWell(
                    onTap: () => _openCategory('ప్రత్యేక ఆఫర్లు', 'offers'),
                    child: const Row(
                      children: [
                        Text('చూడండి', style: TextStyle(color: Color(0xFF6A1B29), fontSize: 13, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Color(0xFF6A1B29), size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Horizontal Offers List
            SizedBox(
              height: 210,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (ctx, i) {
                  final p = products[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreProductDetailScreen(product: p),
                        ),
                      );
                    },
                    child: Container(
                      width: 145,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF0E4D2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            child: Container(
                              height: 105,
                              width: double.infinity,
                              color: const Color(0xFFFAF5EE),
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                p.image,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 40, color: Colors.amber),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${p.price.toInt()}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF6A1B29)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        cart.addToCart(p);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${p.name} కార్ట్‌కు చేర్చబడింది!'), duration: const Duration(seconds: 1)),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6A1B29),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
