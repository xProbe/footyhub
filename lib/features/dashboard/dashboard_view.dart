import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../home/home_view.dart';
import '../maps/maps_view.dart';
import '../profile/profile_view.dart';
import '../game/match_predictor_view.dart';
import '../home/competition_view.dart';

// Provider to manage active tab index
final dashboardTabProvider = StateProvider<int>((ref) => 0);

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  static const List<Widget> _views = [
    HomeView(),
    CompetitionView(),
    MapsView(showBack: false),
    MatchPredictorView(),
    ProfileView(),
  ];

  static const List<String> _labels = [
    'Beranda',
    'Kompetisi',
    'Lapangan',
    'Prediktor',
    'Akun',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(dashboardTabProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isNear = ref.watch(sensorStateProvider.select((s) => s.isNear));

    // Listen to Ambient Light Sensor dimming state changes
    ref.listen<bool>(sensorStateProvider.select((s) => s.isDimmed), (prev, next) {
      if (prev != null && prev != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF39FF14),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                Icon(next ? Icons.nightlight_round : Icons.light_mode_rounded, color: Colors.black),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next
                        ? 'Sensor Cahaya: Lingkungan gelap terdeteksi! Mengaktifkan Mode Malam Peta...'
                        : 'Sensor Cahaya: Cahaya sekitar normal! Mengembalikan Kontras Peta...',
                    style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    // Listen to Proximity Sensor near state changes
    ref.listen<bool>(sensorStateProvider.select((s) => s.isNear), (prev, next) {
      if (prev != null && prev != next) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: next ? Colors.redAccent : const Color(0xFF39FF14),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                Icon(next ? Icons.phonelink_lock_rounded : Icons.lock_open_rounded, color: next ? Colors.white : Colors.black),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next
                        ? 'Sensor Proximity: Objek dekat terdeteksi! Layar dikunci (Pocket Protection).'
                        : 'Sensor Proximity: Objek menjauh. Layar dibuka kembali.',
                    style: GoogleFonts.inter(color: next ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Keep views alive or use simple IndexStack
          IndexedStack(
            index: tabIndex,
            children: _views,
          ),

          // Proximity pocket protection overlay
          if (isNear)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.96),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glow Container for Locked Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.2),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phonelink_lock_rounded,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'POCKET PROTECTION ACTIVE',
                      style: GoogleFonts.orbitron(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Sensor kedekatan mendeteksi objek. Layar dikunci otomatis untuk mencegah penekanan tidak sengaja di saku.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Unlock button
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(sensorStateProvider.notifier).setNear(false);
                      },
                      icon: const Icon(Icons.lock_open_rounded, size: 16),
                      label: Text(
                        'BUKA KUNCI MANUAL',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: GlassBottomNavBar(
        opacity: 0.08,
        blur: 16.0,
        child: BottomNavigationBar(
          currentIndex: tabIndex,
          onTap: (index) => ref.read(dashboardTabProvider.notifier).state = index,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: Colors.white30,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: [
            for (var i = 0; i < _labels.length; i++)
              BottomNavigationBarItem(
                icon: Icon(_iconFor(i, false)),
                activeIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_iconFor(i, true), color: colorScheme.primary),
                ),
                label: _labels[i],
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(int i, bool isSelected) {
    switch (i) {
      case 0:
        return isSelected ? Icons.sports_soccer_rounded : Icons.sports_soccer_rounded;
      case 1:
        return isSelected ? Icons.emoji_events_rounded : Icons.emoji_events_outlined;
      case 2:
        return isSelected ? Icons.map_rounded : Icons.map_outlined;
      case 3:
        return isSelected ? Icons.online_prediction_rounded : Icons.analytics_outlined;
      default:
        return isSelected ? Icons.person_rounded : Icons.person_outline_rounded;
    }
  }
}
