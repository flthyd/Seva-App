import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/store_models.dart';
import '../services/cart_provider.dart';

// ==========================================
// 1. DELIVERY ADDRESS SCREEN
// ==========================================
class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = CartProvider();
    final addresses = cart.addresses;
    final selected = cart.selectedAddress;
    final deliveryMethod = cart.selectedDeliveryMethod;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text(
          'డెలివరీ అడ్రస్',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with location pin
            Row(
              children: const [
                Icon(Icons.location_on_outlined, color: Color(0xFF6A1B29), size: 22),
                SizedBox(width: 8),
                Text(
                  'డెలివరీ అడ్రస్',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B29),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Saved Addresses List
            ...addresses.map((addr) {
              final isChosen = selected.id == addr.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChosen ? const Color(0xFF6A1B29) : Colors.grey.shade300,
                    width: isChosen ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<String>(
                      value: addr.id,
                      groupValue: selected.id,
                      activeColor: const Color(0xFF6A1B29),
                      onChanged: (val) {
                        cart.selectAddress(addr);
                        setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                addr.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A1B29),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _showAddEditAddressDialog(context, existing: addr);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'సవరించు',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addr.recipientName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            addr.fullAddressDisplay,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addr.phoneNumber,
                            style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // "+ కొత్త చిరునామా జోడించండి"
            OutlinedButton.icon(
              onPressed: () {
                _showAddEditAddressDialog(context);
              },
              icon: const Icon(Icons.add, color: Color(0xFF6A1B29)),
              label: const Text(
                'కొత్త చిరునామా జోడించండి',
                style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFF6A1B29)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            // డెలివరీ విధానం (Delivery Method)
            Row(
              children: const [
                Icon(Icons.local_shipping_outlined, color: Color(0xFF6A1B29), size: 22),
                SizedBox(width: 8),
                Text(
                  'డెలివరీ విధానం',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6A1B29),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Standard Delivery option
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: deliveryMethod == 'standard' ? const Color(0xFF6A1B29) : Colors.grey.shade300,
                ),
              ),
              child: RadioListTile<String>(
                value: 'standard',
                groupValue: deliveryMethod,
                activeColor: const Color(0xFF6A1B29),
                title: const Text('సాధారణ డెలివరీ (3-5 రోజులు)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                secondary: const Text('₹40', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                onChanged: (val) {
                  cart.setDeliveryMethod('standard');
                  setState(() {});
                },
              ),
            ),

            // Express Delivery option
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: deliveryMethod == 'express' ? const Color(0xFF6A1B29) : Colors.grey.shade300,
                ),
              ),
              child: RadioListTile<String>(
                value: 'express',
                groupValue: deliveryMethod,
                activeColor: const Color(0xFF6A1B29),
                title: const Text('ఎక్స్‌ప్రెస్ డెలివరీ (1-2 రోజులు)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                secondary: const Text('₹80', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                onChanged: (val) {
                  cart.setDeliveryMethod('express');
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentSelectionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1B29),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'కొనసాగించండి',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditAddressDialog(BuildContext context, {DeliveryAddress? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? 'ఇంటి చిరునామా');
    final nameCtrl = TextEditingController(text: existing?.recipientName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    final houseCtrl = TextEditingController(text: existing?.houseAndStreet ?? '');
    final cityCtrl = TextEditingController(text: existing?.cityOrVillage ?? '');
    final stateCtrl = TextEditingController(text: existing?.districtAndState ?? 'Telangana');
    final pinCtrl = TextEditingController(text: existing?.pincode ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'కొత్త చిరునామా జోడించండి' : 'చిరునామా సవరించండి',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'చిరునామా రకం (ఉదా: ఇంటి / ఆఫీస్)'),
                ),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'పూర్తి పేరు (Full Name)*'),
                ),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'మొబైల్ నెంబర్ (Mobile Number)*'),
                ),
                TextField(
                  controller: houseCtrl,
                  decoration: const InputDecoration(labelText: 'ఇంటి నెంబర్ / వీధి (House & Street)*'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: 'ఊరు / నగరం (City)*'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: pinCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'పిన్‌కోడ్ (Pincode)*'),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: stateCtrl,
                  decoration: const InputDecoration(labelText: 'జిల్లా & రాష్ట్రం (State)*'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || pinCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('దయచేసి అన్ని వివరాలు నమోదు చేయండి!')),
                      );
                      return;
                    }
                    final newAddr = DeliveryAddress(
                      id: existing?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      recipientName: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      houseAndStreet: houseCtrl.text.trim(),
                      cityOrVillage: cityCtrl.text.trim(),
                      districtAndState: stateCtrl.text.trim(),
                      pincode: pinCtrl.text.trim(),
                    );
                    CartProvider().addAddress(newAddr);
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('చిరునామా సేవ్ చేయండి', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 2. PAYMENT SELECTION SCREEN (చెల్లింపు విధానం)
// ==========================================
class PaymentSelectionScreen extends StatefulWidget {
  const PaymentSelectionScreen({super.key});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String _selectedPayment = 'upi'; // 'upi', 'card', 'netbanking', 'wallet', 'cod'

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text(
          'చెల్లింపు విధానం',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Option 1: UPI
            _buildPaymentOption(
              id: 'upi',
              title: 'UPI',
              subtitle: 'UPI ద్వారా చెల్లించండి',
              trailingIcons: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: Color(0xFF5F259F), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('पे', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.payment, size: 22, color: Colors.blue),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF002E6E), borderRadius: BorderRadius.circular(4)),
                    child: const Text('paytm', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Option 2: Cards
            _buildPaymentOption(
              id: 'card',
              title: 'క్రెడిట్ / డెబిట్ కార్డ్స్',
              trailingIcons: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('VISA', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 6),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('RuPay', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),

            // Option 3: Net Banking
            _buildPaymentOption(
              id: 'netbanking',
              title: 'నెట్ బ్యాంకింగ్',
              trailingIcons: const Icon(Icons.account_balance, color: Colors.grey, size: 22),
            ),

            // Option 4: Wallet
            _buildPaymentOption(
              id: 'wallet',
              title: 'వాలెట్',
              trailingIcons: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.orange, size: 20),
                  SizedBox(width: 4),
                  Text('amazon pay', style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Option 5: COD
            _buildPaymentOption(
              id: 'cod',
              title: 'క్యాష్ ఆన్ డెలివరీ (COD)',
              subtitle: '₹50 అదనపు ఛార్జ్',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('మొత్తం చెల్లించాల్సిన మొత్తం', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    '₹${cart.totalAmount.toInt()}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_selectedPayment == 'upi') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpiPaymentScreen()),
                    );
                  } else if (_selectedPayment == 'cod') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentProcessingScreen(paymentType: 'COD'),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentProcessingScreen(paymentType: _selectedPayment.toUpperCase()),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('చెల్లింపు కొనసాగించండి', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    String? subtitle,
    Widget? trailingIcons,
  }) {
    final isSelected = _selectedPayment == id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF6A1B29) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: id,
        groupValue: _selectedPayment,
        activeColor: const Color(0xFF6A1B29),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        secondary: trailingIcons,
        onChanged: (val) {
          setState(() {
            _selectedPayment = val!;
          });
        },
      ),
    );
  }
}

// ==========================================
// 3. UPI PAYMENT SCREEN (QR + Apps + Timer)
// ==========================================
class UpiPaymentScreen extends StatefulWidget {
  const UpiPaymentScreen({super.key});

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  int _secondsLeft = 296; // 04:56 matching user screenshot
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final min = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final sec = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void _completePayment() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentProcessingScreen(paymentType: 'UPI'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text('UPI చెల్లింపు', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount
            Text(
              '₹${cart.totalAmount.toInt()}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 4),
            const Text(
              'క్రింది UPI యాప్‌తో చెల్లించండి',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // QR Code Container matching user UI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    color: Colors.white,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Stylized QR grid representation
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 15,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 3,
                          ),
                          itemCount: 225,
                          itemBuilder: (_, i) {
                            final isCorner = (i < 45 && (i % 15 < 3 || i % 15 > 11)) || (i > 180 && i % 15 < 3);
                            final isRandom = (i * 17) % 3 == 0;
                            return Container(
                              color: (isCorner || isRandom) ? Colors.black87 : Colors.white,
                            );
                          },
                        ),
                        // Center UPI pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: const Text('UPI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // UPI ID with copy icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'UPI ID: merchant@bank',
                        style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: 'merchant@bank'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('UPI ID కాపీ చేయబడింది!')),
                          );
                        },
                        child: const Icon(Icons.copy, size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // UPI Apps Row (PhonePe, Google Pay, Paytm, BHIM)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAppIcon('PhonePe', const Color(0xFF5F259F), 'पे'),
                _buildAppIcon('Google Pay', const Color(0xFF4285F4), 'G'),
                _buildAppIcon('Paytm', const Color(0xFF002E6E), 'pay'),
                _buildAppIcon('BHIM', const Color(0xFFF37A20), 'BHIM'),
              ],
            ),

            const SizedBox(height: 24),

            // Countdown Timer (04:56)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Color(0xFFD32F2F), size: 18),
                const SizedBox(width: 6),
                Text(
                  _formatTime(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'ఈ QR కోడ్ 5 నిమిషాల వరకు చెల్లుబాటు అవుతుంది',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Simulate Pay Button
            ElevatedButton(
              onPressed: _completePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('చెల్లింపు ధృవీకరించు (Simulate Pay)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(String label, Color color, String badgeText) {
    return InkWell(
      onTap: _completePayment,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text(
              badgeText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==========================================
// 4. PAYMENT PROCESSING & ORDER SUCCESS
// ==========================================
class PaymentProcessingScreen extends StatefulWidget {
  final String paymentType;

  const PaymentProcessingScreen({super.key, required this.paymentType});

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  int _step = 1;
  StoreOrder? _createdOrder;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _step = 2);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _step = 3);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      final cart = CartProvider();
      _createdOrder = cart.placeOrder(
        paymentMethod: widget.paymentType,
        paymentStatus: widget.paymentType == 'COD' ? 'Pending' : 'Paid',
      );
      setState(() => _step = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 4 && _createdOrder != null) {
      return OrderSuccessScreen(order: _createdOrder!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text('చెల్లింపు జరుగుతుంది', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating / Animated Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(color: Color(0xFFFFE0B2), shape: BoxShape.circle),
                child: const Icon(Icons.assignment_turned_in, size: 45, color: Color(0xFFF57C00)),
              ),
              const SizedBox(height: 24),
              const Text(
                'దయచేసి చెల్లింపును పూర్తి చేయండి',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              const SizedBox(height: 6),
              const Text(
                'మీ చెల్లింపు సురక్షితంగా ప్రాసెస్ అవుతోంది...',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Checklist Step Process
              _buildStepItem('చెల్లింపు ప్రారంభించబడింది', _step >= 1),
              _buildStepItem('బ్యాంకు అభ్యర్థన పంపబడింది', _step >= 2),
              _buildStepItem('చెల్లింపు ధృవీకరించబడింది', _step >= 3),
              _buildStepItem('ఆర్డర్ ప్రాసెసింగ్ అవుతోంది...', _step >= 4, isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String title, bool isDone, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? const Color(0xFF2E7D32) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? const Color(0xFF2C3E50) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// 4.B ORDER SUCCESS SCREEN (ఆర్డర్ విజయవంతం!)
class OrderSuccessScreen extends StatelessWidget {
  final StoreOrder order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Big Green Tick
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 55, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ఆర్డర్ విజయవంతం!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'మీ ఆర్డర్ విజయవంతంగా స్వీకరించబడింది',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Order Number Container with copy button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('ఆర్డర్ సంఖ్య: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B29)),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: order.orderNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ఆర్డర్ సంఖ్య కాపీ చేయబడింది!')),
                          );
                        },
                        child: const Icon(Icons.copy, size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  'ఆర్డర్ వివరాలు మీ మొబైల్ నంబర్‌కు SMS ద్వారా పంపించబడతాయి.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 36),

                // Button 1: "ఆర్డర్ వివరాలు చూడండి"
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ఆర్డర్ వివరాలు చూడండి', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),

                const SizedBox(height: 12),

                // Button 2: "కొనసాగించండి కొనుగోలు"
                OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6A1B29)),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('కొనసాగించండి కొనుగోలు', style: TextStyle(color: Color(0xFF6A1B29), fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. LIVE ORDER TRACKING SCREEN
// ==========================================
class OrderTrackingScreen extends StatelessWidget {
  final StoreOrder order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text('ఆర్డర్ ట్రాకింగ్', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.hourglass_empty, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text('ప్రాసెసింగ్ అవుతోంది', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Vertical Milestone Tracker matching screenshot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildTrackStep(
                    title: 'ఆర్డర్ స్వీకరించబడింది',
                    time: '${order.orderDate}, 10:30 AM',
                    isDone: true,
                    isCurrent: false,
                  ),
                  _buildTrackStep(
                    title: 'ప్యాకింగ్ జరుగుతోంది',
                    time: 'ప్రాసెసింగ్ అవుతోంది',
                    isDone: true,
                    isCurrent: true,
                  ),
                  _buildTrackStep(
                    title: 'షిప్ చేయబడింది',
                    time: 'త్వరలో...',
                    isDone: false,
                    isCurrent: false,
                  ),
                  _buildTrackStep(
                    title: 'డెలివరీలో ఉంది',
                    time: 'త్వరలో...',
                    isDone: false,
                    isCurrent: false,
                  ),
                  _buildTrackStep(
                    title: 'విజయవంతంగా డెలివరీ అయింది',
                    time: 'అంచనా: 3-5 రోజులు',
                    isDone: false,
                    isCurrent: false,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // "మీ ఉత్పత్తులు (Items)"
            Text(
              'మీ ఉత్పత్తులు (${order.items.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item['image'] ?? 'assets/images/store/prod_pooja_kit.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 30),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('పరిమాణం: ${item['quantity']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item['price']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD32F2F)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Shipping Address Summary
            const Text(
              'డెలివరీ చిరునామా',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.shippingAddress.recipientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(order.shippingAddress.fullAddressDisplay, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(order.shippingAddress.phoneNumber, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackStep({
    required String title,
    required String time,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isDone
                  ? (isCurrent ? Colors.amber.shade700 : const Color(0xFF2E7D32))
                  : Colors.grey.shade300,
              child: Icon(
                isDone ? (isCurrent ? Icons.inventory_2 : Icons.check) : Icons.circle,
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDone ? const Color(0xFF2C3E50) : Colors.grey,
                ),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 6. MY ORDERS LIST SCREEN (నా ఆర్డర్లు)
// ==========================================
class MyOrdersListScreen extends StatefulWidget {
  const MyOrdersListScreen({super.key});

  @override
  State<MyOrdersListScreen> createState() => _MyOrdersListScreenState();
}

class _MyOrdersListScreenState extends State<MyOrdersListScreen> {
  String _selectedFilter = 'all'; // 'all', 'processing', 'delivered'

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider();
    final allOrders = cart.orders;

    final filteredOrders = allOrders.where((o) {
      if (_selectedFilter == 'processing') {
        return o.orderStatus != 'delivered';
      } else if (_selectedFilter == 'delivered') {
        return o.orderStatus == 'delivered';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        title: const Text('నా ఆర్డర్లు', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 1,
      ),
      body: Column(
        children: [
          // Filter Tabs (అన్నీ, ప్రాసెసింగ్ అవుతోంది, డెలివరీ అయింది)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('అన్నీ', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('ప్రాసెసింగ్ అవుతోంది', 'processing'),
                const SizedBox(width: 8),
                _buildFilterChip('డెలివరీ అయింది', 'delivered'),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text('ఆర్డర్లు ఏవీ లేవు', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: filteredOrders.length,
                    itemBuilder: (ctx, idx) {
                      final order = filteredOrders[idx];
                      final isDelivered = order.orderStatus == 'delivered';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(order.orderDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDelivered ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isDelivered ? 'డెలివరీ అయింది' : 'ప్రాసెసింగ్ అవుతోంది',
                                style: TextStyle(
                                  color: isDelivered ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Items Preview thumbnails row
                            Row(
                              children: [
                                ...order.items.take(3).map((it) {
                                  return Container(
                                    width: 45,
                                    height: 45,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF5EE),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        it['image'] ?? 'assets/images/store/prod_pooja_kit.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag, size: 20),
                                      ),
                                    ),
                                  );
                                }),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${order.items.length} ఉత్పత్తులు | ₹${order.totalAmount.toInt()}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => OrderTrackingScreen(order: order),
                                          ),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text('వివరాలు చూడండి', style: TextStyle(color: Color(0xFF6A1B29), fontSize: 12, fontWeight: FontWeight.bold)),
                                          Icon(Icons.arrow_forward, size: 14, color: Color(0xFF6A1B29)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String id) {
    final isSelected = _selectedFilter == id;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A1B29) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF6A1B29) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
