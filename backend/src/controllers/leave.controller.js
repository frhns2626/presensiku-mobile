const db = require('../config/db');

exports.submitLeave = async (req, res) => {
  try {
    const userId = req.user.id;
    const { leave_type, start_date, end_date, reason } = req.body;

    if (!leave_type || !start_date || !end_date || !reason) {
      return res.status(400).json({ success: false, message: 'Jenis izin, tanggal mulai, tanggal selesai, dan alasan wajib diisi.' });
    }

    const attachmentUrl = req.file ? `/uploads/leave/${req.file.filename}` : null;

    const [result] = await db.query(
      'INSERT INTO leave_requests (user_id, leave_type, start_date, end_date, reason, attachment_url, status) VALUES (?, ?, ?, ?, ?, ?, "PENDING")',
      [userId, leave_type, start_date, end_date, reason, attachmentUrl]
    );

    res.status(201).json({
      success: true,
      message: 'Pengajuan permohonan berhasil dikirim. Menunggu verifikasi admin/atasan.',
      leaveId: result.insertId
    });
  } catch (err) {
    console.error('submitLeave error:', err);
    res.status(500).json({ success: false, message: 'Gagal mengirim pengajuan izin/sakit.' });
  }
};

exports.getLeaveHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const [rows] = await db.query(
      'SELECT * FROM leave_requests WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );

    res.json({ success: true, count: rows.length, data: rows });
  } catch (err) {
    console.error('getLeaveHistory error:', err);
    res.status(500).json({ success: false, message: 'Gagal memuat riwayat pengajuan izin.' });
  }
};
