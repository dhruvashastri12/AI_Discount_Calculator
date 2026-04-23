import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
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
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text('DAY BREAKDOWN', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(widget.date != null ? 'SHOPPING ON ${widget.date!.day}/${widget.date!.month}/${widget.date!.year}' : 'CURRENT SESSION', 
              style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2))),
            const SizedBox(height: 20),
            
            _buildGrandTotalCard(isDark),
            const SizedBox(height: 20),
            
            _buildStoreOfferSection(isDark),
            const SizedBox(height: 20),
            
            _buildSavingsSplit(isDark),
            const SizedBox(height: 30),
            
            Text('CATEGORY SPEND', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            ...groups.entries.map((e) => _buildCategoryRow(e.key, e.value, isDark)),
            
            const SizedBox(height: 40),
            _buildDoneButton(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGrandTotalCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text('NET PAYABLE', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('₹', style: GoogleFonts.jetBrainsMono(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              Text(dataService.finalTotalValue.toStringAsFixed(0), style: GoogleFonts.jetBrainsMono(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)),
            ],
          ),
          if (dataService.storeDiscountAmount > 0)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppColors.greenTint.withValues(alpha: isDark ? 0.1 : 1), borderRadius: BorderRadius.circular(10)),
              child: Text('Store Offer: -₹${dataService.storeDiscountAmount.toStringAsFixed(0)}', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreOfferSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white, 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text('STORE-WIDE OFFER', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Spend over ₹', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(
                width: 65,
                child: TextField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0'),
                  onChanged: (_) => _updateStoreOffer(),
                ),
              ),
              Text(' get ', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(
                width: 45,
                child: TextField(
                  controller: _percentController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0'),
                  onChanged: (_) => _updateStoreOffer(),
                ),
              ),
              Text('% OFF', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text('Applied globally on the final subtotal.', style: GoogleFonts.dmSans(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSavingsSplit(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildSavingsCard('SUBTOTAL', '₹${dataService.subtotal.toStringAsFixed(0)}', isDark ? Colors.white70 : Colors.black87, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSavingsCard('YOU SAVED', '₹${dataService.totalSavings.toStringAsFixed(0)}', AppColors.primaryGreen, isDark),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(String title, String val, Color valCol, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w900, color: valCol)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String name, List<dynamic> items, bool isDark) {
    double catTotal = items.fold(0.0, (sum, it) => sum + (it.itemAfterVendorDiscount as num).toDouble());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white, 
        borderRadius: BorderRadius.circular(14)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(_getEmojiForCategory(name), style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(name, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          Text('₹${catTotal.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.w900)),
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
    return '🏷️';
  }

  Widget _buildDoneButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryGreen : Colors.black87, 
          padding: const EdgeInsets.symmetric(vertical: 18), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text('RETURN TO LIST', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
      ),
    );
  }
}
