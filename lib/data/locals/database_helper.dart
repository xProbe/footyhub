import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/football_feed_item.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  // Web cache fallbacks
  static final List<FootballFeedItem> _webNewsCache = [];
  static final Map<int, List<Map<String, dynamic>>> _webFixturesCache = {};
  static final Map<int, List<Map<String, dynamic>>> _webStandingsCache = {};

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web. Use SharedPreferences & Memory fallback.');
    }
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'footyhub.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Users Table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            name TEXT NOT NULL,
            nim TEXT,
            favorite_team TEXT DEFAULT 'DEFAULT',
            biometric_enabled INTEGER DEFAULT 0,
            profile_image TEXT,
            testimonial TEXT,
            created_at INTEGER
          )
        ''');

        // 2. High Scores Table
        await db.execute('''
          CREATE TABLE game_high_scores (
            username TEXT PRIMARY KEY,
            high_score INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // 3. News Cache Table
        await db.execute('''
          CREATE TABLE news_cache (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            imageUrl TEXT NOT NULL,
            statusShort TEXT NOT NULL,
            utcDate TEXT,
            leagueName TEXT,
            stadium TEXT,
            referee TEXT,
            homeName TEXT,
            awayName TEXT,
            homeLogo TEXT,
            awayLogo TEXT,
            updatedAt INTEGER NOT NULL
          )
        ''');

        // 4. Fixtures Cache Table
        await db.execute('''
          CREATE TABLE fixtures_cache (
            id TEXT PRIMARY KEY,
            league_id INTEGER,
            league_name TEXT,
            home_name TEXT,
            away_name TEXT,
            home_logo TEXT,
            away_logo TEXT,
            home_score INTEGER,
            away_score INTEGER,
            status_short TEXT,
            utc_date TEXT,
            venue TEXT,
            referee TEXT,
            updated_at INTEGER
          )
        ''');

        // 5. Standings Cache Table
        await db.execute('''
          CREATE TABLE standings_cache (
            league_id INTEGER,
            position INTEGER,
            team_name TEXT,
            team_logo TEXT,
            played INTEGER,
            won INTEGER,
            drawn INTEGER,
            lost INTEGER,
            goals_diff INTEGER,
            points INTEGER,
            updated_at INTEGER,
            PRIMARY KEY (league_id, team_name)
          )
        ''');
      },
    );
  }

  // ==========================================
  // 1. USER OPERATIONS
  // ==========================================
  Future<int> insertUser(Map<String, dynamic> userRow) async {
    if (kIsWeb) {
      final username = userRow['username'] as String;
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('web_user_$username')) {
        return 0; // User already exists
      }
      await prefs.setString('web_user_$username', jsonEncode(userRow));
      return 1;
    }
    final db = await database;
    return await db.insert('users', userRow, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('web_user_$username');
      if (data == null) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    }
    final db = await database;
    final results = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<int> updateUserField(String username, String field, dynamic value) async {
    if (kIsWeb) {
      final user = await getUser(username);
      if (user == null) return 0;
      user[field] = value is bool ? (value ? 1 : 0) : value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('web_user_$username', jsonEncode(user));
      return 1;
    }
    final db = await database;
    return await db.update(
      'users',
      {field: value is bool ? (value ? 1 : 0) : value},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  // ==========================================
  // 2. HIGH SCORE OPERATIONS
  // ==========================================
  Future<int> getHighScore(String username) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('web_high_score_$username') ?? 0;
    }
    final db = await database;
    final results = await db.query('game_high_scores', where: 'username = ?', whereArgs: [username], limit: 1);
    if (results.isEmpty) return 0;
    return results.first['high_score'] as int;
  }

  Future<void> saveHighScore(String username, int score) async {
    if (kIsWeb) {
      final current = await getHighScore(username);
      if (score > current) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('web_high_score_$username', score);
      }
      return;
    }
    final db = await database;
    final currentHighScore = await getHighScore(username);
    if (score > currentHighScore) {
      await db.insert(
        'game_high_scores',
        {
          'username': username,
          'high_score': score,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // ==========================================
  // 3. NEWS CACHE OPERATIONS
  // ==========================================
  Future<void> upsertNewsItems(List<FootballFeedItem> items) async {
    if (kIsWeb) {
      _webNewsCache.clear();
      _webNewsCache.addAll(items);
      return;
    }
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final it in items) {
      batch.insert(
        'news_cache',
        {
          'id': it.id,
          'title': it.title,
          'subtitle': it.subtitle,
          'imageUrl': it.imageUrl,
          'statusShort': it.statusShort,
          'utcDate': it.utcDate,
          'leagueName': it.leagueName,
          'stadium': it.stadium,
          'referee': it.referee,
          'homeName': it.homeName,
          'awayName': it.awayName,
          'homeLogo': it.homeLogo,
          'awayLogo': it.awayLogo,
          'updatedAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<FootballFeedItem>> getCachedNews() async {
    if (kIsWeb) {
      return List.from(_webNewsCache);
    }
    final db = await database;
    final rows = await db.query(
      'news_cache',
      orderBy: 'updatedAt DESC',
      limit: 50,
    );
    return rows
        .map(
          (r) => FootballFeedItem(
            id: r['id'] as String,
            title: r['title'] as String,
            subtitle: r['subtitle'] as String,
            imageUrl: r['imageUrl'] as String? ?? '',
            statusShort: r['statusShort'] as String? ?? '',
            utcDate: r['utcDate'] as String?,
            leagueName: r['leagueName'] as String? ?? '',
            stadium: r['stadium'] as String? ?? '',
            referee: r['referee'] as String? ?? '',
            homeName: r['homeName'] as String? ?? '',
            awayName: r['awayName'] as String? ?? '',
            homeLogo: r['homeLogo'] as String? ?? '',
            awayLogo: r['awayLogo'] as String? ?? '',
          ),
        )
        .toList();
  }

  Future<void> clearNewsCache() async {
    if (kIsWeb) {
      _webNewsCache.clear();
      return;
    }
    final db = await database;
    await db.delete('news_cache');
  }

  // ==========================================
  // 4. FIXTURES CACHE OPERATIONS
  // ==========================================
  Future<void> upsertFixtures(int leagueId, List<dynamic> fixtures) async {
    if (kIsWeb) {
      final list = <Map<String, dynamic>>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var f in fixtures) {
        final fixture = f['fixture'] ?? {};
        final teams = f['teams'] ?? {};
        final goals = f['goals'] ?? {};
        final home = teams['home'] ?? {};
        final away = teams['away'] ?? {};
        list.add({
          'id': fixture['id']?.toString() ?? '',
          'league_id': leagueId,
          'league_name': f['league']?['name']?.toString() ?? '',
          'home_name': home['name']?.toString() ?? '',
          'away_name': away['name']?.toString() ?? '',
          'home_logo': home['logo']?.toString() ?? '',
          'away_logo': away['logo']?.toString() ?? '',
          'home_score': goals['home'] is int ? goals['home'] : null,
          'away_score': goals['away'] is int ? goals['away'] : null,
          'status_short': fixture['status']?['short']?.toString() ?? '',
          'utc_date': fixture['date']?.toString() ?? '',
          'venue': fixture['venue']?['name']?.toString() ?? '',
          'referee': fixture['referee']?.toString() ?? '',
          'updated_at': now,
        });
      }
      _webFixturesCache[leagueId] = list;
      return;
    }
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var f in fixtures) {
      final fixture = f['fixture'] ?? {};
      final teams = f['teams'] ?? {};
      final goals = f['goals'] ?? {};
      final home = teams['home'] ?? {};
      final away = teams['away'] ?? {};

      batch.insert(
        'fixtures_cache',
        {
          'id': fixture['id']?.toString() ?? '',
          'league_id': leagueId,
          'league_name': f['league']?['name']?.toString() ?? '',
          'home_name': home['name']?.toString() ?? '',
          'away_name': away['name']?.toString() ?? '',
          'home_logo': home['logo']?.toString() ?? '',
          'away_logo': away['logo']?.toString() ?? '',
          'home_score': goals['home'] is int ? goals['home'] : null,
          'away_score': goals['away'] is int ? goals['away'] : null,
          'status_short': fixture['status']?['short']?.toString() ?? '',
          'utc_date': fixture['date']?.toString() ?? '',
          'venue': fixture['venue']?['name']?.toString() ?? '',
          'referee': fixture['referee']?.toString() ?? '',
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedFixtures(int leagueId) async {
    if (kIsWeb) {
      return List.from(_webFixturesCache[leagueId] ?? []);
    }
    final db = await database;
    return await db.query(
      'fixtures_cache',
      where: 'league_id = ?',
      whereArgs: [leagueId],
      orderBy: 'utc_date ASC',
    );
  }

  // ==========================================
  // 5. STANDINGS CACHE OPERATIONS
  // ==========================================
  Future<void> upsertStandings(int leagueId, List<dynamic> standingsList) async {
    if (kIsWeb) {
      final list = <Map<String, dynamic>>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var s in standingsList) {
        final team = s['team'] ?? {};
        final all = s['all'] ?? {};
        list.add({
          'league_id': leagueId,
          'position': s['rank'] as int? ?? 0,
          'team_name': team['name']?.toString() ?? '',
          'team_logo': team['logo']?.toString() ?? '',
          'played': all['played'] as int? ?? 0,
          'won': all['win'] as int? ?? 0,
          'drawn': all['draw'] as int? ?? 0,
          'lost': all['lose'] as int? ?? 0,
          'goals_diff': s['goalsDiff'] as int? ?? 0,
          'points': s['points'] as int? ?? 0,
          'updated_at': now,
        });
      }
      _webStandingsCache[leagueId] = list;
      return;
    }
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (var s in standingsList) {
      final team = s['team'] ?? {};
      final all = s['all'] ?? {};
      batch.insert(
        'standings_cache',
        {
          'league_id': leagueId,
          'position': s['rank'] as int? ?? 0,
          'team_name': team['name']?.toString() ?? '',
          'team_logo': team['logo']?.toString() ?? '',
          'played': all['played'] as int? ?? 0,
          'won': all['win'] as int? ?? 0,
          'drawn': all['draw'] as int? ?? 0,
          'lost': all['lose'] as int? ?? 0,
          'goals_diff': s['goalsDiff'] as int? ?? 0,
          'points': s['points'] as int? ?? 0,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedStandings(int leagueId) async {
    if (kIsWeb) {
      final list = List<Map<String, dynamic>>.from(_webStandingsCache[leagueId] ?? []);
      list.sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));
      return list;
    }
    final db = await database;
    return await db.query(
      'standings_cache',
      where: 'league_id = ?',
      orderBy: 'position ASC',
    );
  }
}
