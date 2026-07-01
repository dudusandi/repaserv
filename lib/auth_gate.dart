import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'pagina_inicial.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return PerfilUsuarioGate(user: snapshot.data!);
        }

        return const LoginPage();
      },
    );
  }
}

class PerfilUsuarioGate extends StatelessWidget {
  const PerfilUsuarioGate({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const AcessoNegadoPage(
            titulo: 'Não foi possível verificar seu acesso',
            mensagem: 'Tente entrar novamente em alguns instantes.',
          );
        }

        final dados = snapshot.data?.data();

        if (dados == null) {
          return const AcessoNegadoPage(
            titulo: 'Usuário sem cadastro interno',
            mensagem:
                'Seu login existe, mas ainda não foi vinculado ao RepaServ.',
          );
        }

        if (dados['ativo'] != true) {
          return const AcessoNegadoPage(
            titulo: 'Usuário inativo',
            mensagem: 'Seu acesso ao RepaServ está desativado.',
          );
        }

        final tipo = dados['tipo']?.toString();
        final plano = dados['plano']?.toString();
        final acessoLiberado = dados['acessoLiberado'] == true;
        final acessoAte = _lerData(dados['acessoAte']);

        if (tipo == 'admin') {
          return AppHomePage(
            nome: dados['nome']?.toString(),
            email: dados['email']?.toString() ?? user.email,
            tipo: tipo,
            plano: plano,
            acessoAte: acessoAte,
          );
        }

        if (tipo != 'cliente') {
          return const AcessoNegadoPage(
            titulo: 'Tipo de usuário inválido',
            mensagem: 'Seu cadastro interno precisa ser revisado.',
          );
        }

        if (!acessoLiberado) {
          return const AcessoNegadoPage(
            titulo: 'Acesso ainda não liberado',
            mensagem:
                'Seu cadastro existe, mas o acesso ao app ainda não foi liberado.',
          );
        }

        if (plano == 'pago') {
          final agora = DateTime.now();

          if (acessoAte == null || acessoAte.isBefore(agora)) {
            return const AcessoNegadoPage(
              titulo: 'Plano vencido',
              mensagem: 'Renove seu acesso anual para continuar usando o app.',
            );
          }
        } else if (plano != 'gratis') {
          return const AcessoNegadoPage(
            titulo: 'Plano inválido',
            mensagem: 'Seu plano de acesso precisa ser revisado.',
          );
        }

        return AppHomePage(
          nome: dados['nome']?.toString(),
          email: dados['email']?.toString() ?? user.email,
          tipo: tipo,
          plano: plano,
          acessoAte: acessoAte,
        );
      },
    );
  }

  DateTime? _lerData(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}

class AcessoNegadoPage extends StatelessWidget {
  const AcessoNegadoPage({
    super.key,
    required this.titulo,
    required this.mensagem,
  });

  final String titulo;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        titulo,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(mensagem, textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        icon: const Icon(Icons.logout_outlined),
                        label: const Text('Sair'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
