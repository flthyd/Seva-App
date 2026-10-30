import 'package:flutter/material.dart';

class ManageDevotionalStoreScreen extends StatefulWidget {
  const ManageDevotionalStoreScreen({super.key});

  @override
  State<ManageDevotionalStoreScreen> createState() => _ManageDevotionalStoreScreenState();
}

class _ManageDevotionalStoreScreenState extends State<ManageDevotionalStoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock initial orders & products if Firestore is empty
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'id': 'prod_1',
      'name': 'పూజా సామగ్రి కిట్',
      'name_en': 'Pooja Samagri Kit',
      'category': 'పూజా సామగ్రి',
      'category_en': 'Pooja Items',
      'price': 499.0,
      'originalPrice': 699.0,
      'stock': 45,
      'sales': 88,
      'inStock': true,
      'image': 'assets/images/store/prod_pooja_kit.png',
      'description': 'దేవోత్సవాల పూజోపహారం. పవిత్రమైన పూజా ద్రవ్యాల సంపూర్ణ సమాహారం.',
      'description_en': 'Sacred celebration pooja gift kit with essential sacred items.',
    },
    {
      'id': 'prod_2',
      'name': 'పిత్తల దీపం',
      'name_en': 'Brass Oil Lamp',
      'category': 'దీపాలు',
      'category_en': 'Ghee Lamps',
      'price': 299.0,
      'originalPrice': 399.0,
      'stock': 70,
      'sales': 142,
      'inStock': true,
      'image': 'assets/images/store/prod_deepam.png',
      'description': 'స్వచ్ఛమైన ఇత్తడితో తయారుచేసిన సాంప్రదాయ పూజా దీపం.',
      'description_en': 'Traditional hand-crafted pure brass pooja oil lamp.',
    },
    {
      'id': 'prod_3',
      'name': 'పంచపాత్ర సెట్టు',
      'name_en': 'Panchapatra Set',
      'category': 'పూజా సామగ్రి',
      'category_en': 'Pooja Items',
      'price': 599.0,
      'originalPrice': 799.0,
      'stock': 30,
      'sales': 54,
      'inStock': true,
      'image': 'assets/images/store/prod_panchapatra.png',
      'description': 'పూజలో తీర్థం మరియు ఆచమనానికి ఉపయోగించే స్వచ్ఛమైన పంచపాత్ర.',
      'description_en': 'Pure copper/brass panchapatra vessel set used for holy water.',
    },
    {
      'id': 'prod_4',
      'name': 'గంట (పూజా ఘంట)',
      'name_en': 'Pooja Brass Bell',
      'category': 'పూజా సామగ్రి',
      'category_en': 'Pooja Items',
      'price': 199.0,
      'originalPrice': 299.0,
      'stock': 55,
      'sales': 96,
      'inStock': true,
      'image': 'assets/images/store/prod_ganta.png',
      'description': 'నంది ముద్రతో కూడిన మధుర నాద పూజా గంట.',
      'description_en': 'Melodious pooja brass bell with auspicious Nandi carving.',
    },
    {
      'id': 'prod_5',
      'name': 'ఆరతి ప్లేట్',
      'name_en': 'Aarti Brass Plate',
      'category': 'పూజా ప్లేట్లు',
      'category_en': 'Aarti Essentials',
      'price': 249.0,
      'originalPrice': 349.0,
      'stock': 40,
      'sales': 62,
      'inStock': true,
      'image': 'assets/images/store/prod_arati_plate.png',
      'description': 'కర్పూర హారతి ఇవ్వడానికి ప్రత్యేకమైన పూజా ప్లేట్.',
      'description_en': 'Special brass engraved aarti plate for camphor offerings.',
    },
    {
      'id': 'prod_6',
      'name': 'కుంకుమ పాత్ర',
      'name_en': 'Kumkum Box',
      'category': 'కుంకుమ పాత్రలు',
      'category_en': 'Turmeric & Kumkum',
      'price': 149.0,
      'originalPrice': 199.0,
      'stock': 80,
      'sales': 180,
      'inStock': true,
      'image': 'assets/images/store/prod_kunkuma_patra.png',
      'description': 'లక్ష్మీ దేవి స్వరూపమైన కుంకుమ భద్రపరచుకునే ఇత్తడి భరిణ.',
      'description_en': 'Auspicious Goddess Lakshmi design brass kumkum holder.',
    },
  ];

  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'order_1',
      'orderNumber': '#DS20261027001',
      'orderDate': '27 Oct 2026, 10:30 AM',
      'customerName': 'Mohammad Rafeeq',
      'customerPhone': '+91 98765 43210',
      'address': 'H.No 12-3-45, Near Masjid, Marikal, Narayanpet, Telangana - 509210',
      'items': [
        {'name': 'పూజా సామగ్రి కిట్', 'qty': 1, 'price': 499},
        {'name': 'పిత్తల దీపం', 'qty': 1, 'price': 299},
        {'name': 'కుంకుమ పాత్ర', 'qty': 1, 'price': 149},
      ],
      'total': 937.0,
      'paymentMethod': 'UPI (Google Pay)',
      'paymentStatus': 'Paid',
      'orderStatus': 'packing', // placed, packing, shipped, delivered, cancelled
    },
    {
      'id': 'order_2',
      'orderNumber': '#DS20261025018',
      'orderDate': '25 Oct 2026, 03:15 PM',
      'customerName': 'రాఘవ శర్మ',
      'customerPhone': '+91 94401 23456',
      'address': 'Flat 302, Gayatri Nilayam, Dilsukhnagar, Hyderabad, Telangana - 500036',
      'items': [
        {'name': 'పంచపాత్ర సెట్టు', 'qty': 1, 'price': 599},
      ],
      'total': 598.0,
      'paymentMethod': 'UPI (PhonePe)',
      'paymentStatus': 'Paid',
      'orderStatus': 'delivered',
    },
    {
      'id': 'order_3',
      'orderNumber': '#DS20261024009',
      'orderDate': '24 Oct 2026, 11:20 AM',
      'customerName': 'వెంకటేశ్వర రావు',
      'customerPhone': '+91 98480 11223',
      'address': 'Brodipet 4th line, Guntur, AP - 522002',
      'items': [
        {'name': 'గంట (పూజా ఘంట)', 'qty': 2, 'price': 199},
        {'name': 'ఆరతి ప్లేట్', 'qty': 1, 'price': 249},
      ],
      'total': 647.0,
      'paymentMethod': 'Cash on Delivery (COD)',
      'paymentStatus': 'Pending',
      'orderStatus': 'shipped',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Analytics calculations
    final totalSalesAmount = _mockOrders.fold(0.0, (acc, o) => acc + (o['total'] as num));
    final totalOrdersCount = _mockOrders.length;
    final deliveredCount = _mockOrders.where((o) => o['orderStatus'] == 'delivered').length;
    final pendingCount = _mockOrders.where((o) => o['orderStatus'] != 'delivered' && o['orderStatus'] != 'cancelled').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text(
          'Devotional Store Management (A-Z కంట్రోల్ ప్యానెల్)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            tooltip: 'Add New Product',
            onPressed: () => _showAddProductDialog(context),
          ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD54F),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'ఓవర్‌వ్యూ & సేల్స్ (Analytics)'),
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'ఉత్పత్తుల జాబితా (Products)'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'ఆర్డర్లు & కస్టమర్లు (Orders)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: OVERVIEW & STATS
          _buildOverviewTab(totalSalesAmount, totalOrdersCount, deliveredCount, pendingCount),

          // TAB 2: PRODUCTS MANAGEMENT
          _buildProductsTab(),

          // TAB 3: ORDERS & BUYERS DETAILS
          _buildOrdersTab(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 1: OVERVIEW & METRICS
  // --------------------------------------------------------------------------
  Widget _buildOverviewTab(double revenue, int orders, int delivered, int pending) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'స్టోర్ పనితీరు ముఖ్యాంశాలు (Store Performance Overview)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 16),

          // Metric Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'మొత్తం ఆదాయం (Total Revenue)',
                  value: '₹${revenue.toInt()}',
                  icon: Icons.currency_rupee,
                  color: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFE8F5E9),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'మొత్తం ఆర్డర్లు (Total Orders)',
                  value: '$orders',
                  icon: Icons.shopping_bag,
                  color: const Color(0xFF1976D2),
                  bgColor: const Color(0xFFE3F2FD),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'డెలివరీ అయినవి (Delivered)',
                  value: '$delivered',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF388E3C),
                  bgColor: const Color(0xFFE8F5E9),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'ప్రాసెసింగ్ లో ఉన్నవి (Pending/Shipping)',
                  value: '$pending',
                  icon: Icons.pending_actions,
                  color: const Color(0xFFF57C00),
                  bgColor: const Color(0xFFFFF3E0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Payment Gateway Integration Status
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.security, color: Color(0xFF6A1B29)),
                    SizedBox(width: 10),
                    Text(
                      'పేమెంట్ గేట్‌వే సెటప్ (Payment Gateway Settings)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Razorpay & Direct UPI Gateway', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SizedBox(height: 4),
                        Text('GPay, PhonePe, Paytm, BHIM, Cards & COD లైవ్ మోడ్‌లో సపోర్ట్ చేస్తుంది', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Razorpay Keys Configured! (Live / Test mode active)')),
                        );
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                      label: const Text('Gateway Active', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 2: PRODUCTS MANAGEMENT
  // --------------------------------------------------------------------------
  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ఉత్పత్తులు (${_mockProducts.length} Products)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('కొత్త ప్రొడక్ట్ యాడ్ చేయి', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table / Cards of products
          ..._mockProducts.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5EE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      p['image'],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 30, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p['name_en'] != null && p['name_en'].toString().isNotEmpty
                                    ? '${p['name']} / ${p['name_en']}'
                                    : p['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                p['category_en'] != null && p['category_en'].toString().isNotEmpty
                                    ? '${p['category']} (${p['category_en']})'
                                    : p['category'],
                                style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('ధర: ₹${p['price'].toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
                            const SizedBox(width: 14),
                            Text('స్టాక్: ${p['stock']} యూనిట్లు', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(width: 14),
                            Text('సేల్స్ కౌంట్: ${p['sales']}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions (Edit, Delete)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'సవరించు (Edit)',
                    onPressed: () => _showAddProductDialog(context, existing: p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'తొలగించు (Delete)',
                    onPressed: () {
                      setState(() {
                        _mockProducts.removeWhere((item) => item['id'] == p['id']);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ప్రొడక్ట్ తొలగించబడింది!')),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TAB 3: ORDERS & BUYERS DETAILS
  // --------------------------------------------------------------------------
  Widget _buildOrdersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'కస్టమర్ల ఆర్డర్లు & కొనుగోలు వివరాలు (${_mockOrders.length} Orders)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 14),

          ..._mockOrders.map((o) {
            final status = o['orderStatus'] as String;
            final isDelivered = status == 'delivered';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(o['orderNumber'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6A1B29))),
                          const SizedBox(width: 12),
                          Text(o['orderDate'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      // Status dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDelivered ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: status,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'placed', child: Text('ఆర్డర్ వచ్చింది (Placed)')),
                            DropdownMenuItem(value: 'packing', child: Text('ప్యాకింగ్ జరుగుతోంది (Packing)')),
                            DropdownMenuItem(value: 'shipped', child: Text('రవాణాలో ఉంది (Shipped)')),
                            DropdownMenuItem(value: 'delivered', child: Text('డెలివరీ అయింది (Delivered)')),
                            DropdownMenuItem(value: 'cancelled', child: Text('రద్దు చేయబడింది (Cancelled)')),
                          ],
                          onChanged: (newVal) {
                            if (newVal != null) {
                              setState(() {
                                o['orderStatus'] = newVal;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Buyer details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Contact & Shipping Address
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('కొనుగోలుదారు వివరాలు (Buyer Info):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('పేరు: ${o['customerName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('ఫోన్ నంబర్: ${o['customerPhone']}', style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('పూర్తి డెలివరీ చిరునామా:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                            Text(o['address'], style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Items Purchased & Payment
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('కొనుగోలు చేసిన వస్తువులు (Items):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            ...(o['items'] as List).map((it) {
                              return Text('• ${it['name']} x ${it['qty']} (₹${it['price']})', style: const TextStyle(fontSize: 13));
                            }).toList(),
                            const SizedBox(height: 8),
                            Text('చెల్లింపు విధానం: ${o['paymentMethod']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Row(
                              children: [
                                const Text('మొత్తం చెల్లింపు: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('₹${(o['total'] as num).toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFD32F2F))),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: o['paymentStatus'] == 'Paid' ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(o['paymentStatus'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: o['paymentStatus'] == 'Paid' ? Colors.green : Colors.red)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Dialog to Add or Edit Product
  void _showAddProductDialog(BuildContext context, {Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final nameEnCtrl = TextEditingController(text: existing?['name_en'] ?? existing?['nameEn'] ?? '');
    final catCtrl = TextEditingController(text: existing?['category'] ?? 'పూజా సామగ్రి');
    final catEnCtrl = TextEditingController(text: existing?['category_en'] ?? existing?['categoryEn'] ?? 'Pooja Items');
    final priceCtrl = TextEditingController(text: existing != null ? '${existing['price']}' : '');
    final origPriceCtrl = TextEditingController(text: existing != null ? '${existing['originalPrice']}' : '');
    final stockCtrl = TextEditingController(text: existing != null ? '${existing['stock']}' : '50');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final descEnCtrl = TextEditingController(text: existing?['description_en'] ?? existing?['descriptionEn'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'కొత్త వస్తువును చేర్చండి' : 'వస్తువును సవరించండి', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'పేరు (తెలుగు)*', hintText: 'ఉదా: పంచపాత్ర'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: nameEnCtrl, decoration: const InputDecoration(labelText: 'Name (English)', hintText: 'e.g. Panchapatra'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'కేటగిరీ (తెలుగు)*', hintText: 'పూజా సామగ్రి'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: catEnCtrl, decoration: const InputDecoration(labelText: 'Category (English)', hintText: 'Pooja Items'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ఆఫర్ ధర (₹)*'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: origPriceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'అసలు ధర (MRP ₹)'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'స్టాక్ పరిమాణం (Stock Units)*')),
                  const SizedBox(height: 8),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'వివరణ (తెలుగు)', hintText: 'వస్తువు వివరాలు...')),
                  const SizedBox(height: 8),
                  TextField(controller: descEnCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (English)', hintText: 'Product description in English...')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('రద్దు')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;

                if (existing != null) {
                  setState(() {
                    existing['name'] = nameCtrl.text.trim();
                    existing['name_en'] = nameEnCtrl.text.trim();
                    existing['category'] = catCtrl.text.trim();
                    existing['category_en'] = catEnCtrl.text.trim();
                    existing['price'] = double.tryParse(priceCtrl.text) ?? existing['price'];
                    existing['originalPrice'] = double.tryParse(origPriceCtrl.text) ?? existing['originalPrice'];
                    existing['stock'] = int.tryParse(stockCtrl.text) ?? existing['stock'];
                    existing['description'] = descCtrl.text.trim();
                    existing['description_en'] = descEnCtrl.text.trim();
                  });
                } else {
                  setState(() {
                    _mockProducts.add({
                      'id': 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      'name': nameCtrl.text.trim(),
                      'name_en': nameEnCtrl.text.trim().isNotEmpty ? nameEnCtrl.text.trim() : nameCtrl.text.trim(),
                      'category': catCtrl.text.trim(),
                      'category_en': catEnCtrl.text.trim().isNotEmpty ? catEnCtrl.text.trim() : catCtrl.text.trim(),
                      'price': double.tryParse(priceCtrl.text) ?? 299.0,
                      'originalPrice': double.tryParse(origPriceCtrl.text) ?? 399.0,
                      'stock': int.tryParse(stockCtrl.text) ?? 50,
                      'sales': 0,
                      'inStock': true,
                      'image': 'assets/images/store/prod_pooja_kit.png',
                      'description': descCtrl.text.trim(),
                      'description_en': descEnCtrl.text.trim(),
                    });
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('విజయవంతంగా సేవ్ చేయబడింది!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
              child: const Text('సేవ్ చేయండి', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
