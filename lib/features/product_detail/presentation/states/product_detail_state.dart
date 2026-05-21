import 'package:shoplux/features/home/domain/models/home_product.dart';

class ProductDetailState {
  final HomeProduct product;
  final bool isLoadingExtras;
  final String brandName;
  final String categoryName;
  final String description;
  final List<String> sizes;
  final List<String> colors;
  final String? selectedSize;
  final String? selectedColor;
  final String? error;
  final String? wishlistError;

  const ProductDetailState({
    required this.product,
    this.isLoadingExtras = true,
    this.brandName = '',
    this.categoryName = '',
    this.description = '',
    this.sizes = const [],
    this.colors = const [],
    this.selectedSize,
    this.selectedColor,
    this.error,
    this.wishlistError,
  });

  ProductDetailState copyWith({
    HomeProduct? product,
    bool? isLoadingExtras,
    String? brandName,
    String? categoryName,
    String? description,
    List<String>? sizes,
    List<String>? colors,
    String? selectedSize,
    String? selectedColor,
    String? error,
    String? wishlistError,
  }) => ProductDetailState(
        product: product ?? this.product,
        isLoadingExtras: isLoadingExtras ?? this.isLoadingExtras,
        brandName: brandName ?? this.brandName,
        categoryName: categoryName ?? this.categoryName,
        description: description ?? this.description,
        sizes: sizes ?? this.sizes,
        colors: colors ?? this.colors,
        selectedSize: selectedSize ?? this.selectedSize,
        selectedColor: selectedColor ?? this.selectedColor,
        error: error ?? this.error,
        wishlistError: wishlistError ?? this.wishlistError,
      );
}
