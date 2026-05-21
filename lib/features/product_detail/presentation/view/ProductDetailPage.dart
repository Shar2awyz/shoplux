import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/product_detail/data/datasources/product_detail_remote_data_source.dart';
import 'package:shoplux/features/product_detail/data/repositories/product_detail_repository_impl.dart';
import 'package:shoplux/features/product_detail/presentation/states/product_detail_state.dart';
import 'package:shoplux/features/product_detail/presentation/viewmodels/product_detail_cubit.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';

Color _colorFromName(String name) {
  switch (name.toLowerCase()) {
    case 'black':       return const Color(0xFF1A1A1A);
    case 'white':       return const Color(0xFFF5F5F5);
    case 'red':         return const Color(0xFFE53935);
    case 'blue':        return const Color(0xFF1E88E5);
    case 'navy':        return const Color(0xFF1A237E);
    case 'green':       return const Color(0xFF43A047);
    case 'olive':       return const Color(0xFF827717);
    case 'yellow':      return const Color(0xFFFDD835);
    case 'orange':      return const Color(0xFFFB8C00);
    case 'purple':      return const Color(0xFF8E24AA);
    case 'lavender':    return const Color(0xFFCE93D8);
    case 'pink':        return const Color(0xFFE91E8C);
    case 'brown':       return const Color(0xFF6D4C41);
    case 'beige':       return const Color(0xFFF5F0DC);
    case 'cream':       return const Color(0xFFFFFDD0);
    case 'grey':
    case 'gray':        return const Color(0xFF757575);
    case 'silver':      return const Color(0xFFBDBDBD);
    case 'gold':        return const Color(0xFFFFCA28);
    case 'teal':        return const Color(0xFF00897B);
    case 'turquoise':   return const Color(0xFF00BCD4);
    case 'cyan':        return const Color(0xFF00ACC1);
    case 'coral':       return const Color(0xFFFF7043);
    case 'salmon':      return const Color(0xFFEF9A9A);
    case 'khaki':       return const Color(0xFFC8B560);
    case 'maroon':      return const Color(0xFF7B1C1C);
    default:            return const Color(0xFF9E9E9E);
  }
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  static Route<void> route(HomeProduct product) => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ProductDetailCubit(
            repository: ProductDetailRepositoryImpl(
              dataSource: ProductDetailRemoteDataSourceImpl(
                client: Supabase.instance.client,
              ),
            ),
            product: product,
          )..loadExtras(),
          child: const ProductDetailPage(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailCubit, ProductDetailState>(
      listenWhen: (prev, curr) => curr.wishlistError != prev.wishlistError,
      listener: (context, state) {
        if (state.wishlistError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.wishlistError!),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) => _ProductDetailView(state: state),
    );
  }
}

// ---------------------------------------------------------------------------
// Main view
// ---------------------------------------------------------------------------

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView({required this.state});

  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _ImageSection(
            product: state.product,
            imageHeight: h * 0.42,
            onWishlistTap: () =>
                context.read<ProductDetailCubit>().toggleWishlist(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                w * 0.06,
                h * 0.025,
                w * 0.06,
                h * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandCategory(context, state, w),
                  SizedBox(height: h * 0.008),
                  Text(
                    state.product.name,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: w * 0.072,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: h * 0.016),
                  _buildPriceRow(state.product, w),
                  SizedBox(height: h * 0.014),
                  _buildRatingRow(state.product, w, colors),
                  if (state.description.isNotEmpty) ...[
                    SizedBox(height: h * 0.02),
                    Text(
                      state.description,
                      style: TextStyle(
                        color: colors.grey,
                        fontSize: w * 0.035,
                        height: 1.55,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (state.isLoadingExtras || state.sizes.isNotEmpty) ...[
                    SizedBox(height: h * 0.026),
                    _buildSizeSelector(context, state, w, h, colors),
                  ],
                  if (state.isLoadingExtras || state.colors.isNotEmpty) ...[
                    SizedBox(height: h * 0.026),
                    _buildColorSelector(context, state, w, h, colors),
                  ],
                  SizedBox(height: h * 0.03),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartButton(
        product: state.product,
        w: w,
        selectedSize: state.selectedSize,
        selectedColor: state.selectedColor,
      ),
    );
  }

  Widget _buildBrandCategory(
      BuildContext context, ProductDetailState state, double w) {
    final colors = context.colors;
    if (state.isLoadingExtras) {
      return Container(
        width: w * 0.35,
        height: 14,
        decoration: BoxDecoration(
          color: colors.fieldBackground,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    final parts = <String>[];
    if (state.brandName.isNotEmpty) parts.add(state.brandName);
    if (state.categoryName.isNotEmpty) parts.add(state.categoryName);
    if (parts.isEmpty) return const SizedBox.shrink();

    return Text(
      parts.join(' — '),
      style: TextStyle(
        color: AppColors.primary,
        fontSize: w * 0.036,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildPriceRow(HomeProduct product, double w) {
    final priceStr = product.price % 1 == 0
        ? '\$${product.price.toInt()}'
        : '\$${product.price.toStringAsFixed(2)}';
    final originalStr = product.originalPrice % 1 == 0
        ? '\$${product.originalPrice.toInt()}'
        : '\$${product.originalPrice.toStringAsFixed(2)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          priceStr,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: w * 0.09,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.hasDiscount) ...[
          SizedBox(width: w * 0.028),
          Builder(builder: (context) {
            final colors = context.colors;
            return Text(
              originalStr,
              style: TextStyle(
                color: colors.grey,
                fontSize: w * 0.042,
                decoration: TextDecoration.lineThrough,
                decorationColor: colors.grey,
              ),
            );
          }),
          SizedBox(width: w * 0.024),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.022,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xff1A3D2A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${product.discountPercentage.toInt()}% OFF',
              style: TextStyle(
                color: const Color(0xff2ECC71),
                fontSize: w * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingRow(HomeProduct product, double w, AppColorScheme colors) {
    final filledStars = product.rating.round().clamp(0, 5);

    return Row(
      children: [
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < filledStars ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xffF4C542),
              size: w * 0.048,
            );
          }),
        ),
        SizedBox(width: w * 0.02),
        Text(
          product.rating > 0
              ? '${product.rating.toStringAsFixed(1)} (${_formatCount(product.reviewCount)})'
              : 'No reviews yet',
          style: TextStyle(color: colors.grey, fontSize: w * 0.036),
        ),
      ],
    );
  }

  String _formatCount(int count) =>
      count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}K' : '$count';

  Widget _buildSizeSelector(
    BuildContext context,
    ProductDetailState state,
    double w,
    double h,
    AppColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SIZE',
          style: TextStyle(
            color: colors.grey,
            fontSize: w * 0.032,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: h * 0.014),
        if (state.isLoadingExtras)
          Row(
            children: List.generate(
              4,
              (_) => Padding(
                padding: EdgeInsets.only(right: w * 0.03),
                child: Container(
                  width: w * 0.13,
                  height: w * 0.13,
                  decoration: BoxDecoration(
                    color: colors.fieldBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: w * 0.03,
            runSpacing: w * 0.025,
            children: state.sizes.map((size) {
              final isSelected = state.selectedSize == size;
              return GestureDetector(
                onTap: () =>
                    context.read<ProductDetailCubit>().selectSize(size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: w * 0.13,
                  height: w * 0.13,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : colors.fieldBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : colors.fieldBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isSelected ? colors.text : colors.grey,
                        fontSize: w * 0.036,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildColorSelector(
    BuildContext context,
    ProductDetailState state,
    double w,
    double h,
    AppColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT COLOR',
          style: TextStyle(
            color: colors.grey,
            fontSize: w * 0.032,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: h * 0.014),
        if (state.isLoadingExtras)
          Row(
            children: List.generate(
              4,
              (_) => Padding(
                padding: EdgeInsets.only(right: w * 0.035),
                child: Container(
                  width: w * 0.11,
                  height: w * 0.11,
                  decoration: BoxDecoration(
                    color: colors.fieldBackground,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: w * 0.035,
            runSpacing: w * 0.03,
            children: state.colors.map((colorName) {
              final isSelected = state.selectedColor == colorName;
              final fill = _colorFromName(colorName);
              final isLight = fill.computeLuminance() > 0.75;
              return GestureDetector(
                onTap: () =>
                    context.read<ProductDetailCubit>().selectColor(colorName),
                child: Tooltip(
                  message: colorName,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: w * 0.11,
                    height: w * 0.11,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isLight
                                ? colors.fieldBorder
                                : Colors.transparent,
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: isLight ? Colors.black54 : Colors.white,
                            size: w * 0.055,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image section
// ---------------------------------------------------------------------------

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.product,
    required this.imageHeight,
    required this.onWishlistTap,
  });

  final HomeProduct product;
  final double imageHeight;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;

    return SizedBox(
      height: imageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: colors.cardBackgrounds[1]),
          Padding(
            padding: EdgeInsets.all(w * 0.08),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        _PlaceholderImage(name: product.name),
                  )
                : _PlaceholderImage(name: product.name),
          ),
          Positioned(
            top: topPad + 8,
            left: 12,
            child: _CircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: topPad + 8,
            right: 12,
            child: _CircleButton(
              icon: product.isWishlisted
                  ? Icons.favorite
                  : Icons.favorite_border,
              iconColor:
                  product.isWishlisted ? AppColors.primary : colors.text,
              onTap: onWishlistTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add to Cart button
// ---------------------------------------------------------------------------

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.product,
    required this.w,
    this.selectedSize,
    this.selectedColor,
  });

  final HomeProduct product;
  final double w;
  final String? selectedSize;
  final String? selectedColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(
        w * 0.06,
        12,
        w * 0.06,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(w * 0.04),
        child: InkWell(
          borderRadius: BorderRadius.circular(w * 0.04),
          splashColor: Colors.white.withValues(alpha: 0.35),
          highlightColor: Colors.white.withValues(alpha: 0.12),
          onTap: () {
            context.read<CartCubit>().addItem(
                  product,
                  selectedSize: selectedSize,
                  selectedColor: selectedColor,
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: w * 0.042),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.046,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: w * 0.025),
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: w * 0.052,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.1,
        height: w * 0.1,
        decoration: BoxDecoration(
          color: colors.fieldBackground.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? colors.text,
          size: w * 0.048,
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: context.colors.text.withValues(alpha: 0.12),
          fontSize: w * 0.38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
