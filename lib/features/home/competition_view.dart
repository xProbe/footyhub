import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import 'competition_providers.dart';

class CompetitionView extends ConsumerStatefulWidget {
  const CompetitionView({super.key});

  @override
  ConsumerState<CompetitionView> createState() => _CompetitionViewState();
}

class _CompetitionViewState extends ConsumerState<CompetitionView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeLeagueId = ref.watch(activeLeagueProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('LEAGUE HUB', style: GoogleFonts.orbitron(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110.0),
          child: Column(
            children: [
              // 1. Horizontal League Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: eliteLeagues.map((league) {
                    final isSelected = activeLeagueId == league.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          league.name,
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            ref.read(activeLeagueProvider.notifier).state = league.id;
                          }
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: const Color(0xFF141418),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(
                          color: isSelected ? colorScheme.primary : Colors.white.withOpacity(0.08),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // 2. Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: Colors.white38,
                labelStyle: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(text: 'Klasemen'),
                  Tab(text: 'Jadwal'),
                  Tab(text: 'Match Center'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStandingsTab(activeLeagueId),
          _buildFixturesTab(activeLeagueId),
          _buildMatchCenterTab(activeLeagueId),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: STANDINGS
  // ==========================================
  Widget _buildStandingsTab(int leagueId) {
    final standingsAsync = ref.watch(standingsProvider(leagueId));
    final colorScheme = Theme.of(context).colorScheme;

    return standingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat klasemen: $err', style: const TextStyle(color: Colors.white70))),
      data: (list) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: GlassCard(
            opacity: 0.05,
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 8,
                headingTextStyle: GoogleFonts.orbitron(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 10),
                dataTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('TIM')),
                  DataColumn(label: Text('M')),
                  DataColumn(label: Text('MN')),
                  DataColumn(label: Text('S')),
                  DataColumn(label: Text('K')),
                  DataColumn(label: Text('SG')),
                  DataColumn(label: Text('PTS')),
                ],
                rows: list.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${item['position']}')),
                      DataCell(Row(
                        children: [
                          Image.network(item['team_logo'], width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 20)),
                          const SizedBox(width: 8),
                          Text(item['team_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      )),
                      DataCell(Text('${item['played']}')),
                      DataCell(Text('${item['won']}')),
                      DataCell(Text('${item['drawn']}')),
                      DataCell(Text('${item['lost']}')),
                      DataCell(Text('${item['goals_diff'] >= 0 ? "+" : ""}${item['goals_diff']}')),
                      DataCell(Text('${item['points']}', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: FIXTURES (Timezone Conversions)
  // ==========================================
  Widget _buildFixturesTab(int leagueId) {
    final fixturesAsync = ref.watch(fixturesProvider(leagueId));

    return fixturesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat jadwal: $err')),
      data: (list) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final f = list[i];
            final utcStr = f['utc_date'] as String;
            final utcTime = DateTime.parse(utcStr).toUtc();
            
            // Conversions
            final wib = utcTime.add(const Duration(hours: 7));
            final wita = utcTime.add(const Duration(hours: 8));
            final wit = utcTime.add(const Duration(hours: 9));

            final isLive = f['status_short'] == '1H' || f['status_short'] == '2H' || f['status_short'] == 'HT' || f['status_short'] == 'LIVE';

            return GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Head Row: Timezone selectors / info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        f['venue'] ?? 'Stadium',
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isLive ? 'LIVE · ${f['status_short']}' : f['status_short'],
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            color: isLive ? Colors.redAccent : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Score Board Row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(f['home_name'], style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                            const SizedBox(width: 8),
                            Image.network(f['home_logo'], width: 28, height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.shield)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          f['home_score'] != null ? '${f['home_score']} — ${f['away_score']}' : 'VS',
                          style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.network(f['away_logo'], width: 28, height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.shield)),
                            const SizedBox(width: 8),
                            Text(f['away_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Timezone Grid
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimezoneItem('WIB', wib),
                        _buildTimezoneItem('WITA', wita),
                        _buildTimezoneItem('WIT', wit),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimezoneItem(String label, DateTime dt) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.orbitron(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(
          DateFormat('HH:mm').format(dt),
          style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: MATCH CENTER (Formation & Timeline)
  // ==========================================
  Widget _buildMatchCenterTab(int leagueId) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Summary Card
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Laga Terakhir Sorotan', style: GoogleFonts.orbitron(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Arsenal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Image.network('https://media.api-sports.io/football/teams/42.png', width: 40, height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('3 — 1', style: GoogleFonts.orbitron(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    ),
                    Image.network('https://media.api-sports.io/football/teams/49.png', width: 40, height: 40),
                    const SizedBox(width: 8),
                    const Text('Chelsea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Selesai · Emirates Stadium', style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Player Formation chart
          Text('FORMASI TAKTIS', style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Arsenal (4-3-3)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Chelsea (4-2-3-1)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                // Graphical Pitch Formation mock
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withOpacity(0.2), // Football grass dark green
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Stack(
                    children: [
                      // Center line
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.white24,
                        ),
                      ),
                      // Center circle
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Home Players dot indicators
                      Positioned(
                        top: 20,
                        left: 40,
                        child: _playerDot('Gabriel', colorScheme.primary),
                      ),
                      Positioned(
                        top: 20,
                        right: 40,
                        child: _playerDot('Saliba', colorScheme.primary),
                      ),
                      Positioned(
                        top: 50,
                        left: 80,
                        child: _playerDot('Rice', colorScheme.primary),
                      ),
                      Positioned(
                        top: 50,
                        right: 80,
                        child: _playerDot('Ødegaard', colorScheme.primary),
                      ),
                      Positioned(
                        top: 80,
                        left: 130,
                        child: _playerDot('Saka', colorScheme.primary),
                      ),

                      // Away Players dot indicators
                      Positioned(
                        bottom: 20,
                        left: 40,
                        child: _playerDot('Silva', Colors.cyanAccent),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 40,
                        child: _playerDot('Disasi', Colors.cyanAccent),
                      ),
                      Positioned(
                        bottom: 50,
                        left: 80,
                        child: _playerDot('Caicedo', Colors.cyanAccent),
                      ),
                      Positioned(
                        bottom: 50,
                        right: 80,
                        child: _playerDot('Enzo', Colors.cyanAccent),
                      ),
                      Positioned(
                        bottom: 85,
                        left: 130,
                        child: _playerDot('Jackson', Colors.cyanAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          Text('STATISTIK PERTANDINGAN', style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.primary)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Penguasaan Bola', '57%', '43%', 0.57, 0.43, colorScheme.primary, Colors.cyanAccent),
                const SizedBox(height: 12),
                _buildStatRow('Total Tendangan', '16', '9', 0.64, 0.36, colorScheme.primary, Colors.cyanAccent),
                const SizedBox(height: 12),
                _buildStatRow('Tendangan ke Gawang', '7', '3', 0.70, 0.30, colorScheme.primary, Colors.cyanAccent),
                const SizedBox(height: 12),
                _buildStatRow('Pelanggaran', '8', '12', 0.40, 0.60, colorScheme.primary, Colors.cyanAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerDot(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 2),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatRow(String label, String home, String away, double homeVal, double awayVal, Color homeColor, Color awayColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(home, style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
            Text(away, style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: (homeVal * 100).toInt(),
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: homeColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(2))),
              ),
            ),
            Expanded(
              flex: (awayVal * 100).toInt(),
              child: Container(
                height: 4,
                decoration: BoxDecoration(color: awayColor, borderRadius: const BorderRadius.horizontal(right: Radius.circular(2))),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
