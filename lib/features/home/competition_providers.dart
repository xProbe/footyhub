import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
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
  if (ApiConstants.footballApiKey != 'MASUKKAN_API_KEY_API_FOOTBALL_ANDA') {
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

  // Static Mock Standings if no cache and offline
  return _getMockStandings(leagueId);
});

// Fetch Fixtures Provider
final fixturesProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, leagueId) async {
  final db = DatabaseHelper.instance;

  if (ApiConstants.footballApiKey != 'MASUKKAN_API_KEY_API_FOOTBALL_ANDA') {
    try {
      final uri = Uri.parse('${ApiConstants.footballBaseUrl}/fixtures?league=$leagueId&next=20');
      final res = await http.get(uri, headers: {
        'x-apisports-key': ApiConstants.footballApiKey,
      }).timeout(const Duration(seconds: 12));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final responseList = data['response'] as List<dynamic>? ?? [];
        if (responseList.isNotEmpty) {
          await db.upsertFixtures(leagueId, responseList);
        }
      }
    } catch (_) {}
  }

  final cached = await db.getCachedFixtures(leagueId);
  if (cached.isNotEmpty) return cached;

  return _getMockFixtures(leagueId);
});

// Helper for Mock Standings
List<Map<String, dynamic>> _getMockStandings(int leagueId) {
  final teams = [
    {'name': 'Arsenal', 'points': 89, 'w': 28, 'd': 5, 'l': 5, 'gd': 62},
    {'name': 'Man City', 'points': 91, 'w': 28, 'd': 7, 'l': 3, 'gd': 62},
    {'name': 'Liverpool', 'points': 82, 'w': 24, 'd': 10, 'l': 4, 'gd': 45},
    {'name': 'Aston Villa', 'points': 68, 'w': 20, 'd': 8, 'l': 10, 'gd': 15},
    {'name': 'Tottenham', 'points': 66, 'w': 20, 'd': 6, 'l': 12, 'gd': 13},
    {'name': 'Chelsea', 'points': 63, 'w': 18, 'd': 9, 'l': 11, 'gd': 14},
    {'name': 'Newcastle', 'points': 60, 'w': 18, 'd': 6, 'l': 14, 'gd': 23},
    {'name': 'Manchester United', 'points': 60, 'w': 18, 'd': 6, 'l': 14, 'gd': -1},
  ];

  if (leagueId == 140) { // La Liga
    teams[0] = {'name': 'Real Madrid', 'points': 95, 'w': 29, 'd': 8, 'l': 1, 'gd': 61};
    teams[1] = {'name': 'Barcelona', 'points': 85, 'w': 26, 'd': 7, 'l': 5, 'gd': 35};
    teams[2] = {'name': 'Girona', 'points': 81, 'w': 25, 'd': 6, 'l': 7, 'gd': 39};
  }

  return List.generate(teams.length, (i) {
    final t = teams[i];
    return {
      'league_id': leagueId,
      'position': i + 1,
      'team_name': t['name'],
      'team_logo': 'https://media.api-sports.io/football/teams/${i + 33}.png',
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
  
  return [
    {
      'id': 'mock_f1',
      'league_id': leagueId,
      'league_name': leagueId == 39 ? 'Premier League' : 'Champions League',
      'home_name': 'Arsenal',
      'away_name': 'Chelsea',
      'home_logo': 'https://media.api-sports.io/football/teams/42.png',
      'away_logo': 'https://media.api-sports.io/football/teams/49.png',
      'home_score': 3,
      'away_score': 1,
      'status_short': 'FT',
      'utc_date': nowStr,
      'venue': 'Emirates Stadium',
      'referee': 'Michael Oliver',
    },
    {
      'id': 'mock_f2',
      'league_id': leagueId,
      'league_name': leagueId == 39 ? 'Premier League' : 'Champions League',
      'home_name': 'Real Madrid',
      'away_name': 'Barcelona',
      'home_logo': 'https://media.api-sports.io/football/teams/541.png',
      'away_logo': 'https://media.api-sports.io/football/teams/529.png',
      'home_score': null,
      'away_score': null,
      'status_short': 'NS',
      'utc_date': futStr,
      'venue': 'Santiago Bernabéu',
      'referee': 'Jesús Gil Manzano',
    }
  ];
}
