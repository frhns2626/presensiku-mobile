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

class CorrectionPage extends StatefulWidget {
  const CorrectionPage({super.key});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Fields
  final _reasonTextController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  TimeOfDay _actualTime = const TimeOfDay(hour: 8, minute: 0);
  String _correctionType = 'MASUK';
  String _selectedReasonCategory = 'Lupa Presensi Masuk';
  File? _proofFile;

  bool _isSubmitting = false;
  bool _isLoadingList = true;
  List<dynamic> _correctionList = [];
  List<dynamic> _faqList = [];

  final List<String> _reasonOptions = [
    'Lupa Presensi Masuk',
    'Lupa Presensi Pulang',
    'Kendala Kamera / Sistem Error',
    'Tugas Luar Mendesak',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reasonTextController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingList = true);
    final resCorrections = await ApiClient.get(ApiConstants.correctionList);
    final resFaq = await ApiClient.get(ApiConstants.faq);

    setState(() {
      _isLoadingList = false;
      if (resCorrections['success'] == true) {
        _correctionList = resCorrections['data'] ?? [];
      }
      if (resFaq['success'] == true) {
        _faqList = resFaq['data'] ?? [];
      }
    });
  }

  Future<void> _pickProof() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) {
      setState(() {
        _proofFile = File(img.path);
      });
    }
  }

  Future<void> _submitCorrection() async {
    setState(() => _isSubmitting = true);

    final actualTimeString = '${_actualTime.hour.toString().padLeft(2, '0')}:${_actualTime.minute.toString().padLeft(2, '0')}:00';
    final formattedDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final res = await ApiClient.postMultipart(
      ApiConstants.submitCorrection,
      fields: {
        'target_date': formattedDate,
        'correction_type': _correctionType,
        'actual_time': actualTimeString,
        'reason': '[$_selectedReasonCategory] ${_reasonTextController.text.trim()}',
      },
      fileField: 'proof',
      file: _proofFile,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.success, content: Text(res['message'] ?? 'Koreksi berhasil dikirim!')),
      );
      _reasonTextController.clear();
      setState(() => _proofFile = null);
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.danger, content: Text(res['message'] ?? 'Gagal mengirim koreksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bantuan & Koreksi Presensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Ajukan Koreksi'),
            Tab(text: 'Pusat Bantuan & FAQ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCorrectionTab(),
          _buildFaqTab(),
        ],
      ),
    );
  }

  Widget _buildCorrectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Pengajuan Koreksi
          CardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Formulir Koreksi Absensi', style: AppTypography.titleMedium),
                const SizedBox(height: 4),
                Text('Gunakan fitur ini jika terjadi kendala lupa presensi atau kendala teknis.', style: AppTypography.bodySmall),
                const SizedBox(height: 20),

                // Pilih Tanggal
                const Text('Tanggal yang Dikoreksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Jenis Koreksi (Segmented Toggle)
                const Text('Jenis Koreksi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _correctionType = 'MASUK'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _correctionType == 'MASUK' ? AppColors.primary : Colors.white,
                          foregroundColor: _correctionType == 'MASUK' ? Colors.white : AppColors.textPrimary,
                          side: BorderSide(color: _correctionType == 'MASUK' ? AppColors.primary : AppColors.border),
                        ),
                        child: const Text('Koreksi Masuk'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _correctionType = 'PULANG'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _correctionType == 'PULANG' ? AppColors.primary : Colors.white,
                          foregroundColor: _correctionType == 'PULANG' ? Colors.white : AppColors.textPrimary,
                          side: BorderSide(color: _correctionType == 'PULANG' ? AppColors.primary : AppColors.border),
                        ),
                        child: const Text('Koreksi Pulang'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jam Sebenarnya (Time Picker)
                const Text('Jam Sebenarnya', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _actualTime,
                    );
                    if (picked != null) setState(() => _actualTime = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${_actualTime.hour.toString().padLeft(2, '0')}:${_actualTime.minute.toString().padLeft(2, '0')} WIB'),
                        const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Alasan Koreksi (Dropdown)
                const Text('Alasan Utama', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReasonCategory,
                      isExpanded: true,
                      items: _reasonOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedReasonCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Keterangan Tambahan
                CustomTextField(
                  label: 'Keterangan Tambahan',
                  hint: 'Tuliskan penjelasan detail...',
                  controller: _reasonTextController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Unggah Bukti
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickProof,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: Text(_proofFile == null ? 'Lampirkan Bukti (Opsional)' : 'Bukti Terlampir'),
                    ),
                    if (_proofFile != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                    ]
                  ],
                ),
                const SizedBox(height: 20),

                CustomButton(
                  text: 'Kirim Pengajuan Koreksi',
                  isLoading: _isSubmitting,
                  icon: Icons.send_rounded,
                  onPressed: _submitCorrection,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Riwayat Pengajuan Koreksi
          Text('Status Koreksi Sebelumnya', style: AppTypography.titleMedium),
          const SizedBox(height: 10),
          if (_isLoadingList)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_correctionList.isEmpty)
            const CardContainer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada riwayat permohonan koreksi.', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            )
          else
            ...(_correctionList.map((item) {
              return CardContainer(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.edit_calendar_outlined, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koreksi ${item['correction_type']} (${item['actual_time']})',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text('Tanggal: ${item['target_date']}', style: AppTypography.bodySmall),
                          Text(item['reason'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    PillBadge.fromStatus(item['status']),
                  ],
                ),
              );
            }).toList()),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Bantuan
          CardContainer(
            color: AppColors.accentSoft,
            border: Border.all(color: AppColors.infoBorder),
            child: Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppColors.accent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Butuh Bantuan Kendala?', style: AppTypography.titleMedium.copyWith(color: AppColors.accent)),
                      const Text(
                        'Baca jawaban pertanyaan umum atau hubungi admin.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Accordion FAQ
          if (_faqList.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else
            ...(_faqList.map((faq) {
              return CardContainer(
                margin: const EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  shape: const Border(),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    faq['q'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq['a'] as String,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),

          const SizedBox(height: 20),

          // Tombol Hubungi WhatsApp Helpdesk
          CardContainer(
            child: Column(
              children: [
                const Text(
                  'Masalah belum terselesaikan?',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tim helpdesk kami siap membantu di jam kerja operasional.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: 'Hubungi Admin via WhatsApp',
                  variant: ButtonVariant.secondary,
                  icon: Icons.chat_outlined,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membuka kontak WhatsApp Helpdesk (+62 812-3456-7890)...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
