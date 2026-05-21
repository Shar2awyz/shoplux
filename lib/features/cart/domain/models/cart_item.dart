import 'dart:convert';

class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    this.quantity = 1,
    this.variant,
    this.selectedColor,
  });

  final String productId;
  final String name;
  final double price;
  final double originalPrice;
  final String imageUrl;
  final int quantity;
  final String? variant;       // selected size
  final String? selectedColor; // selected color

  double get lineTotal => price * quantity;
  double get lineSavings => originalPrice > price ? (originalPrice - price) * quantity : 0.0;
  bool get hasDiscount => originalPrice > price;

  CartItem copyWith({int? quantity, String? variant, String? selectedColor}) => CartItem(
        productId: productId,
        name: name,
        price: price,
        originalPrice: originalPrice,
        imageUrl: imageUrl,
        quantity: quantity ?? this.quantity,
        variant: variant ?? this.variant,
        selectedColor: selectedColor ?? this.selectedColor,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'originalPrice': originalPrice,
        'imageUrl': imageUrl,
        'quantity': quantity,
        if (variant != null) 'variant': variant,
        if (selectedColor != null) 'selectedColor': selectedColor,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['originalPrice'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        variant: json['variant'] as String?,
        selectedColor: json['selectedColor'] as String?,
      );

  static List<CartItem> listFromJson(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<CartItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}
