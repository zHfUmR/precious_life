import 'package:flutter/material.dart';
import 'package:precious_life/config/color_style.dart';

// 自定义底部导航栏项
class CpBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CpBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// 自定义底部导航栏
class CpBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<CpBottomNavItem> items;
  final ValueChanged<int>? onTap;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CpBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.bottomCenter,
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap?.call(index),
              child: SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 48,
                        color: CPColors.lightGrey,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      top: isSelected ? 1 : 16,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CPColors.lightGrey,
                        ),
                      ),
                    ),
                    // 图标大小从32到48的动画
                    SizedBox(
                      height: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(height: 8), // 顶部间距
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            width: isSelected ? 36 : 24,
                            height: isSelected ? 36 : 24,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              item.label,
                              style: const TextStyle(fontSize: 10, color: CPColors.darkGrey),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
