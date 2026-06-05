import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/widgets/glass_widgets.dart';
import '../../core/theme/theme_provider.dart';
import '../auth/auth_provider.dart';
import 'profile_providers.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);
    
    final colorScheme = Theme.of(context).colorScheme;

    // Load initial feedback value once loaded
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.testimonial.isNotEmpty && _feedbackController.text.isEmpty) {
        _feedbackController.text = next.testimonial;
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Banner Stack
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary.withOpacity(0.8), Colors.black],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Profile Avatar Circular Indicator
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: () async {
                      final ok = await profileNotifier.pickProfileImage();
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
                        );
                      }
                    },
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0C),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: 12,
                          ),
                        ],
                        image: profileState.profileImagePath.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(profileState.profileImagePath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profileState.profileImagePath.isEmpty
                          ? const Icon(
                              Icons.person_outline_rounded,
                              size: 50,
                              color: Colors.white60,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // 2. User name & NIM
            Text(
              profileState.name.isNotEmpty ? profileState.name : 'Memuat...',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NIM: ${profileState.nim}',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                color: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                  // Academic Profile Info
                  _buildSectionHeader(Icons.menu_book_rounded, 'PROFIL AKADEMIS', colorScheme.primary),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRow('Program Studi', 'Informatika'),
                        const Divider(color: Colors.white10, height: 20),
                        _buildRow('Fakultas', 'Fakultas Teknik Industri'),
                        const Divider(color: Colors.white10, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status Akademis', style: TextStyle(color: Colors.white60, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Text(
                                'AKTIF',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Testimonial Saran / Kesan
                  _buildSectionHeader(Icons.chat_bubble_outline_rounded, 'SARAN & KESAN TPM', colorScheme.primary),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Evaluasi Kuliah Teknologi & Pemrograman Mobile:',
                          style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _feedbackController,
                          maxLines: 4,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Tuliskan saran & kesan kuliah di sini…',
                            hintStyle: GoogleFonts.inter(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () async {
                            await profileNotifier.submitTpmFeedback(_feedbackController.text);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Saran & Kesan disimpan ke SQLite.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Simpan Evaluasi', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Biometrics Toggle
                  _buildSectionHeader(Icons.settings_outlined, 'PENGATURAN KEAMANAN', colorScheme.primary),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fingerprint_rounded, color: Colors.white60),
                            const SizedBox(width: 12),
                            Text('Login Biometrik', style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                        Switch(
                          value: profileState.isBiometricEnabled,
                          activeColor: colorScheme.primary,
                          onChanged: (val) async {
                            final success = await profileNotifier.toggleBiometric(val);
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Gagal merubah pengaturan biometrik.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sensors Settings & Simulation
                  _buildSectionHeader(Icons.sensors_rounded, 'PENGATURAN & SIMULASI SENSOR', colorScheme.primary),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final sensorState = ref.watch(sensorStateProvider);
                        final sensorNotifier = ref.read(sensorStateProvider.notifier);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Info
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Sensor berjalan otomatis secara REALTIME pada ponsel fisik. Mode simulasi hanya bantuan info untuk menguji fitur pada emulator/web.',
                                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white60, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 24),

                            // Ambient Light Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.light_mode_rounded, color: Colors.white70, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sensor Cahaya (Ambient Light)',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: sensorState.isRealSensor ? Colors.green.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: sensorState.isRealSensor ? Colors.green : Colors.amber, width: 0.5),
                                      ),
                                      child: Text(
                                        sensorState.isRealSensor ? 'REALTIME' : 'SIMULASI',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: sensorState.isRealSensor ? Colors.green : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Fungsi Asli: Mendeteksi kegelapan sekitar. Jika intensitas cahaya < 10 Lux, peta Lapangan otomatis meredup untuk melindungi mata dari kelelahan (Mode Malam/Eye-Care).',
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white38, height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mode Simulasi Manual',
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                                    ),
                                    Switch(
                                      value: !sensorState.isRealSensor,
                                      activeColor: colorScheme.primary,
                                      onChanged: (val) {
                                        sensorNotifier.setRealSensor(!val);
                                      },
                                    ),
                                  ],
                                ),
                                if (!sensorState.isRealSensor) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Simulasi Cahaya: ${sensorState.lux} Lux',
                                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        sensorState.isDimmed ? '(Mode Malam Aktif)' : '(Normal)',
                                        style: TextStyle(fontSize: 11, color: sensorState.isDimmed ? colorScheme.primary : Colors.white38),
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    value: sensorState.lux.toDouble(),
                                    min: 0.0,
                                    max: 200.0,
                                    activeColor: colorScheme.primary,
                                    inactiveColor: Colors.white10,
                                    onChanged: (val) {
                                      sensorNotifier.setLux(val.round());
                                    },
                                  ),
                                ] else ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pembacaan Fisik: ${sensorState.lux} Lux ${sensorState.isDimmed ? "(Redup Aktif)" : ""}',
                                    style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 24),

                            // Proximity Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.phonelink_erase_rounded, color: Colors.white70, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sensor Kedekatan (Proximity)',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: sensorState.isRealProximity ? Colors.green.withOpacity(0.12) : Colors.amber.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: sensorState.isRealProximity ? Colors.green : Colors.amber, width: 0.5),
                                      ),
                                      child: Text(
                                        sensorState.isRealProximity ? 'REALTIME' : 'SIMULASI',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: sensorState.isRealProximity ? Colors.green : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Fungsi Asli: Mendeteksi saku celana/tas. Mengunci layar otomatis (Pocket Protection Mode) untuk mencegah penekanan tombol/sentuhan tidak sengaja.',
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white38, height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Mode Simulasi Manual',
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                                    ),
                                    Switch(
                                      value: !sensorState.isRealProximity,
                                      activeColor: colorScheme.primary,
                                      onChanged: (val) {
                                        sensorNotifier.setRealProximity(!val);
                                      },
                                    ),
                                  ],
                                ),
                                if (!sensorState.isRealProximity) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      sensorNotifier.setNear(!sensorState.isNear);
                                    },
                                    icon: Icon(
                                      sensorState.isNear ? Icons.phonelink_ring_rounded : Icons.phonelink_lock_rounded,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      sensorState.isNear ? 'SIMULASIKAN JAUH (BUKA LAYAR)' : 'SIMULASIKAN DEKAT (KUNCI SAKU)',
                                      style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.black),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: sensorState.isNear ? colorScheme.primary : Colors.white70,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pembacaan Fisik: ${sensorState.isNear ? "DEKAT (TERKUNCI)" : "JAUH (NORMAL)"}',
                                    style: GoogleFonts.orbitron(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 24),

                            // Accelerometer Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.edgesensor_high_rounded, color: Colors.white70, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sensor Akselerometer (G-Force)',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.green, width: 0.5),
                                      ),
                                      child: Text(
                                        'REALTIME',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Fungsi Asli: Mendeteksi goyangan (shake) fisik pada perangkat Anda untuk memicu pemuatan ulang (refresh) otomatis atau efek getaran suara.',
                                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white38, height: 1.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Status Fisik: AKTIF & SINKRON',
                                  style: GoogleFonts.orbitron(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: Text(
                      'LOGOUT',
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.12),
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1.0),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
