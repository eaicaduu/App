import 'package:app/screens/service/admin/attendence.dart';
import 'package:app/screens/service/admin/create_user.dart';
import 'package:app/screens/service/admin/delete_user.dart';
import 'package:app/screens/service/admin/download.dart';
import 'package:app/screens/service/admin/edit_user.dart';
import 'package:app/screens/service/user_service.dart';
import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  AdminScreenState createState() => AdminScreenState();
}

class AdminScreenState extends State<AdminScreen> {
  final UserService userService = UserService(Supabase.instance.client);
  List<Map<String, dynamic>> users = [];
  List<String> attendanceRecords = [];

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

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CreateUserDialog(
        userService: userService,
        onUserCreated: _fetchUsers,
      ),
    );
  }

  void _downloadAttendanceRecords(int userId, String userName) async {
    await downloadAttendanceRecords(userId, userName, userService);
  }

  void _deleteUser(int userId, String userName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteUserScreen(
        userId: userId,
        userName: userName,
        userService: userService,
      ),
    );
    if (result == true) {
      await _fetchUsers();
    }
  }

  void _viewAttendanceRecords(int userId, String userName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AttendanceActionsScreen(
          userId: userId,
          userName: userName,
          userService: userService,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));

          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  void _editUser(int userId, String currentName, String currentUsername,
      String currentPassword, bool isAdmin) async {
    final result = await showDialog(
      context: context,
      builder: (_) => EditUserScreen(
        userId: userId,
        currentName: currentName,
        currentUsername: currentUsername,
        currentPassword: currentPassword,
        isAdmin: isAdmin,
        userService: userService,
      ),
    );
    if (result == true) {
      await _fetchUsers();
    }
  }

  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: getBackgroundColor(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 32,
            onPressed: () => _showCreateUserDialog(context),
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          user['name']?.toString() ?? 'Sem Nome',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _actionButton(
                            icon: Icons.calendar_today,
                            tooltip: 'Ver Registros de Ponto',
                            color: Colors.blue,
                            onPressed: () => _viewAttendanceRecords(
                                user['id'], user['name']),
                          ),
                          _actionButton(
                            icon: Icons.download,
                            tooltip: 'Baixar Registros em PDF',
                            color: Colors.blue,
                            onPressed: () => _downloadAttendanceRecords(
                                user['id'], user['name']),
                          ),
                          _actionButton(
                            icon: Icons.edit,
                            tooltip: 'Editar',
                            color: Colors.blue,
                            onPressed: () => _editUser(
                              user['id'],
                              user['name'],
                              user['username'],
                              user['password'],
                              user['admin'] == true,
                            ),
                          ),
                          _actionButton(
                            icon: Icons.delete,
                            tooltip: 'Excluir',
                            color: Colors.red.shade700,
                            onPressed: () =>
                                _deleteUser(user['id'], user['name']),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
