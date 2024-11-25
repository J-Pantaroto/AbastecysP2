import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showError(_translateFirebaseError(e.code));
    } catch (e) {
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    }
  }

  Future<void> _showResetPasswordDialog() async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Recuperar Senha',
          style: TextStyle(color: Color(0xFFD0BCFF)),
        ),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Digite seu e-mail',
            labelStyle: TextStyle(color: Color(0xFFD0BCFF)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD0BCFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFFD0BCFF))),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira um e-mail válido.')),
                );
                return;
              }
              Navigator.pop(context);
              await _resetPassword(email);
            },
            child: const Text('Enviar', style: TextStyle(color: Color(0xFFD0BCFF))),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de recuperação enviado!')),
      );
    } catch (e) {
      _showError('Erro ao enviar e-mail de recuperação.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _translateFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      default:
        return 'Erro desconhecido. Tente novamente.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF6650A4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Color(0xFFD0BCFF)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0BCFF)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Color(0xFFD0BCFF)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0BCFF)),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6650A4),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showResetPasswordDialog,
              child: const Text(
                'Esqueceu sua senha?',
                style: TextStyle(
                  color: Color(0xFFD0BCFF),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
