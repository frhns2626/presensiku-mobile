import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';

enum AttendanceType { checkIn, checkOut }

class SelfieAttendancePage extends StatefulWidget {
  final AttendanceType type;

  const SelfieAttendancePage({super.key, required this.type});

  @override
  State<SelfieAttendancePage> createState() => _SelfieAttendancePageState();
}

class _SelfieAttendancePageState extends State<SelfieAttendancePage> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isLoading = false;
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    try {
      // Buka kamera depan secara langsung (Front Camera)
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 75, // Kompresi otomatis 300KB-500KB
        maxWidth: 1080,
        maxHeight: 1440,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka kamera: $e')),
      );
    }
  }

  Future<void> _submitAttendance() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto swafoto terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final endpoint = widget.type == AttendanceType.checkIn
        ? ApiConstants.checkIn
        : ApiConstants.checkOut;

    final res = await ApiClient.postMultipart(
      endpoint,
      fields: {
        'time': _currentTime.toIso8601String(),
      },
      fileField: 'photo',
      file: _capturedImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (res['success'] == true) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 36, color: AppColors.success),
              ),
              const SizedBox(height: 16),
              Text(
                widget.type == AttendanceType.checkIn ? 'Presensi Masuk Berhasil!' : 'Presensi Pulang Berhasil!',
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                res['message'] ?? 'Data kehadiran Anda telah tercatat dengan aman.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Kembali ke Beranda',
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true); // Kirim result true untuk refresh dashboard
                },
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(res['message'] ?? 'Gagal memproses presensi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == AttendanceType.checkIn ? 'Presensi Masuk' : 'Presensi Pulang';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info & Jam Live
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    DateFormatter.formatFullDate(_currentTime),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatTime(_currentTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Viewfinder Area dengan Oval Guide
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tampilan Gambar jika sudah dijepret
                    if (_capturedImage != null)
                      Image.file(
                        _capturedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else
                      // Placeholder Viewfinder
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(140),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.8),
                                width: 2.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.face_retouching_natural_outlined,
                                size: 80,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Posisikan wajah di dalam bingkai oval',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kamera Depan Aktif • Live Verification',
                            style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                    // Watermark Visual Waktu di Sudut Bawah
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'PresensiKu Live • ${DateFormatter.formatShortDate(_currentTime)} ${DateFormatter.formatTime(_currentTime)}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: Colors.black,
              child: _capturedImage == null
                  ? Column(
                      children: [
                        // Tombol Shutter Ambil Foto
                        GestureDetector(
                          onTap: _takeSelfie,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              color: AppColors.accent,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 34),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tekan untuk Jepret Foto Selfie',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Foto Ulang (Retake)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _takeSelfie,
                            icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                            label: const Text('Foto Ulang', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Kirim Presensi (Submit)
                        Expanded(
                          child: CustomButton(
                            text: 'Kirim Presensi',
                            isLoading: _isLoading,
                            icon: Icons.send_rounded,
                            onPressed: _submitAttendance,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
