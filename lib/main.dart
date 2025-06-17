import 'package:app/screens/login_screen.dart';
import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

const supabaseUrl = 'https://ibcbnnmvfqitssiwyiaz.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImliY2Jubm12ZnFpdHNzaXd5aWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk4MzE4MTIsImV4cCI6MjA2NTQwNzgxMn0.ncpBpo93AHV9u4e5EKs0qbkTSZsYPB_Kmyxpgn7jNek';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await initializeDateFormatting('pt_BR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: getBackgroundColor(context),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
    );
  }
}
