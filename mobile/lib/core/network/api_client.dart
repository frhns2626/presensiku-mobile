import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/session_manager.dart';

class ApiClient {
  static Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await SessionManager.getToken();
    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('[ApiClient] GET $endpoint failed: $e. Using local mock fallback.');
      return _getMockFallback(endpoint);
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 4));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('[ApiClient] POST $endpoint failed: $e. Using local mock fallback.');
      return _postMockFallback(endpoint, body);
    }
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required String fileField,
    File? file,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 6));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('[ApiClient] MULTIPART $endpoint failed: $e. Using local mock fallback.');
      return {
        'success': true,
        'message': 'Berhasil diproses (Mode Offline Mock)',
        'data': {
          'status': 'HADIR',
          'checkInTime': '08:05:00',
          'photoUrl': file?.path ?? ''
        }
      };
    }
  }

  // --- Smart Mock Fallback untuk presentasi offline tanpa database ---
  static Map<String, dynamic> _getMockFallback(String endpoint) {
    if (endpoint.contains(ApiConstants.todayStatus)) {
      return {
        'success': true,
        'data': {
          'hasCheckedIn': false,
          'hasCheckedOut': false,
          'checkInTime': null,
          'checkOutTime': null,
          'status': 'BELUM_HADIR'
        }
      };
    } else if (endpoint.contains(ApiConstants.history)) {
      return {
        'success': true,
        'data': [
          {
            'id': 1,
            'date': '2026-09-17',
            'check_in_time': '07:55:12',
            'check_out_time': '17:02:40',
            'status': 'HADIR',
            'check_in_photo': null,
          },
          {
            'id': 2,
            'date': '2026-09-16',
            'check_in_time': '08:18:05',
            'check_out_time': '17:05:00',
            'status': 'TERLAMBAT',
            'check_in_photo': null,
          },
          {
            'id': 3,
            'date': '2026-09-15',
            'check_in_time': '07:50:00',
            'check_out_time': '17:00:10',
            'status': 'HADIR',
            'check_in_photo': null,
          },
          {
            'id': 4,
            'date': '2026-09-14',
            'check_in_time': '07:58:22',
            'check_out_time': '17:01:15',
            'status': 'HADIR',
            'check_in_photo': null,
          }
        ]
      };
    } else if (endpoint.contains(ApiConstants.leaveHistory)) {
      return {
        'success': true,
        'data': [
          {
            'id': 1,
            'leave_type': 'SAKIT',
            'start_date': '2026-09-10',
            'end_date': '2026-09-11',
            'reason': 'Demam dan flu, istirahat dokter.',
            'status': 'APPROVED',
            'admin_notes': 'Lekas sembuh!',
            'created_at': '2026-09-10T07:00:00Z'
          },
          {
            'id': 2,
            'leave_type': 'IZIN',
            'start_date': '2026-09-22',
            'end_date': '2026-09-22',
            'reason': 'Urusan administrasi kependudukan keluarga.',
            'status': 'PENDING',
            'admin_notes': null,
            'created_at': '2026-09-16T14:20:00Z'
          }
        ]
      };
    } else if (endpoint.contains(ApiConstants.statsSummary)) {
      return {
        'success': true,
        'data': {
          'month': 9,
          'year': 2026,
          'percentage': 95,
          'totalWorkingDays': 22,
          'ontime': 18,
          'late': 2,
          'leave': 1,
          'alpha': 1,
          'weeklyTrend': [
            {'week': 'Minggu 1', 'ontime': 5, 'late': 0},
            {'week': 'Minggu 2', 'ontime': 4, 'late': 1},
            {'week': 'Minggu 3', 'ontime': 5, 'late': 0},
            {'week': 'Minggu 4', 'ontime': 4, 'late': 1},
          ]
        }
      };
    } else if (endpoint.contains(ApiConstants.schedule)) {
      return {
        'success': true,
        'schedule': {
          'name': 'Shift Reguler Pagi',
          'department_name': 'Teknologi Informasi',
          'check_in_time': '08:00:00',
          'check_out_time': '17:00:00',
          'late_tolerance_minutes': 15
        },
        'holidays': [
          {'date': '2026-01-01', 'name': 'Tahun Baru Masehi'},
          {'date': '2026-05-01', 'name': 'Hari Buruh Internasional'},
          {'date': '2026-08-17', 'name': 'Hari Kemerdekaan RI'},
          {'date': '2026-12-25', 'name': 'Hari Raya Natal'}
        ]
      };
    } else if (endpoint.contains(ApiConstants.faq)) {
      return {
        'success': true,
        'data': [
          {
            'q': 'Bagaimana cara melakukan presensi dengan benar?',
            'a': 'Buka menu Beranda, klik tombol "Presensi Masuk" atau "Presensi Pulang", arahkan wajah ke dalam bingkai oval kamera depan, dan tekan tombol jepret foto. Pastikan pencahayaan cukup jelas.'
          },
          {
            'q': 'Bagaimana jika kamera selfie gagal terbuka?',
            'a': 'Periksa izin aplikasi di pengaturan smartphone Anda (Settings > Apps > PresensiKu > Permissions) dan pastikan izin Kamera telah diberikan akses ("Allow").'
          },
          {
            'q': 'Bagaimana jika saya lupa presensi pulang kemarin?',
            'a': 'Gunakan form "Pengajuan Koreksi Presensi" pada sub-layar ini. Pilih tanggal kemarin, tentukan jenis koreksi pulang, dan masukkan jam kepulangan sebenarnya.'
          },
          {
            'q': 'Berapa lama waktu persetujuan izin dan koreksi?',
            'a': 'Permohonan akan ditinjau oleh HR / Admin maksimal dalam kurun waktu 1x24 jam kerja.'
          }
        ]
      };
    } else if (endpoint.contains(ApiConstants.correctionList)) {
      return {
        'success': true,
        'data': [
          {
            'id': 1,
            'target_date': '2026-09-08',
            'correction_type': 'PULANG',
            'actual_time': '17:15:00',
            'reason': 'Lupa check-out karena langsung meeting mendadak.',
            'status': 'APPROVED'
          }
        ]
      };
    }

    return {'success': true, 'data': {}};
  }

  static Map<String, dynamic> _postMockFallback(String endpoint, Map<String, dynamic> body) {
    if (endpoint.contains(ApiConstants.login)) {
      final identifier = body['identifier']?.toString().trim() ?? 'Pengguna';
      final isEmail = identifier.contains('@');
      final displayName = isEmail ? identifier.split('@')[0] : identifier;
      return {
        'success': true,
        'message': 'Login berhasil',
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 1,
          'nip_nim': identifier,
          'name': displayName,
          'email': isEmail ? identifier : '$identifier@presensiku.com',
          'phone': '-',
          'role': 'user',
          'department_name': 'Pegawai',
          'schedule_name': 'Shift Reguler Pagi'
        }
      };
    } else if (endpoint.contains(ApiConstants.register)) {
      return {
        'success': true,
        'message': 'Pendaftaran akun berhasil. Silakan masuk dengan akun Anda.'
      };
    } else if (endpoint.contains(ApiConstants.submitLeave)) {
      return {
        'success': true,
        'message': 'Pengajuan permohonan izin berhasil dikirim ke Admin.'
      };
    } else if (endpoint.contains(ApiConstants.submitCorrection)) {
      return {
        'success': true,
        'message': 'Pengajuan koreksi presensi berhasil dikirim.'
      };
    }

    return {'success': true, 'message': 'Berhasil diproses.'};
  }
}
