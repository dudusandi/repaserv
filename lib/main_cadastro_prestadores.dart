import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'cadastro_prestadores.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CadastroPrestadoresApp());
}

class CadastroPrestadoresApp extends StatelessWidget {
  const CadastroPrestadoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadastro de Prestadores',
      theme: buildAppTheme(),
      builder: buildAppViewport,
      home: const CadastroPrestadorPage(),
    );
  }
}
