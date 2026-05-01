import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // 1. PALETTE (Sesuai Figma Palette)
  // ==========================================
  static const Color deepOceanBlue = Color(0xFF0A5C7A);
  static const Color seaGreen = Color(0xFF2DD4A8);
  static const Color aquaMist = Color(0xFFE8F4F8);
  static const Color oceanTeal = Color(0xFF5A8BA0);
  static const Color coralOrange = Color(0xFFFFA726);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softGray = Color(0xFF8CAEBB);
  static const Color dangerRed = Color(0xFFDC3545);

  // ---> TAMBAHAN WARNA BARU ANDA <---
  static const Color darkNavy = Color(0xFF0B2A46);

  // ==========================================
  // 2. TAMBAHAN DARI HALAMAN HOME / DASHBOARD
  // ==========================================
  static const Color locationRed = Color(0xFFEA4335); // Ikon map
  static const Color inactiveNav = Color(0xFF9CA3AF); // Ikon nav bawah mati
  static const Color shakeCardBg = Color(0xFFE5E7EB); // Latar shake to refresh

  // Warna aksen lingkaran dalam kartu suhu
  static const Color cardAccentDark = Color(0xFF085269);
  static const Color cardAccentLight = Color(0xFF0D7298);

  // ==========================================
  // 3. SEMANTIC / UI SPECIFIC COLORS
  // ==========================================
  static const Color primary = deepOceanBlue;
  static const Color secondary = oceanTeal;
  static const Color tfPlaceholder = softGray;
  static const Color tfIcon = oceanTeal;
  static const Color tfBackground = Color(0xFFF0F7FA);
  static const Color tfBorder = Color(0xFFD1E4ED);
  static const Color textDark = Color(0xFF1A1A1A);

  // ---> TAMBAHAN SEMANTIK UNTUK GAME <---
  static const Color gameScoreText = darkNavy;
}
