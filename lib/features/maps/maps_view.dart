import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'maps_controller.dart';

class MapsView extends StatelessWidget {
  final bool showBack;

  const MapsView({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final MapsController controller = Get.find<MapsController>();

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentLatLng.value,
                zoom: 14,
              ),
              markers: controller.markers.toSet(),
              circles: controller.circles.toSet(),
              polylines: controller.polylines.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (gController) {
                controller.mapController = gController;
                gController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    controller.currentLatLng.value,
                    14,
                  ),
                );
              },
            ),
          ),
          if (showBack)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + (showBack ? 60 : 16),
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari lapangan futsal...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (value) => controller.searchPlaces(value),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: showBack ? 280 : 280,
            child: FloatingActionButton(
              heroTag: 'map_recenter',
              onPressed: controller.recenterOnUser,
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade700,
              child: const Icon(Icons.my_location),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 260,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'Lapangan futsal terdekat',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(
                      () => controller.isLoading.value &&
                              controller.placeList.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: controller.placeList.length,
                              itemBuilder: (context, index) {
                                var toko = controller.placeList[index];
                                var latToko =
                                    toko['geometry']['location']['lat'];
                                var lngToko =
                                    toko['geometry']['location']['lng'];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.sports_soccer,
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      toko['name']?.toString() ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        toko['vicinity']?.toString() ?? ''),
                                    trailing: TextButton(
                                      onPressed: () =>
                                          controller.openDirections(
                                        (latToko as num).toDouble(),
                                        (lngToko as num).toDouble(),
                                      ),
                                      child: const Text('Rute'),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
