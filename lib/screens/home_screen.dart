import 'package:flutter/material.dart';
import '../widgets/drawer_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Abastecimento'),
      ),
      drawer: const DrawerWidget(),
      body: const Center(
        child: Text('Bem-vindo ao Controle de Abastecimento!'),
      ),
    );
  }
}
