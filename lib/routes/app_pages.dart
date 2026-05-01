import 'package:get/get.dart';

import 'app_routes.dart';

import '../core/bindings/auth_binding.dart';
import '../core/bindings/dashboard_binding.dart';

import '../features/auth/login_view.dart';
import '../features/auth/register_view.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/game/game_view.dart';
import '../features/maps/maps_view.dart';
import '../features/splash/splash_view.dart';
import '../features/fields/field_detail_view.dart';
import '../features/home/match_detail_view.dart';
import '../features/home/conversion_view.dart';

import '../features/game/game_controller.dart';
import '../features/maps/maps_controller.dart';
import '../features/fields/field_detail_controller.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.GAME,
      page: () => const GameView(),
      binding: BindingsBuilder(() {
        Get.put(GameController());
      }),
    ),
    GetPage(
      name: Routes.MAPS,
      page: () => const MapsView(showBack: true),
      binding: BindingsBuilder(() {
        Get.put(MapsController());
      }),
    ),
    GetPage(
      name: Routes.FIELD_DETAIL,
      page: () => const FieldDetailView(),
      binding: BindingsBuilder(() {
        Get.put(FieldDetailController());
      }),
    ),
    GetPage(
      name: Routes.MATCH_DETAIL,
      page: () => MatchDetailView(item: Get.arguments),
    ),
    GetPage(
      name: Routes.CONVERSION,
      page: () => const ConversionView(),
    ),
  ];
}
