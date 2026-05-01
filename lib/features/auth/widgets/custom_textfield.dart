import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final VoidCallback? onTogglePassword;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.onTogglePassword,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.tfBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tfBorder, width: 1.33),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(color: AppColors.textDark, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Icon(prefixIcon, color: AppColors.tfIcon, size: 16),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.tfIcon,
                    size: 22,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: AppColors.tfPlaceholder,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
