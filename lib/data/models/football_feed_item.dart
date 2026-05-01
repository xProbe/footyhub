class FootballFeedItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String statusShort;
  final String? utcDate;

  FootballFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.statusShort,
    this.utcDate,
  });

  factory FootballFeedItem.fromFixture(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>? ?? {};
    final teams = json['teams'] as Map<String, dynamic>? ?? {};
    final home = teams['home'] as Map<String, dynamic>? ?? {};
    final away = teams['away'] as Map<String, dynamic>? ?? {};
    final goals = json['goals'] as Map<String, dynamic>? ?? {};

    final homeName = home['name']?.toString() ?? 'Home';
    final awayName = away['name']?.toString() ?? 'Away';
    final logo = (home['logo'] ?? away['logo'])?.toString() ?? '';
    final status = fixture['status']?['short']?.toString() ?? 'NS';
    final dateStr = fixture['date']?.toString();

    int? hg = goals['home'] is int ? goals['home'] as int : null;
    int? ag = goals['away'] is int ? goals['away'] as int : null;
    final scoreLine = (hg != null && ag != null) ? '$hg — $ag' : 'vs';

    return FootballFeedItem(
      id: fixture['id']?.toString() ?? dateStr ?? homeName + awayName,
      title: '$homeName vs $awayName',
      subtitle: '$scoreLine · $status',
      imageUrl: logo,
      statusShort: status,
      utcDate: dateStr,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'statusShort': statusShort,
        'utcDate': utcDate,
      };

  factory FootballFeedItem.fromMap(Map<String, dynamic> m) {
    return FootballFeedItem(
      id: m['id'] as String,
      title: m['title'] as String,
      subtitle: m['subtitle'] as String,
      imageUrl: m['imageUrl'] as String? ?? '',
      statusShort: m['statusShort'] as String? ?? '',
      utcDate: m['utcDate'] as String?,
    );
  }
}
