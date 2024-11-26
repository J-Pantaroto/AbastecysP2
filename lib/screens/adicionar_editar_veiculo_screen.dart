import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdicionarEditarVeiculoScreen extends StatefulWidget {
  final String? veiculoId;

  const AdicionarEditarVeiculoScreen({Key? key, this.veiculoId})
      : super(key: key);

  @override
  State<AdicionarEditarVeiculoScreen> createState() =>
      _AdicionarEditarVeiculoScreenState();
}

class _AdicionarEditarVeiculoScreenState
    extends State<AdicionarEditarVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _placaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.veiculoId != null) {
      _carregarDadosVeiculo();
    }
  }

  Future<void> _carregarDadosVeiculo() async {
    try {
      final veiculo = await FirebaseFirestore.instance
          .collection('veiculos')
          .doc(widget.veiculoId)
          .get();

      if (veiculo.exists) {
        final dados = veiculo.data() as Map<String, dynamic>;
        _nomeController.text = dados['nome'] ?? '';
        _modeloController.text = dados['modelo'] ?? '';
        _anoController.text = dados['ano'] ?? '';
        _placaController.text = dados['placa'] ?? '';
      }
    } catch (e) {
      debugPrint('Erro ao carregar veículo: $e');
    }
  }

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Erro: usuário não autenticado.');
      return;
    }

    final veiculoData = {
      'nome': _nomeController.text.trim(),
      'modelo': _modeloController.text.trim(),
      'ano': _anoController.text.trim(),
      'placa': _placaController.text.trim(),
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.veiculoId == null) {
        await FirebaseFirestore.instance
            .collection('veiculos')
            .add(veiculoData);
      } else {
        await FirebaseFirestore.instance
            .collection('veiculos')
            .doc(widget.veiculoId)
            .update(veiculoData);
      }
      Navigator.pop(context); 
    } catch (e) {
      debugPrint('Erro ao salvar veículo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.veiculoId == null ? 'Adicionar Veículo' : 'Editar Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value!.isEmpty ? 'Informe o nome' : null,
                ),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (value) =>
                      value!.isEmpty ? 'Informe o modelo' : null,
                ),
                TextFormField(
                  controller: _anoController,
                  decoration: const InputDecoration(labelText: 'Ano'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Informe o ano' : null,
                ),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(labelText: 'Placa'),
                  validator: (value) =>
                      value!.isEmpty ? 'Informe a placa' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarVeiculo,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
