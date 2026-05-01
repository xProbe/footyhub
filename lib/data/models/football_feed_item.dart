class FootballFeedItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String statusShort;
  final String? utcDate;
  final String leagueName;
  final String stadium;
  final String referee;
  final String homeName;
  final String awayName;
  final String homeLogo;
  final String awayLogo;

  FootballFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.statusShort,
    this.utcDate,
    this.leagueName = '',
    this.stadium = '',
    this.referee = '',
    this.homeName = '',
    this.awayName = '',
    this.homeLogo = '',
    this.awayLogo = '',
  });

  factory FootballFeedItem.fromFixture(Map<String, dynamic> json) {
    final fixture = json['fixture'] as Map<String, dynamic>? ?? {};
    final teams = json['teams'] as Map<String, dynamic>? ?? {};
    final league = json['league'] as Map<String, dynamic>? ?? {};
    final home = teams['home'] as Map<String, dynamic>? ?? {};
    final away = teams['away'] as Map<String, dynamic>? ?? {};
    final goals = json['goals'] as Map<String, dynamic>? ?? {};

    final homeName = home['name']?.toString() ?? 'Home';
    final awayName = away['name']?.toString() ?? 'Away';
    final homeLogo = home['logo']?.toString() ?? '';
    final awayLogo = away['logo']?.toString() ?? '';
    final logo = (homeLogo.isNotEmpty ? homeLogo : awayLogo);
    final status = fixture['status']?['short']?.toString() ?? 'NS';
    final dateStr = fixture['date']?.toString();
    
    final leagueName = league['name']?.toString() ?? 'Unknown League';
    final stadium = fixture['venue']?['name']?.toString() ?? 'Unknown Stadium';
    final referee = fixture['referee']?.toString() ?? 'Unknown Referee';

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
      leagueName: leagueName,
      stadium: stadium,
      referee: referee,
      homeName: homeName,
      awayName: awayName,
      homeLogo: homeLogo,
      awayLogo: awayLogo,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'statusShort': statusShort,
        'utcDate': utcDate,
        'leagueName': leagueName,
        'stadium': stadium,
        'referee': referee,
        'homeName': homeName,
        'awayName': awayName,
        'homeLogo': homeLogo,
        'awayLogo': awayLogo,
      };

  factory FootballFeedItem.fromMap(Map<String, dynamic> m) {
    return FootballFeedItem(
      id: m['id'] as String,
      title: m['title'] as String,
      subtitle: m['subtitle'] as String,
      imageUrl: m['imageUrl'] as String? ?? '',
      statusShort: m['statusShort'] as String? ?? '',
      utcDate: m['utcDate'] as String?,
      leagueName: m['leagueName'] as String? ?? '',
      stadium: m['stadium'] as String? ?? '',
      referee: m['referee'] as String? ?? '',
      homeName: m['homeName'] as String? ?? '',
      awayName: m['awayName'] as String? ?? '',
      homeLogo: m['homeLogo'] as String? ?? '',
      awayLogo: m['awayLogo'] as String? ?? '',
    );
  }
}
