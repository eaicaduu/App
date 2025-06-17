import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/screens/service/user_service.dart';

class AttendanceService {
  final UserService userService;

  AttendanceService(this.userService);

  Future<List<String>> loadAllAttendanceRecords(int userId) async {
    final records = await userService.getAttendanceRecords(userId);

    return records.map((record) {
      DateTime time;
      if (record['time'] is String) {
        time = DateTime.parse(record['time']);
      } else {
        time = record['time'];
      }

      final type = record['type'];
      final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(time);
      return '$type: $formattedTime';
    }).toList();
  }

  Future<String?> recordAttendance(int userId) async {
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

    final records = await userService.getAttendanceRecords(userId);
    final dailyRecords = records.where((record) {
      DateTime time;
      if (record['time'] is String) {
        time = DateTime.parse(record['time']).toUtc();
      } else if (record['time'] is DateTime) {
        time = record['time'].toUtc();
      } else {
        return false;
      }
      return time.isAfter(todayStart) && time.isBefore(todayEnd);
    }).toList();

    final entradas = dailyRecords.where((r) => r['type'] == 'Entrada').length;
    final saidas = dailyRecords.where((r) => r['type'] == 'Saída').length;

    String attendanceType;
    if (dailyRecords.isEmpty || dailyRecords.last['type'] == 'Saída') {
      if (entradas >= 2) {
        return 'Limite diário atingido!';
      }
      attendanceType = 'Entrada';
    } else {
      if (saidas >= 2) {
        return 'Limite diário atingido!';
      }
      attendanceType = 'Saída';
    }

    await userService.recordAttendance(userId, now, attendanceType);

    return null;
  }

  Future<void> saveLastRecorded(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    prefs.setInt('lastRecorded_$userId', now.millisecondsSinceEpoch);
  }

  Future<void> clearLastRecorded(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('lastRecorded_$userId');
  }
}
