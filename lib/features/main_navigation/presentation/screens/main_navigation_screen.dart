import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_discount_calculator/features/discount_calculator/presentation/screens/calculator_screen.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/screens/shopping_list_screen.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/screens/history_screen.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/screens/conversion_screen.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/main.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

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
      builder: (context, currentMode, _) {
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'AI DISCOUNT CALCULATOR',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.textDark,
          letterSpacing: 1,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? const Color(0xFFFFC107) : AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8, 
        top: 12
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.calculate, 'Calc', 0, isDark),
          _navItem(Icons.shopping_cart, 'List', 1, isDark),
          _navItem(Icons.history, 'History', 2, isDark),
          _navItem(Icons.compare_arrows, 'Conv', 3, isDark),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool isDark) {
    bool isActive = _selectedIndex == index;
    Color activeColor = AppColors.primaryGreen;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : AppColors.neutralText,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: isActive ? activeColor : AppColors.neutralText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
