import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/card_container.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final res = await ApiClient.get(ApiConstants.statsSummary);
    setState(() {
      _isLoading = false;
      if (res['success'] == true) {
        _stats = res['data'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _stats?['percentage'] ?? 95;
    final ontime = _stats?['ontime'] ?? 18;
    final late = _stats?['late'] ?? 2;
    final leave = _stats?['leave'] ?? 1;
    final alpha = _stats?['alpha'] ?? 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistik Kehadiran'),
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
                  // Skor Utama Kehadiran
                  CardContainer(
                    color: AppColors.primary,
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tingkat Kehadiran',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                percentage >= 90 ? 'Performa Sangat Baik!' : 'Tingkatkan Kedisiplinan',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Periode Bulan ${DateTime.now().month} / ${DateTime.now().year}',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Visualisasi Pie / Donut Chart
                  CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Komposisi Kehadiran', style: AppTypography.titleMedium),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 46,
                              sections: [
                                PieChartSectionData(
                                  value: ontime.toDouble(),
                                  title: '$ontime',
                                  color: AppColors.success,
                                  radius: 36,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                PieChartSectionData(
                                  value: late.toDouble(),
                                  title: '$late',
                                  color: AppColors.warning,
                                  radius: 36,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                PieChartSectionData(
                                  value: leave.toDouble(),
                                  title: '$leave',
                                  color: AppColors.info,
                                  radius: 36,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                PieChartSectionData(
                                  value: alpha.toDouble(),
                                  title: '$alpha',
                                  color: AppColors.danger,
                                  radius: 36,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Legenda Warna
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegend('Tepat Waktu', AppColors.success),
                            _buildLegend('Terlambat', AppColors.warning),
                            _buildLegend('Izin/Sakit', AppColors.info),
                            _buildLegend('Alpa', AppColors.danger),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4 Kotak Metrik Detail
                  Text('Rincian Hari Kerja', style: AppTypography.titleMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Tepat Waktu', '$ontime Hari', Icons.check_circle_outline, AppColors.success, AppColors.successBg)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Terlambat', '$late Hari', Icons.access_time, AppColors.warning, AppColors.warningBg)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Izin / Sakit', '$leave Hari', Icons.insert_drive_file_outlined, AppColors.info, AppColors.infoBg)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricCard('Alpa / Kosong', '$alpha Hari', Icons.highlight_off, AppColors.danger, AppColors.dangerBg)),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return CardContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(title, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
