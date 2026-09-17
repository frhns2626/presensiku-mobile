import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFullDate(DateTime date) {
    // Format: Kamis, 17 September 2026
    final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  static String formatShortDate(DateTime date) {
    // Format: 17 Sep 2026
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    // Format: 08:30:15 WIB
    return '${DateFormat('HH:mm:ss').format(date)} WIB';
  }

  static String formatShortTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '--:--';
    // Biasanya "08:15:00" -> "08:15 WIB"
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]} WIB';
    }
    return timeString;
  }
}
