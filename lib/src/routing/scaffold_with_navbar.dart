import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../features/theme/theme_provider.dart';

class ScaffoldWithNavbar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavbar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.toString();
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final isDarkMode = ref.watch(isDarkModeProvider);

    int currentIndex = 0;
    if (location == '/habits') {
      currentIndex = 1;
    } else if (location == '/prediction') {
      currentIndex = 2;
    } else if (location == '/chat') {
      currentIndex = 3;
    } else if (location == '/purifier') {
      currentIndex = 4;
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor:
            Colors.transparent, // Let child scaffold background show
        body: Row(
          children: [
            // Clean Sidebar
            Container(
              width: 90,
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppColors.darkSurface
                        : AppColors.particulatesCardBackground,
                border: Border(
                  right: BorderSide(
                    color: (isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryDark)
                        .withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSidebarItem(
                    context,
                    '/',
                    Icons.home_outlined,
                    Icons.home,
                    currentIndex == 0,
                    'HOME',
                    isDarkMode,
                  ),
                  const SizedBox(height: 32),
                  _buildSidebarItem(
                    context,
                    '/habits',
                    Icons.person_outline,
                    Icons.person,
                    currentIndex == 1,
                    'PROFILE',
                    isDarkMode,
                  ),
                  const SizedBox(height: 32),
                  _buildSidebarItem(
                    context,
                    '/prediction',
                    Icons.calendar_today_outlined,
                    Icons.calendar_today,
                    currentIndex == 2,
                    'FORECAST',
                    isDarkMode,
                  ),
                  const SizedBox(height: 32),
                  _buildSidebarItem(
                    context,
                    '/chat',
                    Icons.chat_bubble_outline,
                    Icons.chat_bubble,
                    currentIndex == 3,
                    'AI CHAT',
                    isDarkMode,
                  ),
                  const SizedBox(height: 32),
                  _buildSidebarItem(
                    context,
                    '/purifier',
                    Icons.air_outlined,
                    Icons.air,
                    currentIndex == 4,
                    'PURIFIER',
                    isDarkMode,
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: _buildBottomNav(context, currentIndex, isDarkMode),
      );
    }
  }

  Widget _buildSidebarItem(
    BuildContext context,
    String route,
    IconData outlinedIcon,
    IconData filledIcon,
    bool isActive,
    String label,
    bool isDarkMode,
  ) {
    final activeColor =
        isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark;
    final inactiveColor =
        isDarkMode ? AppColors.textSecondary : AppColors.textTertiary;

    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? filledIcon : outlinedIcon,
              color: isActive ? activeColor : inactiveColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    int currentIndex,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? AppColors.darkSurface
                : AppColors.particulatesCardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                '/',
                Icons.home_outlined,
                Icons.home,
                currentIndex == 0,
                isDarkMode,
              ),
              _buildNavItem(
                context,
                '/habits',
                Icons.person_outline,
                Icons.person,
                currentIndex == 1,
                isDarkMode,
              ),
              _buildNavItem(
                context,
                '/prediction',
                Icons.calendar_today_outlined,
                Icons.calendar_today,
                currentIndex == 2,
                isDarkMode,
              ),
              _buildNavItem(
                context,
                '/chat',
                Icons.chat_bubble_outline,
                Icons.chat_bubble,
                currentIndex == 3,
                isDarkMode,
              ),
              _buildNavItem(
                context,
                '/purifier',
                Icons.air_outlined,
                Icons.air,
                currentIndex == 4,
                isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String route,
    IconData outlinedIcon,
    IconData filledIcon,
    bool isActive,
    bool isDarkMode,
  ) {
    final activeColor =
        isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark;
    final inactiveColor =
        isDarkMode ? AppColors.textSecondary : AppColors.textTertiary;
    final activeBgColor =
        isDarkMode
            ? AppColors.neonCyan.withOpacity(0.1)
            : AppColors.textPrimaryDark.withOpacity(0.05);

    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration:
            isActive
                ? BoxDecoration(
                  color: activeBgColor,
                  borderRadius: BorderRadius.circular(20),
                )
                : null,
        child: Icon(
          isActive ? filledIcon : outlinedIcon,
          color: isActive ? activeColor : inactiveColor,
          size: 26,
        ),
      ),
    );
  }
}
