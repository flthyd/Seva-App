class StoreProduct {
  final String id;
  final String name;
  final String teluguCategory;
  final String categoryId;
  final double price;
  final double originalPrice;
  final int discountPercent;
  final double rating;
  final int reviewsCount;
  final String image;
  final List<String> galleryImages;
  final String description;
  final List<String> kitItems; // ఈ కిట్‌లో ఉన్నవి
  final bool inStock;
  final int stockQuantity;

  const StoreProduct({
    required this.id,
    required this.name,
    required this.teluguCategory,
    required this.categoryId,
    required this.price,
    required this.originalPrice,
    required this.discountPercent,
    this.rating = 4.8,
    this.reviewsCount = 120,
    required this.image,
    this.galleryImages = const [],
    required this.description,
    this.kitItems = const [],
    this.inStock = true,
    this.stockQuantity = 50,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teluguCategory': teluguCategory,
      'categoryId': categoryId,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'image': image,
      'galleryImages': galleryImages,
      'description': description,
      'kitItems': kitItems,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
    };
  }

  factory StoreProduct.fromMap(Map<String, dynamic> map, String id) {
    return StoreProduct(
      id: id,
      name: map['name'] ?? '',
      teluguCategory: map['teluguCategory'] ?? 'పూజా సామాగ్రి',
      categoryId: map['categoryId'] ?? 'pooja_samagri',
      price: (map['price'] ?? 0.0).toDouble(),
      originalPrice: (map['originalPrice'] ?? 0.0).toDouble(),
      discountPercent: map['discountPercent'] ?? 0,
      rating: (map['rating'] ?? 4.8).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 120,
      image: map['image'] ?? 'assets/images/store/prod_pooja_kit.png',
      galleryImages: List<String>.from(map['galleryImages'] ?? []),
      description: map['description'] ?? '',
      kitItems: List<String>.from(map['kitItems'] ?? []),
      inStock: map['inStock'] ?? true,
      stockQuantity: map['stockQuantity'] ?? 50,
    );
  }
}

class CartItem {
  final StoreProduct product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class DeliveryAddress {
  final String id;
  final String title; // ఉదా: "ఇంటి చిరునామా" or "ఆఫీస్ చిరునామా"
  final String recipientName;
  final String phoneNumber;
  final String houseAndStreet;
  final String cityOrVillage;
  final String districtAndState;
  final String pincode;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.phoneNumber,
    required this.houseAndStreet,
    required this.cityOrVillage,
    required this.districtAndState,
    required this.pincode,
    this.isDefault = false,
  });

  String get fullAddressDisplay =>
      '$houseAndStreet, $cityOrVillage, $districtAndState - $pincode';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'houseAndStreet': houseAndStreet,
      'cityOrVillage': cityOrVillage,
      'districtAndState': districtAndState,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryAddress(
      id: id,
      title: map['title'] ?? 'ఇంటి చిరునామా',
      recipientName: map['recipientName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      houseAndStreet: map['houseAndStreet'] ?? '',
      cityOrVillage: map['cityOrVillage'] ?? '',
      districtAndState: map['districtAndState'] ?? '',
      pincode: map['pincode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class StoreOrder {
  final String id;
  final String orderNumber; // e.g., #DS20261027001
  final String orderDate;
  final String customerName;
  final String customerPhone;
  final DeliveryAddress shippingAddress;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double totalAmount;
  final String paymentMethod; // UPI, Card, NetBanking, COD
  final String paymentStatus; // Paid, Pending, Failed
  final String orderStatus; // order_placed, packing, shipped, out_for_delivery, delivered
  final String? upiId;

  const StoreOrder({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.upiId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress.toMap(),
      'items': items,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryCharge': deliveryCharge,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'upiId': upiId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory StoreOrder.fromMap(Map<String, dynamic> map, String id) {
    return StoreOrder(
      id: id,
      orderNumber: map['orderNumber'] ?? '#DS${DateTime.now().millisecondsSinceEpoch}',
      orderDate: map['orderDate'] ?? '27 Oct 2026',
      customerName: map['customerName'] ?? 'భక్తుడు',
      customerPhone: map['customerPhone'] ?? '',
      shippingAddress: DeliveryAddress.fromMap(
        map['shippingAddress'] is Map<String, dynamic> ? map['shippingAddress'] : {},
        'addr_$id',
      ),
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      deliveryCharge: (map['deliveryCharge'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      paymentStatus: map['paymentStatus'] ?? 'Paid',
      orderStatus: map['orderStatus'] ?? 'packing',
      upiId: map['upiId'],
    );
  }
}
