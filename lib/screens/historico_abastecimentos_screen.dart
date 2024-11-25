import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoricoAbastecimentosScreen extends StatelessWidget {
  final String veiculoId;

  const HistoricoAbastecimentosScreen({Key? key, required this.veiculoId})
      : super(key: key);

  Stream<QuerySnapshot> listarAbastecimentos() {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .where('email', isEqualTo: userEmail)
        .orderBy('data', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Abastecimentos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listarAbastecimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Erro ao carregar os abastecimentos: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum abastecimento registrado.'),
            );
          }

          final abastecimentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final abastecimento = abastecimentos[index];
              final dados = abastecimento.data() as Map<String, dynamic>;
              final data = (dados['data'] as Timestamp).toDate();
              final litros = dados['litros'] ?? 0.0; // Campo de litros
              final quilometragem = dados['quilometragemAtual'] ?? 0;

              return ListTile(
                leading: const Icon(Icons.local_gas_station),
                title: Text('Data: ${data.day}/${data.month}/${data.year}'),
                subtitle: Text(
                  'Litros: $litros | Km: $quilometragem',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
