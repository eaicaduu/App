import 'package:app/screens/models/appbar_home.dart';
import 'package:app/screens/models/body_home.dart';
import 'package:app/screens/service/values.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'service/user_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const HomeScreen({super.key, required this.userName, required this.userId});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final UserService userService = UserService(Supabase.instance.client);
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: getBackgroundColor(context),
        appBar: AppBarHomeScreen(
          userId: widget.userId,
        ),
        body: BodyHomeScreen(
          userId: widget.userId,
          userName: widget.userName,
        ));
  }
}
