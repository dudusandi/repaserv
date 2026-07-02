import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_condominios.dart';
import 'admin_escolas.dart';
import 'admin_prestadores.dart';
import 'ajustes_usuario.dart';
import 'app_theme.dart';
import 'meus_chamados_page.dart';
import 'servicos_catalogo.dart';
import 'solicitar_servico_page.dart';
import 'sos_page.dart';
import 'todos_servicos_page.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({
    super.key,
    this.nome,
    this.email,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
    this.nomeCondominio,
    this.tipo,
    this.plano,
    this.acessoAte,
  });

  final String? nome;
  final String? email;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? nomeCondominio;
  final String? tipo;
  final String? plano;
  final DateTime? acessoAte;

  @override
  Widget build(BuildContext context) {
    final identificacao = nome ?? email ?? 'RepaServ';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardHeader(
                identificacao: identificacao,
                email: email,
                nomeCondominio: nomeCondominio,
                usuarioId: usuarioId,
                unidadeId: unidadeId,
                unidadeLabel: unidadeLabel,
                plano: plano,
                acessoAte: acessoAte,
                isAdmin: tipo == 'admin',
              ),
              _SosCard(
                identificacao: identificacao,
                usuarioId: usuarioId,
                condominioId: condominioId,
                unidadeId: unidadeId,
                unidadeLabel: unidadeLabel,
                nomeCondominio: nomeCondominio,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Serviços',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Todos profissionais são verificados e certificados',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => TodosServicosPage(
                                  identificacao: identificacao,
                                  usuarioId: usuarioId,
                                  condominioId: condominioId,
                                  unidadeId: unidadeId,
                                  unidadeLabel: unidadeLabel,
                                  nomeCondominio: nomeCondominio,
                                ),
                              ),
                            );
                          },
                          child: const Text('Ver Todos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...servicosDestaque.map(
                      (servico) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ServiceTile(
                          servico: servico,
                          nomeCondominio: nomeCondominio,
                          identificacao: identificacao,
                          usuarioId: usuarioId,
                          condominioId: condominioId,
                          unidadeId: unidadeId,
                          unidadeLabel: unidadeLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.identificacao,
    required this.isAdmin,
    this.email,
    this.usuarioId,
    this.unidadeId,
    this.unidadeLabel,
    this.nomeCondominio,
    this.plano,
    this.acessoAte,
  });

  final String identificacao;
  final String? email;
  final String? usuarioId;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? nomeCondominio;
  final String? plano;
  final DateTime? acessoAte;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: Border.all(color: dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4A453E),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            secondaryBackgroundColor,
            backgroundColor,
            Color(0x4DE8DCC4),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _HeaderChip(
                  label: nomeCondominio ?? identificacao,
                  subtitle: nomeCondominio == null ? null : identificacao,
                  icon: nomeCondominio == null
                      ? Icons.home_rounded
                      : Icons.apartment_rounded,
                ),
                const Spacer(),
                if (isAdmin) ...[
                  IconButton(
                    tooltip: 'Administração',
                    onPressed: () => _abrirMenuAdministracao(context),
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  tooltip: 'Ajustes',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AjustesUsuarioPage(
                          nome: identificacao,
                          email: email,
                          usuarioId: usuarioId,
                          nomeCondominio: nomeCondominio,
                          unidadeId: unidadeId,
                          unidadeLabel: unidadeLabel,
                          plano: plano,
                          acessoAte: acessoAte,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_rounded),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Sair',
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Como Podemos',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            Text(
              'Ajudar hoje?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: usuarioId == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              MeusChamadosPage(usuarioId: usuarioId!),
                        ),
                      );
                    },
              icon: const Icon(Icons.assignment_rounded),
              label: const Text('Meus chamados'),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirMenuAdministracao(BuildContext context) {
    final rootContext = context;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surfaceColor,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Administração',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                _AdminMenuTile(
                  icon: Icons.school_rounded,
                  title: 'Escolas',
                  subtitle: 'Gerenciar escolas e gerar convites',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(rootContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminEscolasPage(),
                      ),
                    );
                  },
                ),
                _AdminMenuTile(
                  icon: Icons.engineering_rounded,
                  title: 'Prestadores',
                  subtitle: 'Gerenciar e cadastrar prestadores',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(rootContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminPrestadoresPage(),
                      ),
                    );
                  },
                ),
                _AdminMenuTile(
                  icon: Icons.apartment_rounded,
                  title: 'Condomínios',
                  subtitle: 'Gerenciar condomínios, unidades e moradores',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(rootContext).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminCondominiosPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  const _AdminMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label, required this.icon, this.subtitle});

  final String label;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: primaryTextColor),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: primaryTextColor),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: secondaryTextColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SosCard extends StatelessWidget {
  const _SosCard({
    required this.identificacao,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
    this.nomeCondominio,
  });

  final String identificacao;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? nomeCondominio;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SosPage(
                nomeCondominio: nomeCondominio,
                identificacao: identificacao,
                usuarioId: usuarioId,
                condominioId: condominioId,
                unidadeId: unidadeId,
                unidadeLabel: unidadeLabel,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: errorColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: dividerColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F4A453E),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency_share_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOS Emergência',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Resposta imediata 24 horas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.servico,
    required this.identificacao,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
    this.nomeCondominio,
  });

  final AppServico servico;
  final String identificacao;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? nomeCondominio;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SolicitarServicoPage(
                servico: servico.label,
                icon: servico.icon,
                color: servico.color,
                nomeCondominio: nomeCondominio,
                identificacao: identificacao,
                usuarioId: usuarioId,
                condominioId: condominioId,
                unidadeId: unidadeId,
                unidadeLabel: unidadeLabel,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: servico.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(servico.icon, color: servico.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servico.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      servico.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardFooter extends StatelessWidget {
  const _DashboardFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Precisa de Ajuda?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 4),
              Text(
                'Suporte',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 40, child: Divider(color: dividerColor)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.eco_rounded,
                  color: Color(0x4D4A453E),
                  size: 16,
                ),
              ),
              SizedBox(width: 40, child: Divider(color: dividerColor)),
            ],
          ),
        ],
      ),
    );
  }
}
