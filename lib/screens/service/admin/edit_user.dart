import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/service/user_service.dart';

class EditUserScreen extends StatefulWidget {
  final int userId;
  final String currentName;
  final String currentUsername;
  final String currentPassword;
  final bool isAdmin;
  final UserService userService;

  const EditUserScreen({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentUsername,
    required this.currentPassword,
    required this.isAdmin,
    required this.userService,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  String? _nameError;
  String? _usernameError;
  String? _passwordError;

  bool _obscurePassword = true;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    usernameController = TextEditingController(text: widget.currentUsername);
    passwordController = TextEditingController(text: widget.currentPassword);
    _isAdmin = widget.isAdmin;
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({required String label, String? error}) {
    return InputDecoration(
      labelText: label,
      errorText: error,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  void saveUser() async {
    setState(() {
      _nameError =
          nameController.text.trim().isEmpty ? 'Campo obrigatório' : null;
      _usernameError =
          usernameController.text.trim().isEmpty ? 'Campo obrigatório' : null;
      _passwordError =
          passwordController.text.trim().isEmpty ? 'Campo obrigatório' : null;
    });

    if (_nameError != null ||
        _usernameError != null ||
        _passwordError != null) {
      return;
    }

    try {
      await widget.userService.updateUser(
        widget.userId,
        nameController.text.trim(),
        usernameController.text.trim(),
        passwordController.text.trim(),
        _isAdmin,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Atualizado com sucesso!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar usuário: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: getBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Editar',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
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
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: _passwordError != null ? Colors.red : Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      value: _isAdmin,
                      focusColor: Colors.transparent,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text("Usuário"),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text("Administrador"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _isAdmin = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          onPressed: saveUser,
          child: const Text(
            'Salvar',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
