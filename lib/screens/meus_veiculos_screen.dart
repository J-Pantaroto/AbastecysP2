import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeusVeiculosScreen extends StatelessWidget {
  const MeusVeiculosScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> listarVeiculos() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('veiculos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Veículos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listarVeiculos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum veículo cadastrado.'));
          }

          final veiculos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];
              final veiculoId = veiculo.id;
              final dados = veiculo.data() as Map<String, dynamic>;

              return ListTile(
                leading: Icon(Icons.directions_car),
                title: Text('${dados['nome']} (${dados['modelo']})'),
                subtitle: Text('Placa: ${dados['placa']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(context, '/editar-veiculo',
                            arguments: veiculoId);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.article),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/historico-abastecimentos',
                          arguments: veiculoId,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/adicionar-veiculo');
        },
      ),
    );
  }
}
