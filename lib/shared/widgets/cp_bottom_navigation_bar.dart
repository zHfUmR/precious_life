import 'package:flutter/material.dart';

/// 自定义底部导航栏项
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

/// 自定义底部导航栏
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 使用主题颜色或传入的自定义颜色
    final selectedColor = selectedItemColor ?? colorScheme.primary;
    final unselectedColor = unselectedItemColor ?? colorScheme.onSurface.withOpacity(0.6);
    final backgroundColor = colorScheme.surface;
    final labelColor = colorScheme.onSurface.withOpacity(0.8);

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
                  alignment: Alignment.bottomCenter,
                  children: [
                    // 底下的背景
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 48,
                        color: backgroundColor,
                      ),
                    ),
                    // 选中顶部弹出的圆弧背景
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      top: isSelected ? 1 : 16,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: backgroundColor,
                        ),
                      ),
                    ),
                    // 图标和标签
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                width: isSelected ? 36 : 24,
                                height: isSelected ? 36 : 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedColor : unselectedColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected 
                                      ? colorScheme.onPrimary 
                                      : colorScheme.surface,
                                  size: 16,
                                ),
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10, 
                              color: labelColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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
