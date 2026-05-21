import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/wishlist/presentation/states/wishlist_state.dart';
import 'package:shoplux/features/wishlist/presentation/viewmodels/wishlist_cubit.dart';
import 'package:shoplux/features/product_detail/presentation/view/ProductDetailPage.dart';

const _skeletonItems = [
  HomeProduct(
    id: 'wsk1', name: 'Air Force 1', price: 110, originalPrice: 110,
    imageUrl: '', categoryId: '', isWishlisted: true,
  ),
  HomeProduct(
    id: 'wsk2', name: 'Dior Rouge', price: 42, originalPrice: 42,
    imageUrl: '', categoryId: '', isWishlisted: true,
  ),
  HomeProduct(
    id: 'wsk3', name: 'Prada Bag', price: 890, originalPrice: 890,
    imageUrl: '', categoryId: '', isWishlisted: true,
  ),
  HomeProduct(
    id: 'wsk4', name: 'Off-White Tee', price: 195, originalPrice: 195,
    imageUrl: '', categoryId: '', isWishlisted: true,
  ),
];

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistCubit>().load();
  }

  Color _colorFor(String id, List<Color> cardColors) =>
      cardColors[id.hashCode.abs() % cardColors.length];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WishlistCubit, WishlistState>(
      listenWhen: (prev, curr) => curr.removeError != prev.removeError,
      listener: (context, state) {
        if (state.removeError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.removeError!),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final colors = context.colors;
        final isSkeletonActive =
            (state.isLoading || state.status == WishlistStatus.initial) &&
            state.items.isEmpty;
        final displayItems = isSkeletonActive ? _skeletonItems : state.items;

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final hPadding = w * 0.05;
            final gap = w * 0.04;

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: colors.fieldBackground,
              onRefresh: () => context.read<WishlistCubit>().refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: w * 0.06,
                          bottom: w * 0.05,
                        ),
                        child: Text(
                          'Wishlist ❤️',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (state.hasError)
                        _ErrorView(
                          message: state.error ?? 'Something went wrong',
                          onRetry: () =>
                              context.read<WishlistCubit>().load(),
                        )
                      else if (state.isEmpty)
                        const _EmptyView()
                      else
                        Skeletonizer(
                          enabled: isSkeletonActive,
                          child: _WishlistGrid(
                            items: displayItems,
                            gap: gap,
                            colorFor: (id) =>
                                _colorFor(id, colors.cardBackgrounds),
                            interactive: !isSkeletonActive,
                            onRemove: (id) =>
                                context.read<WishlistCubit>().removeItem(id),
                            onAddToCart: (product) =>
                                context.read<CartCubit>().addItem(product),
                            onProductTap: (product) => Navigator.push(
                              context,
                              ProductDetailPage.route(product),
                            ),
                          ),
                        ),

                      SizedBox(height: w * 0.06),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Grid ────────────────────────────────────────────────────────────────────

class _WishlistGrid extends StatelessWidget {
  final List<HomeProduct> items;
  final double gap;
  final Color Function(String) colorFor;
  final bool interactive;
  final void Function(String) onRemove;
  final void Function(HomeProduct) onAddToCart;
  final void Function(HomeProduct) onProductTap;

  const _WishlistGrid({
    required this.items,
    required this.gap,
    required this.colorFor,
    required this.interactive,
    required this.onRemove,
    required this.onAddToCart,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - gap) / 2;
        final cardHeight = cardWidth * 1.58;

        final rows = <Widget>[];
        for (var i = 0; i < items.length; i += 2) {
          final pair = items.skip(i).take(2).toList();
          rows.add(
            Row(
              children: [
                for (var j = 0; j < pair.length; j++) ...[
                  if (j > 0) SizedBox(width: gap),
                  _WishlistCard(
                    product: pair[j],
                    width: cardWidth,
                    height: cardHeight,
                    bgColor: colorFor(pair[j].id),
                    onRemove: interactive ? () => onRemove(pair[j].id) : null,
                    onAddToCart: interactive ? () => onAddToCart(pair[j]) : null,
                    onTap: interactive ? () => onProductTap(pair[j]) : null,
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

        return Column(children: rows);
      },
    );
  }
}

// ─── Card ────────────────────────────────────────────────────────────────────

class _WishlistCard extends StatelessWidget {
  final HomeProduct product;
  final double width;
  final double height;
  final Color bgColor;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const _WishlistCard({
    required this.product,
    required this.width,
    required this.height,
    required this.bgColor,
    required this.onRemove,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final heartSize = width * 0.085;

    return GestureDetector(
      onTap: onTap,
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
                            errorBuilder: (context, error, stack) =>
                                _ImageFallback(
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
                    onTap: onRemove,
                    child: Container(
                      width: heartSize * 1.4,
                      height: heartSize * 1.4,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: AppColors.primary,
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
              width * 0.065,
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
                const SizedBox(height: 2),
                if (product.hasDiscount)
                  Text(
                    '\$${product.originalPrice % 1 == 0 ? product.originalPrice.toInt() : product.originalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: width * 0.07,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey,
                    ),
                  ),
                Text(
                  '\$${product.price % 1 == 0 ? product.price.toInt() : product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: width * 0.085,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: width * 0.045),
                GestureDetector(
                  onTap: onAddToCart,
                  child: Container(
                    height: width * 0.19,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '+ Add to Cart',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: width * 0.078,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

// ─── Helpers ─────────────────────────────────────────────────────────────────

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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    return SizedBox(
      height: w * 1.4,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤍', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 20),
              Text(
                'Your wishlist is empty',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save items you love and add them\nto your cart when ready.',
                style: TextStyle(color: colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    return SizedBox(
      height: w * 1.4,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'Try again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
