import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppBarPointScreen extends StatelessWidget implements PreferredSizeWidget {
  final int selectedMonth;
  final int selectedYear;
  final Function(int month, int year) onFilterChanged;

  const AppBarPointScreen({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onFilterChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final List<int> years =
        List.generate(10, (index) => DateTime.now().year - 5 + index);
    final List<int> months = List.generate(12, (index) => index + 1);

    return AppBar(
      backgroundColor: getBackgroundColor(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${DateFormat.MMMM('pt_BR').format(DateTime(0, selectedMonth)).toUpperCase()} $selectedYear',
            style: const TextStyle(fontSize: 18),
          ),
          Row(
            children: [
              DropdownButton<int>(
                value: selectedMonth,
                dropdownColor: getBackgroundColor(context),
                items: months.map((month) {
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(
                      DateFormat.MMMM('pt_BR')
                          .format(DateTime(0, month))
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (month) {
                  if (month != null) {
                    onFilterChanged(month, selectedYear);
                  }
                },
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: selectedYear,
                dropdownColor: getBackgroundColor(context),
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (year) {
                  if (year != null) {
                    onFilterChanged(selectedMonth, year);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
