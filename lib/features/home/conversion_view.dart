import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../data/services/exchange_rate_service.dart';

class ConversionView extends StatefulWidget {
  const ConversionView({super.key});

  @override
  State<ConversionView> createState() => _ConversionViewState();
}

class _ConversionViewState extends State<ConversionView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Currency conversion
  final TextEditingController _currencyCtrl = TextEditingController(text: '10,000');
  Map<String, double>? _usdRates;
  bool _isLoadingRates = true;
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
    _tabController = TabController(length: 2, vsync: this);
    _loadRates();
    _timeCtrl.text = _formatTimeOfDay(_selectedTime);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _currencyCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
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

  double _convertCurrency(double amount, String from, String to) {
    if (_usdRates == null || !_usdRates!.containsKey(from) || !_usdRates!.containsKey(to)) return 0.0;
    final amountInUsd = amount / _usdRates![from]!;
    return amountInUsd * _usdRates![to]!;
  }

  String _convertTime(TimeOfDay time, String fromTz, String toTz) {
    final offsets = {
      'WIB': 7,
      'WITA': 8,
      'WIT': 9,
      'London': 1, // British Summer Time offset
    };

    final fromOffset = offsets[fromTz] ?? 7;
    final toOffset = offsets[toTz] ?? 7;

    int utcHour = time.hour - fromOffset;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('KONVERSI UTILITY', style: GoogleFonts.orbitron(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: Colors.white30,
          labelStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'MATA UANG', icon: Icon(Icons.monetization_on_outlined)),
            Tab(text: 'WAKTU', icon: Icon(Icons.access_time_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCurrencyTab(),
          _buildTimeTab(),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoadingRates) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_usdRates == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat kurs terbaru.',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoadingRates = true);
                  _loadRates();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    double inputAmount = double.tryParse(_currencyCtrl.text.replaceAll(',', '')) ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'INPUT JUMLAH',
            style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _currencyCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {}),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedBaseCurrency,
                  dropdownColor: const Color(0xFF0A0A0C),
                  style: GoogleFonts.orbitron(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  underline: const SizedBox.shrink(),
                  items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedBaseCurrency = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'HASIL KONVERSI',
            style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          ..._currencies.where((c) => c != _selectedBaseCurrency).map((target) {
            final converted = _convertCurrency(inputAmount, _selectedBaseCurrency, target);
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.12),
                        child: Text(
                          target == 'IDR' ? 'Rp' : target == 'USD' ? '\$' : target == 'EUR' ? '€' : '£',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        target,
                        style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    _formatCurrency(converted),
                    style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'WAKTU AWAL',
            style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    readOnly: true,
                    onTap: _pickTime,
                    style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.schedule_rounded, color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedBaseTimezone,
                  dropdownColor: const Color(0xFF0A0A0C),
                  style: GoogleFonts.orbitron(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  underline: const SizedBox.shrink(),
                  items: _timezones.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedBaseTimezone = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'HASIL KONVERSI ZONA WAKTU',
            style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          ..._timezones.where((c) => c != _selectedBaseTimezone).map((target) {
            final converted = _convertTime(_selectedTime, _selectedBaseTimezone, target);
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language_rounded, color: colorScheme.primary, size: 24),
                      const SizedBox(width: 16),
                      Text(
                        target,
                        style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    converted,
                    style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
