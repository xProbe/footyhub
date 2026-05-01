import 'package:get/get.dart';
import '../../features/auth/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    // Get.lazyPut membuat controller HANYA saat halamannya dibuka, menghemat RAM
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
