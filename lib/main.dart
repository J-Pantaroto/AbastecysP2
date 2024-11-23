import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:controle_abastecimento/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ControleAbastecimentoApp());
}

class ControleAbastecimentoApp extends StatelessWidget {
  const ControleAbastecimentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Abastecimento',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
