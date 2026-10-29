import 'package:flutter/material.dart';
import '../services/store_data_service.dart';
import '../services/cart_provider.dart';
import 'store_product_detail_screen.dart';
import 'store_cart_screen.dart';

class StoreCategoryListingScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const StoreCategoryListingScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<StoreCategoryListingScreen> createState() => _StoreCategoryListingScreenState();
}

class _StoreCategoryListingScreenState extends State<StoreCategoryListingScreen> {
  String _selectedSubFilter = 'అన్నీ';
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _wishlist = {};

  final List<String> _filterTabs = [
    'అన్నీ',
    'పూజా సామాగ్రి',
    'దీపాలు',
    'పూజా ప్లేట్లు',
    'కుంకుమ పాత్రలు',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider();
    final allProducts = StoreDataService.defaultProducts;

    final filtered = allProducts.where((p) {
      if (_selectedSubFilter != 'అన్నీ' && p.teluguCategory != _selectedSubFilter) {
        return false;
      }
      if (_searchCtrl.text.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchCtrl.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StoreCartScreen()),
                  );
                },
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFFF9800), shape: BoxShape.circle),
                    child: Text(
                      '${cart.items.length}',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'ఈ విభాగంలో వెతకండి...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sub-category filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: _filterTabs.map((tab) {
                final isSelected = _selectedSubFilter == tab;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubFilter = tab),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6A1B29) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF424242),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2-Column Product Grid matching user screenshot
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('ఉత్పత్తులు ఏవీ లేవు', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final product = filtered[index];
                      final isWishlisted = _wishlist.contains(product.id);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF0E4D2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image + Wishlist heart
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 120,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFAF5EE),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      product.image,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.shopping_bag, size: 40, color: Colors.amber),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isWishlisted) {
                                            _wishlist.remove(product.id);
                                          } else {
                                            _wishlist.add(product.id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                                          color: isWishlisted ? Colors.red : Colors.grey,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Name & Price & Add button
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹${product.price.toInt()}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF6A1B29),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            cart.addToCart(product);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${product.name} కార్ట్‌కు చేర్చబడింది!'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6A1B29),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.add, color: Colors.white, size: 20),
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
        ],
      ),
    );
  }
}
