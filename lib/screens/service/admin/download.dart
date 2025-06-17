import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app/screens/service/user_service.dart'; // importe seu userService se necessário

class AttendanceDay {
  final String date;
  final String? entryTime;
  final String? exitTime;

  AttendanceDay({required this.date, this.entryTime, this.exitTime});
}

Future<void> downloadAttendanceRecords(
    int userId, String userName, UserService userService) async {
  final records = await userService.getAttendanceRecords(userId);

  final Map<String, AttendanceDay> groupedRecords = {};

  for (var record in records) {
    final dynamic rawTime = record['time'];
    final DateTime time =
        rawTime is DateTime ? rawTime : DateTime.parse(rawTime.toString());
    final type = record['type'];
    final dateStr = DateFormat('dd/MM/yyyy').format(time);
    final hourStr = DateFormat('HH:mm:ss').format(time);

    if (!groupedRecords.containsKey(dateStr)) {
      groupedRecords[dateStr] = AttendanceDay(date: dateStr);
    }

    if (type == 'Entrada') {
      groupedRecords[dateStr] = AttendanceDay(
        date: dateStr,
        entryTime: hourStr,
        exitTime: groupedRecords[dateStr]?.exitTime,
      );
    } else if (type == 'Saida') {
      groupedRecords[dateStr] = AttendanceDay(
        date: dateStr,
        entryTime: groupedRecords[dateStr]?.entryTime,
        exitTime: hourStr,
      );
    }
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Espelho de Ponto - $userName',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Data',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Entrada',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Saída',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...groupedRecords.values.map(
                  (record) => pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(record.date)),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(record.entryTime ?? '-')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(record.exitTime ?? '-')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'registro_ponto_$userName.pdf',
  );
}
