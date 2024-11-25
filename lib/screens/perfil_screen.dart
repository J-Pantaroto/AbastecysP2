import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_perfil_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF6650A4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Usuário:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD0BCFF)),
            ),
            const SizedBox(height: 10),
            Text('Nome: ${user?.displayName ?? 'Não disponível'}', style: const TextStyle(color: Color(0xFFD0BCFF))),
            const SizedBox(height: 5),
            Text('E-mail: ${user?.email ?? 'Não disponível'}', style: const TextStyle(color: Color(0xFFD0BCFF))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6650A4),
              ),
              icon: const Icon(Icons.edit, color: Color(0xFFD0BCFF)),
              label: const Text('Editar Informações'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditPerfilScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
