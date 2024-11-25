import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'historico_abastecimentos_screen.dart';
import 'adicionar_editar_veiculo_screen.dart';

class MeusVeiculosScreen extends StatelessWidget {
  const MeusVeiculosScreen({Key? key}) : super(key: key);

  Stream<QuerySnapshot> listarVeiculos() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('Usuário não autenticado!');
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('veiculos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Função para excluir o veículo
  Future<void> excluirVeiculo(BuildContext context, String veiculoId) async {
    final confirmarExclusao = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Veículo'),
          content:
              const Text('Tem certeza de que deseja excluir este veículo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmarExclusao == true) {
      try {
        await FirebaseFirestore.instance
            .collection('veiculos')
            .doc(veiculoId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo excluído com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir veículo: $e')),
        );
      }
    }
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

          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar veículos: ${snapshot.error}'));
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdicionarEditarVeiculoScreen(
                                veiculoId: veiculoId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.article),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoricoAbastecimentosScreen(
                                veiculoId: veiculoId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        excluirVeiculo(context, veiculoId);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HistoricoAbastecimentosScreen(veiculoId: veiculoId),
                    ),
                  );
                },
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
