import 'package:flutter/material.dart';
import 'package:shoplux/core/app_color_scheme.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return Container(
          height: w * 0.135,
          decoration: BoxDecoration(
            color: colors.fieldBackground,
            borderRadius: BorderRadius.circular(w * 0.07),
          ),
          padding: EdgeInsets.symmetric(horizontal: w * 0.045),
          child: Row(
            children: [
              Text('🔍', style: TextStyle(fontSize: w * 0.048)),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Text(
                  'Search 10,000+ products...',
                  style: TextStyle(
                    color: colors.grey,
                    fontSize: w * 0.038,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(w * 0.018),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(w * 0.022),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: colors.grey,
                  size: w * 0.048,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
