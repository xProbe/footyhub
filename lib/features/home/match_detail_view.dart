import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/football_feed_item.dart';
import '../../data/services/exchange_rate_service.dart';

class MatchDetailView extends ConsumerStatefulWidget {
  final FootballFeedItem item;

  const MatchDetailView({super.key, required this.item});

  @override
  ConsumerState<MatchDetailView> createState() => _MatchDetailViewState();
}

class _MatchDetailViewState extends ConsumerState<MatchDetailView> {
  Map<String, double>? _usdRates;
  bool _isLoadingRates = true;

  // AI Brief
  String _aiTacticalBrief = '';
  bool _isLoadingAi = false;

  final double _baseTicketIdr = 1500000;

  @override
  void initState() {
    super.initState();
    _loadRates();
    _fetchAiBrief();
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

  Future<void> _fetchAiBrief() async {
    if (ApiConstants.geminiKey == 'MASUKKAN_GEMINI_API_KEY_ANDA') {
      setState(() {
        _aiTacticalBrief = 'Asisten AI belum dikonfigurasi (Kunci API kosong). Silakan masukkan API Key di constants.';
      });
      return;
    }

    setState(() {
      _isLoadingAi = true;
      _aiTacticalBrief = '';
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConstants.geminiKey,
      );

      final prompt = '''
Anda adalah pundit taktik sepakbola FootyHub. Rangkum analisis singkat taktik (3-5 poin) untuk pertandingan berikut:
Laga: ${widget.item.title}
Skor/Status: ${widget.item.subtitle}
Liga: ${widget.item.leagueName}
Stadion: ${widget.item.stadium}
Wasit: ${widget.item.referee}

Berikan output ramah, analitis, sporty, dan ringkas dalam Bahasa Indonesia menggunakan format poin-poin.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (mounted) {
        setState(() {
          _aiTacticalBrief = response.text ?? 'Gagal membuat rangkuman taktis.';
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTacticalBrief = 'Gagal memanggil Gemini AI: $e';
          _isLoadingAi = false;
        });
      }
    }
  }

  String _formatCurrency(double amount, String symbol) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: symbol, decimalDigits: 0);
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = widget.item;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Detail Pertandingan', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0C),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // League Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  item.leagueName,
                  style: GoogleFonts.orbitron(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
                      item.subtitle.split(' · ').first,
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusShort == 'LIVE' || item.statusShort == '1H' || item.statusShort == '2H'
                            ? Colors.redAccent.withOpacity(0.12)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.statusShort,
                        style: GoogleFonts.orbitron(
                          color: item.statusShort == 'LIVE' || item.statusShort == '1H' || item.statusShort == '2H'
                              ? Colors.redAccent
                              : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildTeamLogo(item.awayName, item.awayLogo),
              ],
            ),
            const SizedBox(height: 32),

            // Info rows
            Text(
              'INFORMASI LAGA',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow(Icons.stadium_rounded, 'Stadion', item.stadium.isNotEmpty ? item.stadium : '-'),
                  const Divider(color: Colors.white10),
                  _infoRow(Icons.sports_rounded, 'Wasit', item.referee.isNotEmpty ? item.referee : '-'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Tactical Brief Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI TACTICAL BRIEF',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                if (!_isLoadingAi)
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: colorScheme.primary, size: 18),
                    onPressed: _fetchAiBrief,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: _isLoadingAi
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Menganalisis laga dengan Gemini...',
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    )
                  : Text(
                      _aiTacticalBrief,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Time & Tickets conversions
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
          width: 64,
          height: 64,
          child: url.isNotEmpty
              ? Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40))
              : const Icon(Icons.shield, size: 48, color: Colors.white24),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 100,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 12),
        Text('$label:', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard() {
    if (widget.item.utcDate == null) return const SizedBox.shrink();

    final utcTime = DateTime.parse(widget.item.utcDate!);
    final wib = utcTime.add(const Duration(hours: 7));
    final wita = utcTime.add(const Duration(hours: 8));
    final wit = utcTime.add(const Duration(hours: 9));

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Colors.white38, size: 18),
              const SizedBox(width: 8),
              Text(
                'Konversi Waktu Kick-off',
                style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _timeRow('WIB (Jakarta)', dateFormat.format(wib)),
          const Divider(color: Colors.white10),
          _timeRow('WITA (Bali)', dateFormat.format(wita)),
          const Divider(color: Colors.white10),
          _timeRow('WIT (Papua)', dateFormat.format(wit)),
        ],
      ),
    );
  }

  Widget _timeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
        Text(value, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
      ],
    );
  }

  Widget _buildCurrencyCard() {
    if (_isLoadingRates) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_usdRates == null) return const SizedBox.shrink();

    final idr = _baseTicketIdr;
    final usd = ExchangeRateService.idrToTarget(idrAmount: idr, target: 'USD', usdRates: _usdRates!) ?? 0;
    final eur = ExchangeRateService.idrToTarget(idrAmount: idr, target: 'EUR', usdRates: _usdRates!) ?? 0;
    final gbp = ExchangeRateService.idrToTarget(idrAmount: idr, target: 'GBP', usdRates: _usdRates!) ?? 0;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined, color: Colors.white38, size: 18),
              const SizedBox(width: 8),
              Text(
                'Estimasi Harga Tiket',
                style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _currencyRow('IDR', _formatCurrency(idr, 'Rp ')),
          const Divider(color: Colors.white10),
          _currencyRow('USD', _formatCurrency(usd, '\$ ')),
          const Divider(color: Colors.white10),
          _currencyRow('EUR', _formatCurrency(eur, '€ ')),
          const Divider(color: Colors.white10),
          _currencyRow('GBP', _formatCurrency(gbp, '£ ')),
        ],
      ),
    );
  }

  Widget _currencyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
        Text(value, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
      ],
    );
  }
}
