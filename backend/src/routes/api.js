const express = require('express');
const router = express.Router();

const authMiddleware = require('../middleware/auth');
const upload = require('../middleware/upload');

const authController = require('../controllers/auth.controller');
const attendanceController = require('../controllers/attendance.controller');
const leaveController = require('../controllers/leave.controller');
const statsController = require('../controllers/stats.controller');
const correctionController = require('../controllers/correction.controller');

// 1. Auth Routes
router.post('/auth/register', authController.register);
router.post('/auth/login', authController.login);
router.get('/auth/profile', authMiddleware, authController.getProfile);

// 2. Attendance Routes
router.get('/attendance/today', authMiddleware, attendanceController.getTodayStatus);
router.post('/attendance/check-in', authMiddleware, upload.single('photo'), attendanceController.checkIn);
router.post('/attendance/check-out', authMiddleware, upload.single('photo'), attendanceController.checkOut);
router.get('/attendance/history', authMiddleware, attendanceController.getHistory);

// 3. Leave & Sick Routes
router.post('/leave/submit', authMiddleware, upload.single('attachment'), leaveController.submitLeave);
router.get('/leave/history', authMiddleware, leaveController.getLeaveHistory);

// 4. Schedule & Statistics Routes
router.get('/stats/summary', authMiddleware, statsController.getStats);
router.get('/schedule/my-schedule', authMiddleware, statsController.getSchedule);

// 5. Correction & Help Routes
router.post('/correction/submit', authMiddleware, upload.single('proof'), correctionController.submitCorrection);
router.get('/correction/list', authMiddleware, correctionController.getCorrections);
router.get('/help/faq', correctionController.getFaq);

module.exports = router;
