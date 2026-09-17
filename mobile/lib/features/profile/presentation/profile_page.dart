import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/session_manager.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/presentation/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  bool _notificationReminder = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await SessionManager.getUser();
    setState(() {
      _user = user;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Konfirmasi Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun PresensiKu? Anda harus memasukkan kredensial lagi untuk melakukan presensi.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Batal', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionManager.clearSession();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?['name'] ?? 'Pengguna';
    final nip = _user?['nip_nim'] ?? '-';
    final email = _user?['email'] ?? '-';
    final phone = _user?['phone'] ?? '-';
    final dept = _user?['department_name'] ?? 'Pegawai';
    final role = _user?['role'] ?? 'user';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Profil
            CardContainer(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTypography.titleLarge),
                        const SizedBox(height: 2),
                        Text('NIP/NIM: $nip', style: AppTypography.bodySmall),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$dept • Role: ${role.toUpperCase()}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Informasi Akun Detail
            CardContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildProfileRow(Icons.email_outlined, 'Email', email),
                  const Divider(),
                  _buildProfileRow(Icons.phone_outlined, 'No. WhatsApp', phone),
                  const Divider(),
                  _buildProfileRow(Icons.business_outlined, 'Departemen', dept),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Menu Pengaturan
            CardContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  // Switch Pengingat Absen
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.notifications_active_outlined, color: AppColors.accent, size: 20),
                    ),
                    title: const Text('Pengingat Absen Harian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Notifikasi 15 menit sebelum shift', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    trailing: Switch(
                      value: _notificationReminder,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) {
                        setState(() => _notificationReminder = v);
                      },
                    ),
                  ),
                  const Divider(),
                  _buildNavRow(Icons.lock_outline, 'Ganti Kata Sandi', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur ubah kata sandi dibuka.')),
                    );
                  }),
                  const Divider(),
                  _buildNavRow(Icons.policy_outlined, 'Syarat & Kebijakan Privasi', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PresensiKu mematuhi privasi data swafoto & kehadiran.')),
                    );
                  }),
                  const Divider(),
                  _buildNavRow(Icons.info_outline, 'Tentang Aplikasi (Versi 1.0.0 MVP)', () {}),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Logout
            CustomButton(
              text: 'Keluar dari Akun',
              variant: ButtonVariant.danger,
              icon: Icons.logout_rounded,
              onPressed: _showLogoutConfirmation,
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'PresensiKu Mobile v1.0.0 • Clean Architecture',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildNavRow(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
