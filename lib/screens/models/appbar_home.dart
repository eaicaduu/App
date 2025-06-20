import 'dart:async';
import 'package:app/screens/admin_screen.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBarHomeScreen extends StatefulWidget implements PreferredSizeWidget {
  final int userId;
  const AppBarHomeScreen({super.key, required this.userId});

  @override
  AppBarHomeScreenState createState() => AppBarHomeScreenState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppBarHomeScreenState extends State<AppBarHomeScreen> {
  late String horaAtual;
  Timer? timer;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    atualizarHora();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      atualizarHora();
    });

    verificarAdmin();
  }

  void atualizarHora() {
    final agora = DateTime.now();
    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    final segundo = agora.second.toString().padLeft(2, '0');
    setState(() {
      horaAtual = '$hora:$minuto:$segundo';
    });
  }

  Future<void> verificarAdmin() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('admin')
          .eq('id', widget.userId)
          .single();

      if (response.isNotEmpty) {
        setState(() {
          isAdmin = response['admin'] == true;
        });
      }
    } catch (e) {
      setState(() {
        isAdmin = false;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: getBackgroundColor(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: isAdmin
          ? IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin',
              iconSize: 32,
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AdminScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var tween = Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
            )
          : null,
      title: Text(
        horaAtual,
        style: const TextStyle(
          fontSize: 30,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton.icon(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();

            if (!mounted) return;
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Sair',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}
