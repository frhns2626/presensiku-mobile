const db = require('../config/db');

exports.submitCorrection = async (req, res) => {
  try {
    const userId = req.user.id;
    const { target_date, correction_type, actual_time, reason } = req.body;

    if (!target_date || !correction_type || !actual_time || !reason) {
      return res.status(400).json({ success: false, message: 'Tanggal, jenis koreksi, jam sebenarnya, dan alasan wajib diisi.' });
    }

    const proofUrl = req.file ? `/uploads/leave/${req.file.filename}` : null;

    const [result] = await db.query(
      'INSERT INTO correction_requests (user_id, target_date, correction_type, actual_time, reason, proof_url, status) VALUES (?, ?, ?, ?, ?, ?, "PENDING")',
      [userId, target_date, correction_type, actual_time, reason, proofUrl]
    );

    res.status(201).json({
      success: true,
      message: 'Pengajuan koreksi presensi berhasil dikirim. Menunggu verifikasi admin.',
      correctionId: result.insertId
    });
  } catch (err) {
    console.error('submitCorrection error:', err);
    res.status(500).json({ success: false, message: 'Gagal mengirim pengajuan koreksi presensi.' });
  }
};

exports.getCorrections = async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await db.query(
      'SELECT * FROM correction_requests WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );

    res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('getCorrections error:', err);
    res.status(500).json({ success: false, message: 'Gagal memuat daftar koreksi presensi.' });
  }
};

exports.getFaq = (req, res) => {
  const faqList = [
    {
      q: 'Bagaimana cara melakukan presensi dengan benar?',
      a: 'Buka menu Beranda, klik tombol "Presensi Masuk" atau "Presensi Pulang", arahkan wajah ke dalam bingkai oval kamera depan, dan tekan tombol jepret foto. Pastikan pencahayaan cukup jelas.'
    },
    {
      q: 'Bagaimana jika kamera selfie gagal terbuka?',
      a: 'Periksa izin aplikasi di pengaturan smartphone Anda (Settings > Apps > PresensiKu > Permissions) dan pastikan izin Kamera telah diberikan akses ("Allow").'
    },
    {
      q: 'Bagaimana jika saya lupa melakukan presensi pulang kemarin?',
      a: 'Gunakan fitur "Pengajuan Koreksi Presensi" pada sub-layar ini. Pilih tanggal kemarin, pilih jenis "Koreksi Jam Pulang", masukkan jam pulang sebenarnya, dan jelaskan alasannya.'
    },
    {
      q: 'Berapa lama waktu persetujuan izin dan koreksi?',
      a: 'Permohonan akan diproses oleh pihak HR / Admin maksimal dalam waktu 1x24 jam pada hari kerja reguler.'
    }
  ];

  res.json({ success: true, data: faqList });
};
