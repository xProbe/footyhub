import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/audio_provider.dart';

class MapState {
  final LatLng currentLatLng;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final List<dynamic> placeList;
  final bool isLoading;
  final Map<String, dynamic>? selectedPlace;

  MapState({
    this.currentLatLng = const LatLng(-6.2000, 106.8166),
    this.markers = const {},
    this.circles = const {},
    this.placeList = const [],
    this.isLoading = false,
    this.selectedPlace,
  });

  MapState copyWith({
    LatLng? currentLatLng,
    Set<Marker>? markers,
    Set<Circle>? circles,
    List<dynamic>? placeList,
    bool? isLoading,
    Map<String, dynamic>? selectedPlace,
  }) {
    return MapState(
      currentLatLng: currentLatLng ?? this.currentLatLng,
      markers: markers ?? this.markers,
      circles: circles ?? this.circles,
      placeList: placeList ?? this.placeList,
      isLoading: isLoading ?? this.isLoading,
      selectedPlace: selectedPlace ?? this.selectedPlace,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final Ref _ref;
  GoogleMapController? mapController;

  MapNotifier(this._ref) : super(MapState()) {
    determinePosition();
  }

  String calculateDistance(double endLat, double endLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      state.currentLatLng.latitude,
      state.currentLatLng.longitude,
      endLat,
      endLng,
    );
    return (distanceInMeters / 1000).toStringAsFixed(1);
  }

  void selectPlace(Map<String, dynamic> place, LatLng position) {
    state = state.copyWith(selectedPlace: place);
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15.5,
          tilt: 45,
          bearing: 30,
        ),
      ),
    );
  }

  void recenterOnUser() {
    determinePosition();
  }

  Future<void> determinePosition() async {
    state = state.copyWith(isLoading: true);
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
        throw Exception("Izin lokasi diblokir permanen.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Gagal mendapat sinyal GPS."),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);
      state = state.copyWith(
        currentLatLng: userLatLng,
        circles: {
          Circle(
            circleId: const CircleId("radius_futsal"),
            center: userLatLng,
            radius: 8000,
            fillColor: const Color(0xFF39FF14).withOpacity(0.04), // Accent opacity
            strokeColor: const Color(0xFF39FF14).withOpacity(0.25),
            strokeWidth: 1,
          ),
        },
      );

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 14),
      );

      fetchNearbyPlaces(position.latitude, position.longitude);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Fallback search with default coords
      fetchNearbyPlaces(state.currentLatLng.latitude, state.currentLatLng.longitude);
    }
  }

  void searchPlaces(String query) {
    if (query.trim().isEmpty) {
      fetchNearbyPlaces(state.currentLatLng.latitude, state.currentLatLng.longitude, keyword: "futsal");
    } else {
      fetchNearbyPlaces(state.currentLatLng.latitude, state.currentLatLng.longitude, keyword: query.trim());
    }
  }

  Future<void> fetchNearbyPlaces(double lat, double lng, {String keyword = "futsal"}) async {
    state = state.copyWith(isLoading: true);
    
    if (ApiConstants.googleMapsKey == 'MASUKKAN_GOOGLE_MAPS_KEY_ANDA') {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final dummyPlaces = [
        {
          'name': 'Stadion Futsal Nusantara',
          'vicinity': 'Jl. Sepak Bola No. 10, Jakarta',
          'geometry': {
            'location': {'lat': lat + 0.008, 'lng': lng + 0.008}
          },
          'priceIdr': 120000,
          'place_id': 'dummy_1'
        },
        {
          'name': 'Glow Arena Football',
          'vicinity': 'Kawasan Bisnis Sudirman Blok B9',
          'geometry': {
            'location': {'lat': lat - 0.008, 'lng': lng - 0.008}
          },
          'priceIdr': 180000,
          'place_id': 'dummy_2'
        },
        {
          'name': 'Elite Soccer Center',
          'vicinity': 'Jl. Pemuda Menteng No. 142',
          'geometry': {
            'location': {'lat': lat + 0.004, 'lng': lng - 0.006}
          },
          'priceIdr': 250000,
          'place_id': 'dummy_3'
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
            infoWindow: InfoWindow(
              title: place['name'] as String,
              snippet: "${place['distance']} km",
            ),
            onTap: () {
              selectPlace(place, LatLng(latToko, lngToko));
            },
          ),
        );
      }

      state = state.copyWith(
        placeList: dummyPlaces,
        markers: newMarkers,
        isLoading: false,
      );
      return;
    }

    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=8000&keyword=$keyword&type=gym&key=${ApiConstants.googleMapsKey}";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var results = data['results'] as List? ?? [];
        final Set<Marker> newMarkers = {};

        final placesListFormatted = [];
        for (var place in results) {
          final latToko = place['geometry']['location']['lat'] as double;
          final lngToko = place['geometry']['location']['lng'] as double;
          
          final formattedPlace = {
            'name': place['name']?.toString() ?? 'Lapangan Olahraga',
            'vicinity': place['vicinity']?.toString() ?? 'Alamat dekat lokasi',
            'geometry': {
              'location': {'lat': latToko, 'lng': lngToko}
            },
            'priceIdr': 150000 + ((latToko * 1000).toInt() % 11) * 10000,
            'place_id': place['place_id']?.toString() ?? '$latToko$lngToko',
            'distance': calculateDistance(latToko, lngToko),
          };
          placesListFormatted.add(formattedPlace);

          newMarkers.add(
            Marker(
              markerId: MarkerId(formattedPlace['place_id'] as String),
              position: LatLng(latToko, lngToko),
              infoWindow: InfoWindow(
                title: formattedPlace['name'] as String,
                snippet: "${formattedPlace['distance']} km",
              ),
              onTap: () {
                selectPlace(formattedPlace, LatLng(latToko, lngToko));
              },
            ),
          );
        }

        state = state.copyWith(
          placeList: placesListFormatted,
          markers: newMarkers,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier(ref);
});
