import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum BadgeType { success, warning, danger, info, neutral }

class PillBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;

  const PillBadge({
    super.key,
    required this.text,
    this.type = BadgeType.neutral,
    this.icon,
  });

  factory PillBadge.fromStatus(String? status) {
    final s = (status ?? '').toUpperCase().trim();
    if (s == 'HADIR' || s == 'APPROVED' || s == 'DISETUJUI') {
      return const PillBadge(text: 'Hadir', type: BadgeType.success, icon: Icons.check_circle_outline);
    } else if (s == 'TERLAMBAT') {
      return const PillBadge(text: 'Terlambat', type: BadgeType.warning, icon: Icons.access_time);
    } else if (s == 'PENDING' || s == 'MENUNGGU') {
      return const PillBadge(text: 'Menunggu', type: BadgeType.warning, icon: Icons.access_time);
    } else if (s == 'ALPA') {
      return const PillBadge(text: 'Alpa', type: BadgeType.danger, icon: Icons.highlight_off);
    } else if (s == 'REJECTED' || s == 'DITOLAK') {
      return const PillBadge(text: 'Ditolak', type: BadgeType.danger, icon: Icons.highlight_off);
    } else if (s == 'SAKIT') {
      return const PillBadge(text: 'Sakit', type: BadgeType.info, icon: Icons.info_outline);
    } else if (s == 'IZIN') {
      return const PillBadge(text: 'Izin', type: BadgeType.info, icon: Icons.info_outline);
    } else if (s == 'CUTI') {
      return const PillBadge(text: 'Cuti', type: BadgeType.info, icon: Icons.info_outline);
    } else if (s == 'BELUM_HADIR' || s == 'BELUM HADIR' || s.isEmpty) {
      return const PillBadge(text: 'Belum Hadir', type: BadgeType.neutral);
    }

    // Ubah format underscore menjadi spasi dengan huruf kapital awal yang rapi
    final cleanWords = s.replaceAll('_', ' ').split(' ').where((w) => w.isNotEmpty).map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return PillBadge(text: cleanWords.isNotEmpty ? cleanWords : 'Belum Hadir', type: BadgeType.neutral);
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successBg;
        fg = AppColors.success;
        border = AppColors.successBorder;
        break;
      case BadgeType.warning:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        border = AppColors.warningBorder;
        break;
      case BadgeType.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.danger;
        border = AppColors.dangerBorder;
        break;
      case BadgeType.info:
        bg = AppColors.infoBg;
        fg = AppColors.info;
        border = AppColors.infoBorder;
        break;
      case BadgeType.neutral:
        bg = AppColors.surfaceSecondary;
        fg = AppColors.textSecondary;
        border = AppColors.border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
