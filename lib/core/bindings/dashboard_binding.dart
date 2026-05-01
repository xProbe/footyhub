import 'package:get/get.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/home/home_controller.dart';
import '../../features/schedule/schedule_controller.dart';
import '../../features/maps/maps_controller.dart';
import '../../features/pundit/pundit_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    Get.lazyPut<MapsController>(() => MapsController());
    Get.lazyPut<PunditController>(() => PunditController());
  }
}
