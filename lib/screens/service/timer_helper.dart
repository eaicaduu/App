import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TimerHelper {
  Timer? timer;

  Future<bool> isButtonEnabled(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRecorded = prefs.getInt('lastRecorded_$userId') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastRecorded != 0 && now - lastRecorded < 60000) {
      return false;
    }
    return true;
  }

  void startCooldown(int userId, Function enableButtonCallback) async {
    final prefs = await SharedPreferences.getInstance();
    final lastRecorded = prefs.getInt('lastRecorded_$userId') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final remainingTime = 60000 - (now - lastRecorded);

    timer = Timer(Duration(milliseconds: remainingTime), () async {
      enableButtonCallback();
      prefs.remove('lastRecorded_$userId');
    });
  }

  void dispose() {
    timer?.cancel();
  }
}
