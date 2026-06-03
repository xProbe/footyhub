import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/notification_helper.dart';
import '../../data/locals/database_helper.dart';
import '../../data/services/football_api_service.dart';

// Elite Competitions definition
class EliteLeague {
  final int id;
  final String name;
  final String logo;

  const EliteLeague({required this.id, required this.name, required this.logo});
}

const List<EliteLeague> eliteLeagues = [
  EliteLeague(id: 39, name: 'Premier League', logo: 'https://media.api-sports.io/football/leagues/39.png'),
  EliteLeague(id: 140, name: 'La Liga', logo: 'https://media.api-sports.io/football/leagues/140.png'),
  EliteLeague(id: 135, name: 'Serie A', logo: 'https://media.api-sports.io/football/leagues/135.png'),
  EliteLeague(id: 78, name: 'Bundesliga', logo: 'https://media.api-sports.io/football/leagues/78.png'),
  EliteLeague(id: 61, name: 'Ligue 1', logo: 'https://media.api-sports.io/football/leagues/61.png'),
  EliteLeague(id: 2, name: 'Champions League', logo: 'https://media.api-sports.io/football/leagues/2.png'),
];

final activeLeagueProvider = StateProvider<int>((ref) => 39); // Default to Premier League (39)

// Fetch Standings Provider
final standingsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, leagueId) async {
  final db = DatabaseHelper.instance;

  // Attempt network pull
  if (!ApiConstants.isPlaceholder(ApiConstants.footballApiKey)) {
    try {
      final uri = Uri.parse('${ApiConstants.footballBaseUrl}/standings?league=$leagueId&season=2024');
      final res = await http.get(uri, headers: {
        'x-apisports-key': ApiConstants.footballApiKey,
      }).timeout(const Duration(seconds: 12));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final responseList = data['response'] as List<dynamic>? ?? [];
        if (responseList.isNotEmpty) {
          final leagueData = responseList[0]['league'] ?? {};
          final standings = leagueData['standings']?[0] as List<dynamic>? ?? [];
          
          if (standings.isNotEmpty) {
            await db.upsertStandings(leagueId, standings);
          }
        }
      }
    } catch (_) {}
  }

  // Load from SQLite cache (fresh or cached offline fallback)
  final cached = await db.getCachedStandings(leagueId);
  if (cached.isNotEmpty) return cached;

  if (ApiConstants.isPlaceholder(ApiConstants.footballApiKey)) {
    // Static Mock Standings if no cache and offline
    return _getMockStandings(leagueId);
  }
  return [];
});

// Fetch Fixtures Provider
final fixturesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, leagueId) async {
  final db = DatabaseHelper.instance;

  if (!ApiConstants.isPlaceholder(ApiConstants.footballApiKey)) {
    try {
      final uri = Uri.parse('${ApiConstants.footballBaseUrl}/fixtures?league=$leagueId&season=2024');
      final res = await http.get(uri, headers: {
        'x-apisports-key': ApiConstants.footballApiKey,
      }).timeout(const Duration(seconds: 15));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final responseList = data['response'] as List<dynamic>? ?? [];
        if (responseList.isNotEmpty) {
          // Sort chronologically
          responseList.sort((a, b) {
            final dateA = a['fixture']?['date']?.toString() ?? '';
            final dateB = b['fixture']?['date']?.toString() ?? '';
            return dateA.compareTo(dateB);
          });
          // Use the last 30 fixtures for display limit
          final displayList = responseList.length > 30
              ? responseList.sublist(responseList.length - 30)
              : responseList;
          await db.upsertFixtures(leagueId, displayList);
        }
      }
    } catch (_) {}
  }

  final cached = await db.getCachedFixtures(leagueId);
  if (cached.isNotEmpty) return cached;

  if (ApiConstants.isPlaceholder(ApiConstants.footballApiKey)) {
    return _getMockFixtures(leagueId);
  }
  return [];
});

// Helper for Mock Standings
List<Map<String, dynamic>> _getMockStandings(int leagueId) {
  final List<Map<String, dynamic>> teams;

  switch (leagueId) {
    case 140: // La Liga
      teams = [
        {'name': 'Real Madrid', 'id': 541, 'points': 95, 'w': 29, 'd': 8, 'l': 1, 'gd': 61},
        {'name': 'Barcelona', 'id': 529, 'points': 85, 'w': 26, 'd': 7, 'l': 5, 'gd': 35},
        {'name': 'Girona', 'id': 547, 'points': 81, 'w': 25, 'd': 6, 'l': 7, 'gd': 39},
        {'name': 'Atletico Madrid', 'id': 530, 'points': 76, 'w': 24, 'd': 4, 'l': 10, 'gd': 27},
        {'name': 'Athletic Club', 'id': 531, 'points': 68, 'w': 19, 'd': 11, 'l': 8, 'gd': 24},
        {'name': 'Real Sociedad', 'id': 548, 'points': 60, 'w': 16, 'd': 12, 'l': 10, 'gd': 12},
        {'name': 'Real Betis', 'id': 543, 'points': 57, 'w': 14, 'd': 15, 'l': 9, 'gd': 3},
        {'name': 'Villarreal', 'id': 533, 'points': 53, 'w': 14, 'd': 11, 'l': 13, 'gd': 0},
      ];
      break;
    case 135: // Serie A
      teams = [
        {'name': 'Inter', 'id': 505, 'points': 94, 'w': 29, 'd': 7, 'l': 2, 'gd': 67},
        {'name': 'AC Milan', 'id': 489, 'points': 75, 'w': 22, 'd': 9, 'l': 7, 'gd': 27},
        {'name': 'Juventus', 'id': 496, 'points': 71, 'w': 19, 'd': 14, 'l': 5, 'gd': 23},
        {'name': 'Atalanta', 'id': 499, 'points': 69, 'w': 22, 'd': 3, 'l': 13, 'gd': 30},
        {'name': 'Bologna', 'id': 500, 'points': 68, 'w': 18, 'd': 14, 'l': 6, 'gd': 22},
        {'name': 'AS Roma', 'id': 497, 'points': 63, 'w': 18, 'd': 9, 'l': 11, 'gd': 19},
        {'name': 'Lazio', 'id': 487, 'points': 61, 'w': 18, 'd': 7, 'l': 13, 'gd': 10},
        {'name': 'Fiorentina', 'id': 502, 'points': 60, 'w': 17, 'd': 9, 'l': 12, 'gd': 13},
      ];
      break;
    case 78: // Bundesliga
      teams = [
        {'name': 'Bayer Leverkusen', 'id': 168, 'points': 90, 'w': 28, 'd': 6, 'l': 0, 'gd': 65},
        {'name': 'Stuttgart', 'id': 172, 'points': 73, 'w': 23, 'd': 4, 'l': 7, 'gd': 39},
        {'name': 'Bayern Munich', 'id': 157, 'points': 72, 'w': 23, 'd': 3, 'l': 8, 'gd': 49},
        {'name': 'RB Leipzig', 'id': 173, 'points': 65, 'w': 19, 'd': 8, 'l': 7, 'gd': 38},
        {'name': 'Borussia Dortmund', 'id': 165, 'points': 63, 'w': 18, 'd': 9, 'l': 7, 'gd': 25},
        {'name': 'Eintracht Frankfurt', 'id': 169, 'points': 47, 'w': 11, 'd': 14, 'l': 9, 'gd': 1},
        {'name': 'Hoffenheim', 'id': 167, 'points': 46, 'w': 13, 'd': 7, 'l': 14, 'gd': -4},
        {'name': 'Werder Bremen', 'id': 162, 'points': 42, 'w': 11, 'd': 9, 'l': 14, 'gd': -6},
      ];
      break;
    case 61: // Ligue 1
      teams = [
        {'name': 'PSG', 'id': 85, 'points': 76, 'w': 22, 'd': 10, 'l': 2, 'gd': 48},
        {'name': 'Monaco', 'id': 91, 'points': 67, 'w': 20, 'd': 7, 'l': 7, 'gd': 30},
        {'name': 'Brest', 'id': 106, 'points': 61, 'w': 17, 'd': 10, 'l': 7, 'gd': 19},
        {'name': 'Lille', 'id': 79, 'points': 59, 'w': 16, 'd': 11, 'l': 7, 'gd': 18},
        {'name': 'Nice', 'id': 84, 'points': 55, 'w': 15, 'd': 10, 'l': 9, 'gd': 11},
        {'name': 'Lens', 'id': 116, 'points': 53, 'w': 15, 'd': 8, 'l': 11, 'gd': 8},
        {'name': 'Lyon', 'id': 80, 'points': 53, 'w': 16, 'd': 5, 'l': 13, 'gd': -6},
        {'name': 'Marseille', 'id': 81, 'points': 50, 'w': 13, 'd': 11, 'l': 10, 'gd': 11},
      ];
      break;
    case 2: // Champions League
      teams = [
        {'name': 'Real Madrid', 'id': 541, 'points': 20, 'w': 6, 'd': 2, 'l': 0, 'gd': 12},
        {'name': 'Man City', 'id': 50, 'points': 20, 'w': 6, 'd': 2, 'l': 0, 'gd': 15},
        {'name': 'Arsenal', 'id': 42, 'points': 16, 'w': 5, 'd': 1, 'l': 2, 'gd': 11},
        {'name': 'Bayern Munich', 'id': 157, 'points': 16, 'w': 5, 'd': 1, 'l': 2, 'gd': 10},
        {'name': 'Inter', 'id': 505, 'points': 15, 'w': 4, 'd': 3, 'l': 1, 'gd': 5},
        {'name': 'Barcelona', 'id': 529, 'points': 15, 'w': 5, 'd': 0, 'l': 3, 'gd': 8},
        {'name': 'Borussia Dortmund', 'id': 165, 'points': 14, 'w': 4, 'd': 2, 'l': 2, 'gd': 3},
        {'name': 'PSG', 'id': 85, 'points': 14, 'w': 4, 'd': 2, 'l': 2, 'gd': 8},
      ];
      break;
    case 39: // Premier League
    default:
      teams = [
        {'name': 'Man City', 'id': 50, 'points': 91, 'w': 28, 'd': 7, 'l': 3, 'gd': 62},
        {'name': 'Arsenal', 'id': 42, 'points': 89, 'w': 28, 'd': 5, 'l': 5, 'gd': 62},
        {'name': 'Liverpool', 'id': 40, 'points': 82, 'w': 24, 'd': 10, 'l': 4, 'gd': 45},
        {'name': 'Aston Villa', 'id': 66, 'points': 68, 'w': 20, 'd': 8, 'l': 10, 'gd': 15},
        {'name': 'Tottenham', 'id': 47, 'points': 66, 'w': 20, 'd': 6, 'l': 12, 'gd': 13},
        {'name': 'Chelsea', 'id': 49, 'points': 63, 'w': 18, 'd': 9, 'l': 11, 'gd': 14},
        {'name': 'Newcastle', 'id': 34, 'points': 60, 'w': 18, 'd': 6, 'l': 14, 'gd': 23},
        {'name': 'Manchester United', 'id': 33, 'points': 60, 'w': 18, 'd': 6, 'l': 14, 'gd': -1},
      ];
      break;
  }

  return List.generate(teams.length, (i) {
    final t = teams[i];
    final id = t['id'] as int;
    return {
      'league_id': leagueId,
      'position': i + 1,
      'team_name': t['name'],
      'team_logo': id > 0 ? 'https://media.api-sports.io/football/teams/$id.png' : '',
      'played': (t['w'] as int) + (t['d'] as int) + (t['l'] as int),
      'won': t['w'],
      'drawn': t['d'],
      'lost': t['l'],
      'goals_diff': t['gd'],
      'points': t['points'],
    };
  });
}

// Helper for Mock Fixtures
List<Map<String, dynamic>> _getMockFixtures(int leagueId) {
  final nowStr = DateTime.now().toUtc().toIso8601String();
  final futStr = DateTime.now().toUtc().add(const Duration(hours: 3)).toIso8601String();

  final String leagueName;
  final String h1, a1, h2, a2;
  final int hid1, aid1, hid2, aid2;
  final String v1, v2;
  final String r1, r2;
  final int? hs1, as1;

  switch (leagueId) {
    case 140:
      leagueName = 'La Liga';
      h1 = 'Real Madrid'; hid1 = 541; v1 = 'Santiago Bernabéu'; r1 = 'Jesús Gil Manzano';
      a1 = 'Barcelona'; aid1 = 529; hs1 = 3; as1 = 2;
      h2 = 'Atletico Madrid'; hid2 = 530; v2 = 'Cívitas Metropolitano'; r2 = 'Alejandro Hernández';
      a2 = 'Sevilla'; aid2 = 536;
      break;
    case 135:
      leagueName = 'Serie A';
      h1 = 'Inter'; hid1 = 505; v1 = 'San Siro'; r1 = 'Daniele Orsato';
      a1 = 'AC Milan'; aid1 = 489; hs1 = 2; as1 = 1;
      h2 = 'Juventus'; hid2 = 496; v2 = 'Allianz Stadium'; r2 = 'Marco Di Bello';
      a2 = 'Atalanta'; aid2 = 499;
      break;
    case 78:
      leagueName = 'Bundesliga';
      h1 = 'Bayern Munich'; hid1 = 157; v1 = 'Allianz Arena'; r1 = 'Felix Zwayer';
      a1 = 'Borussia Dortmund'; aid1 = 165; hs1 = 2; as1 = 0;
      h2 = 'Bayer Leverkusen'; hid2 = 168; v2 = 'BayArena'; r2 = 'Daniel Siebert';
      a2 = 'Stuttgart'; aid2 = 172;
      break;
    case 61:
      leagueName = 'Ligue 1';
      h1 = 'PSG'; hid1 = 85; v1 = 'Parc des Princes'; r1 = 'Clément Turpin';
      a1 = 'Monaco'; aid1 = 91; hs1 = 4; as1 = 1;
      h2 = 'Marseille'; hid2 = 81; v2 = 'Orange Vélodrome'; r2 = 'Benoît Bastien';
      a2 = 'Lyon'; aid2 = 80;
      break;
    case 2:
      leagueName = 'Champions League';
      h1 = 'Real Madrid'; hid1 = 541; v1 = 'Santiago Bernabéu'; r1 = 'Szymon Marciniak';
      a1 = 'Man City'; aid1 = 50; hs1 = 1; as1 = 1;
      h2 = 'PSG'; hid2 = 85; v2 = 'Parc des Princes'; r2 = 'Anthony Taylor';
      a2 = 'Bayern Munich'; aid2 = 157;
      break;
    case 39:
    default:
      leagueName = 'Premier League';
      h1 = 'Arsenal'; hid1 = 42; v1 = 'Emirates Stadium'; r1 = 'Michael Oliver';
      a1 = 'Chelsea'; aid1 = 49; hs1 = 3; as1 = 1;
      h2 = 'Man City'; hid2 = 50; v2 = 'Etihad Stadium'; r2 = 'Anthony Taylor';
      a2 = 'Manchester United'; aid2 = 33;
      break;
  }

  return [
    {
      'id': 'mock_${leagueId}_f1',
      'league_id': leagueId,
      'league_name': leagueName,
      'home_name': h1,
      'away_name': a1,
      'home_logo': 'https://media.api-sports.io/football/teams/$hid1.png',
      'away_logo': 'https://media.api-sports.io/football/teams/$aid1.png',
      'home_score': hs1,
      'away_score': as1,
      'status_short': 'FT',
      'utc_date': DateTime.now().subtract(const Duration(days: 2)).toUtc().toIso8601String(),
      'venue': v1,
      'referee': r1,
    },
    {
      'id': 'mock_${leagueId}_f2',
      'league_id': leagueId,
      'league_name': leagueName,
      'home_name': h2,
      'away_name': a2,
      'home_logo': 'https://media.api-sports.io/football/teams/$hid2.png',
      'away_logo': 'https://media.api-sports.io/football/teams/$aid2.png',
      'home_score': null,
      'away_score': null,
      'status_short': 'NS',
      'utc_date': futStr,
      'venue': v2,
      'referee': r2,
    }
  ];
}

// --- FIXTURE REMINDERS ---
class FixtureRemindersNotifier extends StateNotifier<Set<String>> {
  FixtureRemindersNotifier() : super({}) {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('fixture_reminders') ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> toggleReminder(Map<String, dynamic> fixture) async {
    final id = fixture['id']?.toString() ?? '';
    if (id.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final current = Set<String>.from(state);

      if (current.contains(id)) {
        current.remove(id);
        state = current;
        await prefs.setStringList('fixture_reminders', current.toList());
        
        final int notificationId = id.hashCode & 0x7FFFFFFF;
        await NotificationHelper.cancelNotification(notificationId);
      } else {
        current.add(id);
        state = current;
        await prefs.setStringList('fixture_reminders', current.toList());

        final utcDateStr = fixture['utc_date']?.toString();
        if (utcDateStr != null && utcDateStr.isNotEmpty) {
          final kickoffTime = DateTime.parse(utcDateStr).toLocal();
          // Schedule 5 minutes before kickoff
          final reminderTime = kickoffTime.subtract(const Duration(minutes: 5));
          final int notificationId = id.hashCode & 0x7FFFFFFF;
          
          final homeTeam = fixture['home_name'] ?? 'Home Team';
          final awayTeam = fixture['away_name'] ?? 'Away Team';
          
          await NotificationHelper.scheduleNotification(
            id: notificationId,
            title: '⚽ Jadwal Pertandingan Akan Dimulai!',
            body: '$homeTeam vs $awayTeam akan kick-off dalam 5 menit. Bersiaplah!',
            scheduledDate: reminderTime,
          );
        }
      }
    } catch (_) {}
  }
}

final fixtureRemindersProvider = StateNotifierProvider<FixtureRemindersNotifier, Set<String>>((ref) {
  return FixtureRemindersNotifier();
});
