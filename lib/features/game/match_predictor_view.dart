import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../data/services/predictor_service.dart';

class MatchPredictorView extends ConsumerStatefulWidget {
  const MatchPredictorView({super.key});

  @override
  ConsumerState<MatchPredictorView> createState() => _MatchPredictorViewState();
}

class _MatchPredictorViewState extends ConsumerState<MatchPredictorView> {
  // Inputs
  double _homePos = 5.0;
  double _awayPos = 8.0;
  double _homeGoals = 12.0;
  double _awayGoals = 9.0;
  bool _isHomeAdvantage = true;

  // Outputs
  double _winProb = 50.0;
  double _drawProb = 25.0;
  double _lossProb = 25.0;

  bool _isModelLoaded = false;
  late final PredictorService _predictorService;

  @override
  void initState() {
    super.initState();
    _predictorService = getPredictorService();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _predictorService.init();
    if (mounted) {
      setState(() {
        _isModelLoaded = _predictorService.isModelActive;
      });
      _runInference();
    }
  }

  // Runs platform-aware TFLite or fallback inference
  Future<void> _runInference() async {
    final standingsDiff = _homePos - _awayPos;
    final goalsDiff = _homeGoals - _awayGoals;
    final homeAdv = _isHomeAdvantage ? 1.0 : 0.0;

    final results = await _predictorService.predict(
      standingsDiff: standingsDiff,
      goalsDiff: goalsDiff,
      homeAdvantage: homeAdv,
      homeGoals: _homeGoals,
      awayGoals: _awayGoals,
    );

    if (mounted) {
      setState(() {
        _winProb = results[0] * 100.0;
        _drawProb = results[1] * 100.0;
        _lossProb = results[2] * 100.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('SMART PREDICTOR', style: GoogleFonts.orbitron(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ML Status badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isModelLoaded ? Colors.green.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isModelLoaded ? Colors.green : Colors.amber),
                ),
                child: Text(
                  _isModelLoaded ? 'TFLite Model Active' : 'Fallback Predictive Engine Active',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: _isModelLoaded ? Colors.green : Colors.amber),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form inputs
            Text(
              'PARAMETRIK LAGA',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Standings selector sliders
                  _buildSliderRow(
                    'Posisi Klasemen Kandang',
                    _homePos,
                    1,
                    20,
                    (val) {
                      setState(() => _homePos = val);
                      _runInference();
                    },
                  ),
                  _buildSliderRow(
                    'Posisi Klasemen Tandang',
                    _awayPos,
                    1,
                    20,
                    (val) {
                      setState(() => _awayPos = val);
                      _runInference();
                    },
                  ),
                  const Divider(color: Colors.white10),
                  // Goals slider
                  _buildSliderRow(
                    'Rata-rata Gol Kandang (5 Laga)',
                    _homeGoals,
                    0,
                    25,
                    (val) {
                      setState(() => _homeGoals = val);
                      _runInference();
                    },
                    isInteger: false,
                  ),
                  _buildSliderRow(
                    'Rata-rata Gol Tandang (5 Laga)',
                    _awayGoals,
                    0,
                    25,
                    (val) {
                      setState(() => _awayGoals = val);
                      _runInference();
                    },
                    isInteger: false,
                  ),
                  const Divider(color: Colors.white10),
                  // Switch Home advantage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Home Advantage (Kandang)', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                      Switch(
                        value: _isHomeAdvantage,
                        activeColor: colorScheme.primary,
                        onChanged: (val) {
                          setState(() => _isHomeAdvantage = val);
                          _runInference();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Outputs Probability percentages
            Text(
              'HASIL PREDIKSI PERSENTASE',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProbMeter('PELUANG MENANG', _winProb, colorScheme.primary),
                  const SizedBox(height: 16),
                  _buildProbMeter('PELUANG SERI', _drawProb, Colors.grey),
                  const SizedBox(height: 16),
                  _buildProbMeter('PELUANG KALAH', _lossProb, Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged, {bool isInteger = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
              Text(
                isInteger ? '${value.toInt()}' : value.toStringAsFixed(1),
                style: GoogleFonts.orbitron(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: colorScheme.primary,
            inactiveColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildProbMeter(String title, double prob, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold)),
            Text(
              '${prob.toStringAsFixed(1)}%',
              style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(5)),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 10,
                  width: maxWidth * (prob / 100.0),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [BoxShadow(color: barColor.withOpacity(0.5), blurRadius: 6)],
                  ),
                );
              }
            ),
          ],
        ),
      ],
    );
  }
}
