import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'widgets/custom_textfield.dart';
import 'auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController nimController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const Icon(Icons.sports_soccer, size: 88, color: AppColors.primary),
              Text(
                'FootyHub',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Daftar akun (backend bcrypt + JWT)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.tfPlaceholder,
                ),
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: nameController,
                hintText: 'Nama lengkap',
                prefixIcon: Icons.person_outline,
              ),
              CustomTextField(
                controller: nimController,
                hintText: 'NIM',
                prefixIcon: Icons.badge_outlined,
              ),
              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
                prefixIcon: Icons.alternate_email,
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
              Obx(
                () => CustomTextField(
                  controller: confirmPasswordController,
                  hintText: 'Konfirmasi password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: authC.isConfirmPasswordHidden.value,
                  onTogglePassword: () =>
                      authC.toggleConfirmPasswordVisibility(),
                ),
              ),
              const SizedBox(height: 18),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authC.isLoading.value
                        ? null
                        : () async {
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              Get.snackbar(
                                'Error',
                                'Konfirmasi password tidak cocok',
                              );
                              return;
                            }
                            bool success = await authC.register(
                              nameController.text,
                              nimController.text,
                              usernameController.text,
                              passwordController.text,
                            );
                            if (success) {
                              Get.offAllNamed(Routes.DASHBOARD);
                              Get.snackbar(
                                'Berhasil',
                                'Akun dibuat dan sesi JWT aktif.',
                              );
                            } else {
                              Get.snackbar('Gagal', authC.errorMessage.value);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authC.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Daftar',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: GoogleFonts.inter(color: AppColors.tfPlaceholder),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      'Login',
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
