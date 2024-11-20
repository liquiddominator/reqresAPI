import 'package:flutter/material.dart';
import 'package:reqres_api_andres/Themes/app_theme.dart';
import 'package:reqres_api_andres/Views/user_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReqRes Users',
      theme: AppTheme.lightTheme,
      home: const UserListView(),
      debugShowCheckedModeBanner: false,
    );
  }
}