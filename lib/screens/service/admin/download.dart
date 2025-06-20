import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app/screens/service/user_service.dart';

class AttendanceDay {
  final String date;
  final String? entryTime;
  final String? exitTime;

  AttendanceDay({required this.date, this.entryTime, this.exitTime});
}

Future<void> downloadAttendanceRecords(
    int userId,
    String userName,
    UserService userService,
    String empresa,
    int mes,
    int ano,
    String cargo,
    String horario) async {
  final pdf = pw.Document();
  final nomeMes = DateFormat.MMMM('pt_BR').format(DateTime(ano, mes));
  
  final records = await userService.getAttendanceRecords(userId);

  final Map<int, List<Map<String, dynamic>>> registrosPorDia = {};
  for (var record in records) {
    final DateTime time = DateTime.parse(record['time'].toString());
    if (time.month == 6) {
      registrosPorDia.putIfAbsent(time.day, () => []).add(record);
    }
  }

  Map<String, String?> obterTurnos(List<Map<String, dynamic>> registros) {
    registros
        .sort((a, b) => a['time'].toString().compareTo(b['time'].toString()));

    String? entradaManha,
        saidaManha,
        entradaTarde,
        saidaTarde,
        entradaExtra,
        saidaExtra;

    for (var r in registros) {
      final DateTime hora = DateTime.parse(r['time'].toString());
      final String horaStr = DateFormat('HH:mm').format(hora);

      if (hora.hour < 12) {
        if (r['type'] == 'Entrada' && entradaManha == null)
          entradaManha = horaStr;
        if (r['type'] == 'Saida' && saidaManha == null) saidaManha = horaStr;
      } else if (hora.hour < 18) {
        if (r['type'] == 'Entrada' && entradaTarde == null)
          entradaTarde = horaStr;
        if (r['type'] == 'Saida' && saidaTarde == null) saidaTarde = horaStr;
      } else {
        if (r['type'] == 'Entrada' && entradaExtra == null)
          entradaExtra = horaStr;
        if (r['type'] == 'Saida' && saidaExtra == null) saidaExtra = horaStr;
      }
    }

    return {
      'entradaManha': entradaManha,
      'saidaManha': saidaManha,
      'entradaTarde': entradaTarde,
      'saidaTarde': saidaTarde,
      'entradaExtra': entradaExtra,
      'saidaExtra': saidaExtra,
    };
  }

  void adicionarPagina(int inicio, int fim, String quinzena) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('EMPRESA: $empresa'),
              pw.Text('FUNCIONÁRIO: $userName'),
              pw.Text('CARGO: $cargo'),
              pw.Text('HORÁRIO: $horario'),
              pw.Text('MÊS: ${toBeginningOfSentenceCase(nomeMes)} / $ano'),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('$quinzena QUINZENA',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FixedColumnWidth(25),
                  1: pw.FixedColumnWidth(45),
                  2: pw.FixedColumnWidth(45),
                  3: pw.FixedColumnWidth(45),
                  4: pw.FixedColumnWidth(45),
                  5: pw.FixedColumnWidth(45),
                  6: pw.FixedColumnWidth(45),
                  7: pw.FixedColumnWidth(25),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text(''),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 0),
                        child: pw.Text('MANHÃ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        // ocupa visualmente as duas células (Entrada e Saída)
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 0),
                        child: pw.Text('MANHÃ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        // ocupa visualmente as duas células (Entrada e Saída)
                      ), // <- deixamos vazia só pra manter a estrutura
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 0),
                        child: pw.Text('TARDE',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 0),
                        child: pw.Text('TARDE',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 0),
                        child: pw.Text('EXTRA',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.symmetric(horizontal: 0),
                        child: pw.Text('EXTRA',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Center(
                          child: pw.Text('DIA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('ENTRADA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('SAÍDA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('ENTRADA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('SAÍDA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('ENTRADA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('SAÍDA',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Center(
                          child: pw.Text('H',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  for (int i = inicio; i <= fim; i++)
                    () {
                      final registros = registrosPorDia[i] ?? [];
                      final turnos = obterTurnos(registros);

                      return pw.TableRow(
                        children: [
                          pw.Center(child: pw.Text('$i')),
                          pw.Center(
                              child: pw.Text(turnos['entradaManha'] ?? '')),
                          pw.Center(child: pw.Text(turnos['saidaManha'] ?? '')),
                          pw.Center(
                              child: pw.Text(turnos['entradaTarde'] ?? '')),
                          pw.Center(child: pw.Text(turnos['saidaTarde'] ?? '')),
                          pw.Center(
                              child: pw.Text(turnos['entradaExtra'] ?? '')),
                          pw.Center(child: pw.Text(turnos['saidaExtra'] ?? '')),
                          pw.Center(child: pw.Text('')),
                        ],
                      );
                    }(),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('RECEBÍ O SALDO ACIMA MENCIONADO'),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Container(height: 1, width: 200, color: PdfColors.black),
                    pw.Text('ASSINATURA DO EMPREGADO'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  adicionarPagina(1, 15, '1ª');
  adicionarPagina(16, 31, '2ª');

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'cartao_ponto_$userName.pdf',
  );
}
