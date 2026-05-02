import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'game_controller.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  double _y = 0.12;
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
    final gc = Get.find<GameController>();
    if (gc.isGameOver.value) return;
    setState(() {
      _vy += 0.0005; // Slower gravity
      _y += _vy;
      if (_y > 0.9) {
        _y = 0.1;
        _vy = 0.001;
        _x = 0.3 + (DateTime.now().millisecond % 100) / 250;
        gc.decreaseHeart();
      }
    });
  }

  void _tap(TapDownDetails d, Size size) {
    final gc = Get.find<GameController>();
    if (gc.isGameOver.value) return;
    final cx = _x * size.width;
    final cy = _y * size.height;
    if ((d.localPosition - Offset(cx, cy)).distance < 56) {
      setState(() {
        _vy = -0.012; // Slower jump
        _y = (_y - 0.06).clamp(0.08, 0.5);
        gc.increaseScore();
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
    final GameController gc = Get.find<GameController>();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            3,
                            (i) => Icon(
                              Icons.favorite,
                              color: i < gc.hearts.value
                                  ? AppColors.dangerRed
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                        Text(
                          'Skor ${gc.score.value}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, cts) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (d) => _tap(d, cts.biggest),
                          child: Stack(
                            children: [
                              CustomPaint(
                                painter: _PitchPainter(),
                                size: Size.infinite,
                              ),
                              Positioned(
                                left: (_x * cts.maxWidth) - 25,
                                top: (_y * cts.maxHeight) - 25,
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logobola.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
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
              if (gc.isGameOver.value)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Game over',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dangerRed,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Skor: ${gc.score.value}',
                            style: GoogleFonts.inter(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () {
                              gc.resetGame();
                              setState(() {
                                _y = 0.12;
                                _vy = 0.001;
                                _x = 0.5;
                              });
                            },
                            child: const Text('Main lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final h = s.height;
    final w = s.width;
    final grass = Paint()..color = const Color(0xFFE8F5E9);
    canvas.drawRect(Offset.zero & s, grass);

    final line = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, h * 0.92), Offset(w, h * 0.92), line);
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) {
    return false;
  }
}
