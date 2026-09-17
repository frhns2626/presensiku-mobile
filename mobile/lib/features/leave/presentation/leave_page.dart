import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/pill_badge.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form State
  String _selectedLeaveType = 'IZIN';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final _reasonController = TextEditingController();
  File? _attachmentFile;
  bool _isSubmitting = false;

  // History State
  bool _isLoadingHistory = true;
  List<dynamic> _leaveHistory = [];

  final List<Map<String, String>> _leaveTypes = [
    {'value': 'IZIN', 'label': 'Izin Keperluan Pribadi'},
    {'value': 'SAKIT', 'label': 'Sakit (Surat Dokter)'},
    {'value': 'CUTI', 'label': 'Cuti Tahunan'},
    {'value': 'TUGAS_LUAR', 'label': 'Tugas Luar / Dinas'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaveHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveHistory() async {
    setState(() => _isLoadingHistory = true);
    final res = await ApiClient.get(ApiConstants.leaveHistory);
    setState(() {
      _isLoadingHistory = false;
      if (res['success'] == true) {
        _leaveHistory = res['data'] ?? [];
      }
    });
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      setState(() {
        _attachmentFile = File(file.path);
      });
    }
  }

  int get _calculatedDays {
    return _endDate.difference(_startDate).inDays + 1;
  }

  Future<void> _submitLeave() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan pengajuan izin wajib diisi.')),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final sDateStr = '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';
    final eDateStr = '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}';

    final res = await ApiClient.postMultipart(
      ApiConstants.submitLeave,
      fields: {
        'leave_type': _selectedLeaveType,
        'start_date': sDateStr,
        'end_date': eDateStr,
        'reason': _reasonController.text.trim(),
      },
      fileField: 'attachment',
      file: _attachmentFile,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text(res['message'] ?? 'Permohonan berhasil dikirim!')),
      );
      _reasonController.clear();
      setState(() {
        _attachmentFile = null;
        _tabController.animateTo(1); // Pindah ke tab riwayat
      });
      _loadLeaveHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text(res['message'] ?? 'Gagal mengirim permohonan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengajuan Izin & Sakit'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Buat Pengajuan'),
            Tab(text: 'Riwayat Izin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Form Permohonan Ketidakhadiran', style: AppTypography.titleMedium),
                const SizedBox(height: 4),
                Text('Pastikan data yang diisi akurat dan lampirkan bukti jika diperlukan.', style: AppTypography.bodySmall),
                const SizedBox(height: 20),

                // Kategori Izin
                const Text('Jenis Permohonan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLeaveType,
                      isExpanded: true,
                      items: _leaveTypes.map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLeaveType = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Rentang Tanggal
                Row(
                  children: [
                    // Tanggal Mulai
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Mulai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 7)),
                                lastDate: DateTime.now().add(const Duration(days: 60)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _startDate = picked;
                                  if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tanggal Selesai
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Selesai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: _startDate,
                                lastDate: DateTime.now().add(const Duration(days: 60)),
                              );
                              if (picked != null) setState(() => _endDate = picked);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Hitungan Total Hari
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total Durasi: $_calculatedDays Hari',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
                  ),
                ),
                const SizedBox(height: 16),

                // Alasan Keterangan
                CustomTextField(
                  label: 'Alasan / Keterangan',
                  hint: 'Tuliskan rincian alasan izin atau sakit Anda...',
                  controller: _reasonController,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Upload Berkas / Surat Dokter
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickAttachment,
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: Text(_attachmentFile == null ? 'Unggah Surat Dokter / Bukti' : 'Bukti Terpilih'),
                    ),
                    if (_attachmentFile != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    ]
                  ],
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Kirim Permohonan Izin',
                  isLoading: _isSubmitting,
                  icon: Icons.send_rounded,
                  onPressed: _submitLeave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_leaveHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 54, color: AppColors.border),
            const SizedBox(height: 12),
            Text('Belum ada riwayat permohonan izin.', style: AppTypography.titleMedium.copyWith(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaveHistory,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _leaveHistory.length,
        itemBuilder: (context, index) {
          final item = _leaveHistory[index] as Map<String, dynamic>;
          final type = item['leave_type'] ?? 'IZIN';
          final sDate = item['start_date'] ?? '';
          final eDate = item['end_date'] ?? '';
          final reason = item['reason'] ?? '';
          final status = item['status'] ?? 'PENDING';
          final adminNotes = item['admin_notes'];

          return CardContainer(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.event_note, color: AppColors.info, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Izin: $type', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    PillBadge.fromStatus(status),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Periode: $sDate s.d. $eDate', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(reason, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                if (adminNotes != null && adminNotes.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Catatan Admin: $adminNotes', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
