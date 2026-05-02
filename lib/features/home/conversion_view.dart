import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/services/exchange_rate_service.dart';

class ConversionView extends StatefulWidget {
  final bool isFromDashboard;
  const ConversionView({super.key, this.isFromDashboard = false});

  @override
  State<ConversionView> createState() => _ConversionViewState();
}

class _ConversionViewState extends State<ConversionView> {
  final TextEditingController _currencyCtrl = TextEditingController(text: '100000');
  Map<String, double>? _usdRates;
  bool _isLoadingRates = true;
  
  // Base currency for input
  String _selectedBaseCurrency = 'IDR';
  final List<String> _currencies = ['IDR', 'USD', 'EUR', 'GBP'];

  // Time conversion
  final TextEditingController _timeCtrl = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedBaseTimezone = 'WIB';
  final List<String> _timezones = ['WIB', 'WITA', 'WIT', 'London'];

  @override
  void initState() {
    super.initState();
    _loadRates();
    _timeCtrl.text = _formatTimeOfDay(_selectedTime);
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

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);
    return format.format(amount);
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat('HH:mm').format(dt);
  }

  // Currency Conversion Logic
  double _convertCurrency(double amount, String from, String to) {
    if (_usdRates == null || !_usdRates!.containsKey(from) || !_usdRates!.containsKey(to)) return 0.0;
    
    // First convert to USD
    final amountInUsd = amount / _usdRates![from]!;
    // Then convert to Target
    return amountInUsd * _usdRates![to]!;
  }

  // Time Conversion Logic
  String _convertTime(TimeOfDay time, String fromTz, String toTz) {
    // Base UTC offset in hours
    final offsets = {
      'WIB': 7,
      'WITA': 8,
      'WIT': 9,
      'London': 1, // Using BST (+1) roughly, or GMT (+0). Let's use +1 for summer.
    };

    final fromOffset = offsets[fromTz] ?? 7;
    final toOffset = offsets[toTz] ?? 7;

    // Convert input time to UTC
    int utcHour = time.hour - fromOffset;
    
    // Convert UTC to target timezone
    int targetHour = (utcHour + toOffset) % 24;
    if (targetHour < 0) targetHour += 24;

    final dt = DateTime(2000, 1, 1, targetHour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeCtrl.text = _formatTimeOfDay(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.tfBackground,
        appBar: AppBar(
          automaticallyImplyLeading: !widget.isFromDashboard,
          title: Text('Konversi Manual', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.seaGreen,
            tabs: [
              Tab(text: 'Mata Uang', icon: Icon(Icons.monetization_on)),
              Tab(text: 'Waktu', icon: Icon(Icons.access_time)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCurrencyTab(),
            _buildTimeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTab() {
    if (_isLoadingRates) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_usdRates == null) {
      return const Center(child: Text('Gagal memuat data kurs terbaru.'));
    }

    double inputAmount = double.tryParse(_currencyCtrl.text.replaceAll(',', '')) ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Jumlah', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _currencyCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedBaseCurrency,
                items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedBaseCurrency = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Hasil Konversi:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ..._currencies.where((c) => c != _selectedBaseCurrency).map((target) {
            final converted = _convertCurrency(inputAmount, _selectedBaseCurrency, target);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(target == 'IDR' ? 'Rp' : target == 'USD' ? '\$' : target == 'EUR' ? '€' : '£', style: const TextStyle(color: AppColors.primary)),
                ),
                title: Text(target, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                trailing: Text(_formatCurrency(converted), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pilih Waktu Awal', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _timeCtrl,
                  readOnly: true,
                  onTap: _pickTime,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Icon(Icons.schedule),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedBaseTimezone,
                items: _timezones.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedBaseTimezone = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Hasil Konversi:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ..._timezones.where((c) => c != _selectedBaseTimezone).map((target) {
            final converted = _convertTime(_selectedTime, _selectedBaseTimezone, target);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.language, color: AppColors.primary),
                title: Text(target, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                trailing: Text(converted, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
