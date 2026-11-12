import 'package:crop_shield_ai/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Bottom tab shell for Scan, Tools, Community, and Play.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _AppBottomBar extends StatelessWidget {
  const _AppBottomBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  // iOS style icons for the navbar.
  static const _items = [
    _NavItem(
      label: 'Scan',
      icon: CupertinoIcons.viewfinder,
      activeIcon: CupertinoIcons.viewfinder,
    ),
    _NavItem(
      label: 'Tools',
      icon: CupertinoIcons.square_grid_2x2,
      activeIcon: CupertinoIcons.square_grid_2x2_fill,
    ),
    _NavItem(
      label: 'Community',
      icon: CupertinoIcons.chat_bubble_2,
      activeIcon: CupertinoIcons.chat_bubble_2_fill,
    ),
    _NavItem(
      label: 'Play',
      icon: CupertinoIcons.gamecontroller,
      activeIcon: CupertinoIcons.gamecontroller_fill,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.parchment),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: isNarrow ? 52 : 56,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: i == currentIndex,
                    compact: isNarrow,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.moss : AppColors.stone;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? item.activeIcon : item.icon,
            size: compact ? 22 : 24,
            color: color,
          ),
          SizedBox(height: compact ? 2 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.label,
              maxLines: 1,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontSize: compact ? 10 : 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
