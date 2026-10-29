import 'package:flutter/material.dart';
import '../models/store_models.dart';
import '../services/store_data_service.dart';

class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;

  CartProvider._internal() {
    _initDefaultCart();
  }

  final List<CartItem> _items = [];
  final List<DeliveryAddress> _addresses = List.from(StoreDataService.defaultAddresses);
  DeliveryAddress? _selectedAddress;
  String _selectedDeliveryMethod = 'standard'; // 'standard' (₹40) or 'express' (₹80)
  final List<StoreOrder> _orders = List.from(StoreDataService.initialOrders);

  List<CartItem> get items => _items;
  List<DeliveryAddress> get addresses => _addresses;
  DeliveryAddress get selectedAddress =>
      _selectedAddress ?? (_addresses.isNotEmpty ? _addresses.first : StoreDataService.defaultAddresses.first);
  String get selectedDeliveryMethod => _selectedDeliveryMethod;
  List<StoreOrder> get orders => _orders;

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get discount => subtotal > 500 ? 50.0 : 0.0;
  double get deliveryCharge => _items.isEmpty ? 0.0 : (_selectedDeliveryMethod == 'express' ? 80.0 : 40.0);
  double get totalAmount => (subtotal - discount + deliveryCharge).clamp(0.0, double.infinity);

  void _initDefaultCart() {
    // Seed with sample items matching user UI screenshot:
    // Pooja Samagri Kit (499), Pittala Deepam (299), Kunkuma Patra (149) = 947 subtotal
    if (StoreDataService.defaultProducts.length >= 6) {
      _items.add(CartItem(product: StoreDataService.defaultProducts[0], quantity: 1));
      _items.add(CartItem(product: StoreDataService.defaultProducts[1], quantity: 1));
      _items.add(CartItem(product: StoreDataService.defaultProducts[5], quantity: 1));
    }
  }

  void addToCart(StoreProduct product, {int qty = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += qty;
    } else {
      _items.add(CartItem(product: product, quantity: qty));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void selectAddress(DeliveryAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void addAddress(DeliveryAddress address) {
    _addresses.add(address);
    _selectedAddress = address;
    notifyListeners();
  }

  void setDeliveryMethod(String method) {
    _selectedDeliveryMethod = method;
    notifyListeners();
  }

  StoreOrder placeOrder({
    required String paymentMethod,
    required String paymentStatus,
    String? upiId,
  }) {
    final newOrderNum = '#DS${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}${DateTime.now().millisecond.toString().padLeft(3, '0')}';
    
    final order = StoreOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: newOrderNum,
      orderDate: '${DateTime.now().day} Oct ${DateTime.now().year}',
      customerName: selectedAddress.recipientName,
      customerPhone: selectedAddress.phoneNumber,
      shippingAddress: selectedAddress,
      items: _items.map((i) => {
        'name': i.product.name,
        'price': i.product.price,
        'quantity': i.quantity,
        'image': i.product.image,
      }).toList(),
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      orderStatus: 'packing',
      upiId: upiId,
    );

    _orders.insert(0, order);
    _items.clear(); // Clear cart after order placed
    notifyListeners();
    return order;
  }
}
