import 'package:shoplux/features/product_detail/domain/models/product_variant.dart';

class ProductExtras {
  final String brandName;
  final String categoryName;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final List<ProductVariant> variants;

  const ProductExtras({
    required this.brandName,
    required this.categoryName,
    required this.description,
    required this.sizes,
    required this.colors,
    required this.variants,
  });
}
