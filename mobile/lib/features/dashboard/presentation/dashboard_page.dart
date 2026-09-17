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
import '../../leave/presentation/leave_page.dart';
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
  Map<String, dynamic>? _schedule;
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
    final scheduleRes = await ApiClient.get(ApiConstants.schedule);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _user = user;
        if (todayRes['success'] == true) {
          _todayStatus = todayRes['data'];
        }
        if (statsRes['success'] == true) {
          _statsSummary = statsRes['data'];
        }
        if (scheduleRes['success'] == true && scheduleRes['schedule'] != null) {
          _schedule = scheduleRes['schedule'];
        }
      });
    }
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
    final rawStatus = _todayStatus?['status'] ?? 'Belum Hadir';
    final statusText = rawStatus.toString().replaceAll('_', ' ');

    final userName = _user?['name'] ?? 'Pengguna';
    final userDept = _user?['department_name'] ?? 'Pegawai';
    final shiftName = _schedule?['name'] ?? 'Shift Reguler';
    final shiftHours = _schedule != null
        ? '${_schedule!['check_in_time']?.toString().substring(0, 5)} - ${_schedule!['check_out_time']?.toString().substring(0, 5)}'
        : '08:00 - 17:00';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading && _todayStatus == null
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: AppColors.accent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header Profil & Jam Server Live
                      _buildHeader(userName, userDept),

                      const SizedBox(height: 20),

                      // 2. Hero Card: Presensi Swafoto Hari Ini
                      _buildHeroAttendanceCard(
                        hasCheckedIn: hasCheckedIn,
                        hasCheckedOut: hasCheckedOut,
                        checkInTime: checkInTime,
                        checkOutTime: checkOutTime,
                        statusText: statusText,
                        shiftName: shiftName,
                        shiftHours: shiftHours,
                      ),

                      const SizedBox(height: 24),

                      // 3. Akses Cepat Menu (Quick Navigation Grid)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Aksi & Layanan Cepat', style: AppTypography.titleMedium),
                          const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionGrid(),

                      const SizedBox(height: 24),

                      // 4. Ringkasan Performa Bulan Ini
                      _buildMonthlyPerformanceSection(),

                      const SizedBox(height: 24),

                      // 5. Kartu Informasi & Kebijakan Instansi
                      _buildPolicyCard(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // --- Sub-Widgets Header & Komponen ---

  Widget _buildHeader(String userName, String userDept) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $userName',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userDept,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Indikator Waktu Real-Time
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                DateFormatter.formatTime(_now).split(' ')[0],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAttendanceCard({
    required bool hasCheckedIn,
    required bool hasCheckedOut,
    required String? checkInTime,
    required String? checkOutTime,
    required String statusText,
    required String shiftName,
    required String shiftHours,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Tanggal Hari Ini & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note_rounded, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatFullDate(_now),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              PillBadge.fromStatus(statusText),
            ],
          ),

          const SizedBox(height: 16),

          // Jam Digital Besar & Shift Kerja
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatTime(_now).split(' ')[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Waktu Server Presensi (WIB)',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(
                      shiftHours,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Dua Panel Status: Presensi Masuk vs Pulang
          Row(
            children: [
              Expanded(
                child: _buildAttendanceSlot(
                  title: 'Presensi Masuk',
                  timeStr: checkInTime != null ? DateFormatter.formatShortTime(checkInTime) : '--:--',
                  isCompleted: hasCheckedIn,
                  icon: Icons.login_rounded,
                  activeColor: AppColors.success,
                  subLabel: hasCheckedIn ? 'Tercatat valid' : 'Shift: 08:00 WIB',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceSlot(
                  title: 'Presensi Pulang',
                  timeStr: checkOutTime != null ? DateFormatter.formatShortTime(checkOutTime) : '--:--',
                  isCompleted: hasCheckedOut,
                  icon: Icons.logout_rounded,
                  activeColor: AppColors.accent,
                  subLabel: hasCheckedOut
                      ? 'Tercatat valid'
                      : (hasCheckedIn ? 'Mulai 17:00 WIB' : 'Belum masuk'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Tombol Tindakan Kontekstual (Smart Action)
          if (!hasCheckedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomButton(
                  text: 'Ambil Swafoto Masuk',
                  icon: Icons.camera_front_outlined,
                  variant: ButtonVariant.primary,
                  onPressed: () => _openSelfie(AttendanceType.checkIn),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '📸 Swafoto kamera depan langsung • Validasi otomatis server',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ],
            )
          else if (hasCheckedIn && !hasCheckedOut)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomButton(
                  text: 'Ambil Swafoto Pulang',
                  icon: Icons.logout_rounded,
                  variant: ButtonVariant.danger,
                  onPressed: () => _openSelfie(AttendanceType.checkOut),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '🟢 Masuk tercatat pukul ${DateFormatter.formatShortTime(checkInTime)} • Ketuk untuk pulang',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Presensi Hari Ini Lengkap & Valid',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSlot({
    required String title,
    required String timeStr,
    required bool isCompleted,
    required IconData icon,
    required Color activeColor,
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? activeColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                isCompleted ? Icons.check_circle_rounded : icon,
                size: 15,
                color: isCompleted ? activeColor : Colors.white38,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            timeStr,
            style: TextStyle(
              color: isCompleted ? Colors.white : Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: TextStyle(
              color: isCompleted ? activeColor : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return Row(
      children: [
        _buildActionTile(
          label: 'Jadwal Shift',
          subtitle: 'Kalender kerja',
          icon: Icons.calendar_month_outlined,
          iconColor: AppColors.accent,
          bgColor: AppColors.accentSoft,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const ScheduleCalendarPage()),
          ),
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          label: 'Izin & Cuti',
          subtitle: 'Form dispensasi',
          icon: Icons.assignment_turned_in_outlined,
          iconColor: AppColors.info,
          bgColor: AppColors.infoBg,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const LeavePage()),
          ),
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          label: 'Statistik',
          subtitle: 'Grafik bulanan',
          icon: Icons.insights_rounded,
          iconColor: AppColors.success,
          bgColor: AppColors.successBg,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const StatisticsPage()),
          ),
        ),
        const SizedBox(width: 10),
        _buildActionTile(
          label: 'Koreksi',
          subtitle: 'Klaim kendala',
          icon: Icons.support_agent_rounded,
          iconColor: AppColors.warning,
          bgColor: AppColors.warningBg,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const CorrectionPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: CardContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyPerformanceSection() {
    final percentage = _statsSummary?['percentage'] ?? 95;
    final ontime = _statsSummary?['ontime'] ?? 18;
    final late = _statsSummary?['late'] ?? 2;
    final leave = _statsSummary?['leave'] ?? 1;
    final alpha = _statsSummary?['alpha'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Performa Kehadiran', style: AppTypography.titleMedium),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const StatisticsPage()),
              ),
              child: const Row(
                children: [
                  Text(
                    'Detail Grafik',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.accent),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CardContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress Bar Tingkat Kehadiran
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tingkat Kehadiran Bulan Ini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (percentage as num) / 100.0,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  minHeight: 7,
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle, height: 1),
              const SizedBox(height: 14),

              // 4 Stat Chip Boxes
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Tepat Waktu',
                      value: '$ontime',
                      color: AppColors.success,
                      bgColor: AppColors.successBg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Terlambat',
                      value: '$late',
                      color: AppColors.warning,
                      bgColor: AppColors.warningBg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Izin / Sakit',
                      value: '$leave',
                      color: AppColors.info,
                      bgColor: AppColors.infoBg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricItem(
                      label: 'Alpa',
                      value: '$alpha',
                      color: AppColors.danger,
                      bgColor: AppColors.dangerBg,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard() {
    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_outlined, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kebijakan Presensi Swafoto',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Presensi diverifikasi langsung dengan foto selfie kamera depan dan waktu server tanpa hambatan GPS. Toleransi keterlambatan 15 menit dari jam shift.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
