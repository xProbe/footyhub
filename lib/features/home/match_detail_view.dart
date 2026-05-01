import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/football_feed_item.dart';
import '../../data/services/exchange_rate_service.dart';

class MatchDetailView extends StatefulWidget {
  final FootballFeedItem item;

  const MatchDetailView({super.key, required this.item});

  @override
  State<MatchDetailView> createState() => _MatchDetailViewState();
}

class _MatchDetailViewState extends State<MatchDetailView> {
  Map<String, double>? _usdRates;
  bool _isLoadingRates = true;

  // Base random price for ticket estimation
  final double _baseTicketIdr = 1500000;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    final rates = await ExchangeRateService.ratesFromUsdBase();
    if (mounted) {
      setState(() {
        _usdRates = rates;
        _isLoadingRates = false;
      });
    }
  }

  String _formatCurrency(double amount, String symbol) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: symbol, decimalDigits: 0);
    return format.format(amount);
  }

  Widget _buildCurrencyCard() {
    if (_isLoadingRates) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_usdRates == null) {
      return Text('Gagal memuat kurs mata uang.', style: GoogleFonts.inter(color: Colors.red));
    }

    final idr = _baseTicketIdr;
    final usd = ExchangeRateService.idrToTarget(idrAmount: idr, target: 'USD', usdRates: _usdRates!) ?? 0;
    final eur = ExchangeRateService.idrToTarget(idrAmount: idr, target: 'EUR', usdRates: _usdRates!) ?? 0;
    final gbp = ExchangeRateService.idrToTarget(idrAmount: idr, target: 'GBP', usdRates: _usdRates!) ?? 0;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_num, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Estimasi Harga Tiket',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _currencyRow('Rp', _formatCurrency(idr, 'Rp ')),
            _currencyRow('\$', _formatCurrency(usd, '\$ ')),
            _currencyRow('€', _formatCurrency(eur, '€ ')),
            _currencyRow('£', _formatCurrency(gbp, '£ ')),
          ],
        ),
      ),
    );
  }

  Widget _currencyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    if (widget.item.utcDate == null) {
      return const SizedBox.shrink();
    }

    final utcTime = DateTime.parse(widget.item.utcDate!);
    final wibTime = utcTime.add(const Duration(hours: 7));
    final witaTime = utcTime.add(const Duration(hours: 8));
    final witTime = utcTime.add(const Duration(hours: 9));
    final londonTime = utcTime.add(const Duration(hours: 1)); // Assuming BST for simplicity, or we can just say +0/1

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Konversi Waktu Kick-off',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _timeRow('WIB (Jakarta)', dateFormat.format(wibTime)),
            _timeRow('WITA (Bali/Makassar)', dateFormat.format(witaTime)),
            _timeRow('WIT (Papua/Maluku)', dateFormat.format(witTime)),
            _timeRow('London (UK)', dateFormat.format(londonTime)),
          ],
        ),
      ),
    );
  }

  Widget _timeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.tfBackground,
      appBar: AppBar(
        title: Text('Detail Pertandingan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // League Info
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.leagueName,
                  style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Score Board
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamLogo(item.homeName, item.homeLogo),
                Column(
                  children: [
                    Text(
                      item.subtitle.split(' · ').first, // The score part
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusShort == 'LIVE' ? Colors.red : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.statusShort,
                        style: GoogleFonts.inter(
                          color: item.statusShort == 'LIVE' ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildTeamLogo(item.awayName, item.awayLogo),
              ],
            ),
            const SizedBox(height: 32),

            // Additional Details
            Text('Informasi Laga', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            _infoRow(Icons.stadium, 'Stadion', item.stadium.isNotEmpty ? item.stadium : '-'),
            _infoRow(Icons.sports, 'Wasit', item.referee.isNotEmpty ? item.referee : '-'),
            
            const SizedBox(height: 32),
            _buildTimeCard(),
            
            const SizedBox(height: 24),
            _buildCurrencyCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String name, String url) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: url.isNotEmpty
              ? Image.network(url, fit: BoxFit.contain)
              : const Icon(Icons.shield, size: 50, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 100,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text('$label:', style: GoogleFonts.inter(color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
