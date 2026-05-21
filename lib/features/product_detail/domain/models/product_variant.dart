class ProductVariant {
  final String id;
  final String? size;
  final String? color;
  final String stockStatus;

  const ProductVariant({
    required this.id,
    this.size,
    this.color,
    required this.stockStatus,
  });
}
