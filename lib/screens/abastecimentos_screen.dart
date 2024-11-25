import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbastecimentosScreen extends StatefulWidget {
  const AbastecimentosScreen({Key? key}) : super(key: key);

  @override
  _AbastecimentosScreenState createState() => _AbastecimentosScreenState();
}

class _AbastecimentosScreenState extends State<AbastecimentosScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _quilometragemController =
      TextEditingController();
  String? _selectedVeiculoId;
  Future<void> _cadastrarAbastecimento() async {
    if (_selectedVeiculoId == null ||
        _litrosController.text.isEmpty ||
        _quilometragemController.text.isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('veiculos')
          .doc(_selectedVeiculoId)
          .collection('abastecimentos')
          .add({
        'litros': double.parse(_litrosController.text),
        'quilometragemAtual': int.parse(_quilometragemController.text),
        'data': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abastecimento cadastrado com sucesso!')));
      _litrosController.clear();
      _quilometragemController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar abastecimento: $e')));
    }
  }

  Stream<QuerySnapshot> _listarVeiculos() {
    return FirebaseFirestore.instance
        .collection('veiculos')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Abastecimentos'),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _listarVeiculos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar veículos'));
              }

              final veiculos = snapshot.data!.docs;
              return DropdownButton<String>(
                hint: Text("Selecione o veículo"),
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
              decoration: InputDecoration(labelText: 'Litros abastecidos'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _quilometragemController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quilometragem atual'),
            ),
          ),
          ElevatedButton(
            onPressed: _cadastrarAbastecimento,
            child: Text('Cadastrar Abastecimento'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('veiculos')
                  .doc(_selectedVeiculoId)
                  .collection('abastecimentos')
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar abastecimentos'));
                }

                final abastecimentos = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: abastecimentos.length,
                  itemBuilder: (context, index) {
                    final abastecimento = abastecimentos[index];
                    final dados = abastecimento.data() as Map<String, dynamic>;
                    final data = (dados['data'] as Timestamp).toDate();
                    return ListTile(
                      title: Text(
                          'Litros: ${dados['litros']} | Km: ${dados['quilometragemAtual']}'),
                      subtitle:
                          Text('Data: ${data.day}/${data.month}/${data.year}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
