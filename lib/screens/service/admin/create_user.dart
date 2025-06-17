import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/service/user_service.dart';

class CreateUserDialog extends StatefulWidget {
  final UserService userService;
  final Function() onUserCreated;

  const CreateUserDialog({
    super.key,
    required this.userService,
    required this.onUserCreated,
  });

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _nameError;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    setState(() {
      _nameError = null;
      _usernameError = null;
      _passwordError = null;
    });

    final nome = nameController.text.trim();
    final username = usernameController.text.trim();
    final senha = passwordController.text.trim();

    bool hasError = false;

    if (nome.isEmpty) {
      _nameError = 'Preencha o nome completo';
      hasError = true;
    }
    if (username.isEmpty) {
      _usernameError = 'Preencha o nome de usuário';
      hasError = true;
    }
    if (senha.isEmpty) {
      _passwordError = 'Preencha a senha';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final exists = await widget.userService.usernameExists(username);
    if (exists) {
      setState(() {
        _usernameError = 'Nome de usuário já está em uso';
      });
      return;
    }

    await widget.userService.createUser(nome, username, senha);
    widget.onUserCreated();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  InputDecoration _inputDecoration({required String label, String? error}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      errorText: error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: getBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Novo',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:
                  _inputDecoration(label: 'Nome Completo', error: _nameError),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: usernameController,
              decoration:
                  _inputDecoration(label: 'Usuário', error: _usernameError),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration:
                  _inputDecoration(label: 'Senha', error: _passwordError)
                      .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: _passwordError != null ? Colors.red : Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _createUser,
          child: const Text(
            'Criar',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
