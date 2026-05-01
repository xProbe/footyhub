import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/football_feed_item.dart';

class NewsDatabase {
  NewsDatabase._();
  static final NewsDatabase instance = NewsDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'footyhub_news.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE news_cache ADD COLUMN leagueName TEXT DEFAULT ""');
          await db.execute('ALTER TABLE news_cache ADD COLUMN stadium TEXT DEFAULT ""');
          await db.execute('ALTER TABLE news_cache ADD COLUMN referee TEXT DEFAULT ""');
          await db.execute('ALTER TABLE news_cache ADD COLUMN homeName TEXT DEFAULT ""');
          await db.execute('ALTER TABLE news_cache ADD COLUMN awayName TEXT DEFAULT ""');
          await db.execute('ALTER TABLE news_cache ADD COLUMN homeLogo TEXT DEFAULT ""');
          await db.execute('ALTER TABLE news_cache ADD COLUMN awayLogo TEXT DEFAULT ""');
        }
      },
    );
  }

  Future<void> upsertItems(List<FootballFeedItem> items) async {
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

  Future<List<FootballFeedItem>> getCached() async {
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

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('news_cache');
  }
}
