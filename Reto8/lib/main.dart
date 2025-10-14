import 'package:flutter/material.dart';
import 'screens/company_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directorio de Empresas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CompanyListScreen(),
    );
  }
}
