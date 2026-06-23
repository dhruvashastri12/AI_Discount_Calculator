import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/data_service.dart';

class DaySummaryScreen extends StatefulWidget {
  final DateTime? date;
  const DaySummaryScreen({super.key, this.date});

  @override
  State<DaySummaryScreen> createState() => _DaySummaryScreenState();
}

class _DaySummaryScreenState extends State<DaySummaryScreen> {
  final TextEditingController _thresholdController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _thresholdController.text = dataService.storeThreshold > 0 ? dataService.storeThreshold.toStringAsFixed(0) : '';
    _percentController.text = dataService.storePercentage > 0 ? dataService.storePercentage.toStringAsFixed(0) : '';
    dataService.addListener(_updateUI);
  }

  @override
  void dispose() {
    dataService.removeListener(_updateUI);
    _thresholdController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  void _updateStoreOffer() {
    double threshold = double.tryParse(_thresholdController.text) ?? 0;
    double percent = double.tryParse(_percentController.text) ?? 0;
    dataService.setStoreOffer(threshold, percent);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final groups = dataService.groupItemsByCategory(dataService.currentItems);
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.summaryDayBreakdown,
          style: TextStyle(fontFamily: 'JetBrainsMono', 
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontTitleS,
            color: AppColors.primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL, vertical: AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.date != null
                    ? 'SHOPPING ON ${widget.date!.day}/${widget.date!.month}/${widget.date!.year}'
                    : 'CURRENT SESSION',
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: AppDimensions.fontXS,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutralText,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            
            _buildGrandTotalCard(isDark),
            const SizedBox(height: AppDimensions.paddingXL),
            
            _buildStoreOfferSection(isDark),
            const SizedBox(height: AppDimensions.paddingXL),
            
            _buildSavingsSplit(isDark),
            const SizedBox(height: AppDimensions.paddingXXL),
            
            Text(
              AppStrings.summaryCategorySpend,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: AppDimensions.fontXS,
                fontWeight: FontWeight.w900,
                color: AppColors.neutralText,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ...groups.entries.map((e) => _buildCategoryRow(e.key, e.value, isDark)),
            
            const SizedBox(height: AppDimensions.paddingXXXL),
            _buildDoneButton(isDark),
            const SizedBox(height: AppDimensions.paddingXXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildGrandTotalCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL + 4),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.summaryNetPayable,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: AppDimensions.fontS - 1,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralText,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹',
                style: TextStyle(fontFamily: 'JetBrainsMono', 
                  fontSize: AppDimensions.fontTitleXXL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              Text(
                dataService.finalTotalValue.toStringAsFixed(0),
                style: TextStyle(fontFamily: 'JetBrainsMono', 
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          if (dataService.storeDiscountAmount > 0)
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.paddingL),
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenTint.withValues(alpha: isDark ? 0.1 : 1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Text(
                'Store Offer: -₹${dataService.storeDiscountAmount.toStringAsFixed(0)}',
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: AppDimensions.fontS,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreOfferSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white, 
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.orange, size: 16),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                AppStrings.summaryStoreWideOffer,
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: AppDimensions.fontXS,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Row(
            children: [
              Text(AppStrings.summarySpendOver, style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontS + 1, fontWeight: FontWeight.w500)),
              SizedBox(
                width: 65,
                child: TextField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: AppDimensions.fontM, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0'),
                  onChanged: (_) => _updateStoreOffer(),
                ),
              ),
              Text(AppStrings.summaryGet, style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontS + 1, fontWeight: FontWeight.w500)),
              SizedBox(
                width: 45,
                child: TextField(
                  controller: _percentController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: AppDimensions.fontM, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0'),
                  onChanged: (_) => _updateStoreOffer(),
                ),
              ),
              Text(AppStrings.summaryOff, style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontS + 1, fontWeight: FontWeight.w900, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            AppStrings.summaryAppliedGlobally,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: AppDimensions.fontXS,
              fontStyle: FontStyle.italic,
              color: AppColors.neutralText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsSplit(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildSavingsCard(
            AppStrings.listSubtotalSavings.split(' ').first,
            '₹${dataService.subtotal.toStringAsFixed(0)}',
            isDark ? AppColors.textLight.withValues(alpha: 0.7) : Colors.black87,
            isDark,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: _buildSavingsCard(
            AppStrings.historySaved.toUpperCase(),
            '₹${dataService.totalSavings.toStringAsFixed(0)}',
            AppColors.primaryGreen,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(String title, String val, Color valCol, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(AppDimensions.radiusL)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: AppDimensions.fontS - 3,
              fontWeight: FontWeight.w900,
              color: AppColors.neutralText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: AppDimensions.fontTitleL, fontWeight: FontWeight.w900, color: valCol)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String name, List<dynamic> items, bool isDark) {
    double catTotal = items.fold(0.0, (sum, it) => sum + (it.itemAfterVendorDiscount as num).toDouble());
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: AppDimensions.paddingM + 3),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white, 
        borderRadius: BorderRadius.circular(AppDimensions.radiusL)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(_getEmojiForCategory(name), style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingM),
              Text(name, style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontS + 1, fontWeight: FontWeight.w700)),
            ],
          ),
          Text('₹${catTotal.toStringAsFixed(0)}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: AppDimensions.fontM, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  String _getEmojiForCategory(String name) {
    String n = name.toUpperCase();
    if (n.contains('VEG')) return '🥦';
    if (n.contains('DAIRY')) return '🥛';
    if (n.contains('GROCERY')) return '🛒';
    if (n.contains('HOUSEHOLD') || n.contains('HOME')) return '🏠';
    if (n.contains('CLOTH')) return '👗';
    if (n.contains('STATIO')) return '✏️';
    if (n.contains('ELECTRO')) return '📱';
    if (n.contains('HEALTH')) return '💊';
    if (n.contains('BEAUTY')) return '💄';
    return '🏷️';
  }

  Widget _buildDoneButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryGreen : Colors.black87, 
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXL), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusL)),
          elevation: 0,
        ),
        child: Text(
          AppStrings.summaryReturnToList,
          style: TextStyle(fontFamily: 'DMSans', 
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: AppDimensions.fontS + 1,
          ),
        ),
      ),
    );
  }
}
