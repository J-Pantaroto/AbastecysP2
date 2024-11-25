import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoricoAbastecimentosScreen extends StatelessWidget {
  const HistoricoAbastecimentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Referência ao Firestore e ID do usuário logado
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Verificar se o usuário está logado
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Histórico de Abastecimentos'),
        ),
        body: const Center(
          child: Text('Erro: Usuário não autenticado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Abastecimentos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(userId)
            .collection('abastecimentos')
            .orderBy('data', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum abastecimento registrado.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final abastecimento = snapshot.data!.docs[index];
              final DateTime dataAbastecimento =
                  (abastecimento['data'] as Timestamp).toDate();

              return ListTile(
                title: Text(
                  'Data: ${dataAbastecimento.toLocal().toString().substring(0, 16)}',
                ),
                subtitle: Text(
                  'Litros: ${abastecimento['litros']} - KM: ${abastecimento['quilometragem']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
