import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'historico_abastecimentos_screen.dart';
import 'adicionar_editar_veiculo_screen.dart';

class MeusVeiculosScreen extends StatelessWidget {
  const MeusVeiculosScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> listarVeiculos() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('Erro: usuário não autenticado.');
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('veiculos')
        .where('email', isEqualTo: user.email)
        .snapshots();
  }

  Future<double> _calcularMediaConsumo(String veiculoId) async {
    final abastecimentosSnapshot = await FirebaseFirestore.instance
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .orderBy('data')
        .get();

    if (abastecimentosSnapshot.docs.isEmpty) {
      return 0.0;
    }

    double consumoTotal = 0.0;
    int quilometragemAnterior = 0;

    for (var abastecimento in abastecimentosSnapshot.docs) {
      final dados = abastecimento.data();
      int quilometragemAtual = dados['quilometragemAtual'];
      double litros = dados['litros'];

      if (quilometragemAnterior != 0) {
        consumoTotal += (quilometragemAtual - quilometragemAnterior) / litros;
      }

      quilometragemAnterior = quilometragemAtual;
    }

    return consumoTotal / abastecimentosSnapshot.docs.length; // Média
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listarVeiculos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar veículos: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum veículo cadastrado.'));
          }

          final veiculos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              final veiculoId = veiculo.id;
              final dados = veiculo.data() as Map<String, dynamic>;

              return FutureBuilder<double>(
                future: _calcularMediaConsumo(veiculoId),
                builder: (context, mediaSnapshot) {
                  if (mediaSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final mediaConsumo = mediaSnapshot.data ?? 0.0;

                  return ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text('${dados['nome']} (${dados['modelo']})'),
                    subtitle: Text(
                      'Placa: ${dados['placa']} \nMédia: ${mediaConsumo.toStringAsFixed(2)} km/L',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdicionarEditarVeiculoScreen(
                                        veiculoId: veiculoId),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.article),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HistoricoAbastecimentosScreen(
                                        veiculoId: veiculoId),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/adicionar-veiculo');
        },
      ),
    );
  }
}
