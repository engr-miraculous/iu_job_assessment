import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iu_job_assessment/models/report_model.dart';
import 'package:iu_job_assessment/providers/report_form_provider.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Reusable category selector widget
class ReportCategorySelector extends ConsumerWidget {
  const ReportCategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(reportFormProvider).category;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What are you reporting?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 2,
          runSpacing: 12,
          children: ReportCategories.categories.map((category) {
            return _CategoryCard(
              category: category,
              isSelected: selectedCategory?.id == category.id,
              onTap: () {
                ref.read(reportFormProvider.notifier).updateCategory(category);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Individual category card widget
class _CategoryCard extends StatelessWidget {
  final ReportCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 95,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _getCategoryIcon(category.id, isSelected),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get appropriate icon for each category
  Widget _getCategoryIcon(String categoryId, bool isSelected) {
    final Color iconColor = isSelected ? AppColors.background : AppColors.black;
    const double iconSize = 20;

    switch (categoryId) {
      case 'dumped_rubbish':
        return SvgPicture.asset(
          'assets/svgs/bin.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      case 'graffiti_vandalism':
        return SvgPicture.asset(
          'assets/svgs/vandalism.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      case 'pedestrian_hazard':
        return SvgPicture.asset(
          'assets/svgs/pedestrian.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      case 'traffic_hazard':
        return SvgPicture.asset(
          'assets/svgs/traffic.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      case 'other':
        return SvgPicture.asset(
          'assets/svgs/others.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        );
      default:
        return Icon(Icons.report_outlined, color: iconColor, size: iconSize);
    }
  }
}
