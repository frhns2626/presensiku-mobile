const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = async (req, res) => {
  try {
    const { nip_nim, name, email, phone, password, department_id } = req.body;

    if (!nip_nim || !name || !email || !password) {
      return res.status(400).json({ success: false, message: 'NIP/NIM, Nama, Email, dan Password wajib diisi.' });
    }

    const [existing] = await db.query('SELECT id FROM users WHERE email = ? OR nip_nim = ?', [email, nip_nim]);
    if (existing.length > 0) {
      return res.status(400).json({ success: false, message: 'Email atau NIP/NIM sudah terdaftar.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await db.query(
      'INSERT INTO users (nip_nim, name, email, phone, password, department_id, schedule_id, role) VALUES (?, ?, ?, ?, ?, ?, 1, "user")',
      [nip_nim, name, email, phone || null, hashedPassword, department_id || 1]
    );

    res.status(201).json({
      success: true,
      message: 'Registrasi berhasil. Silakan masuk dengan akun Anda.',
      userId: result.insertId
    });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan server saat registrasi.' });
  }
};

exports.login = async (req, res) => {
  try {
    const { identifier, password } = req.body; // identifier bisa email atau NIP/NIM

    if (!identifier || !password) {
      return res.status(400).json({ success: false, message: 'Email/NIP dan password wajib diisi.' });
    }

    const [users] = await db.query(
      `SELECT u.*, d.name as department_name, s.name as schedule_name, s.check_in_time, s.check_out_time, s.late_tolerance_minutes
       FROM users u
       LEFT JOIN departments d ON u.department_id = d.id
       LEFT JOIN work_schedules s ON u.schedule_id = s.id
       WHERE u.email = ? OR u.nip_nim = ?`,
      [identifier, identifier]
    );

    if (users.length === 0) {
      return res.status(401).json({ success: false, message: 'Akun tidak ditemukan. Periksa kembali NIP/Email Anda.' });
    }

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Kata sandi salah.' });
    }

    const token = jwt.sign(
      { id: user.id, nip_nim: user.nip_nim, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'super_secret_presensiku_key_2026',
      { expiresIn: '7d' }
    );

    delete user.password;

    res.json({
      success: true,
      message: 'Login berhasil.',
      token,
      user
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ success: false, message: 'Terjadi kesalahan server saat login.' });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const [users] = await db.query(
      `SELECT u.id, u.nip_nim, u.name, u.email, u.phone, u.avatar_url, u.role, u.created_at,
              d.name as department_name, s.name as schedule_name, s.check_in_time, s.check_out_time, s.late_tolerance_minutes
       FROM users u
       LEFT JOIN departments d ON u.department_id = d.id
       LEFT JOIN work_schedules s ON u.schedule_id = s.id
       WHERE u.id = ?`,
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
    }

    res.json({ success: true, user: users[0] });
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ success: false, message: 'Gagal mengambil data profil.' });
  }
};
