import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../home/home_view.dart';
import '../home/conversion_view.dart';
import '../maps/maps_view.dart';
import '../pundit/pundit_view.dart';
import '../profile/profile_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static const _labels = ['Beranda', 'Konversi', 'Peta', 'Pundit', 'Akun'];

  @override
  Widget build(BuildContext context) {
    final DashboardController dash = Get.find<DashboardController>();

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => IndexedStack(
              index: dash.tabIndex.value,
              children: const [
                HomeView(),
                ConversionView(isFromDashboard: true),
                MapsView(showBack: false),
                PunditView(),
                ProfileView(),
              ],
            ),
          ),
          Obx(
            () => dash.isProximityNear.value
                ? Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: Icon(Icons.screen_lock_portrait, color: Colors.white24, size: 100),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: dash.tabIndex.value,
          onDestinationSelected: dash.changeTabIndex,
          destinations: [
            for (var i = 0; i < _labels.length; i++)
              NavigationDestination(
                icon: Icon(_iconFor(i, false)),
                selectedIcon: Icon(_iconFor(i, true)),
                label: _labels[i],
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(int i, bool sel) {
    switch (i) {
      case 0:
        return sel ? Icons.home : Icons.home_outlined;
      case 1:
        return sel ? Icons.calculate : Icons.calculate_outlined;
      case 2:
        return sel ? Icons.map : Icons.map_outlined;
      case 3:
        return sel ? Icons.chat : Icons.chat_outlined;
      default:
        return sel ? Icons.person : Icons.person_outline;
    }
  }
}
