import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home_screen.dart';
import '../screens/meus_veiculos_screen.dart';
import '../screens/adicionar_editar_veiculo_screen.dart';
import '../screens/historico_abastecimentos_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/login_screen.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  Future<String?> obterVeiculoId() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('veiculos')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

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
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
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
            leading: const Icon(Icons.local_gas_station),
            title: const Text('Abastecimentos'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AbastecimentosScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Adicionar Veículo'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AdicionarEditarVeiculoScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico de Abastecimentos'),
            onTap: () async {
              final veiculoId = await obterVeiculoId();

              if (veiculoId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HistoricoAbastecimentosScreen(veiculoId: veiculoId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nenhum veículo encontrado')),
                );
              }
            },
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
