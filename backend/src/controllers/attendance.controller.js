const db = require('../config/db');

exports.getTodayStatus = async (req, res) => {
  try {
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];

    const [rows] = await db.query(
      'SELECT * FROM attendance_logs WHERE user_id = ? AND date = ?',
      [userId, today]
    );

    if (rows.length === 0) {
      return res.json({
        success: true,
        data: {
          hasCheckedIn: false,
          hasCheckedOut: false,
          checkInTime: null,
          checkOutTime: null,
          status: 'BELUM_HADIR'
        }
      });
    }

    const log = rows[0];
    res.json({
      success: true,
      data: {
        id: log.id,
        hasCheckedIn: !!log.check_in_time,
        hasCheckedOut: !!log.check_out_time,
        checkInTime: log.check_in_time,
        checkOutTime: log.check_out_time,
        checkInPhoto: log.check_in_photo,
        checkOutPhoto: log.check_out_photo,
        status: log.status,
        notes: log.notes
      }
    });
  } catch (err) {
    console.error('getTodayStatus error:', err);
    res.status(500).json({ success: false, message: 'Gagal memuat status presensi hari ini.' });
  }
};

exports.checkIn = async (req, res) => {
  try {
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];
    const now = new Date();
    const currentTime = now.toTimeString().split(' ')[0]; // HH:mm:ss

    // Cek apakah sudah absen masuk hari ini
    const [existing] = await db.query(
      'SELECT * FROM attendance_logs WHERE user_id = ? AND date = ?',
      [userId, today]
    );

    if (existing.length > 0 && existing[0].check_in_time) {
      return res.status(400).json({ success: false, message: 'Anda sudah melakukan presensi masuk hari ini.' });
    }

    const photoUrl = req.file ? `/uploads/attendance/${req.file.filename}` : null;

    // Ambil jadwal kerja pengguna untuk penentuan status (Tepat Waktu / Terlambat)
    const [userSchedule] = await db.query(
      `SELECT s.check_in_time, s.late_tolerance_minutes
       FROM users u
       JOIN work_schedules s ON u.schedule_id = s.id
       WHERE u.id = ?`,
      [userId]
    );

    let status = 'HADIR';
    if (userSchedule.length > 0) {
      const scheduleTime = userSchedule[0].check_in_time;
      const tolerance = userSchedule[0].late_tolerance_minutes || 15;

      const [cHour, cMin] = currentTime.split(':').map(Number);
      const [sHour, sMin] = scheduleTime.split(':').map(Number);

      const currentMinutes = cHour * 60 + cMin;
      const thresholdMinutes = sHour * 60 + sMin + tolerance;

      if (currentMinutes > thresholdMinutes) {
        status = 'TERLAMBAT';
      }
    }

    if (existing.length === 0) {
      await db.query(
        'INSERT INTO attendance_logs (user_id, date, check_in_time, check_in_photo, status) VALUES (?, ?, ?, ?, ?)',
        [userId, today, currentTime, photoUrl, status]
      );
    } else {
      await db.query(
        'UPDATE attendance_logs SET check_in_time = ?, check_in_photo = ?, status = ? WHERE id = ?',
        [currentTime, photoUrl, status, existing[0].id]
      );
    }

    res.json({
      success: true,
      message: status === 'TERLAMBAT' ? 'Presensi Masuk Berhasil (Status: Terlambat)' : 'Presensi Masuk Berhasil (Tepat Waktu)!',
      data: {
        checkInTime: currentTime,
        status,
        photoUrl
      }
    });
  } catch (err) {
    console.error('checkIn error:', err);
    res.status(500).json({ success: false, message: 'Gagal memproses presensi masuk.' });
  }
};

exports.checkOut = async (req, res) => {
  try {
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];
    const currentTime = new Date().toTimeString().split(' ')[0];

    const [existing] = await db.query(
      'SELECT * FROM attendance_logs WHERE user_id = ? AND date = ?',
      [userId, today]
    );

    if (existing.length === 0 || !existing[0].check_in_time) {
      return res.status(400).json({ success: false, message: 'Anda belum melakukan presensi masuk hari ini.' });
    }

    if (existing[0].check_out_time) {
      return res.status(400).json({ success: false, message: 'Anda sudah melakukan presensi pulang hari ini.' });
    }

    const photoUrl = req.file ? `/uploads/attendance/${req.file.filename}` : null;

    await db.query(
      'UPDATE attendance_logs SET check_out_time = ?, check_out_photo = ? WHERE id = ?',
      [currentTime, photoUrl, existing[0].id]
    );

    res.json({
      success: true,
      message: 'Presensi Pulang Berhasil. Selamat beristirahat!',
      data: {
        checkOutTime: currentTime,
        photoUrl
      }
    });
  } catch (err) {
    console.error('checkOut error:', err);
    res.status(500).json({ success: false, message: 'Gagal memproses presensi pulang.' });
  }
};

exports.getHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { month, year, status } = req.query;

    let query = 'SELECT * FROM attendance_logs WHERE user_id = ?';
    const params = [userId];

    if (month && year) {
      query += ' AND MONTH(date) = ? AND YEAR(date) = ?';
      params.push(month, year);
    }

    if (status && status !== 'SEMUA') {
      query += ' AND status = ?';
      params.push(status);
    }

    query += ' ORDER BY date DESC';

    const [logs] = await db.query(query, params);
    res.json({ success: true, count: logs.length, data: logs });
  } catch (err) {
    console.error('getHistory error:', err);
    res.status(500).json({ success: false, message: 'Gagal memuat riwayat presensi.' });
  }
};
