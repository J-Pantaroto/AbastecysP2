import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeusVeiculosScreen extends StatelessWidget {
  const MeusVeiculosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    const String userId = "exampleUserId";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(userId)
            .collection('veiculos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum veículo cadastrado.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final veiculo = snapshot.data!.docs[index];
              return ListTile(
                title: Text(veiculo['nome']),
                subtitle: Text('Modelo: ${veiculo['modelo']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    firestore
                        .collection('users')
                        .doc(userId)
                        .collection('veiculos')
                        .doc(veiculo.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
