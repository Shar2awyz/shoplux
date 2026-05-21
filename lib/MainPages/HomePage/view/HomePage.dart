import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/components/custom_bottom_nav_bar.dart';
import 'package:shoplux/features/cart/presentation/states/cart_state.dart';
import 'package:shoplux/features/cart/presentation/view/CartPage.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/home/presentation/states/home_state.dart';
import 'package:shoplux/features/home/presentation/viewmodels/home_cubit.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_header.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_search_bar.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_banner.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_categories.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_trending.dart';
import 'package:shoplux/MainPages/ProfilePage/view/ProfilePage.dart';
import 'package:shoplux/features/product_detail/presentation/view/ProductDetailPage.dart';
import 'package:shoplux/features/search/presentation/view/SearchPage.dart';
import 'package:shoplux/features/wishlist/presentation/view/WishlistPage.dart';
import 'package:shoplux/features/wishlist/presentation/viewmodels/wishlist_cubit.dart';
import 'package:shoplux/features/chat/presentation/view/ChatPage.dart';
import 'package:shoplux/features/notifications/presentation/view/NotificationsPage.dart';
import 'package:shoplux/features/notifications/presentation/viewmodels/notification_cubit.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/MainPages/HomePage/view/AllCategoriesPage.dart';
import 'package:shoplux/MainPages/HomePage/view/AllProductsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    context.read<CartCubit>().load(userId);
    context.read<NotificationCubit>().load();
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

  String get _userName {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    return meta?['full_name'] as String? ??
        meta?['name'] as String? ??
        'there';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPadding = mq.size.width * 0.05;
    final vSpacing = mq.size.height * 0.027;
    final colors = context.colors;

    return MultiBlocListener(
      listeners: [
        BlocListener<CartCubit, CartState>(
          listenWhen: (prev, curr) =>
              curr.addedProductName != null &&
              curr.addedProductName != prev.addedProductName,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('${state.addedProductName} added to cart'),
                  backgroundColor: context.colors.fieldBackground,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'View Cart',
                    textColor: AppColors.primary,
                    onPressed: () => setState(() => _currentIndex = 2),
                  ),
                ),
              );
            context.read<CartCubit>().clearAddedFeedback();
          },
        ),
      ],
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (prev, curr) =>
            curr.wishlistError != prev.wishlistError ||
            curr.loadMoreError != prev.loadMoreError,
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
          if (state.loadMoreError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Could not load more products'),
                backgroundColor: context.colors.fieldBackground,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.hasError && _currentIndex == 0) {
            return _buildErrorPage(
                context, state.errorMessage ?? 'Unknown error');
          }

          return _buildPage(
            context: context,
            hPadding: hPadding,
            vSpacing: vSpacing,
            state: state,
            colors: colors,
          );
        },
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required double hPadding,
    required double vSpacing,
    required HomeState state,
    required AppColorScheme colors,
  }) {
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: BlocSelector<CartCubit, CartState, int>(
        selector: (s) => s.totalCount,
        builder: (context, cartCount) => CustomBottomNavBar(
          currentIndex: _currentIndex > 3 ? 3 : _currentIndex,
          cartItemCount: cartCount,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
      body: _currentIndex == 1
          ? SafeArea(child: SearchPage(onProductTap: _navigateToProduct))
          : _currentIndex == 2
              ? const CartPage()
          : _currentIndex == 3
              ? SafeArea(
                  child: ProfilePage(
                    onLiveChatTap: () => setState(() => _currentIndex = 6),
                    onNotificationsTap: () => setState(() => _currentIndex = 4),
                    onWishlistTap: () {
                      context.read<WishlistCubit>().load();
                      setState(() => _currentIndex = 5);
                    },
                  ),
                )
          : _currentIndex == 4
              ? const NotificationsPage()
          : _currentIndex == 5
              ? const SafeArea(child: WishlistPage())
          : _currentIndex == 6
              ? ChatPage(
                  onBack: () => setState(() => _currentIndex = 0),
                )
          : SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: colors.fieldBackground,
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: hPadding,
                    vertical: MediaQuery.of(context).size.height * 0.022,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocSelector<CartCubit, CartState, int>(
                        selector: (s) => s.totalCount,
                        builder: (context, cartCount) => HomeHeader(
                          cartCount: cartCount,
                          userName: isLoading ? null : _userName,
                          onCartTap: () => setState(() => _currentIndex = 2),
                        ),
                      ),
                      SizedBox(height: vSpacing),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 1),
                        child: const HomeSearchBar(),
                      ),
                      SizedBox(height: vSpacing),
                      HomeBanner(
                        banner: isLoading ? null : state.featuredBanner,
                        isLoading: isLoading,
                      ),
                      SizedBox(height: vSpacing),
                      HomeCategories(
                        categories: state.categories,
                        isLoading: isLoading,
                        onSeeAll: state.categories.isNotEmpty
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllCategoriesPage(
                                      categories: state.categories,
                                    ),
                                  ),
                                )
                            : null,
                        onCategoryTap: (HomeCategory category) =>
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CategoryProductsPage(category: category),
                          ),
                        ),
                      ),
                      SizedBox(height: vSpacing),
                      HomeTrending(
                        products: state.trendingProducts,
                        isLoading: isLoading,
                        isLoadingMore: state.isLoadingMoreProducts,
                        hasMore: state.hasMoreProducts,
                        onWishlistTap: (id) =>
                            context.read<HomeCubit>().toggleWishlist(id),
                        onAddToCart: _addToCart,
                        onProductTap: _navigateToProduct,
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllProductsPage(),
                          ),
                        ),
                      ),
                      SizedBox(height: vSpacing),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildErrorPage(BuildContext context, String message) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                onTap: () => context.read<HomeCubit>().refresh(),
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
