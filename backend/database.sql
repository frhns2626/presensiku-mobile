-- Skrip Database MySQL untuk PresensiKu
CREATE DATABASE IF NOT EXISTS presensi_db;
USE presensi_db;

-- 1. Tabel Departemen / Divisi
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tabel Jadwal Jam Kerja
CREATE TABLE IF NOT EXISTS work_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    check_in_time TIME NOT NULL,
    check_out_time TIME NOT NULL,
    late_tolerance_minutes INT DEFAULT 15,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Tabel Pengguna (Users)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nip_nim VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    department_id INT,
    schedule_id INT,
    role ENUM('user', 'admin') DEFAULT 'user' NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    FOREIGN KEY (schedule_id) REFERENCES work_schedules(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. Tabel Log Kehadiran (Attendance Logs)
CREATE TABLE IF NOT EXISTS attendance_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    date DATE NOT NULL,
    check_in_time TIME,
    check_out_time TIME,
    check_in_photo VARCHAR(255),
    check_out_photo VARCHAR(255),
    status ENUM('HADIR', 'TERLAMBAT', 'PULANG_CEPAT') DEFAULT 'HADIR',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_attendance_per_day (user_id, date),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Tabel Pengajuan Izin & Sakit (Leave Requests)
CREATE TABLE IF NOT EXISTS leave_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    leave_type ENUM('IZIN', 'SAKIT', 'CUTI', 'TUGAS_LUAR') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    attachment_url VARCHAR(255),
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Tabel Pengajuan Koreksi Presensi (Attendance Corrections)
CREATE TABLE IF NOT EXISTS correction_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    target_date DATE NOT NULL,
    correction_type ENUM('MASUK', 'PULANG') NOT NULL,
    actual_time TIME NOT NULL,
    reason TEXT NOT NULL,
    proof_url VARCHAR(255),
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Data Awal (Seeder)
INSERT INTO departments (id, name, description) VALUES
(1, 'Teknologi Informasi', 'Divisi IT & Pengembangan Sistem'),
(2, 'Sumber Daya Manusia', 'Divisi HR & Personalia'),
(3, 'Keuangan & Akuntansi', 'Divisi Finansial');

INSERT INTO work_schedules (id, name, check_in_time, check_out_time, late_tolerance_minutes) VALUES
(1, 'Shift Reguler Pagi', '08:00:00', '17:00:00', 15);

-- Dummy user: password adalah 'password123' (hash bcrypt)
INSERT INTO users (id, nip_nim, name, email, phone, password, department_id, schedule_id, role) VALUES
(1, 'EMP001', 'Farhan Developer', 'farhan@presensiku.com', '081234567890', '$2a$10$Plr7ELyX6en/Nzy/Fh6.Vu1tMAwmF.x2HaAnMsB25vHy5KzelSbMq', 1, 1, 'user'),
(2, 'ADM001', 'Admin HR', 'admin@presensiku.com', '081298765432', '$2a$10$Plr7ELyX6en/Nzy/Fh6.Vu1tMAwmF.x2HaAnMsB25vHy5KzelSbMq', 2, 1, 'admin');
