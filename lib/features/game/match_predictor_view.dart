import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../data/services/predictor_service.dart';

class ScoreProbability {
  final String score;
  final double prob;
  ScoreProbability(this.score, this.prob);
}

class PredictorTeam {
  final String name;
  final String logo;
  final int defaultPosition;
  final double defaultGoals;

  const PredictorTeam({
    required this.name,
    required this.logo,
    required this.defaultPosition,
    required this.defaultGoals,
  });
}

const List<PredictorTeam> predictorTeams = [
  PredictorTeam(name: 'Real Madrid', logo: 'https://media.api-sports.io/football/teams/541.png', defaultPosition: 1, defaultGoals: 2.3),
  PredictorTeam(name: 'Barcelona', logo: 'https://media.api-sports.io/football/teams/529.png', defaultPosition: 2, defaultGoals: 2.1),
  PredictorTeam(name: 'Manchester City', logo: 'https://media.api-sports.io/football/teams/50.png', defaultPosition: 1, defaultGoals: 2.4),
  PredictorTeam(name: 'Arsenal', logo: 'https://media.api-sports.io/football/teams/42.png', defaultPosition: 2, defaultGoals: 2.2),
  PredictorTeam(name: 'Liverpool', logo: 'https://media.api-sports.io/football/teams/40.png', defaultPosition: 3, defaultGoals: 2.0),
  PredictorTeam(name: 'Chelsea', logo: 'https://media.api-sports.io/football/teams/49.png', defaultPosition: 6, defaultGoals: 1.8),
  PredictorTeam(name: 'Manchester United', logo: 'https://media.api-sports.io/football/teams/33.png', defaultPosition: 8, defaultGoals: 1.5),
  PredictorTeam(name: 'Inter Milan', logo: 'https://media.api-sports.io/football/teams/505.png', defaultPosition: 1, defaultGoals: 2.2),
  PredictorTeam(name: 'AC Milan', logo: 'https://media.api-sports.io/football/teams/489.png', defaultPosition: 2, defaultGoals: 1.9),
  PredictorTeam(name: 'Juventus', logo: 'https://media.api-sports.io/football/teams/496.png', defaultPosition: 3, defaultGoals: 1.6),
  PredictorTeam(name: 'Bayern Munich', logo: 'https://media.api-sports.io/football/teams/157.png', defaultPosition: 3, defaultGoals: 2.5),
  PredictorTeam(name: 'Bayer Leverkusen', logo: 'https://media.api-sports.io/football/teams/168.png', defaultPosition: 1, defaultGoals: 2.4),
  PredictorTeam(name: 'Borussia Dortmund', logo: 'https://media.api-sports.io/football/teams/165.png', defaultPosition: 5, defaultGoals: 1.8),
  PredictorTeam(name: 'PSG', logo: 'https://media.api-sports.io/football/teams/85.png', defaultPosition: 1, defaultGoals: 2.3),
];

class MatchPredictorView extends ConsumerStatefulWidget {
  const MatchPredictorView({super.key});

  @override
  ConsumerState<MatchPredictorView> createState() => _MatchPredictorViewState();
}

class _MatchPredictorViewState extends ConsumerState<MatchPredictorView> {
  // Team selection
  late PredictorTeam _homeTeam;
  late PredictorTeam _awayTeam;

  // Inputs
  double _homePos = 1.0;
  double _awayPos = 2.0;
  double _homeGoals = 2.3;
  double _awayGoals = 2.1;
  bool _isHomeAdvantage = true;

  // Outputs
  double _winProb = 50.0;
  double _drawProb = 25.0;
  double _lossProb = 25.0;
  int _predictedHomeScore = 2;
  int _predictedAwayScore = 1;
  List<ScoreProbability> _topScores = [];

  bool _isModelLoaded = false;
  late final PredictorService _predictorService;

  @override
  void initState() {
    super.initState();
    _homeTeam = predictorTeams[0]; // Real Madrid
    _awayTeam = predictorTeams[1]; // Barcelona
    _homePos = _homeTeam.defaultPosition.toDouble();
    _awayPos = _awayTeam.defaultPosition.toDouble();
    _homeGoals = _homeTeam.defaultGoals;
    _awayGoals = _awayTeam.defaultGoals;
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

  double poisson(int k, double lambda) {
    if (lambda <= 0) lambda = 0.1;
    final double exponent = math.exp(-lambda);
    double numerator = math.pow(lambda, k) * exponent;
    double denominator = 1.0;
    for (int i = 1; i <= k; i++) {
      denominator *= i;
    }
    return numerator / denominator;
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

    // Expected Win/Draw/Loss probs from predictor
    final win = results[0] * 100.0;
    final draw = results[1] * 100.0;
    final loss = results[2] * 100.0;

    // Poisson-based Score outputs
    double lambdaHome = _homeGoals * 0.95 + (homeAdv * 0.35) + (20 - _homePos) * 0.05;
    double lambdaAway = _awayGoals * 0.85 + (20 - _awayPos) * 0.04;
    
    // Clamp to logical limits
    if (lambdaHome < 0.2) lambdaHome = 0.2;
    if (lambdaAway < 0.2) lambdaAway = 0.2;

    final predHome = lambdaHome.round();
    final predAway = lambdaAway.round();

    // Calculate exact scores matrix
    final List<ScoreProbability> scoreProbs = [];
    double totalSum = 0.0;
    for (int h = 0; h <= 4; h++) {
      for (int a = 0; a <= 4; a++) {
        double p = poisson(h, lambdaHome) * poisson(a, lambdaAway);
        scoreProbs.add(ScoreProbability('$h — $a', p));
        totalSum += p;
      }
    }

    final normalizedProbs = scoreProbs.map((sp) {
      return ScoreProbability(sp.score, (sp.prob / (totalSum > 0 ? totalSum : 1.0)) * 100.0);
    }).toList();

    normalizedProbs.sort((a, b) => b.prob.compareTo(a.prob));
    final topScores = normalizedProbs.take(4).toList();

    if (mounted) {
      setState(() {
        _winProb = win;
        _drawProb = draw;
        _lossProb = loss;
        _predictedHomeScore = predHome;
        _predictedAwayScore = predAway;
        _topScores = topScores;
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

            // Teams Selection Card
            Text(
              'PILIH TIM TANDING',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Home Team Select
                  Expanded(
                    child: Column(
                      children: [
                        Text('KANDANG (HOME)', style: GoogleFonts.orbitron(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Image.network(_homeTeam.logo, width: 54, height: 54, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 54, color: Colors.white24)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<PredictorTeam>(
                              value: _homeTeam,
                              dropdownColor: const Color(0xFF0A0A0C),
                              isExpanded: true,
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              items: predictorTeams.map((t) {
                                return DropdownMenuItem<PredictorTeam>(
                                  value: t,
                                  child: Text(t.name, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _homeTeam = val;
                                    _homePos = val.defaultPosition.toDouble();
                                    _homeGoals = val.defaultGoals;
                                  });
                                  _runInference();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // VS Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('VS', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ),

                  // Away Team Select
                  Expanded(
                    child: Column(
                      children: [
                        Text('TANDANG (AWAY)', style: GoogleFonts.orbitron(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Image.network(_awayTeam.logo, width: 54, height: 54, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 54, color: Colors.white24)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<PredictorTeam>(
                              value: _awayTeam,
                              dropdownColor: const Color(0xFF0A0A0C),
                              isExpanded: true,
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              items: predictorTeams.map((t) {
                                return DropdownMenuItem<PredictorTeam>(
                                  value: t,
                                  child: Text(t.name, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _awayTeam = val;
                                    _awayPos = val.defaultPosition.toDouble();
                                    _awayGoals = val.defaultGoals;
                                  });
                                  _runInference();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Score Prediction Card
            Text(
              'ESTIMASI SKOR AKHIR',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _homeTeam.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            '$_predictedHomeScore — $_predictedAwayScore',
                            style: GoogleFonts.orbitron(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _awayTeam.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prediksi skor terkuat berdasarkan parametrik performa',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form inputs sliders for fine-tuning
            Text(
              'PARAMETRIK HALUS LAGA',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  _buildSliderRow(
                    'Gol Kandang Per Laga',
                    _homeGoals,
                    0,
                    5,
                    (val) {
                      setState(() => _homeGoals = val);
                      _runInference();
                    },
                    isInteger: false,
                  ),
                  _buildSliderRow(
                    'Gol Tandang Per Laga',
                    _awayGoals,
                    0,
                    5,
                    (val) {
                      setState(() => _awayGoals = val);
                      _runInference();
                    },
                    isInteger: false,
                  ),
                  const Divider(color: Colors.white10),
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
              'HASIL PREDIKSI KELUARAN',
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
            const SizedBox(height: 24),

            // Top Exact Scores list
            Text(
              'PROBABILITAS SKOR TERTINGGI',
              style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _topScores.isEmpty
                    ? [const Text('Menghitung skor...')]
                    : _topScores.map((scoreProb) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 70,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                                ),
                                child: Text(
                                  scoreProb.score,
                                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                  textAlign: Center,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 6,
                                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3)),
                                      ),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            height: 6,
                                            width: constraints.maxWidth * (scoreProb.prob / 100),
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary,
                                              borderRadius: BorderRadius.circular(3),
                                              boxShadow: [BoxShadow(color: colorScheme.secondary.withOpacity(0.3), blurRadius: 4)],
                                            ),
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                '${scoreProb.prob.toStringAsFixed(1)}%',
                                style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12, color: colorScheme.secondary),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
            Text(title, style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold)),
            Text(
              '${prob.toStringAsFixed(1)}%',
              style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
