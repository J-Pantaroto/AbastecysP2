import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/historico_abastecimentos_screen.dart';
import 'screens/home_screen.dart';
import 'screens/adicionar_Editar_veiculo_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Função para atualizar os documentos com o campo 'userId'
Future<void> atualizarDocumentos() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('Usuário não autenticado!');
    return; // Se o usuário não estiver autenticado, não faz nada.
  }

  // Obtenha todos os documentos da coleção 'veiculos' e atualize com 'userId'
  final querySnapshot = await FirebaseFirestore.instance.collection('veiculos').get();
  
  for (var doc in querySnapshot.docs) {
    // Atualize o campo 'userId' para cada documento
    await doc.reference.update({'userId': user.uid});
  }

  print('Documentos atualizados com sucesso!');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      // Se o usuário estiver autenticado, atualiza os documentos
      await atualizarDocumentos();
    } else {
      print('Usuário não autenticado!');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abastecys',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD0BCFF),
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6650A4),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFD0BCFF)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/adicionar-veiculo': (context) => AdicionarEditarVeiculoScreen(),
        '/historico-abastecimentos': (context) => HistoricoAbastecimentosScreen(
              veiculoId: ModalRoute.of(context)!.settings.arguments as String,
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
