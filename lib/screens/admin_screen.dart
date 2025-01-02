import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/user_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final UserService userService = UserService(Supabase.instance.client);
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final fetchedUsers = await userService.getUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  Future<void> _downloadAttendanceRecords(int userId, String userName) async {
    final records = await userService.getAttendanceRecords(userId);

    final List<String> attendanceRecords = records.map((record) {
      final time = DateTime.parse(record['time']);
      final type = record['type'];
      final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(time);
      return '$type: $formattedTime';
    }).toList();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Registros de Ponto - $userName',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              ...attendanceRecords.map(
                (record) =>
                    pw.Text(record, style: const pw.TextStyle(fontSize: 14)),
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

  void _showCreateUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Novo Funcionário'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome Completo'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Criar'),
              onPressed: () async {
                String nome = nameController.text.trim();
                await userService.createUser(nome);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                await _fetchUsers();
              },
            ),
          ],
        );
      },
    );
  }

  void _editUser(int userId) {
    final TextEditingController nameController = TextEditingController();
    final user = users.firstWhere((user) => user['id'] == userId);
    nameController.text = user['name'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Funcionário'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome Completo'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () async {
                String novoNome = nameController.text.trim();
                if (novoNome.isNotEmpty) {
                  try {
                    await userService.updateUser(userId.toString(), novoNome);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    await _fetchUsers();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Funcionário atualizado com sucesso!')),
                    );
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar usuário: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('O nome não pode estar vazio.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int userId, String userName) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Deseja excluir $userName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () async {
                try {
                  await userService.deleteUser(userId);
                  setState(() {
                    users.removeWhere((user) => user['id'] == userId);
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Funcionário excluído com sucesso!')),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewAttendanceRecords(int userId, String userName) async {
    final records = await userService.getAttendanceRecords(userId);

    final List<String> attendanceRecords = records.map((record) {
      final time = DateTime.parse(record['time']);
      final type = record['type'];
      final formattedTime = DateFormat('dd/MM/yyyy HH:mm:ss').format(time);
      return '$type: $formattedTime';
    }).toList();

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registros de Ponto - $userName'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('GlobalNet Admin', style: TextStyle(fontSize: 28))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 34,
            onPressed: () {
              _showCreateUserDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user['name'], style: const TextStyle(fontSize: 24)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                  ),
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  iconSize: 35,
                  onPressed: () {
                    _editUser(user['id']);
                  },
                ),
                ),
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                  ),
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 35,
                  onPressed: () {
                    _deleteUser(user['id'], user['name']);
                  },
                ),
                ),
          Container(
          padding: const EdgeInsets.all(1),
          decoration: const BoxDecoration(
          ),
          child:IconButton(
                  icon: const Icon(Icons.calendar_today),
                  iconSize: 35,
                  onPressed: () {
                    _viewAttendanceRecords(user['id'], user['name']);
                  },
                ),
          ),
          Container(
          padding: const EdgeInsets.all(1),
          decoration: const BoxDecoration(
          ),
          child:IconButton(
                  icon: const Icon(Icons.download),
                  iconSize: 35,
                  onPressed: () {
                    _downloadAttendanceRecords(user['id'], user['name']);
                  },
                ),
          ),
              ],
            ),
          );
        },
      ),
    );
  }
}
