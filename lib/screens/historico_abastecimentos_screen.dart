import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricoAbastecimentosScreen extends StatelessWidget {
  final String veiculoId;

  const HistoricoAbastecimentosScreen({Key? key, required this.veiculoId})
      : super(key: key);

  Stream<QuerySnapshot> listarAbastecimentos() {
    return FirebaseFirestore.instance
        .collection('veiculos')
        .doc(veiculoId)
        .collection('abastecimentos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Abastecimentos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listarAbastecimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum abastecimento registrado.'));
          }

          final abastecimentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final abastecimento = abastecimentos[index];
              final dados = abastecimento.data() as Map<String, dynamic>;

              final data = (dados['data'] as Timestamp).toDate();
              final litros = dados['quantidadeLitros'];
              final quilometragem = dados['quilometragemAtual'];

              return ListTile(
                leading: Icon(Icons.local_gas_station),
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
