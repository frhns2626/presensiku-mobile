import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Untuk Web / iOS Simulator gunakan localhost, untuk Android Emulator gunakan 10.0.2.2, untuk Real Device gunakan IP LAN
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  static const String todayStatus = '/attendance/today';
  static const String checkIn = '/attendance/check-in';
  static const String checkOut = '/attendance/check-out';
  static const String history = '/attendance/history';

  static const String submitLeave = '/leave/submit';
  static const String leaveHistory = '/leave/history';

  static const String statsSummary = '/stats/summary';
  static const String schedule = '/schedule/my-schedule';

  static const String submitCorrection = '/correction/submit';
  static const String correctionList = '/correction/list';
  static const String faq = '/help/faq';
}
