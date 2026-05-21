import 'package:flutter/material.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/product_detail/presentation/view/ProductDetailPage.dart';
import 'package:shoplux/features/search/presentation/view/SearchPage.dart';

class AllCategoriesPage extends StatelessWidget {
  final List<HomeCategory> categories;

  const AllCategoriesPage({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          'All Categories',
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.78,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsPage(category: category),
              ),
            ),
            child: _CategoryGridTile(category: category),
          );
        },
      ),
    );
  }
}

class CategoryProductsPage extends StatelessWidget {
  final HomeCategory category;

  const CategoryProductsPage({super.key, required this.category});

  void _navigateToProduct(BuildContext context, HomeProduct product) {
    Navigator.push(context, ProductDetailPage.route(product));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          category.name,
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SearchPage(
          initialCategoryId: category.id,
          showTitle: false,
          onProductTap: (product) => _navigateToProduct(context, product),
        ),
      ),
    );
  }
}

class _CategoryGridTile extends StatelessWidget {
  final HomeCategory category;

  const _CategoryGridTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.fieldBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.grey.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: category.iconUrl.isNotEmpty
                  ? Image.network(
                      category.iconUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _FallbackIcon(),
                    )
                  : const _FallbackIcon(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category.name,
          style: TextStyle(
            color: colors.text,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (category.productCount > 0)
          Text(
            '${category.productCount} items',
            style: TextStyle(
              color: colors.grey,
              fontSize: 10,
            ),
          ),
      ],
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.category_outlined,
        color: context.colors.grey,
        size: 32,
      ),
    );
  }
}
