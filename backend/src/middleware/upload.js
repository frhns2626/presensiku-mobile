const multer = require('multer');
const path = require('path');
const fs = require('fs');

const attendanceDir = path.join(__dirname, '../../public/uploads/attendance');
const leaveDir = path.join(__dirname, '../../public/uploads/leave');

if (!fs.existsSync(attendanceDir)) fs.mkdirSync(attendanceDir, { recursive: true });
if (!fs.existsSync(leaveDir)) fs.mkdirSync(leaveDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (file.fieldname === 'photo') {
      cb(null, attendanceDir);
    } else {
      cb(null, leaveDir);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, `${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 } // Maks 5MB
});

module.exports = upload;
