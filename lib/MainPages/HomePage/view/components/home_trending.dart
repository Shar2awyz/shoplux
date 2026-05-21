import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_section_header.dart';

const _skeletonProducts = [
  HomeProduct(
    id: 'sk1', name: 'Running Shoes', price: 89.99, originalPrice: 149.99,
    imageUrl: '', categoryId: '', isTrending: true,
  ),
  HomeProduct(
    id: 'sk2', name: 'Smart Watch', price: 149.99, originalPrice: 199.99,
    imageUrl: '', categoryId: '', isTrending: true,
  ),
  HomeProduct(
    id: 'sk3', name: 'Tote Bag', price: 42.49, originalPrice: 49.99,
    imageUrl: '', categoryId: '', isTrending: true,
  ),
  HomeProduct(
    id: 'sk4', name: 'Laptop Sleeve', price: 20.99, originalPrice: 29.99,
    imageUrl: '', categoryId: '', isTrending: true,
  ),
];

const _loadMorePlaceholders = [
  HomeProduct(
    id: 'lm1', name: 'New Product', price: 59.99, originalPrice: 79.99,
    imageUrl: '', categoryId: '', isTrending: true,
  ),
  HomeProduct(
    id: 'lm2', name: 'New Product', price: 59.99, originalPrice: 79.99,
    imageUrl: '', categoryId: '', isTrending: true,
  ),
];

class HomeTrending extends StatelessWidget {
  final List<HomeProduct> products;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final void Function(String productId) onWishlistTap;
  final void Function(HomeProduct product) onProductTap;
  final void Function(HomeProduct product) onAddToCart;
  final VoidCallback? onSeeAll;
  final bool showSectionHeader;

  const HomeTrending({
    super.key,
    required this.products,
    required this.onWishlistTap,
    required this.onProductTap,
    required this.onAddToCart,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onSeeAll,
    this.showSectionHeader = true,
  });

  Color _colorFor(String id, List<Color> cardColors) =>
      cardColors[id.hashCode.abs() % cardColors.length];

  List<Widget> _buildRows(
    List<HomeProduct> items,
    double cardWidth,
    double cardHeight,
    double gap,
    bool interactive,
    List<Color> cardColors,
  ) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final pair = items.skip(i).take(2).toList();
      rows.add(
        Row(
          children: [
            for (var j = 0; j < pair.length; j++) ...[
              if (j > 0) SizedBox(width: gap),
              _TrendingCard(
                product: pair[j],
                width: cardWidth,
                height: cardHeight,
                bgColor: _colorFor(pair[j].id, cardColors),
                onWishlistTap: interactive ? onWishlistTap : (_) {},
                onProductTap: interactive ? onProductTap : (_) {},
                onAddToCart: interactive ? onAddToCart : (_) {},
              ),
            ],
            if (pair.length == 1) ...[
              SizedBox(width: gap),
              SizedBox(width: cardWidth),
            ],
          ],
        ),
      );
      if (i + 2 < items.length) rows.add(SizedBox(height: gap));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cardColors = colors.cardBackgrounds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final gap = w * 0.04;
        final cardWidth = (w - gap) / 2;
        final cardHeight = cardWidth * 1.45;

        final isSkeletonActive = isLoading && products.isEmpty;
        final displayItems = isSkeletonActive ? _skeletonProducts : products;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSectionHeader) ...[
              HomeSectionHeader(title: 'Trending Now', onSeeAll: onSeeAll),
              SizedBox(height: w * 0.038),
            ],
            Skeletonizer(
              enabled: isSkeletonActive,
              child: Column(
                children: _buildRows(
                  displayItems,
                  cardWidth,
                  cardHeight,
                  gap,
                  !isSkeletonActive,
                  cardColors,
                ),
              ),
            ),
            if (isLoadingMore) ...[
              SizedBox(height: gap),
              Skeletonizer(
                enabled: true,
                child: Column(
                  children: _buildRows(
                    _loadMorePlaceholders,
                    cardWidth,
                    cardHeight,
                    gap,
                    false,
                    cardColors,
                  ),
                ),
              ),
            ],
            if (!isLoadingMore && !hasMore && products.isNotEmpty) ...[
              SizedBox(height: gap),
              Center(
                child: Text(
                  "You've seen it all",
                  style: TextStyle(
                    color: colors.grey,
                    fontSize: w * 0.034,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final HomeProduct product;
  final double width;
  final double height;
  final Color bgColor;
  final void Function(String) onWishlistTap;
  final void Function(HomeProduct) onProductTap;
  final void Function(HomeProduct) onAddToCart;

  const _TrendingCard({
    required this.product,
    required this.width,
    required this.height,
    required this.bgColor,
    required this.onWishlistTap,
    required this.onProductTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final heartSize = width * 0.085;

    return GestureDetector(
      onTap: () => onProductTap(product),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _ImageFallback(
                                name: product.name,
                                width: width,
                              ),
                            )
                          : _ImageFallback(name: product.name, width: width),
                    ),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toInt()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.072,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => onWishlistTap(product.id),
                      child: Container(
                        width: heartSize * 1.4,
                        height: heartSize * 1.4,
                        decoration: BoxDecoration(
                          color: product.isWishlisted
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : colors.fieldBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isWishlisted
                              ? AppColors.primary
                              : colors.grey,
                          size: heartSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                width * 0.07,
                width * 0.025,
                width * 0.07,
                width * 0.06,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: width * 0.09,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.hasDiscount)
                              Text(
                                '\$${product.originalPrice % 1 == 0 ? product.originalPrice.toInt() : product.originalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: width * 0.065,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                            Text(
                              '\$${product.price % 1 == 0 ? product.price.toInt() : product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: width * 0.082,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onAddToCart(product),
                        child: Container(
                          width: width * 0.22,
                          height: width * 0.22,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            color: AppColors.primary,
                            size: width * 0.11,
                          ),
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
  }
}

class _ImageFallback extends StatelessWidget {
  final String name;
  final double width;

  const _ImageFallback({required this.name, required this.width});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: context.colors.text.withValues(alpha: 0.3),
          fontSize: width * 0.38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
