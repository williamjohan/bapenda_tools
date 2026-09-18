import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_new.dart';
import 'home_feature_menu_item.dart';

class HomeBapendaCoreFeatureGrid extends StatelessWidget {
  const HomeBapendaCoreFeatureGrid({super.key, required this.items});

  final List<HomeFeatureMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppThemeColors.defaultSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppThemeColors.subtleBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu layanan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppThemeColors.secondaryText,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) => _FeatureCard(item: items[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});

  final HomeFeatureMenuItem item;

  @override
  Widget build(BuildContext context) {
    final disabled = !item.enabled;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Material(
        color: AppThemeColors.defaultBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: disabled
                        ? AppThemeColors.defaultBackground
                        : AppThemeColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 19,
                    color: disabled ? AppThemeColors.tertiaryText : AppThemeColors.gold,
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? AppThemeColors.secondaryText
                        : AppThemeColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppThemeColors.tertiaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
