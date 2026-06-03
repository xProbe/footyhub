import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/football_feed_item.dart';

/// Mengambil jadwal & pertandingan dari API-Football (api-sports).
class FootballApiService {
  static Map<String, String> get _headers => {
        'x-apisports-key': ApiConstants.footballApiKey,
      };

  static Future<List<FootballFeedItem>> fetchFeed() async {
    if (ApiConstants.isPlaceholder(ApiConstants.footballApiKey)) {
      await Future.delayed(const Duration(seconds: 1));
      return [
        FootballFeedItem(
          id: 'mock1',
          title: 'Arsenal vs Chelsea',
          subtitle: '3 — 1 · FT',
          imageUrl: 'https://media.api-sports.io/football/teams/42.png',
          statusShort: 'FT',
          utcDate: DateTime.now().toString(),
          leagueName: 'Premier League',
        ),
        FootballFeedItem(
          id: 'mock2',
          title: 'Real Madrid vs Barcelona',
          subtitle: 'vs · NS',
          imageUrl: 'https://media.api-sports.io/football/teams/541.png',
          statusShort: 'NS',
          utcDate: DateTime.now().add(const Duration(hours: 2)).toString(),
          leagueName: 'La Liga',
        ),
      ];
    }

    final items = <FootballFeedItem>[];

    try {
      final liveUri = Uri.parse(
        '${ApiConstants.footballBaseUrl}/fixtures?live=all',
      );
      final liveRes = await http
          .get(liveUri, headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (liveRes.statusCode == 200) {
        final data = jsonDecode(liveRes.body) as Map<String, dynamic>;
        final list = data['response'] as List<dynamic>? ?? [];
        for (final raw in list) {
          items.add(FootballFeedItem.fromFixture(raw as Map<String, dynamic>));
        }
      }

      final nextUri = Uri.parse(
        '${ApiConstants.footballBaseUrl}/fixtures?league=39&season=2024',
      );
      final nextRes = await http
          .get(nextUri, headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (nextRes.statusCode == 200) {
        final data = jsonDecode(nextRes.body) as Map<String, dynamic>;
        final list = data['response'] as List<dynamic>? ?? [];
        final reversedList = list.reversed.toList();
        final limitList = reversedList.length > 15
            ? reversedList.sublist(0, 15)
            : reversedList;
        for (final raw in limitList) {
          final o = raw as Map<String, dynamic>;
          final id = o['fixture']?['id']?.toString() ?? '';
          if (items.any((e) => e.id == id)) continue;
          items.add(FootballFeedItem.fromFixture(o));
        }
      }
    } catch (e) {
      // Biarkan pemanggil memakai cache SQLite
    }

    if (items.isEmpty && ApiConstants.isPlaceholder(ApiConstants.footballApiKey)) {
      return [
        FootballFeedItem(
          id: 'mock1',
          title: 'Arsenal vs Chelsea',
          subtitle: '3 — 1 · FT',
          imageUrl: 'https://media.api-sports.io/football/teams/42.png',
          statusShort: 'FT',
          utcDate: DateTime.now().subtract(const Duration(days: 2)).toUtc().toIso8601String(),
          leagueName: 'Premier League',
          stadium: 'Emirates Stadium',
          referee: 'Michael Oliver',
          homeName: 'Arsenal',
          awayName: 'Chelsea',
          homeLogo: 'https://media.api-sports.io/football/teams/42.png',
          awayLogo: 'https://media.api-sports.io/football/teams/49.png',
        ),
        FootballFeedItem(
          id: 'mock2',
          title: 'Real Madrid vs Barcelona',
          subtitle: 'vs · NS',
          imageUrl: 'https://media.api-sports.io/football/teams/541.png',
          statusShort: 'NS',
          utcDate: DateTime.now().add(const Duration(hours: 3)).toUtc().toIso8601String(),
          leagueName: 'La Liga',
          stadium: 'Santiago Bernabéu',
          referee: 'Jesús Gil Manzano',
          homeName: 'Real Madrid',
          awayName: 'Barcelona',
          homeLogo: 'https://media.api-sports.io/football/teams/541.png',
          awayLogo: 'https://media.api-sports.io/football/teams/529.png',
        ),
        FootballFeedItem(
          id: 'mock3',
          title: 'Bayern Munich vs Dortmund',
          subtitle: '2 — 2 · FT',
          imageUrl: 'https://media.api-sports.io/football/teams/157.png',
          statusShort: 'FT',
          utcDate: DateTime.now().subtract(const Duration(days: 1)).toUtc().toIso8601String(),
          leagueName: 'Bundesliga',
          stadium: 'Allianz Arena',
          referee: 'Felix Zwayer',
          homeName: 'Bayern Munich',
          awayName: 'Dortmund',
          homeLogo: 'https://media.api-sports.io/football/teams/157.png',
          awayLogo: 'https://media.api-sports.io/football/teams/165.png',
        ),
        FootballFeedItem(
          id: 'mock4',
          title: 'Inter vs AC Milan',
          subtitle: '1 — 0 · FT',
          imageUrl: 'https://media.api-sports.io/football/teams/505.png',
          statusShort: 'FT',
          utcDate: DateTime.now().subtract(const Duration(days: 1, hours: 4)).toUtc().toIso8601String(),
          leagueName: 'Serie A',
          stadium: 'San Siro',
          referee: 'Daniele Orsato',
          homeName: 'Inter',
          awayName: 'AC Milan',
          homeLogo: 'https://media.api-sports.io/football/teams/505.png',
          awayLogo: 'https://media.api-sports.io/football/teams/489.png',
        ),
      ];
    }

    return items;
  }
}
