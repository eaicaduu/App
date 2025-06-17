import 'package:flutter/material.dart';
import 'package:app/screens/service/user_service.dart';

class DeleteUserScreen extends StatelessWidget {
  final int userId;
  final String userName;
  final UserService userService;

  const DeleteUserScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userService,
  });

  Future<void> _deleteUser(BuildContext context) async {
    try {
      await userService.deleteUser(userId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionário excluído com sucesso!')),
        );
        Navigator.of(context).pop(true); // Retorna true para sucesso
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar Exclusão'),
      content: Text('Deseja excluir $userName?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => _deleteUser(context),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
