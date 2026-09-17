const db = require('../config/db');

exports.getStats = async (req, res) => {
  try {
    const userId = req.user.id;
    const { month, year } = req.query;

    const currentYear = year || new Date().getFullYear();
    const currentMonth = month || (new Date().getMonth() + 1);

    // Hitung total hadir tepat waktu
    const [ontimeCount] = await db.query(
      'SELECT COUNT(*) as count FROM attendance_logs WHERE user_id = ? AND status = "HADIR" AND MONTH(date) = ? AND YEAR(date) = ?',
      [userId, currentMonth, currentYear]
    );

    // Hitung total terlambat
    const [lateCount] = await db.query(
      'SELECT COUNT(*) as count FROM attendance_logs WHERE user_id = ? AND status = "TERLAMBAT" AND MONTH(date) = ? AND YEAR(date) = ?',
      [userId, currentMonth, currentYear]
    );

    // Hitung total izin/sakit yang disetujui
    const [leaveCount] = await db.query(
      'SELECT COUNT(*) as count FROM leave_requests WHERE user_id = ? AND status = "APPROVED" AND MONTH(start_date) = ? AND YEAR(start_date) = ?',
      [userId, currentMonth, currentYear]
    );

    const ontime = ontimeCount[0].count || 0;
    const late = lateCount[0].count || 0;
    const leave = leaveCount[0].count || 0;
    const totalWorkingDays = 22; // Standar hari kerja bulanan
    const totalAttended = ontime + late;
    const percentage = totalWorkingDays > 0 ? Math.min(100, Math.round((totalAttended / totalWorkingDays) * 100)) : 0;

    res.json({
      success: true,
      data: {
        month: Number(currentMonth),
        year: Number(currentYear),
        percentage,
        totalWorkingDays,
        ontime,
        late,
        leave,
        alpha: Math.max(0, totalWorkingDays - (totalAttended + leave)),
        // Data tren mingguan untuk bar chart
        weeklyTrend: [
          { week: 'Minggu 1', ontime: Math.min(ontime, 5), late: Math.min(late, 1) },
          { week: 'Minggu 2', ontime: Math.min(Math.max(0, ontime - 5), 5), late: Math.min(Math.max(0, late - 1), 1) },
          { week: 'Minggu 3', ontime: Math.min(Math.max(0, ontime - 10), 5), late: 0 },
          { week: 'Minggu 4', ontime: Math.min(Math.max(0, ontime - 15), 5), late: 0 }
        ]
      }
    });
  } catch (err) {
    console.error('getStats error:', err);
    res.status(500).json({ success: false, message: 'Gagal memuat data statistik kehadiran.' });
  }
};

exports.getSchedule = async (req, res) => {
  try {
    const userId = req.user.id;
    const [schedule] = await db.query(
      `SELECT s.*, d.name as department_name
       FROM users u
       JOIN work_schedules s ON u.schedule_id = s.id
       JOIN departments d ON u.department_id = d.id
       WHERE u.id = ?`,
      [userId]
    );

    // Daftar hari libur nasional statis untuk kalender
    const holidays = [
      { date: '2026-01-01', name: 'Tahun Baru Masehi' },
      { date: '2026-03-20', name: 'Hari Raya Nyepi' },
      { date: '2026-04-03', name: 'Wafat Isa Almasih' },
      { date: '2026-05-01', name: 'Hari Buruh Internasional' },
      { date: '2026-05-14', name: 'Kenaikan Isa Almasih' },
      { date: '2026-06-01', name: 'Hari Lahir Pancasila' },
      { date: '2026-08-17', name: 'Hari Kemerdekaan RI' },
      { date: '2026-12-25', name: 'Hari Raya Natal' }
    ];

    res.json({
      success: true,
      schedule: schedule[0] || null,
      holidays
    });
  } catch (err) {
    console.error('getSchedule error:', err);
    res.status(500).json({ success: false, message: 'Gagal memuat jadwal kerja.' });
  }
};
