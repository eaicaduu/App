import 'package:app/screens/models/point.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase, DateFormat;
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/screens/service/user_service.dart';
import 'package:app/screens/point_screen.dart';
import 'package:app/screens/service/attendance_service.dart';
import 'package:app/screens/service/timer_helper.dart';

class BodyHomeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const BodyHomeScreen(
      {super.key, required this.userId, required this.userName});

  @override
  ViewScreenState createState() => ViewScreenState();
}

class ViewScreenState extends State<BodyHomeScreen> {
  List<String> attendanceRecords = [];
  bool isButtonEnabled = true;
  late AttendanceService attendanceService;
  late TimerHelper timerHelper;

  @override
  void initState() {
    super.initState();
    attendanceService =
        AttendanceService(UserService(Supabase.instance.client));
    timerHelper = TimerHelper();
    _initialize();
  }

  Future<void> _initialize() async {
    isButtonEnabled = await timerHelper.isButtonEnabled(widget.userId);
    if (!isButtonEnabled) {
      timerHelper.startCooldown(widget.userId, () {
        if (mounted) setState(() => isButtonEnabled = true);
      });
    }
    _loadAttendanceRecords();
  }

  Future<void> _loadAttendanceRecords() async {
    attendanceRecords =
        await attendanceService.loadAllAttendanceRecords(widget.userId);
    if (mounted) setState(() {});
  }

  Future<void> _recordAttendance() async {
    if (!isButtonEnabled) return;
    setState(() => isButtonEnabled = false);

    final error = await attendanceService.recordAttendance(widget.userId);
    if (error != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      setState(() => isButtonEnabled = true);
      return;
    }

    await attendanceService.saveLastRecorded(widget.userId);
    timerHelper.startCooldown(widget.userId, () {
      if (mounted) setState(() => isButtonEnabled = true);
    });

    await _loadAttendanceRecords();
  }

  List<String> generateMonthDays() {
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    return List.generate(totalDays, (i) => i + 1).map((day) {
      final date = DateTime(now.year, now.month, day);
      return DateFormat('yyyy-MM-dd').format(date);
    }).toList();
  }

  Future<void> viewAttendanceRecords() async {
    final grouped = await _groupedRecords();
    final allDays = generateMonthDays();
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return PointScreen(
            groupedAttendanceRecords: grouped,
            allDaysOfMonth: allDays,
            userName: widget.userName,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween =
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  Future<Map<String, Map<String, List<String>>>> _groupedRecords() async {
    final records =
        await attendanceService.loadAllAttendanceRecords(widget.userId);
    final Map<String, Map<String, List<String>>> grouped = {};
    for (var record in records) {
      final parts = record.split(': ');
      if (parts.length != 2) continue;
      final type = parts[0];
      final datetime = parts[1];
      final date = datetime.split(' ')[0];
      final time = datetime.split(' ')[1].substring(0, 5);
      grouped.putIfAbsent(date, () => {'Entrada': [], 'Saída': []});
      grouped[date]![type]?.add(time);
    }
    return grouped;
  }

  DateTime safeParseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr.trim());
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  void dispose() {
    timerHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Ponto Digital | Mês de ${toBeginningOfSentenceCase(DateFormat.MMMM('pt_BR').format(DateTime.now()))}',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: isButtonEnabled ? _recordAttendance : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.access_time, size: 28),
                    SizedBox(height: 6),
                    Text('Bater Ponto', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: viewAttendanceRecords,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.calendar_today, size: 28),
                    SizedBox(height: 6),
                    Text('Visualizar', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<Map<String, Map<String, List<String>>>>(
              future: _groupedRecords(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final grouped = snapshot.data!;
                final daysInDb = grouped.keys.toList();
                return PointCard(
                  grouped: grouped,
                  monthDays: daysInDb,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
