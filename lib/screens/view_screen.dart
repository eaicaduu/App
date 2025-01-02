import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../service/user_service.dart';

class ViewScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const ViewScreen({super.key, required this.userId, required this.userName});

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<String> attendanceRecords = [];
  bool isEntry = true;
  bool isButtonEnabled = true;
  Timer? _timer;
  late UserService userService;

  @override
  void initState() {
    super.initState();
    userService = UserService(Supabase.instance.client);
    _checkButtonStatus();
    _loadAttendanceRecords();
  }

  Future<void> _checkButtonStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRecorded = prefs.getInt('lastRecorded_${widget.userId}') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastRecorded != 0 && now - lastRecorded < 60000) {
      setState(() {
        isButtonEnabled = false;
      });

      final remainingTime = 60000 - (now - lastRecorded);
      _timer = Timer(Duration(milliseconds: remainingTime), () {
        if (mounted) {
          setState(() {
            isButtonEnabled = true;
          });
          prefs.remove('lastRecorded_${widget.userId}');
        }
      });
    } else {
      setState(() {
        isButtonEnabled = true;
      });
    }
  }

  Future<void> _recordAttendance() async {
    if (!isButtonEnabled) return;

    setState(() {
      isButtonEnabled = false;
    });

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    try {
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final records = await userService.getAttendanceRecords(widget.userId);
      final dailyRecords = records.where((record) {
        final time = DateTime.parse(record['time']);
        return time.isAfter(todayStart) && time.isBefore(todayEnd);
      }).toList();

      if ((isEntry &&
              dailyRecords.where((r) => r['type'] == 'Entrada').length >= 2) ||
          (!isEntry &&
              dailyRecords.where((r) => r['type'] == 'Saída').length >= 2)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Limite diário atingido!')),
        );
        setState(() {
          isButtonEnabled = true;
        });
        return;
      }

      String attendanceType;
      if (dailyRecords.isNotEmpty) {
        final lastRecordType = dailyRecords.last['type'];
        attendanceType = lastRecordType == 'Entrada' ? 'Saída' : 'Entrada';
      } else {
        attendanceType = 'Entrada';
      }

      await userService.recordAttendance(widget.userId, now, attendanceType);
      setState(() {
        attendanceRecords.add(
            '$attendanceType: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(now)}');
        isEntry = attendanceType == 'Entrada';
      });

      prefs.setInt('lastRecorded_${widget.userId}', now.millisecondsSinceEpoch);

      _timer = Timer(const Duration(seconds: 60), () {
        if (mounted) {
          setState(() {
            isButtonEnabled = true;
          });
          prefs.remove('lastRecorded_${widget.userId}');
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar ponto: $e')),
      );
      setState(() {
        isButtonEnabled = true;
      });
    }
  }

  Future<void> _loadAttendanceRecords() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final records = await userService.getAttendanceRecords(widget.userId);

    final dailyRecords = records.where((record) {
      final time = DateTime.parse(record['time']);
      return time.isAfter(todayStart) && time.isBefore(todayEnd);
    }).toList();

    if (mounted) {
      setState(() {
        attendanceRecords.clear();
        for (var record in dailyRecords) {
          final time = DateTime.parse(record['time']);
          final type = record['type'];
          final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(time);
          attendanceRecords.add('$type: $formattedTime');
        }
      });
    }
  }

  Future<void> _viewAttendanceRecords() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registros de Ponto'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(attendanceRecords[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ponto ${widget.userName}', style: TextStyle(fontSize: 25)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: isButtonEnabled ? _recordAttendance : null,
                  icon: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    'Bater Ponto',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _viewAttendanceRecords,
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text('Visualizar',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Horários Registrados:',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceRecords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      attendanceRecords[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
