import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'map_providers.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../core/utils/audio_provider.dart';
import '../../data/services/exchange_rate_service.dart';

class MapsView extends ConsumerStatefulWidget {
  final bool showBack;

  const MapsView({super.key, this.showBack = true});

  @override
  ConsumerState<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends ConsumerState<MapsView> {
  final TextEditingController _searchController = TextEditingController();

  // Dark Map Style JSON Configuration
  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#0d0d11"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#8f9cae"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#0d0d11"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#181824"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#29293d"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#050508"}]
    }
  ]
  ''';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final mapNotifier = ref.read(mapProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final isAmbientDimmed = ref.watch(ambientDimmedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Google Map View
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mapState.currentLatLng,
              zoom: 14,
            ),
            markers: mapState.markers,
            circles: mapState.circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              mapNotifier.mapController = controller;
              controller.setMapStyle(_darkMapStyle);
            },
          ),

          // 2. Ambient Light Sensor Contrast Reducer Overlay
          if (isAmbientDimmed)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.40),
                ),
              ),
            ),

          // 2.5 Light Sensor Dimming Indicator Banner
          if (isAmbientDimmed)
            Positioned(
              top: MediaQuery.paddingOf(context).top + (widget.showBack ? 124 : 80),
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => _showSensorInfoDialog(context),
                child: GlassCard(
                  opacity: 0.2,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.nightlight_round, color: Color(0xFF39FF14), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'SENSOR CAHAYA: MODE MALAM AKTIF (<10 LUX)',
                        style: GoogleFonts.orbitron(
                          color: const Color(0xFF39FF14),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF39FF14), size: 12),
                    ],
                  ),
                ),
              ),
            ),

          // 3. Search Bar Area
          Positioned(
            top: MediaQuery.paddingOf(context).top + (widget.showBack ? 60 : 16),
            left: 16,
            right: 16,
            child: Row(
              children: [
                if (widget.showBack)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF0A0A0C),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0C).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari lapangan futsal terdekat…',
                        hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (val) => mapNotifier.searchPlaces(val),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Loading States Shimmer
          if (mapState.isLoading)
            Positioned(
              left: 20,
              right: 20,
              bottom: 120,
              child: Shimmer.fromColors(
                baseColor: const Color(0xFF0A0A0C),
                highlightColor: const Color(0xFF141418),
                child: GlassCard(
                  opacity: 0.1,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 140, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 200, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

          // 4.8 Sensor Info Floating Action Button
          Positioned(
            right: 16,
            bottom: mapState.selectedPlace != null ? 365 : 185,
            child: FloatingActionButton(
              heroTag: 'sensor_info_btn',
              backgroundColor: const Color(0xFF0A0A0C),
              foregroundColor: colorScheme.primary,
              shape: const CircleBorder(),
              onPressed: () {
                _showSensorInfoDialog(context);
              },
              child: const Icon(Icons.sensors_rounded),
            ),
          ),

          // 5. My Location Centering Floating Action Button
          Positioned(
            right: 16,
            bottom: mapState.selectedPlace != null ? 300 : 120,
            child: FloatingActionButton(
              heroTag: 'recenter_my_loc',
              backgroundColor: const Color(0xFF0A0A0C),
              foregroundColor: colorScheme.primary,
              shape: const CircleBorder(),
              onPressed: mapNotifier.recenterOnUser,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // 6. Interactive Bottom Sheet for Pitch Details
          if (mapState.selectedPlace != null)
            _buildDraggableSheet(context, mapState.selectedPlace!),
        ],
      ),
    );
  }

  void _showSensorInfoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final sensorState = ref.watch(sensorStateProvider);
            final colorScheme = Theme.of(context).colorScheme;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.sensors_rounded, color: colorScheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'DASHBOARD SENSOR HARDWARE',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FootyHub terintegrasi langsung dengan sensor fisik perangkat Anda untuk keamanan dan kenyamanan.',
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  // 1. Light Sensor Row
                  _buildSensorInfoItem(
                    context: context,
                    icon: Icons.light_mode_rounded,
                    title: 'Sensor Cahaya (Ambient Light)',
                    subtitle: 'Auto-dimming peta di kegelapan (<10 Lux)',
                    value: '${sensorState.lux} Lux',
                    valueColor: sensorState.isDimmed ? colorScheme.primary : Colors.white70,
                    statusText: sensorState.isDimmed ? 'MODE REDUP AKTIF' : 'NORMAL',
                    statusColor: sensorState.isDimmed ? colorScheme.primary : Colors.white38,
                    description: 'Membaca tingkat cahaya sekitar. Jika ruangan gelap (lux < 10), kontras peta otomatis diturunkan untuk melindungi mata dari kelelahan (Eye Care).',
                  ),
                  const Divider(color: Colors.white10, height: 32),

                  // 2. Proximity Sensor Row
                  _buildSensorInfoItem(
                    context: context,
                    icon: Icons.phonelink_erase_rounded,
                    title: 'Sensor Kedekatan (Proximity)',
                    subtitle: 'Pocket Protection Mode (kunci saku)',
                    value: sensorState.isNear ? 'TERTUTUP' : 'JAUH',
                    valueColor: sensorState.isNear ? Colors.redAccent : Colors.white70,
                    statusText: sensorState.isNear ? 'TERKUNCI' : 'AKTIF',
                    statusColor: sensorState.isNear ? Colors.redAccent : Colors.white38,
                    description: 'Mencegah ketukan tidak sengaja saat ponsel diletakkan di saku celana atau tas dengan mengunci layar sementara.',
                  ),
                  const Divider(color: Colors.white10, height: 32),

                  // 3. Accelerometer Row
                  _buildSensorInfoItem(
                    context: context,
                    icon: Icons.edgesensor_high_rounded,
                    title: 'Sensor Akselerometer (G-Force)',
                    subtitle: 'Deteksi goyangan (Shake Device)',
                    value: 'AKTIF',
                    valueColor: colorScheme.primary,
                    statusText: 'SINKRON',
                    statusColor: Colors.white38,
                    description: 'Mendeteksi hentakan/goyangan perangkat. Goyangkan ponsel Anda untuk memuat ulang data atau memicu efek suara tendangan bola.',
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'TUTUP DASHBOARD',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSensorInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color valueColor,
    required String statusText,
    required Color statusColor,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white60, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            description,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white38, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableSheet(BuildContext context, Map<String, dynamic> place) {
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.20,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return GlassCard(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.12))),
          color: Colors.black,
          opacity: 0.70,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: _PlaceDetailContent(place: place),
          ),
        );
      },
    );
  }
}

class _PlaceDetailContent extends ConsumerStatefulWidget {
  final Map<String, dynamic> place;

  const _PlaceDetailContent({required this.place});

  @override
  ConsumerState<_PlaceDetailContent> createState() => _PlaceDetailContentState();
}

class _PlaceDetailContentState extends ConsumerState<_PlaceDetailContent> {
  String _selectedCurrency = 'USD';
  Map<String, double>? _usdRates;
  bool _isLoadingRates = true;

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  @override
  void didUpdateWidget(covariant _PlaceDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place['place_id'] != widget.place['place_id']) {
      _loadExchangeRates();
    }
  }

  Future<void> _loadExchangeRates() async {
    setState(() => _isLoadingRates = true);
    final r = await ExchangeRateService.ratesFromUsdBase();
    if (mounted) {
      setState(() {
        _usdRates = r;
        _isLoadingRates = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priceIdr = (widget.place['priceIdr'] as num?)?.toDouble() ?? 150000.0;

    String convertedLabel = '—';
    if (_usdRates != null) {
      final converted = ExchangeRateService.idrToTarget(
        idrAmount: priceIdr,
        target: _selectedCurrency,
        usdRates: _usdRates!,
      );
      if (converted != null) {
        final symbol = switch (_selectedCurrency) {
          'USD' => '\$',
          'EUR' => '€',
          'GBP' => '£',
          _ => '',
        };
        convertedLabel = '$symbol ${converted.toStringAsFixed(2)}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag Indicator bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.place['name'] ?? 'Nama Lapangan',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.place['distance'] ?? "0.0"} km',
                style: GoogleFonts.orbitron(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.place['vicinity'] ?? 'Detail alamat',
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga Sewa (per jam)',
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${NumberFormat.decimalPattern().format(priceIdr)}',
                  style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            // Currency Converter selector dropdown
            _isLoadingRates
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox.shrink(),
                      dropdownColor: const Color(0xFF0A0A0C),
                      style: GoogleFonts.orbitron(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCurrency = val);
                      },
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        if (!_isLoadingRates)
          Text(
            'Konversi: $convertedLabel',
            style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.secondary),
          ),
        const SizedBox(height: 24),

        // Play Sound ball kick on Book button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              // Play ball kick low-latency sound
              ref.read(audioFeedbackProvider).playKickSound();
              
              // Mock success dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF0A0A0C),
                  title: Text('Booking Berhasil', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                  content: Text(
                    'Anda telah berhasil menyewa ${widget.place['name']}. Silakan cek struk di lokasi.',
                    style: GoogleFonts.inter(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      child: Text('OK', style: TextStyle(color: colorScheme.primary)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Sewa Lapangan Sekarang',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
