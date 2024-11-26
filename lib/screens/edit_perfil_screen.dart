import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPerfilScreen extends StatefulWidget {
  const EditPerfilScreen({super.key});

  @override
  State<EditPerfilScreen> createState() => _EditPerfilScreenState();
}

class _EditPerfilScreenState extends State<EditPerfilScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (_user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _nameController.text = data?['name'] ?? '';
        _emailController.text = _user!.email ?? '';
      });
    }
  }

  Future<bool> _isEmailAvailable(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return query.docs.isEmpty;
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final name = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      if (newEmail != _user!.email && !(await _isEmailAvailable(newEmail))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('O e-mail informado já está em uso.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Atualiza no Firebase Auth
      if (newEmail != _user!.email) {
        await _user!.updateEmail(newEmail);
      }

      // Atualiza no Firestore
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        'name': name,
        'email': newEmail,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informações atualizadas com sucesso!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro ao atualizar informações.';
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Reautentique-se antes de alterar o e-mail.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF6650A4),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        labelStyle: TextStyle(color: Color(0xFFD0BCFF)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD0BCFF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: Color(0xFFD0BCFF)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFD0BCFF)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6650A4),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      onPressed: _updateProfile,
                      child: const Text('Atualizar Informações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
