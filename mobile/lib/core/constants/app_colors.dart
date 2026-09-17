import 'package:flutter/material.dart';

/// Design tokens warna profesional berstandar Anti-AI-Slop.
/// Menghindari gradien ungu/pink generik; menggunakan palet Deep Slate,
/// Electric Blue, Emerald, Amber, dan Rose dengan kontras tinggi & terkalibrasi.
class AppColors {
  // Brand & Neutrals (Deep Slate)
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF2563EB); // Electric Blue 600
  static const Color accentSoft = Color(0xFFEFF6FF); // Blue 50

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (Off-white bersih)
  static const Color surface = Colors.white;
  static const Color surfaceSecondary = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Slate 100

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Colors.white;

  // Semantic Status Colors (Pill Badge & Indicator)
  // 1. Success / Tepat Waktu (Emerald)
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successBg = Color(0xFFECFDF5); // Emerald 50
  static const Color successBorder = Color(0xFFA7F3D0); // Emerald 200

  // 2. Warning / Terlambat / Pending (Amber)
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningBg = Color(0xFFFFFBEB); // Amber 50
  static const Color warningBorder = Color(0xFFFDE68A); // Amber 200

  // 3. Danger / Alpa / Ditolak (Rose)
  static const Color danger = Color(0xFFE11D48); // Rose 600
  static const Color dangerBg = Color(0xFFFFF1F2); // Rose 50
  static const Color dangerBorder = Color(0xFFFECDD3); // Rose 200

  // 4. Info / Izin / Sakit (Sky)
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoBg = Color(0xFFF0F9FF); // Sky 50
  static const Color infoBorder = Color(0xFFBAE6FD); // Sky 200

  // Card Shadow Halus (Subtle Elevation)
  static List<BoxShadow> get cardShadow => const [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get buttonShadow => const [
    BoxShadow(
      color: Color(0x402563EB),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
