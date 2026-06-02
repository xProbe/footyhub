import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../core/utils/audio_provider.dart';
import 'game_provider.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _y = 0.15;
  double _vy = 0.001;
  double _x = 0.5;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _anim.addListener(_step);
  }

  void _step() {
    final game = ref.read(gameProvider);
    if (game.isGameOver) return;
    setState(() {
      _vy += 0.0004; // Slower gravity
      _y += _vy;
      if (_y > 0.88) {
        _y = 0.15;
        _vy = 0.001;
        _x = 0.2 + (DateTime.now().millisecond % 100) / 160;
        ref.read(gameProvider.notifier).decreaseHeart();
      }
    });
  }

  void _tap(TapDownDetails d, Size size) {
    final game = ref.read(gameProvider);
    if (game.isGameOver) return;
    
    final cx = _x * size.width;
    final cy = _y * size.height;
    
    // Tap detection range
    if ((d.localPosition - Offset(cx, cy)).distance < 50) {
      // Play tactile kick sound
      ref.read(audioFeedbackProvider).playKickSound();
      setState(() {
        _vy = -0.011; // Bounce up
        _y = (_y - 0.05).clamp(0.08, 0.5);
        ref.read(gameProvider.notifier).increaseScore();
      });
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header Panel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lives Left
                      Row(
                        children: List.generate(
                          3,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: i < game.hearts ? colorScheme.primary : Colors.white10,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Score & High Score
                      Column(
                        children: [
                          Text(
                            'SKOR: ${game.score}',
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text(
                            'REKOR: ${game.highScore}',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                // Play area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, cts) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) => _tap(d, cts.biggest),
                        child: Stack(
                          children: [
                            // Pitch graphics
                            CustomPaint(
                              painter: _PitchPainter(colorScheme.primary),
                              size: Size.infinite,
                            ),
                            // Ball
                            Positioned(
                              left: (_x * cts.maxWidth) - 25,
                              top: (_y * cts.maxHeight) - 25,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logobola.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => CircleAvatar(
                                      backgroundColor: colorScheme.primary,
                                      child: const Icon(Icons.sports_soccer_rounded, color: Colors.black, size: 30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Game Over overlay dialog
            if (game.isGameOver)
              Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: GlassCard(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_soccer_rounded, size: 64, color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'PERMAINAN BERAKHIR',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Skor Anda: ${game.score}',
                        style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                      ),
                      if (game.score >= game.highScore && game.score > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'REKOR BARU!',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () {
                          ref.read(gameProvider.notifier).resetGame();
                          setState(() {
                            _y = 0.15;
                            _vy = 0.001;
                            _x = 0.5;
                          });
                        },
                        child: Text(
                          'MAIN LAGI',
                          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final Color neonColor;
  _PitchPainter(this.neonColor);

  @override
  void paint(Canvas canvas, Size s) {
    final h = s.height;
    final w = s.width;
    
    // Draw grid lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Grass color
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF020202));

    // Pitch center line
    canvas.drawLine(Offset(0, h * 0.9), Offset(w, h * 0.9), Paint()
      ..color = neonColor.withOpacity(0.3)
      ..strokeWidth = 3);
    
    // Circle
    canvas.drawCircle(Offset(w / 2, h * 0.9), 60, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return false;
  }
}
