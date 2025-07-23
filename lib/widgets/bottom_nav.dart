import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iu_job_assessment/utils/app_colors.dart';

/// Bottom navigation bar component
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  /// Standard BottomNavigationBar with custom BottomNavigationBarItem
  /// to give darker background effect on selected item
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: _buildNavItems(),
    );
  }

  /// Build navigation items with custom selected icons
  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      BottomNavigationBarItem(
        icon: _buildIconWithBackground(0, Icons.speed),
        activeIcon: _buildIconWithBackground(0, Icons.speed, isActive: true),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: _buildIconWithBackground(1, Icons.list),
        activeIcon: _buildIconWithBackground(1, Icons.list, isActive: true),
        label: 'Report List',
      ),
      BottomNavigationBarItem(
        icon: _buildIconWithBackground(2, Icons.location_on_outlined),
        activeIcon: _buildIconWithBackground(
          2,
          Icons.location_on_outlined,
          isActive: true,
        ),
        label: 'Report Map',
      ),
      BottomNavigationBarItem(
        icon: _buildIconWithBackground(
          3,
          SvgPicture.asset('assets/svgs/Account mannager.svg'),
        ),
        activeIcon: _buildIconWithBackground(
          3,
          SvgPicture.asset('assets/svgs/Account mannager.svg'),
          isActive: true,
        ),
        label: 'Account',
      ),
    ];
  }

  /// Build icon with optional background for selected state
  Widget _buildIconWithBackground(
    int index,
    dynamic icon, { // In order to Accept IconData or Widget(SvgPicture)
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: isActive && currentIndex == index
          ? BoxDecoration(
              color: AppColors.black, // Subtle background
              borderRadius: BorderRadius.circular(24),
            )
          : null,
      child: icon is IconData
          ? Icon(icon)
          : icon is Widget
          ? icon
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBottomNav();
  }
}
