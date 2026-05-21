import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/search/presentation/states/search_state.dart';
import 'package:shoplux/features/search/presentation/viewmodels/search_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.onProductTap,
    this.initialCategoryId,
    this.showTitle = true,
  });

  final void Function(HomeProduct)? onProductTap;
  final String? initialCategoryId;
  final bool showTitle;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _scrollController = ScrollController()..addListener(_onScroll);
    final cubit = context.read<SearchCubit>();
    cubit.init();
    if (widget.initialCategoryId != null) {
      cubit.onQueryChanged('');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) cubit.setCategoryFilter(widget.initialCategoryId!);
      });
    }
  }

  void _onFocusChange() => setState(() => _isFocused = _focusNode.hasFocus);

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPadding = mq.size.width * 0.05;
    final vPadding = mq.size.height * 0.022;
    final colors = context.colors;

    return BlocConsumer<SearchCubit, SearchState>(
      listenWhen: (prev, curr) => curr.wishlistError != prev.wishlistError,
      listener: (context, state) {
        if (state.wishlistError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.wishlistError!),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: vPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showTitle) ...[
                  Text(
                    'Discover',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: mq.size.width * 0.075,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: mq.size.height * 0.02),
                ],
                _SearchBar(
                  controller: _textController,
                  focusNode: _focusNode,
                  isFocused: _isFocused,
                  onChanged: context.read<SearchCubit>().onQueryChanged,
                  onClear: () {
                    _textController.clear();
                    context.read<SearchCubit>().onQueryChanged('');
                  },
                ),
                SizedBox(height: mq.size.height * 0.018),
                _FilterChipBar(state: state),
                SizedBox(height: mq.size.height * 0.022),
                _buildBody(context, state, mq),
                SizedBox(height: mq.size.height * 0.022),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SearchState state, MediaQueryData mq) {
    if (state.isInitial) {
      return _SearchPrompt(width: mq.size.width);
    }
    if (state.isLoading) {
      return _SearchGrid(
        products: _skeletonProducts,
        isLoadingMore: false,
        hasMore: false,
        onWishlistTap: (_) {},
        onProductTap: null,
        isSkeleton: true,
        width: mq.size.width - mq.size.width * 0.1,
      );
    }
    if (state.hasError) {
      return _ErrorState(
        message: state.error ?? 'Something went wrong',
        onRetry: () => context.read<SearchCubit>().onQueryChanged(state.query),
      );
    }
    if (state.isEmpty) {
      return _EmptyState(query: state.query, width: mq.size.width);
    }
    return _SearchGrid(
      products: state.results,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      onWishlistTap: context.read<SearchCubit>().toggleWishlist,
      onProductTap: widget.onProductTap,
      isSkeleton: false,
      width: mq.size.width - mq.size.width * 0.1,
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    final hasText = controller.text.isNotEmpty;
    final isActive = isFocused || hasText;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: w * 0.135,
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(w * 0.05),
        border: Border.all(
          color: isActive ? AppColors.primary : colors.fieldBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: isActive ? AppColors.primary : colors.grey,
            size: w * 0.055,
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(
                color: colors.text,
                fontSize: w * 0.038,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: colors.grey,
                  fontSize: w * 0.038,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close_rounded,
                color: colors.grey,
                size: w * 0.048,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip bar
// ---------------------------------------------------------------------------

class _FilterChipBar extends StatelessWidget {
  const _FilterChipBar({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final allSelected = state.selectedCategoryId == null && !state.onSaleOnly;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: allSelected,
            onTap: cubit.setAllFilter,
          ),
          for (final category in state.categories) ...[
            const SizedBox(width: 8),
            _Chip(
              label: category.name,
              isSelected: state.selectedCategoryId == category.id,
              onTap: () => cubit.setCategoryFilter(category.id),
            ),
          ],
          const SizedBox(width: 8),
          _Chip(
            label: 'On Sale',
            isSelected: state.onSaleOnly,
            onTap: cubit.setOnSaleFilter,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.042,
          vertical: w * 0.022,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primary : colors.fieldBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colors.text : colors.grey,
            fontSize: w * 0.034,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Results grid
// ---------------------------------------------------------------------------

const _skeletonProducts = [
  HomeProduct(
    id: 'sk1', name: 'Air Max 270', price: 89, originalPrice: 120,
    imageUrl: '', categoryId: '',
  ),
  HomeProduct(
    id: 'sk2', name: 'React Run', price: 130, originalPrice: 130,
    imageUrl: '', categoryId: '',
  ),
  HomeProduct(
    id: 'sk3', name: 'Blazer Mid', price: 100, originalPrice: 140,
    imageUrl: '', categoryId: '',
  ),
  HomeProduct(
    id: 'sk4', name: 'Pegasus 41', price: 120, originalPrice: 120,
    imageUrl: '', categoryId: '',
  ),
];

class _SearchGrid extends StatelessWidget {
  const _SearchGrid({
    required this.products,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onWishlistTap,
    required this.isSkeleton,
    required this.width,
    this.onProductTap,
  });

  final List<HomeProduct> products;
  final bool isLoadingMore;
  final bool hasMore;
  final void Function(String) onWishlistTap;
  final void Function(HomeProduct)? onProductTap;
  final bool isSkeleton;
  final double width;

  Color _colorFor(String id, List<Color> cardColors) =>
      cardColors[id.hashCode.abs() % cardColors.length];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cardColors = colors.cardBackgrounds;
    final gap = width * 0.04;
    final cardWidth = (width - gap) / 2;
    final cardHeight = cardWidth * 1.32;

    final rows = <Widget>[];
    for (var i = 0; i < products.length; i += 2) {
      final pair = products.skip(i).take(2).toList();
      rows.add(Row(
        children: [
          for (var j = 0; j < pair.length; j++) ...[
            if (j > 0) SizedBox(width: gap),
            Skeletonizer(
              enabled: isSkeleton,
              child: _SearchCard(
                product: pair[j],
                width: cardWidth,
                height: cardHeight,
                bgColor: _colorFor(pair[j].id, cardColors),
                onWishlistTap: isSkeleton ? (_) {} : onWishlistTap,
                onProductTap: isSkeleton ? null : onProductTap,
              ),
            ),
          ],
          if (pair.length == 1) ...[
            SizedBox(width: gap),
            SizedBox(width: cardWidth),
          ],
        ],
      ));
      if (i + 2 < products.length) rows.add(SizedBox(height: gap));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...rows,
        if (isLoadingMore) ...[
          SizedBox(height: gap),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
        if (!isLoadingMore && !hasMore && products.isNotEmpty) ...[
          SizedBox(height: gap),
          Center(
            child: Text(
              "You've seen it all",
              style: TextStyle(
                color: colors.grey,
                fontSize: width * 0.034,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.product,
    required this.width,
    required this.height,
    required this.bgColor,
    required this.onWishlistTap,
    this.onProductTap,
  });

  final HomeProduct product;
  final double width;
  final double height;
  final Color bgColor;
  final void Function(String) onWishlistTap;
  final void Function(HomeProduct)? onProductTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final badgeFontSize = width * 0.072;
    final nameFontSize = width * 0.09;
    final priceFontSize = width * 0.082;
    final heartSize = width * 0.085;

    return GestureDetector(
      onTap: onProductTap != null ? () => onProductTap!(product) : null,
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
                              errorBuilder: (_, _, _) =>
                                  _Fallback(name: product.name, width: width),
                            )
                          : _Fallback(name: product.name, width: width),
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
                            fontSize: badgeFontSize,
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
                      fontSize: nameFontSize,
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
                                  fontSize: priceFontSize * 0.8,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                ),
                              ),
                            Text(
                              '\$${product.price % 1 == 0 ? product.price.toInt() : product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: priceFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.read<CartCubit>().addItem(product),
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

class _Fallback extends StatelessWidget {
  const _Fallback({required this.name, required this.width});

  final String name;
  final double width;

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

// ---------------------------------------------------------------------------
// Empty / prompt / error states
// ---------------------------------------------------------------------------

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: width * 1.2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              color: colors.grey.withValues(alpha: 0.4),
              size: width * 0.18,
            ),
            SizedBox(height: width * 0.04),
            Text(
              'Search for products',
              style: TextStyle(
                color: colors.grey,
                fontSize: width * 0.042,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: width * 0.02),
            Text(
              'Find shoes, clothing, accessories and more',
              style: TextStyle(
                color: colors.grey.withValues(alpha: 0.6),
                fontSize: width * 0.034,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, required this.width});
  final String query;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: width * 1.2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔍', style: TextStyle(fontSize: width * 0.14)),
            SizedBox(height: width * 0.04),
            Text(
              query.isNotEmpty ? 'No results for "$query"' : 'No products found',
              style: TextStyle(
                color: colors.text,
                fontSize: width * 0.042,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.02),
            Text(
              'Try a different search or filter',
              style: TextStyle(
                color: colors.grey,
                fontSize: width * 0.034,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    return SizedBox(
      height: w * 1.2,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('😕', style: TextStyle(fontSize: w * 0.12)),
            SizedBox(height: w * 0.04),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: colors.text,
                fontSize: w * 0.042,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: w * 0.02),
            Text(
              message,
              style: TextStyle(color: colors.grey, fontSize: w * 0.034),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: w * 0.06),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.08,
                  vertical: w * 0.035,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Try again',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.036,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
