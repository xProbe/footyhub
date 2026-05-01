import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'core/theme/app_colors.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/utils/notification_helper.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await Hive.openBox('gameBox');

  await NotificationHelper.init();
  Get.put(ThemeModeController(), permanent: true);

  runApp(const FootyHubApp());
}

class FootyHubApp extends StatelessWidget {
  const FootyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeModeController theme = Get.find<ThemeModeController>();

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.seaGreen,
        brightness: Brightness.dark,
      ),
    );

    return Obx(
      () => GetMaterialApp(
        title: 'FootyHub',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: theme.themeMode.value,
        initialRoute: Routes.SPLASH,
        getPages: AppPages.routes,
      ),
    );
  }
}
