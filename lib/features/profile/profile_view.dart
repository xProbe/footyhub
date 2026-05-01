import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // - Header -
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(color: AppColors.primary),
                ),
                // Avatar Lingkaran
                Positioned(
                  bottom: -50,
                  child: GestureDetector(
                    onTap: controller
                        .pickProfileImage,
                    child: Obx(
                      () => Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.pureWhite,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image:
                              controller
                                  .currentProfileImagePath
                                  .value
                                  .isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(
                                    File(
                                      controller.currentProfileImagePath.value,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: controller.currentProfileImagePath.value.isEmpty
                            ? const Icon(
                                Icons.person_outline_rounded,
                                size: 50,
                                color: AppColors.pureWhite,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -45,
                  right: MediaQuery.of(context).size.width / 2 - 55,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.seaGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // --- NAMA DAN NIM DINAMIS MENGGUNAKAN Obx ---
            Obx(
              () => Text(
                controller.currentName.value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Obx(
              () => Text(
                'Student ID: ${controller.currentNim.value}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.tfPlaceholder,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    Icons.menu_book_rounded,
                    'Academic Profile',
                    AppColors.oceanTeal.withValues(alpha: 0.1),
                    AppColors.oceanTeal,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tfBorder),
                    ),
                    child: Column(
                      children: [
                        _buildProfileRow('Program', 'Informatika'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.tfBorder),
                        ),
                        _buildProfileRow('Faculty', 'Teknik Industri'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.tfBorder),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.tfPlaceholder,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'Active',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    Icons.chat_bubble_outline_rounded,
                    'Saran & kesan TPM',
                    AppColors.dangerRed.withValues(alpha: 0.1),
                    AppColors.dangerRed,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tfBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluasi untuk dosen pengampu',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.tfPlaceholder,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.tfBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.tfBorder),
                          ),
                          child: TextField(
                            controller: controller.testimonialController,
                            maxLines: 5,
                            minLines: 3,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Tuliskan saran dan kesan Anda di sini…',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.tfPlaceholder,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: controller.submitTpmFeedback,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Kirim Evaluasi',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(
                    Icons.settings_outlined,
                    'App Settings',
                    AppColors.seaGreen.withValues(alpha: 0.1),
                    AppColors.seaGreen,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.tfBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.fingerprint_rounded,
                              color: AppColors.tfPlaceholder,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Login Biometric',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Obx(
                          () => Switch(
                            value: controller.isBiometricEnabled.value,
                            onChanged: controller.toggleBiometric,
                            activeThumbColor: AppColors.pureWhite,
                            activeTrackColor: AppColors.seaGreen,
                            inactiveThumbColor: AppColors.tfPlaceholder,
                            inactiveTrackColor: AppColors.tfBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: controller.logout,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.dangerRed,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.tfPlaceholder,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
