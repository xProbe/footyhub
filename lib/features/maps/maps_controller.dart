import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../routes/app_routes.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapsController extends GetxController {
  var currentLatLng = const LatLng(-6.2000, 106.8166).obs;
  var markers = <Marker>{}.obs;
  var circles = <Circle>{}.obs;
  var polylines = <Polyline>{}.obs;
  var placeList = <dynamic>[].obs;
  var isLoading = false.obs;

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    determinePosition();
  }

  String calculateDistance(double endLat, double endLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentLatLng.value.latitude,
      currentLatLng.value.longitude,
      endLat,
      endLng,
    );
    return (distanceInMeters / 1000).toStringAsFixed(1);
  }

  void openDirections(double lat, double lng) async {
    isLoading.value = true;
    try {
      PolylinePoints polylinePoints = PolylinePoints(apiKey: ApiConstants.googleMapsKey);
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(currentLatLng.value.latitude, currentLatLng.value.longitude),
          destination: PointLatLng(lat, lng),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        List<LatLng> polylineCoordinates = [];
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        polylines.assign(
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ),
        );

        // Adjust bounds
        double minLat = currentLatLng.value.latitude < lat ? currentLatLng.value.latitude : lat;
        double maxLat = currentLatLng.value.latitude > lat ? currentLatLng.value.latitude : lat;
        double minLng = currentLatLng.value.longitude < lng ? currentLatLng.value.longitude : lng;
        double maxLng = currentLatLng.value.longitude > lng ? currentLatLng.value.longitude : lng;

        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );

        mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      } else {
        Get.snackbar("Info", "Rute tidak ditemukan. Mungkin Anda berada dalam mode offline.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menggambar rute: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void recenterOnUser() {
    determinePosition();
  }

  void determinePosition() async {
    isLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("GPS mati. Mohon nyalakan GPS.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Izin lokasi ditolak.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw Exception("Izin lokasi diblokir permanen.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () =>
            throw Exception("Gagal mendapat sinyal GPS."),
      );

      currentLatLng.value = LatLng(position.latitude, position.longitude);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng.value, 14),
      );

      circles.assign(
        Circle(
          circleId: const CircleId("radius_futsal"),
          center: currentLatLng.value,
          radius: 8000,
          fillColor: Colors.red.withOpacity(0.06),
          strokeColor: Colors.red.withOpacity(0.35),
          strokeWidth: 1,
        ),
      );

      fetchNearbyPlaces(position.latitude, position.longitude);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "GPS",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void searchPlaces(String query) {
    if (query.trim().isEmpty) {
      fetchNearbyPlaces(currentLatLng.value.latitude, currentLatLng.value.longitude, keyword: "futsal");
    } else {
      fetchNearbyPlaces(currentLatLng.value.latitude, currentLatLng.value.longitude, keyword: query.trim());
    }
  }

  void fetchNearbyPlaces(double lat, double lng, {String keyword = "futsal"}) async {
    if (ApiConstants.googleMapsKey == 'MASUKKAN_GOOGLE_MAPS_KEY_ANDA') {
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar(
        "Mode Offline",
        "Menampilkan data dummy karena Google Maps API Key belum dikonfigurasi.",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      final dummyPlaces = [
        {
          'name': 'Futsal Arena (Dummy)',
          'vicinity': 'Jl. Dummy Futsal No. 1',
          'geometry': {
            'location': {'lat': lat + 0.01, 'lng': lng + 0.01}
          },
          'place_id': 'dummy_1'
        },
        {
          'name': 'Bintang Futsal (Dummy)',
          'vicinity': 'Jl. Bintang No. 99',
          'geometry': {
            'location': {'lat': lat - 0.01, 'lng': lng - 0.01}
          },
          'place_id': 'dummy_2'
        }
      ];

      final Set<Marker> newMarkers = {};
      for (var place in dummyPlaces) {
        final geometry = place['geometry'] as Map<String, dynamic>;
        final location = geometry['location'] as Map<String, dynamic>;
        final latToko = location['lat'] as double;
        final lngToko = location['lng'] as double;
        place['distance'] = calculateDistance(latToko, lngToko);
        final pid = place['place_id'] as String;

        newMarkers.add(
          Marker(
            markerId: MarkerId(pid),
            position: LatLng(latToko, lngToko),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: place['name'] as String,
              snippet: "${place['distance']} km",
            ),
            onTap: () {
              Get.toNamed(
                Routes.FIELD_DETAIL,
                arguments: {
                  'name': place['name'],
                  'vicinity': place['vicinity'],
                  'lat': latToko,
                  'lng': lngToko,
                  'priceIdr': 150000,
                },
              );
            },
          ),
        );
      }
      placeList.value = dummyPlaces;
      markers.assignAll(newMarkers);
      isLoading.value = false;
      return;
    }

    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=8000&keyword=$keyword&type=gym&key=${ApiConstants.googleMapsKey}";

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] != "OK" && data['status'] != "ZERO_RESULTS") {
          Get.snackbar(
            "Maps API",
            data['error_message']?.toString() ?? data['status'].toString(),
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }

        var results = data['results'] as List? ?? [];
        final Set<Marker> newMarkers = {};

        for (var place in results) {
          final latToko = place['geometry']['location']['lat'];
          final lngToko = place['geometry']['location']['lng'];
          place['distance'] = calculateDistance(latToko, lngToko);
          final pid = place['place_id']?.toString() ?? '$latToko$lngToko';

          newMarkers.add(
            Marker(
              markerId: MarkerId(pid),
              position: LatLng(
                (latToko as num).toDouble(),
                (lngToko as num).toDouble(),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: place['name']?.toString(),
                snippet: "${place['distance']} km",
              ),
              onTap: () {
                Get.toNamed(
                  Routes.FIELD_DETAIL,
                  arguments: {
                    'name': place['name']?.toString() ?? 'Lapangan',
                    'vicinity': place['vicinity']?.toString() ?? '',
                    'lat': latToko,
                    'lng': lngToko,
                    'priceIdr': 150000,
                  },
                );
              },
            ),
          );
        }

        placeList.value = results;
        markers.assignAll(newMarkers);
      } else {
        Get.snackbar(
          "Server",
          "Gagal Places API: ${response.statusCode}",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Jaringan",
        "Periksa koneksi / API key",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
