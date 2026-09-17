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
    final s = (status ?? '').toUpperCase();
    if (s == 'HADIR' || s == 'APPROVED' || s == 'DISETUJUI') {
      return PillBadge(text: status ?? 'Hadir', type: BadgeType.success, icon: Icons.check_circle_outline);
    } else if (s == 'TERLAMBAT' || s == 'PENDING' || s == 'MENUNGGU') {
      return PillBadge(text: status ?? 'Terlambat', type: BadgeType.warning, icon: Icons.access_time);
    } else if (s == 'ALPA' || s == 'REJECTED' || s == 'DITOLAK') {
      return PillBadge(text: status ?? 'Ditolak', type: BadgeType.danger, icon: Icons.highlight_off);
    } else if (s == 'IZIN' || s == 'SAKIT' || s == 'CUTI') {
      return PillBadge(text: status ?? 'Izin', type: BadgeType.info, icon: Icons.info_outline);
    }
    return PillBadge(text: status ?? 'Belum Hadir', type: BadgeType.neutral);
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
