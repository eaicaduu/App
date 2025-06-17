import 'package:app/screens/models/appbar_point.dart';
import 'package:app/screens/models/point.dart';
import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';

class PointScreen extends StatefulWidget {
  final Map<String, Map<String, List<String>>> groupedAttendanceRecords;
  final List<String> allDaysOfMonth;
  final String userName;

  const PointScreen({
    super.key,
    required this.groupedAttendanceRecords,
    required this.allDaysOfMonth,
    required this.userName,
  });

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  List<String> generateDaysOfMonth(int month, int year) {
    final daysCount = DateUtils.getDaysInMonth(year, month);
    return List.generate(daysCount, (index) {
      final day = index + 1;
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDays = generateDaysOfMonth(selectedMonth, selectedYear);

    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      appBar: AppBarPointScreen(
        selectedMonth: selectedMonth,
        selectedYear: selectedYear,
        onFilterChanged: (month, year) {
          setState(() {
            selectedMonth = month;
            selectedYear = year;
          });
        },
      ),
      body: PointCard(
        grouped: widget.groupedAttendanceRecords,
        monthDays: filteredDays,
      ),
    );
  }
}
