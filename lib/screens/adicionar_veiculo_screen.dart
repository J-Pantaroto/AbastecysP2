import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdicionarVeiculoScreen extends StatefulWidget {
  const AdicionarVeiculoScreen({super.key});

  @override
  State<AdicionarVeiculoScreen> createState() => _AdicionarVeiculoScreenState();
}

class _AdicionarVeiculoScreenState extends State<AdicionarVeiculoScreen> {
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _placaController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = "exampleUserId"; // Substitua pelo ID real do usuário.

  Future<void> _adicionarVeiculo() async {
    if (_nomeController.text.isEmpty ||
        _modeloController.text.isEmpty ||
        _anoController.text.isEmpty ||
        _placaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('veiculos')
        .add({
      'nome': _nomeController.text,
      'modelo': _modeloController.text,
      'ano': _anoController.text,
      'placa': _placaController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veículo adicionado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _modeloController,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            TextField(
              controller: _anoController,
              decoration: const InputDecoration(labelText: 'Ano'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _placaController,
              decoration: const InputDecoration(labelText: 'Placa'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _adicionarVeiculo,
              child: const Text('Adicionar Veículo'),
            ),
          ],
        ),
      ),
    );
  }
}
