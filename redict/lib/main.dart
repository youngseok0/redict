import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Redict',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(), // 홈 화면으로 이동
    );
  }
}
