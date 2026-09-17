import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/pill_badge.dart';
import '../../attendance/presentation/selfie_attendance_page.dart';
import '../../correction/presentation/correction_page.dart';
import '../../schedule/presentation/schedule_calendar_page.dart';
import '../../statistics/presentation/statistics_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _todayStatus;
  Map<String, dynamic>? _statsSummary;
  bool _isLoading = true;

  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadDashboardData();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final user = await SessionManager.getUser();
    final todayRes = await ApiClient.get(ApiConstants.todayStatus);
    final statsRes = await ApiClient.get(ApiConstants.statsSummary);

    setState(() {
      _isLoading = false;
      _user = user;
      if (todayRes['success'] == true) {
        _todayStatus = todayRes['data'];
      }
      if (statsRes['success'] == true) {
        _statsSummary = statsRes['data'];
      }
    });
  }

  Future<void> _openSelfie(AttendanceType type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfieAttendancePage(type: type),
      ),
    );

    if (result == true) {
      _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckedIn = _todayStatus?['hasCheckedIn'] ?? false;
    final hasCheckedOut = _todayStatus?['hasCheckedOut'] ?? false;
    final checkInTime = _todayStatus?['checkInTime'];
    final checkOutTime = _todayStatus?['checkOutTime'];
    final statusText = _todayStatus?['status'] ?? 'BELUM_HADIR';

    final userName = _user?['name'] ?? 'Pengguna';
    final userDept = _user?['department_name'] ?? 'Pegawai';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading && _todayStatus == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Profil Pengguna & Jam Real-Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Halo, $userName', style: AppTypography.titleMedium),
                            Text(userDept, style: AppTypography.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    // Indikator Jam Live
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.formatTime(_now).split(' ')[0],
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Card Status Kehadiran Hari Ini
                CardContainer(
                  color: AppColors.primary,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormatter.formatFullDate(_now),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          PillBadge.fromStatus(statusText),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Jam Masuk & Pulang
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Presensi Masuk', style: TextStyle(color: Colors.white60, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatter.formatShortTime(checkInTime),
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 36, width: 1, color: Colors.white24),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Presensi Pulang', style: TextStyle(color: Colors.white60, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatter.formatShortTime(checkOutTime),
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tombol Aksi Swafoto
                      Row(
                        children: [
                          // Tombol Masuk
                          Expanded(
                            child: CustomButton(
                              text: hasCheckedIn ? 'Sudah Masuk' : 'Presensi Masuk',
                              variant: hasCheckedIn ? ButtonVariant.secondary : ButtonVariant.primary,
                              icon: Icons.camera_front_outlined,
                              onPressed: hasCheckedIn ? null : () => _openSelfie(AttendanceType.checkIn),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Tombol Pulang
                          Expanded(
                            child: CustomButton(
                              text: hasCheckedOut ? 'Sudah Pulang' : 'Presensi Pulang',
                              variant: ButtonVariant.danger,
                              icon: Icons.logout_rounded,
                              onPressed: (!hasCheckedIn || hasCheckedOut) ? null : () => _openSelfie(AttendanceType.checkOut),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Akses Cepat Sub-Layar (3 Menu Sub-Screen)
                Row(
                  children: [
                    _buildSubMenuButton(
                      'Jadwal Kerja',
                      Icons.calendar_month_outlined,
                      AppColors.accent,
                      AppColors.accentSoft,
                      () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ScheduleCalendarPage())),
                    ),
                    const SizedBox(width: 10),
                    _buildSubMenuButton(
                      'Statistik',
                      Icons.insights_rounded,
                      AppColors.success,
                      AppColors.successBg,
                      () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const StatisticsPage())),
                    ),
                    const SizedBox(width: 10),
                    _buildSubMenuButton(
                      'Bantuan & Koreksi',
                      Icons.support_agent_rounded,
                      AppColors.warning,
                      AppColors.warningBg,
                      () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CorrectionPage())),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 4. Ringkasan Cepat Kehadiran Bulan Ini
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Performa Bulan Ini', style: AppTypography.titleMedium),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const StatisticsPage())),
                      child: const Text('Lihat Detail', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildMiniStatCard('Tepat Waktu', '${_statsSummary?['ontime'] ?? 18}', AppColors.success, AppColors.successBg)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStatCard('Terlambat', '${_statsSummary?['late'] ?? 2}', AppColors.warning, AppColors.warningBg)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStatCard('Izin/Sakit', '${_statsSummary?['leave'] ?? 1}', AppColors.info, AppColors.infoBg)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStatCard('Alpa', '${_statsSummary?['alpha'] ?? 1}', AppColors.danger, AppColors.dangerBg)),
                  ],
                ),

                const SizedBox(height: 22),

                // 5. Banner Pengumuman Resmi
                Text('Pengumuman Instansi', style: AppTypography.titleMedium),
                const SizedBox(height: 10),
                CardContainer(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.campaign_outlined, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemberlakuan Sistem Presensi Swafoto',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Presensi wajib menggunakan swafoto kamera depan dengan pencahayaan jelas. Waktu toleransi keterlambatan adalah 15 menit.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuButton(String label, IconData icon, Color iconColor, Color bgColor, VoidCallback onTap) {
    return Expanded(
      child: CardContainer(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(String label, String value, Color color, Color bgColor) {
    return CardContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
