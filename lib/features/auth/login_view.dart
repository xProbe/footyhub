import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'widgets/custom_textfield.dart';
import 'auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();

    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.sports_soccer, size: 100, color: AppColors.primary),
              Text(
                'FootyHub',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Berita bola · live score · lapangan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
                prefixIcon: Icons.person_outline,
              ),
              Obx(
                () => CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: authC.isPasswordHidden.value,
                  onTogglePassword: () => authC.togglePasswordVisibility(),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authC.isLoading.value
                        ? null
                        : () async {
                            bool success = await authC.login(
                              usernameController.text,
                              passwordController.text,
                            );
                            if (success) {
                              Get.offAllNamed(Routes.DASHBOARD);
                            } else {
                              Get.snackbar(
                                'Login gagal',
                                authC.errorMessage.value,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: authC.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Login',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: AppColors.tfBorder, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'atau',
                      style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: AppColors.tfBorder, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 64,
                width: 64,
                decoration: const BoxDecoration(
                  color: AppColors.tfBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.fingerprint,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  onPressed: () async {
                    bool success = await authC.loginWithBiometric();
                    if (success) {
                      Get.offAllNamed(Routes.DASHBOARD);
                    } else if (authC.errorMessage.value.isNotEmpty) {
                      Get.snackbar(
                        'Biometrik',
                        authC.errorMessage.value,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(24),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.REGISTER),
                    child: Text(
                      'Daftar',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
