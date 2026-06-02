import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'core/theme/theme_provider.dart';
import 'core/utils/notification_helper.dart';
import 'data/locals/database_helper.dart';
import 'data/models/football_feed_item.dart';
import 'features/splash/splash_view.dart';
import 'features/auth/login_view.dart';
import 'features/auth/register_view.dart';
import 'features/dashboard/dashboard_view.dart';
import 'features/home/match_detail_view.dart';
import 'features/game/game_view.dart';
import 'features/home/conversion_view.dart';
import 'features/home/chatbot_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  // Initialize unified SQLite database (guarded for non-web)
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }

  // Initialize local notifications helper (guarded for non-web)
  if (!kIsWeb) {
    await NotificationHelper.init();
  }

  runApp(
    const ProviderScope(
      child: FootyHubApp(),
    ),
  );
}

class FootyHubApp extends ConsumerWidget {
  const FootyHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeDataProvider);

    return MaterialApp(
      title: 'FootyHub',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        if (settings.name == '/match-detail') {
          final item = settings.arguments as FootballFeedItem;
          return MaterialPageRoute(
            builder: (context) => MatchDetailView(item: item),
          );
        }
        return null;
      },
      routes: {
        '/splash': (context) => const SplashView(),
        '/auth': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/dashboard': (context) => const DashboardView(),
        '/game': (context) => const GameView(),
        '/conversion': (context) => const ConversionView(),
        '/chatbot': (context) => const ChatbotView(),
      },
    );
  }
}
