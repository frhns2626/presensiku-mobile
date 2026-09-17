import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/pill_badge.dart';
import '../../correction/presentation/correction_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  List<dynamic> _logs = [];
  String _selectedStatus = 'SEMUA';

  final List<String> _statusFilters = ['SEMUA', 'HADIR', 'TERLAMBAT', 'IZIN', 'SAKIT', 'ALPA'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final endpoint = '${ApiConstants.history}?status=$_selectedStatus';
    final res = await ApiClient.get(endpoint);

    setState(() {
      _isLoading = false;
      if (res['success'] == true) {
        _logs = res['data'] ?? [];
      }
    });
  }

  void _showDetailBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dateParsed = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
        final checkInTime = item['check_in_time'];
        final checkOutTime = item['check_out_time'];
        final status = item['status'] ?? 'HADIR';

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormatter.formatFullDate(dateParsed), style: AppTypography.titleMedium),
                      const SizedBox(height: 2),
                      const Text('Detail Log Presensi Harian', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                  PillBadge.fromStatus(status),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Pratinjau Foto Swafoto jika ada
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Foto Masuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.face, size: 36, color: AppColors.textMuted),
                              SizedBox(height: 4),
                              Text('Swafoto Masuk', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Foto Pulang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.face_retouching_natural, size: 36, color: AppColors.textMuted),
                              SizedBox(height: 4),
                              Text('Swafoto Pulang', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Rincian Jam
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeColumn('Jam Masuk', checkInTime ?? '--:--:--', AppColors.success),
                  Container(height: 32, width: 1, color: AppColors.border),
                  _buildTimeColumn('Jam Pulang', checkOutTime ?? '--:--:--', AppColors.danger),
                ],
              ),

              const SizedBox(height: 24),

              // Tombol Ajukan Koreksi
              CustomButton(
                text: 'Ajukan Koreksi Presensi Ini',
                variant: ButtonVariant.secondary,
                icon: Icons.edit_note_rounded,
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const CorrectionPage()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Status Horizontal Scrollable Chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _statusFilters.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = _selectedStatus == status;

                return ChoiceChip(
                  label: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedStatus = status);
                      _loadHistory();
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Daftar Kartu Riwayat
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy_outlined, size: 54, color: AppColors.border),
                            const SizedBox(height: 12),
                            Text('Tidak ada riwayat presensi.', style: AppTypography.titleMedium.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final item = _logs[index] as Map<String, dynamic>;
                            final dateParsed = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
                            final checkIn = item['check_in_time'];
                            final checkOut = item['check_out_time'];
                            final status = item['status'];

                            return CardContainer(
                              margin: const EdgeInsets.only(bottom: 12),
                              onTap: () => _showDetailBottomSheet(item),
                              child: Row(
                                children: [
                                  // Tanggal Box
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSecondary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${dateParsed.day}',
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          DateFormatter.formatShortDate(dateParsed).split(' ')[1],
                                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Detail Jam Masuk & Pulang
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(DateFormatter.formatFullDate(dateParsed), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.login, size: 14, color: AppColors.success),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormatter.formatShortTime(checkIn),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.logout, size: 14, color: AppColors.danger),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormatter.formatShortTime(checkOut),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Badge Status
                                  PillBadge.fromStatus(status),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
