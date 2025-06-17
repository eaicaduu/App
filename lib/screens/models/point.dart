import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PointCard extends StatelessWidget {
  final Map<String, Map<String, List<String>>> grouped;
  final List<String> monthDays;

  const PointCard({super.key, required this.grouped, required this.monthDays});

  String extractDay(String dateStr) {
    try {
      DateTime date;
      if (dateStr.length == 10) {
        date = DateFormat('dd/MM/yyyy').parse(dateStr);
      } else if (dateStr.length == 8) {
        date = DateFormat('dd/MM/yy').parse(dateStr);
      } else {
        date = DateTime.now();
      }
      return date.day.toString().padLeft(2, '0');
    } catch (e) {
      return '--';
    }
  }

  Color invertColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

  Widget buildCell(String text) {
    return SizedBox(
      width: 50, // ajuste aqui a largura da coluna
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: getBackgroundColor(context),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          width: 2,
          color: invertColor(getBackgroundColor(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                SizedBox(
                    width: 50,
                    child: Center(
                        child: Text("Dia",
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                SizedBox(
                    width: 50,
                    child: Center(
                        child: Text("Entrada",
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                SizedBox(
                    width: 50,
                    child: Center(
                        child: Text("Saída",
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                SizedBox(
                    width: 50,
                    child: Center(
                        child: Text("Entrada",
                            style: TextStyle(fontWeight: FontWeight.bold)))),
                SizedBox(
                    width: 50,
                    child: Center(
                        child: Text("Saída",
                            style: TextStyle(fontWeight: FontWeight.bold)))),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: monthDays.length,
                itemBuilder: (context, index) {
                  final dayDate = monthDays[index];
                  final times =
                      grouped[dayDate] ?? {'Entrada': [], 'Saída': []};
                  final entradas = times['Entrada'] ?? [];
                  final saidas = times['Saída'] ?? [];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildCell(extractDay(dayDate)),
                        buildCell(entradas.isNotEmpty ? entradas[0] : "--"),
                        buildCell(saidas.isNotEmpty ? saidas[0] : "--"),
                        buildCell(entradas.length > 1 ? entradas[1] : "--"),
                        buildCell(saidas.length > 1 ? saidas[1] : "--"),
                      ],
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
