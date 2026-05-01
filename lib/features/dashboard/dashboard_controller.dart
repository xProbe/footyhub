import 'package:get/get.dart';

class DashboardController extends GetxController {
  // 0 Home, 1 Schedule, 2 Map, 3 Pundit, 4 Account (profil + TPM + logout)
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
