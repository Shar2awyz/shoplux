import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/MainPages/HomePage/view/components/home_section_header.dart';

const _skeletonCategories = [
  HomeCategory(id: '1', name: 'Shoes', iconUrl: '', color: '#6C63FF'),
  HomeCategory(id: '2', name: 'Apparel', iconUrl: '', color: '#6C63FF'),
  HomeCategory(id: '3', name: 'Tech', iconUrl: '', color: '#6C63FF'),
  HomeCategory(id: '4', name: 'Watches', iconUrl: '', color: '#6C63FF'),
  HomeCategory(id: '5', name: 'Bags', iconUrl: '', color: '#6C63FF'),
];

class HomeCategories extends StatefulWidget {
  final List<HomeCategory> categories;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final void Function(HomeCategory)? onCategoryTap;

  const HomeCategories({
    super.key,
    required this.categories,
    this.isLoading = false,
    this.onSeeAll,
    this.onCategoryTap,
  });

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final tileSize = w * 0.19;
        final labelFontSize = tileSize * 0.2;
        final labelSpacing = tileSize * 0.1;
        final labelHeight = labelFontSize * 1.5;
        final listHeight = tileSize + labelSpacing + labelHeight;

        final isSkeletonActive =
            widget.isLoading && widget.categories.isEmpty;
        final items =
            isSkeletonActive ? _skeletonCategories : widget.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(title: 'Categories', onSeeAll: widget.onSeeAll),
            SizedBox(height: w * 0.038),
            Skeletonizer(
              enabled: isSkeletonActive,
              child: SizedBox(
                height: listHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, i) => SizedBox(width: w * 0.042),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: isSkeletonActive
                        ? null
                        : () {
                            setState(() => _selectedIndex = index);
                            widget.onCategoryTap?.call(items[index]);
                          },
                    child: _CategoryTile(
                      category: items[index],
                      size: tileSize,
                      isSelected: !isSkeletonActive && index == _selectedIndex,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final HomeCategory category;
  final double size;
  final bool isSelected;

  const _CategoryTile({
    required this.category,
    required this.size,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.fieldBackground,
            borderRadius: BorderRadius.circular(size * 0.24),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.24),
            child: category.iconUrl.isNotEmpty
                ? Image.network(
                    category.iconUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        _FallbackIcon(size: size),
                  )
                : _FallbackIcon(size: size),
          ),
        ),
        SizedBox(height: size * 0.1),
        Text(
          category.name,
          style: TextStyle(
            color: isSelected ? colors.text : colors.grey,
            fontSize: size * 0.2,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final double size;

  const _FallbackIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.category_outlined,
        color: context.colors.grey,
        size: size * 0.46,
      ),
    );
  }
}
