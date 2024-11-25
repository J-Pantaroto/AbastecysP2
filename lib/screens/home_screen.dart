import 'package:flutter/material.dart';
import 'meus_veiculos_screen.dart';
import 'adicionar_editar_veiculo_screen.dart';
import 'historico_abastecimentos_screen.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Abastecimento')),
      drawer: _buildDrawer(context),
      body: const Center(child: Text('Bem-vindo!')),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Usuário'),
            accountEmail: Text(user?.email ?? 'email@exemplo.com'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Meus Veículos'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MeusVeiculosScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerfilScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
