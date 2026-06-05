import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'home_providers.dart';
import '../auth/auth_provider.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../core/utils/sensor_controller.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);
    final filteredNews = ref.watch(filteredNewsProvider);
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Trigger loading sensors
    ref.watch(sensorManagerProvider);

    // Listen to shake event from Accelerometer
    ref.listen<AsyncValue<void>>(shakeEventProvider, (prev, next) {
      if (next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF39FF14),
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.edgesensor_high_rounded, color: Colors.black),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sensor Akselerometer: Goyangan Terdeteksi! Memuat Ulang Berita Sepakbola...',
                    style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: () => ref.read(newsProvider.notifier).fetchNews(),
        child: CustomScrollView(
          slivers: [
            // 1. Parallax Header Banner
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFF0A0A0C),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                collapseMode: CollapseMode.parallax,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'FootyHub Portal',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Network stadium background image
                    Image.network(
                      'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1200&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF0A0A0C),
                        child: const Icon(Icons.stadium_outlined, color: Colors.white24, size: 80),
                      ),
                    ),
                    // Dark linear gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Welcome & Live Summary Panel
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${authState.name.split(' ').first}',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Goyangkan HP untuk memuat ulang data laga',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        // Top Logo Badge
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.sports_soccer_rounded, color: colorScheme.primary, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0C),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cari tim, pertandingan, atau liga…',
                          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Services section
                    Text(
                      'LAYANAN FOOTYHUB',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            context: context,
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'AI PUNDIT',
                            subtitle: 'Tanya Jawab AI',
                            color: colorScheme.primary,
                            onTap: () => Navigator.pushNamed(context, '/chatbot'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildServiceCard(
                            context: context,
                            icon: Icons.currency_exchange_rounded,
                            title: 'KONVERSI',
                            subtitle: 'Uang & Waktu',
                            color: Colors.cyanAccent,
                            onTap: () => Navigator.pushNamed(context, '/conversion'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildServiceCard(
                            context: context,
                            icon: Icons.sports_esports_outlined,
                            title: 'MINI GAME',
                            subtitle: 'Pantul Bola',
                            color: Colors.amberAccent,
                            onTap: () => Navigator.pushNamed(context, '/game'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'RILIS BERITA TERKINI',
                      style: GoogleFonts.orbitron(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Staggered Animated News List
            if (newsState.isLoading && filteredNews.isEmpty)
              SliverFillRemaining(
                child: _buildShimmerLoading(context),
              )
            else if (filteredNews.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, color: colorScheme.primary.withOpacity(0.4), size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Berita tidak ditemukan',
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredNews[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _NewsCard(item: item),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredNews.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      opacity: 0.05,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 8, color: Colors.white30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF0A0A0C),
      highlightColor: const Color(0xFF141418),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 12, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 10, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final dynamic item;

  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      opacity: 0.05,
      blur: 8.0,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/match-detail',
            arguments: item,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0A0A0C),
                          child: Icon(Icons.sports_soccer_rounded, color: colorScheme.primary.withOpacity(0.5)),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF0A0A0C),
                        child: Icon(Icons.sports_soccer_rounded, color: colorScheme.primary.withOpacity(0.5)),
                      ),
              ),
            ),
            // Title & Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.leagueName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white38,
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
