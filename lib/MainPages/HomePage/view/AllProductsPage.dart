import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/home/presentation/states/home_state.dart';
import 'package:shoplux/features/home/presentation/viewmodels/home_cubit.dart';
import 'package:shoplux/features/product_detail/presentation/view/ProductDetailPage.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_trending.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      context.read<HomeCubit>().loadMoreProducts();
    }
  }

  void _navigateToProduct(HomeProduct product) {
    Navigator.push(context, ProductDetailPage.route(product));
  }

  void _addToCart(HomeProduct product) {
    context.read<CartCubit>().addItem(product);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Products',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: colors.fieldBackground,
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.all(hPadding),
              child: HomeTrending(
                products: state.trendingProducts,
                isLoading: state.isLoading && state.trendingProducts.isEmpty,
                isLoadingMore: state.isLoadingMoreProducts,
                hasMore: state.hasMoreProducts,
                onWishlistTap: (id) =>
                    context.read<HomeCubit>().toggleWishlist(id),
                onAddToCart: _addToCart,
                onProductTap: _navigateToProduct,
                showSectionHeader: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
