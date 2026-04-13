/// Centralized string constants for the application.
/// Supports internationalization and ensures text consistency.
class AppStrings {
  // App General
  static const String appName = "Stitch";

  // Navigation Tabs
  static const String navLists = "Lists";
  static const String navCalc = "Calc";
  static const String navHistory = "History";
  static const String navConv = "Conv";

  // Discount Calculator
  static const String calcTitle = "DISCOUNT CALCULATOR";
  static const String calcOriginalPrice = "ORIGINAL PRICE";
  static const String calcDiscountPercent = "DISCOUNT %";
  static const String calcFinalPrice = "FINAL PRICE";
  static const String calcSavings = "YOU SAVE";
  static const String calcRupeeSymbol = "₹";
  static const String calcPercentSymbol = "%";

  // Shopping List
  static const String listTitle = "CART ITEMS";
  static const String listSubtotalSavings = "SUBTOTAL & SAVINGS";
  static const String listFinalTotal = "FINAL TOTAL";
  static const String listEmpty = "List is empty";
  static const String listItemName = "ITEM NAME";
  static const String listQty = "QTY";
  static const String listUnitType = "UNIT TYPE";
  static const String listUnitPrice = "UNIT PRICE";
  static const String listDiscount = "DISCOUNT";
  static const String listAddToList = "Add to List";
  static const String listUpdate = "Update Item";
  static const String listEditItem = "EDIT ITEM";
  static const String listDeleteConfirmTitle = "Are you sure to delete this item?";
  static const String listDeleteConfirmMsg = "Deleted items can't be reverted.";
  static const String listDeleteFromHistoryTitle = "Delete from history?";
  static const String listDeleteFromHistoryMsg = "Do you also want to remove this item from your past history?";
  static const String listBtnYesDelete = "Yes, Delete";
  static const String listBtnKeepIt = "Keep It";
  static const String listCancel = "Cancel";
  static const String listScan = "Scan";
  static const String listItemHint = "e.g. Apples";
  static const String listPriceHint = "₹ 0";
  static const String listQtyHint = "1";
  static const String listDiscountHint = "0";
  static const String listSelectUnit = "Select Unit";
  static const String listOffLabel = "OFF";
  static const String listPurchasedLabel = "purchased";

  // Item Units
  static const List<String> unitOptions = [
    'Select Unit', 'piece', 'unit', 'kg', 'g', 'litre', 'ml', 'metre', 'cm', 'pack', 'box', 'dozen'
  ];

  // History
  static const String historyTitle = "HISTORY";
  static const String historyEmpty = "No history found";
  static const String historyItems = "Items";
  static const String historyTotal = "Total";
  static const String historySaved = "Saved";
  static const String historyDayTotal = "Day Total";

  // Conversion
  static const String convTitle = "CONVERSION";
  static const String convComingSoon = "Coming Soon";
  static const String convFlavorText = "We are working on powerful conversion tools for you.";

  // Scan
  static const String scanAlignPrice = "Align price inside the box";
  static const String scanGallery = "Gallery";
  static const String scanFlash = "Flash";
  static const String scanNoPriceFound = "No price found. Try again or select manually.";
  static const String scanFailed = "Scanning failed";
  static const String scanNoCamera = "No camera found on this device.";
  static const String scanPermissionDenied = "Camera permission denied. Please enable it in settings.";
  static const String scanGalleryFailed = "Gallery access failed";

  // Validation Messages
  static const String errorEnterItemName = "Enter item name";
  static const String errorEnterPrice = "Enter valid price";
  static const String errorDiscountPercentLimit = "Discount % must be < 100";
  static const String errorDiscountAmountLimit = "Discount must be < Total Price";
  static const String errorPercentDigits = "Max 2 digits for %";

  // Splash
  static const String splashStitch = "STITCH";
  static const String splashAntigravity = "Antigravity";
  static const String splashTagline = "F I R S T   S Y N C";

  // Settings
  static const String settingsTitle = "Settings";
  static const String settingsAppearance = "Appearance";
  static const String settingsAccount = "Account";
  static const String settingsSupport = "Support";
  static const String settingsProfile = "Profile";
  static const String settingsNotifications = "Notifications";
  static const String settingsSecurity = "Security";
  static const String settingsHelp = "Help Center";
  static const String settingsAbout = "About";
  static const String settingsThemeMode = "Theme Mode";
  static const String settingsDarkThemeActive = "Dark Theme Active";
  static const String settingsLightThemeActive = "Light Theme Active";
  static const String settingsVersionPrefix = "Antigravity FirstSync v";
  static const String settingsVersion = "1.1.0";

  // Date Formats (templates)
  static const String formatFullDayDate = "EEEE, MMM d";
  static const String formatMonthYear = "MMMM yyyy";

  // Icon Keywords
  static const String keywordApple = "apple";
  static const String keywordMilk = "milk";
  static const String keywordWater = "water";
  static const String keywordBread = "bread";
}

