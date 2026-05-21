import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';

class HomeHeader extends StatelessWidget {
  final int cartCount;
  final String? userName;
  final VoidCallback? onCartTap;

  const HomeHeader({super.key, this.cartCount = 0, this.userName, this.onCartTap});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _greetingEmoji {
    final h = DateTime.now().hour;
    if (h < 12) return '⛅';
    if (h < 18) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final iconSize = w * 0.115;
        final displayName =
            (userName?.isNotEmpty == true) ? userName! : 'Alex Johnson';
        final initial =
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$_greeting ',
                        style: TextStyle(
                          color: colors.grey,
                          fontSize: w * 0.038,
                        ),
                      ),
                      Text(
                        _greetingEmoji,
                        style: TextStyle(fontSize: w * 0.038),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Skeletonizer(
                    enabled: userName == null,
                    child: Text(
                      displayName,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: w * 0.062,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _CartButton(size: iconSize, count: cartCount, onTap: onCartTap),
            SizedBox(width: w * 0.03),
            _Avatar(size: iconSize, initial: initial),
          ],
        );
      },
    );
  }
}

class _CartButton extends StatelessWidget {
  final double size;
  final int count;
  final VoidCallback? onTap;

  const _CartButton({required this.size, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.fieldBackground,
              borderRadius: BorderRadius.circular(size * 0.28),
            ),
            child: Center(
              child: Text('🛒', style: TextStyle(fontSize: size * 0.48)),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: size * 0.38,
                minHeight: size * 0.38,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final double size;
  final String initial;

  const _Avatar({required this.size, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.46,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
