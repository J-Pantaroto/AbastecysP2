import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdicionarEditarVeiculoScreen extends StatefulWidget {
  final String? veiculoId;

  const AdicionarEditarVeiculoScreen({Key? key, this.veiculoId}) : super(key: key);

  @override
  State<AdicionarEditarVeiculoScreen> createState() => _AdicionarEditarVeiculoScreenState();
}

class _AdicionarEditarVeiculoScreenState extends State<AdicionarEditarVeiculoScreen> {
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
    final veiculo = await FirebaseFirestore.instance
        .collection('veiculos')
        .doc(widget.veiculoId)
        .get();

    if (veiculo.exists) {
      final dados = veiculo.data() as Map<String, dynamic>;
      _nomeController.text = dados['nome'];
      _modeloController.text = dados['modelo'];
      _anoController.text = dados['ano'];
      _placaController.text = dados['placa'];
    }
  }

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final dados = {
      'nome': _nomeController.text,
      'modelo': _modeloController.text,
      'ano': _anoController.text,
      'placa': _placaController.text,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (widget.veiculoId == null) {
      await FirebaseFirestore.instance.collection('veiculos').add(dados);
    } else {
      await FirebaseFirestore.instance
          .collection('veiculos')
          .doc(widget.veiculoId)
          .update(dados);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.veiculoId == null ? 'Adicionar Veículo' : 'Editar Veículo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(labelText: 'Modelo'),
                validator: (value) => value!.isEmpty ? 'Informe o modelo' : null,
              ),
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o ano' : null,
              ),
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(labelText: 'Placa'),
                validator: (value) => value!.isEmpty ? 'Informe a placa' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarVeiculo,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
