import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbastecimentosScreen extends StatefulWidget {
  const AbastecimentosScreen({Key? key}) : super(key: key);

  @override
  _AbastecimentosScreenState createState() => _AbastecimentosScreenState();
}

class _AbastecimentosScreenState extends State<AbastecimentosScreen> {
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _quilometragemController =
      TextEditingController();
  String? _selectedVeiculoId;

  Future<void> _cadastrarAbastecimento() async {
    if (_selectedVeiculoId == null ||
        _litrosController.text.isEmpty ||
        _quilometragemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
      return;
    }

    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        throw 'Usuário não autenticado!';
      }

      print('Cadastrando abastecimento para veículo ID: $_selectedVeiculoId');

      await FirebaseFirestore.instance
          .collection('veiculos')
          .doc(_selectedVeiculoId)
          .collection('abastecimentos')
          .add({
        'litros': double.parse(_litrosController.text),
        'quilometragemAtual': int.parse(_quilometragemController.text),
        'data': FieldValue.serverTimestamp(),
        'email': userEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abastecimento cadastrado com sucesso!')),
      );
      _litrosController.clear();
      _quilometragemController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar abastecimento: $e')),
      );
      print('Erro ao cadastrar abastecimento: $e');
    }
  }

  Stream<QuerySnapshot> _listarVeiculos() {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('veiculos')
        .where('email', isEqualTo: userEmail)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimentos'),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _listarVeiculos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar veículos'));
              }

              final veiculos = snapshot.data?.docs ?? [];
              return DropdownButton<String>(
                hint: const Text("Selecione o veículo"),
                value: _selectedVeiculoId,
                onChanged: (value) {
                  setState(() {
                    _selectedVeiculoId = value;
                  });
                },
                items: veiculos.map((veiculo) {
                  final dados = veiculo.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: veiculo.id,
                    child: Text('${dados['nome']} (${dados['modelo']})'),
                  );
                }).toList(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _litrosController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Litros abastecidos'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _quilometragemController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Quilometragem atual'),
            ),
          ),
          ElevatedButton(
            onPressed: _cadastrarAbastecimento,
            child: const Text('Cadastrar Abastecimento'),
          ),
        ],
      ),
    );
  }
}
