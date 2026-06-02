import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          // Keep views alive or use simple IndexStack
          IndexedStack(
            index: tabIndex,
            children: _views,
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
