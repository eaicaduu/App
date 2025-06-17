import 'package:flutter/material.dart';
import 'package:app/screens/service/user_service.dart';

class EditAttendanceScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final UserService userService;

  const EditAttendanceScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userService,
  });

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int selectedDay = DateTime.now().day;
  List<dynamic> results = [];

  List<int> years = List.generate(10, (index) => DateTime.now().year - index);
  List<int> months = List.generate(12, (index) => index + 1);
  List<int> days = List.generate(31, (index) => index + 1);

  Future<void> _fetchRecords() async {
    final response = await widget.userService.client
        .from('point')
        .select()
        .eq('user_id', widget.userId)
        .eq('year', selectedYear)
        .eq('month', selectedMonth)
        .eq('day', selectedDay)
        .order('id');

    setState(() {
      results = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ponto: ${widget.userName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedYear,
                    isExpanded: true,
                    onChanged: (value) => setState(() => selectedYear = value!),
                    items: years
                        .map((y) =>
                            DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMonth,
                    isExpanded: true,
                    onChanged: (value) =>
                        setState(() => selectedMonth = value!),
                    items: months
                        .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0'))))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedDay,
                    isExpanded: true,
                    onChanged: (value) => setState(() => selectedDay = value!),
                    items: days
                        .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.toString().padLeft(2, '0'))))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchRecords,
              child: const Text("Buscar pontos"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text("Nenhum ponto encontrado"))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, index) {
                        final r = results[index];
                        final h = r['hour'].toString().padLeft(2, '0');
                        final m = r['minute'].toString().padLeft(2, '0');
                        final s = r['second'].toString().padLeft(2, '0');
                        return ListTile(
                          title: Text('${r['type']} - $h:$m:$s'),
                          subtitle: Text('ID: ${r['id']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // aqui você pode abrir outra tela ou dialog para editar este ponto específico
                            },
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
