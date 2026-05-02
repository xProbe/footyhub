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
    if (ApiConstants.footballApiKey == 'MASUKKAN_API_KEY_API_FOOTBALL_ANDA') {
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
        '${ApiConstants.footballBaseUrl}/fixtures?league=39&next=12',
      );
      final nextRes = await http
          .get(nextUri, headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (nextRes.statusCode == 200) {
        final data = jsonDecode(nextRes.body) as Map<String, dynamic>;
        final list = data['response'] as List<dynamic>? ?? [];
        for (final raw in list) {
          final o = raw as Map<String, dynamic>;
          final id = o['fixture']?['id']?.toString() ?? '';
          if (items.any((e) => e.id == id)) continue;
          items.add(FootballFeedItem.fromFixture(o));
        }
      }
    } catch (e) {
      // Biarkan pemanggil memakai cache SQLite
    }

    return items;
  }
}
