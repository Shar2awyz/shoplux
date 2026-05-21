import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/home/domain/models/featured_banner.dart';

const _placeholder = FeaturedBanner(
  id: '',
  productId: '',
  title: 'New Season Arrivals',
  subtitle: 'Limited time offer on premium footwear',
  imageUrl: '',
  discountPercentage: 40,
  ctaText: 'Shop Now',
);

class HomeBanner extends StatelessWidget {
  final FeaturedBanner? banner;
  final bool isLoading;

  const HomeBanner({super.key, this.banner, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isSkeletonActive = isLoading && banner == null;
    final data = banner ?? _placeholder;

    return Skeletonizer(
      enabled: isSkeletonActive,
      child: _BannerContent(banner: data),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final FeaturedBanner banner;

  const _BannerContent({required this.banner});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = colors.cardBackgrounds[0];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = w * 0.62;
        final hPad = w * 0.06;
        final vPad = h * 0.09;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: Container(color: baseColor),
                ),
                if (banner.imageUrl.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                // Dark overlay gradient for text readability (always dark)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.52, 1.0],
                      ),
                    ),
                  ),
                ),
                if (banner.imageUrl.isEmpty)
                  Positioned(
                    right: -(w * 0.04),
                    bottom: -(h * 0.06),
                    child: Transform.rotate(
                      angle: -0.22,
                      child: Text(
                        '👟',
                        style: TextStyle(fontSize: w * 0.44),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, vPad, w * 0.44, vPad),
                  child: LayoutBuilder(
                    builder: (context, inner) {
                      final availH = inner.maxHeight;
                      final badgeFontSize = (w * 0.028).clamp(9.0, 13.0);
                      final titleFontSize = (w * 0.056).clamp(18.0, 26.0);
                      final subtitleFontSize = (w * 0.03).clamp(10.0, 14.0);
                      final btnFontSize = (w * 0.034).clamp(11.0, 15.0);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (banner.discountPercentage > 0) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: w * 0.03,
                                vertical: availH * 0.045,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🔥 ',
                                    style: TextStyle(fontSize: badgeFontSize),
                                  ),
                                  Text(
                                    'SALE — ${banner.discountPercentage.toInt()}% OFF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: badgeFontSize,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: availH * 0.06),
                          ],
                          Text(
                            banner.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: availH * 0.04),
                          if (banner.subtitle.isNotEmpty)
                            Text(
                              banner.subtitle,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: subtitleFontSize,
                                height: 1.45,
                              ),
                            ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.045,
                              vertical: availH * 0.055,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  banner.ctaText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: btnFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: w * 0.015),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: btnFontSize,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
