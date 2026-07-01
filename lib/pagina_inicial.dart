import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({
    super.key,
    this.nome,
    this.email,
    this.tipo,
    this.plano,
    this.acessoAte,
  });

  final String? nome;
  final String? email;
  final String? tipo;
  final String? plano;
  final DateTime? acessoAte;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RepaServ'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', height: 120, fit: BoxFit.contain),
              const SizedBox(height: 24),
              Text(
                'Acesso liberado',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(nome ?? email ?? 'Usuário autenticado'),
              if (tipo != null) ...[
                const SizedBox(height: 4),
                Text('Perfil: $tipo'),
              ],
              if (plano != null) ...[
                const SizedBox(height: 4),
                Text('Plano: $plano'),
              ],
              if (acessoAte != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Acesso até: ${acessoAte!.day.toString().padLeft(2, '0')}/'
                  '${acessoAte!.month.toString().padLeft(2, '0')}/'
                  '${acessoAte!.year}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
