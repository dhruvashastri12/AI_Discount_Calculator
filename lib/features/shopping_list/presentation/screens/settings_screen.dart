import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';
import 'package:ai_discount_calculator/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? AppColors.background : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppStrings.settingsTitle,
          style: GoogleFonts.publicSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spaceL),
        children: [
          _buildSectionHeader(AppStrings.settingsAppearance),
          _buildThemeToggle(isDark),
          const SizedBox(height: AppConstants.spaceXXL),
          _buildSectionHeader(AppStrings.settingsAccount),
          _buildSettingsTile(Icons.person, AppStrings.settingsProfile),
          _buildSettingsTile(Icons.notifications, AppStrings.settingsNotifications),
          _buildSettingsTile(Icons.security, AppStrings.settingsSecurity),
          const SizedBox(height: AppConstants.spaceXXL),
          _buildSectionHeader(AppStrings.settingsSupport),
          _buildSettingsTile(Icons.help, AppStrings.settingsHelp),
          _buildSettingsTile(Icons.info, AppStrings.settingsAbout),
          const SizedBox(height: AppConstants.spaceXXL),
          Center(
            child: Text(
              "${AppStrings.settingsVersionPrefix}${AppStrings.settingsVersion}",
              style: const TextStyle(color: AppColors.textMuted, fontSize: AppConstants.fontSizeM),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: AppConstants.fontSizeM,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    return Card(
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusL)),
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: isDark ? Colors.orange : AppColors.primaryList,
        ),
        title: const Text(AppStrings.settingsThemeMode),
        subtitle: Text(isDark ? AppStrings.settingsDarkThemeActive : AppStrings.settingsLightThemeActive),
        trailing: Switch(
          value: isDark,
          activeThumbColor: AppColors.primaryList,
          onChanged: (val) {
             themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
          },
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
       shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.accentMuted.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textMuted),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, size: AppConstants.iconSizeM, color: AppColors.textMuted),
        onTap: () {},
      ),
    );
  }
}
