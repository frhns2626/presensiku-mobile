import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/card_container.dart';

class ScheduleCalendarPage extends StatefulWidget {
  const ScheduleCalendarPage({super.key});

  @override
  State<ScheduleCalendarPage> createState() => _ScheduleCalendarPageState();
}

class _ScheduleCalendarPageState extends State<ScheduleCalendarPage> {
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = true;
  Map<String, dynamic>? _scheduleData;
  List<dynamic> _holidays = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    final res = await ApiClient.get(ApiConstants.schedule);
    setState(() {
      _isLoading = false;
      if (res['success'] == true) {
        _scheduleData = res['schedule'];
        _holidays = res['holidays'] ?? [];
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final titleMonth = '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jadwal & Kalender Kerja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Jam Kerja Aktif
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.schedule, color: AppColors.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _scheduleData?['name'] ?? 'Shift Reguler Pagi',
                                    style: AppTypography.titleMedium,
                                  ),
                                  Text(
                                    _scheduleData?['department_name'] ?? 'Teknologi Informasi',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildShiftItem(
                              'Jam Masuk',
                              _scheduleData?['check_in_time'] ?? '08:00 WIB',
                              Icons.login_rounded,
                              AppColors.success,
                            ),
                            Container(height: 36, width: 1, color: AppColors.border),
                            _buildShiftItem(
                              'Jam Pulang',
                              _scheduleData?['check_out_time'] ?? '17:00 WIB',
                              Icons.logout_rounded,
                              AppColors.danger,
                            ),
                            Container(height: 36, width: 1, color: AppColors.border),
                            _buildShiftItem(
                              'Toleransi',
                              '${_scheduleData?['late_tolerance_minutes'] ?? 15} Menit',
                              Icons.timelapse,
                              AppColors.warning,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Kalender Bulanan Interaktif
                  CardContainer(
                    child: Column(
                      children: [
                        // Header Navigasi Bulan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Text(
                              titleMonth,
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Header Hari (Sen, Sel, Rab, ...)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: (day == 'Min' || day == 'Sab') ? AppColors.danger : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Grid Tanggal
                        _buildDaysGrid(),

                        const SizedBox(height: 16),
                        // Legenda Indikator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Hari Kerja', AppColors.success),
                            const SizedBox(width: 16),
                            _buildLegendItem('Hari Libur', AppColors.danger),
                            const SizedBox(width: 16),
                            _buildLegendItem('Izin/Cuti', AppColors.info),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Daftar Hari Libur Nasional
                  Text('Hari Libur Nasional Terdaftar', style: AppTypography.titleMedium),
                  const SizedBox(height: 10),
                  ...(_holidays.map((h) {
                    return CardContainer(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.celebration_outlined, color: AppColors.danger, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(h['date'] as String, style: AppTypography.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()),
                ],
              ),
            ),
    );
  }

  Widget _buildShiftItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7; // 0 for Sunday

    final totalCells = daysInMonth + firstDayWeekday;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - firstDayWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final isWeekend = (colIndex == 0 || colIndex == 6);
              final isToday = _currentMonth.year == DateTime.now().year &&
                  _currentMonth.month == DateTime.now().month &&
                  dayNumber == DateTime.now().day;

              return Expanded(
                child: Container(
                  height: 36,
                  decoration: isToday
                      ? BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday
                              ? Colors.white
                              : (isWeekend ? AppColors.danger : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isWeekend
                              ? AppColors.danger
                              : (isToday ? Colors.white : AppColors.success),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
