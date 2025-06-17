import 'package:app/screens/models/point.dart';
import 'package:app/screens/service/admin/edit_attendence.dart';
import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/service/user_service.dart';
import 'package:intl/intl.dart';

class AttendanceActionsScreen extends StatelessWidget {
  final int userId;
  final String userName;
  final UserService userService;

  const AttendanceActionsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userService,
  });

  Future<Map<String, Map<String, List<String>>>>
      _fetchGroupedAttendanceRecords() async {
    final records = await userService.getAttendanceRecords(userId);

    Map<String, Map<String, List<String>>> grouped = {};

    for (var record in records) {
      try {
        final timeString = record['time'] ?? record['created_at'];
        final time = DateTime.parse(timeString.toString());
        final type = record['type'] ?? 'Desconhecido';
        final dateKey = DateFormat('dd/MM/yyyy').format(time);
        final hourMinute = DateFormat('HH:mm').format(time);

        grouped.putIfAbsent(dateKey, () => {'Entrada': [], 'Saída': []});
        if (type == 'Entrada') {
          grouped[dateKey]!['Entrada']!.add(hourMinute);
        } else if (type == 'Saída') {
          grouped[dateKey]!['Saída']!.add(hourMinute);
        }
      } catch (e) {
        print('Erro ao processar registro: $e');
      }
    }

    return grouped;
  }

  List<String> generateDaysFromGrouped(
      Map<String, Map<String, List<String>>> grouped) {
    List<String> days = grouped.keys.toList();
    days.sort((a, b) => DateFormat('dd/MM/yyyy')
        .parse(a)
        .compareTo(DateFormat('dd/MM/yyyy').parse(b)));
    return days;
  }

  void _editAttendence(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAttendanceScreen(
          userId: userId,
          userName: userName,
          userService: userService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, List<String>>>>(
      future: _fetchGroupedAttendanceRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao carregar registros: ${snapshot.error}'),
            ),
          );
        }

        final grouped = snapshot.data ?? {};
        final monthDays = generateDaysFromGrouped(grouped);

        return Scaffold(
          backgroundColor: getBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: getBackgroundColor(context),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_calendar_rounded),
                onPressed: () => _editAttendence(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: PointCard(grouped: grouped, monthDays: monthDays),
          ),
        );
      },
    );
  }
}
