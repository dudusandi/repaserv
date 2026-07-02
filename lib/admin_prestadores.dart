import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'cadastro_prestadores.dart';

class AdminPrestadoresPage extends StatelessWidget {
  const AdminPrestadoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Prestadores'),
        backgroundColor: backgroundColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CadastroPrestadorPage(cadastroAdmin: true),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cadastrar'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('prestadores')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const _EstadoListaPrestadores(
                icon: Icons.error_outline_rounded,
                title: 'Não foi possível carregar',
                subtitle: 'Tente novamente em alguns instantes.',
              );
            }

            final prestadores = snapshot.data?.docs ?? [];

            if (prestadores.isEmpty) {
              return const _EstadoListaPrestadores(
                icon: Icons.engineering_rounded,
                title: 'Nenhum prestador cadastrado',
                subtitle:
                    'Use o botão cadastrar para adicionar o primeiro prestador.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
              itemCount: prestadores.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = prestadores[index].data();
                final servicos = data['servicos'];

                return _PrestadorCard(
                  nome: data['nome']?.toString() ?? 'Prestador sem nome',
                  empresa: data['empresa']?.toString(),
                  servicos: servicos is List
                      ? servicos.map((item) => item.toString()).toList()
                      : const [],
                  emergencia: data['emergencia'] == true,
                  ativo: data['ativo'] == true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PrestadorCard extends StatelessWidget {
  const _PrestadorCard({
    required this.nome,
    required this.servicos,
    required this.emergencia,
    required this.ativo,
    this.empresa,
  });

  final String nome;
  final String? empresa;
  final List<String> servicos;
  final bool emergencia;
  final bool ativo;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (empresa != null && empresa!.isNotEmpty) empresa!,
      if (servicos.isNotEmpty) servicos.take(2).join(', '),
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144A453E),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.engineering_rounded, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
                if (emergencia) ...[
                  const SizedBox(height: 8),
                  const Chip(
                    label: Text('Emergência'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
          Chip(
            label: Text(ativo ? 'Ativo' : 'Inativo'),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _EstadoListaPrestadores extends StatelessWidget {
  const _EstadoListaPrestadores({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
