import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_discount_calculator/features/discount_calculator/presentation/screens/calculator_screen.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/screens/shopping_list_screen.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/screens/history_screen.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/screens/conversion_screen.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';
import 'package:ai_discount_calculator/main.dart';

/// The root navigation controller of the app.
/// Manages the bottom navigation bar and switches between primary feature screens.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Rule 1: Set Discount Calculator as the default screen (Index 0)
  int _selectedIndex = 0;

  // List of screens accessible via the bottom navigation bar
  final List<Widget> _screens = [
    const CalculatorScreen(),
    const ShoppingListScreen(),
    const HistoryScreen(),
    const ConversionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        // Determine theme brightness based on current app settings
        bool isDark = currentMode == ThemeMode.dark || 
                     (currentMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark);
        
        return Scaffold(
          backgroundColor: isDark ? AppColors.background : AppColors.backgroundLight,
          appBar: _buildAppBar(isDark),
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNavBar(isDark),
        );
      },
    );
  }

  /// Builds the persistent top app bar with theme toggle.
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.background : AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        AppStrings.calcTitle.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: AppConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.white : AppColors.textDark,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Toggle between light and dark theme
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? AppColors.warning : AppColors.textDark, // Use warning yellow for sun
          ),
        ),
        const SizedBox(width: AppConstants.spaceS),
      ],
    );
  }

  /// Builds the custom bottom navigation bar.
  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navBarDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.accentMuted,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppConstants.spaceS, 
        top: AppConstants.spaceM
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.calculate, AppStrings.navCalc, 0, isDark),
          _navItem(Icons.format_list_bulleted, AppStrings.navLists, 1, isDark),
          _navItem(Icons.history, AppStrings.navHistory, 2, isDark),
          _navItem(Icons.swap_horiz, AppStrings.navConv, 3, isDark),
        ],
      ),
    );
  }

  /// Builds an individual navigation item.
  Widget _navItem(IconData icon, String label, int index, bool isDark) {
    bool isActive = _selectedIndex == index;
    // Highlight items based on their context (Calculator vs List/History)
    Color activeColor = index == 0 ? AppColors.primaryCalc : AppColors.primaryList;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : AppColors.textMuted,
            size: AppConstants.iconSizeL - 2,
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

