class AppConstants {
  // Common Durations
  static const Duration splashDuration = Duration(milliseconds: 3000);
  static const Duration chipInfoDuration = Duration(seconds: 3);
  static const Duration splashFadeDuration = Duration(milliseconds: 1000);
  static const Duration animationDurationSmall = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);

  // Common Border Radius
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 20.0;
  static const double borderRadiusXXL = 32.0;

  // Spacing & Padding
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 12.0;
  static const double spaceL = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;

  // Layout Ratios
  static const double calcTopFlex = 35.0;
  static const double calcBottomFlex = 65.0;
  static const double keypadAspectRatio = 2.2;
  
  // Limits
  static const int maxInputDigits = 10;
  static const int itemNameMaxLength = 50;
  static const int maxDiscountPercent = 100;
  static const int discountLabelFontSize = 9;
  static const double fieldHeight = 56.0;
  static const double toggleWidth = 32.0;
  static const double toggleHeight = 48.0;
  static const double toggleFontSize = 11.0;
  
  // Icon Sizes
  static const double iconSizeS = 18.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 28.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeGiant = 64.0;
  static const double iconSizeEmpty = 80.0;

  // Text Sizes
  static const double fontSizeXS = 9.0;
  static const double fontSizeS = 10.0;
  static const double fontSizeM = 12.0;
  static const double fontSizeL = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 22.0;
  static const double fontSizeGiant = 56.0;

  // Storage Keys
  static const String keyCurrentItems = 'current_items';
  static const String keyHistoryData = 'history_data';
}
