import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/storage_util.dart';
import '../../data/locals/database_helper.dart';

enum FavoriteTeam {
  defaultTeam,
  realMadrid,
  barcelona,
  arsenal,
  chelsea,
  liverpool,
  manUnited,
}

extension FavoriteTeamExtension on FavoriteTeam {
  String get code {
    switch (this) {
      case FavoriteTeam.defaultTeam:
        return 'DEFAULT';
      case FavoriteTeam.realMadrid:
        return 'RMD';
      case FavoriteTeam.barcelona:
        return 'BAR';
      case FavoriteTeam.arsenal:
        return 'ARS';
      case FavoriteTeam.chelsea:
        return 'CHE';
      case FavoriteTeam.liverpool:
        return 'LIV';
      case FavoriteTeam.manUnited:
        return 'MUN';
    }
  }

  String get displayName {
    switch (this) {
      case FavoriteTeam.defaultTeam:
        return 'FootyHub Neon';
      case FavoriteTeam.realMadrid:
        return 'Real Madrid';
      case FavoriteTeam.barcelona:
        return 'FC Barcelona';
      case FavoriteTeam.arsenal:
        return 'Arsenal';
      case FavoriteTeam.chelsea:
        return 'Chelsea FC';
      case FavoriteTeam.liverpool:
        return 'Liverpool FC';
      case FavoriteTeam.manUnited:
        return 'Manchester United';
    }
  }

  Color get primaryColor {
    switch (this) {
      case FavoriteTeam.defaultTeam:
        return const Color(0xFF39FF14); // Neon Green
      case FavoriteTeam.realMadrid:
        return const Color(0xFFFFFFFF); // White
      case FavoriteTeam.barcelona:
        return const Color(0xFFA82C44); // Blaugrana Red
      case FavoriteTeam.arsenal:
        return const Color(0xFFEF0107); // Gunners Red
      case FavoriteTeam.chelsea:
        return const Color(0xFF034694); // Chelsea Blue
      case FavoriteTeam.liverpool:
        return const Color(0xFFC8102E); // Liverpool Red
      case FavoriteTeam.manUnited:
        return const Color(0xFFDA291C); // Manchester United Red
    }
  }

  Color get accentColor {
    switch (this) {
      case FavoriteTeam.defaultTeam:
        return const Color(0xFF00E5FF); // Cyan
      case FavoriteTeam.realMadrid:
        return const Color(0xFF00529F); // Madrid Blue
      case FavoriteTeam.barcelona:
        return const Color(0xFF004D98); // Blaugrana Blue
      case FavoriteTeam.arsenal:
        return const Color(0xFFFFFFFF); // White
      case FavoriteTeam.chelsea:
        return const Color(0xFFFFFFFF); // White
      case FavoriteTeam.liverpool:
        return const Color(0xFFF6EB61); // Gold/Yellow
      case FavoriteTeam.manUnited:
        return const Color(0xFFFFE500); // Yellow
    }
  }

  static FavoriteTeam fromCode(String code) {
    return FavoriteTeam.values.firstWhere(
      (e) => e.code == code,
      orElse: () => FavoriteTeam.defaultTeam,
    );
  }
}

class FavoriteTeamNotifier extends StateNotifier<FavoriteTeam> {
  FavoriteTeamNotifier() : super(FavoriteTeam.defaultTeam) {
    _loadFromDatabase();
  }

  Future<void> _loadFromDatabase() async {
    final username = await StorageUtil.getLoggedInUsername();
    if (username != null) {
      final user = await DatabaseHelper.instance.getUser(username);
      if (user != null) {
        final teamCode = user['favorite_team'] as String? ?? 'DEFAULT';
        state = FavoriteTeamExtension.fromCode(teamCode);
      }
    }
  }

  Future<void> setFavoriteTeam(FavoriteTeam team) async {
    state = team;
    final username = await StorageUtil.getLoggedInUsername();
    if (username != null) {
      await DatabaseHelper.instance.updateUserField(username, 'favorite_team', team.code);
    }
  }
}

final favoriteTeamProvider = StateNotifierProvider<FavoriteTeamNotifier, FavoriteTeam>((ref) {
  return FavoriteTeamNotifier();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  const primaryColor = Color(0xFF39FF14); // Neon Green
  const accentColor = Color(0xFF00E5FF); // Cyan

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000), // Pitch Black background
    cardColor: const Color(0xFF0A0A0C), // Carbon Gray cards
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: const Color(0xFF0A0A0C),
      error: const Color(0xFFDC3545),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: GoogleFonts.inter(color: Colors.white70),
      bodyMedium: GoogleFonts.inter(color: Colors.white70),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0A0A0C),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
  );
});

class SensorState {
  final int lux;
  final bool isRealSensor;
  final bool isDimmed;
  final bool isNear;
  final bool isRealProximity;

  SensorState({
    this.lux = 100,
    this.isRealSensor = true,
    this.isDimmed = false,
    this.isNear = false,
    this.isRealProximity = true,
  });

  SensorState copyWith({
    int? lux,
    bool? isRealSensor,
    bool? isDimmed,
    bool? isNear,
    bool? isRealProximity,
  }) {
    return SensorState(
      lux: lux ?? this.lux,
      isRealSensor: isRealSensor ?? this.isRealSensor,
      isDimmed: isDimmed ?? this.isDimmed,
      isNear: isNear ?? this.isNear,
      isRealProximity: isRealProximity ?? this.isRealProximity,
    );
  }
}

class SensorStateNotifier extends StateNotifier<SensorState> {
  SensorStateNotifier() : super(SensorState());

  void setLux(int value) {
    state = state.copyWith(
      lux: value,
      isDimmed: value < 10,
    );
  }

  void setRealSensor(bool enabled) {
    state = state.copyWith(isRealSensor: enabled);
  }

  void setNear(bool near) {
    state = state.copyWith(isNear: near);
  }

  void setRealProximity(bool enabled) {
    state = state.copyWith(isRealProximity: enabled);
  }
}

final sensorStateProvider = StateNotifierProvider<SensorStateNotifier, SensorState>((ref) {
  return SensorStateNotifier();
});

// Ambient Light sensor provider to dim UI (compatibility wrapper)
final ambientDimmedProvider = Provider<bool>((ref) {
  return ref.watch(sensorStateProvider).isDimmed;
});
