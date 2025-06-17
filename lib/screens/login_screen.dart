import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/service/values.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    loadRememberMe();
  }

  Future<void> loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final savedUsername = prefs.getString('saved_username') ?? '';
    final savedPassword = prefs.getString('saved_password') ?? '';
    final savedUserId = prefs.getInt('saved_userid') ?? 0;

    if (rememberMe &&
        savedUsername.isNotEmpty &&
        savedPassword.isNotEmpty &&
        savedUserId != 0) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomeScreen(userName: savedUsername, userId: savedUserId),
        ),
      );
    } else {
      setState(() {
        _rememberMe = rememberMe;
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
      });
    }
  }

  Future<void> saveRememberMe(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text.trim());
      await prefs.setString('saved_password', _passwordController.text.trim());
      await prefs.setInt('saved_userid', userId);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.remove('saved_userid');
    }
  }

  Future<void> login(BuildContext context) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .single();

      if (response.isNotEmpty) {
        final username = response['username'];
        final userid = response['id'];

        await saveRememberMe(userid);

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(
                    userName: username,
                    userId: userid,
                  )),
        );
      } else {
        setState(() {
          _errorMessage = 'Usuário ou senha incorretos.';
        });
      }
    } on PostgrestException {
      setState(() {
        _errorMessage = 'Usuário ou senha inválidos.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao conectar com o servidor.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: getBackgroundColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Usuário',
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : Colors.blue,
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : Colors.grey,
                              width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(Icons.person,
                            color: _errorMessage != null
                                ? Colors.red
                                : Colors.blue),
                        errorText: _errorMessage,
                      ),
                      onSubmitted: (_) => login(context),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        labelStyle: const TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : Colors.blue,
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : Colors.grey,
                              width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: _errorMessage != null
                                ? Colors.red
                                : Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        errorText: _errorMessage,
                      ),
                      onSubmitted: (_) => login(context),
                    ),
                    const SizedBox(height: 16),
                    Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Lembrar-me',
                          style: TextStyle(color: Colors.black87),
                        ),
                        value: _rememberMe,
                        activeColor: Colors.blue,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                        shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
