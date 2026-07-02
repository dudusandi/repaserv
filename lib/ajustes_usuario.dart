import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'email_seguranca_page.dart';
import 'meu_condominio_page.dart';
import 'unidade_display.dart';

class AjustesUsuarioPage extends StatelessWidget {
  const AjustesUsuarioPage({
    super.key,
    required this.nome,
    this.email,
    this.usuarioId,
    this.nomeCondominio,
    this.unidadeId,
    this.unidadeLabel,
    this.plano,
    this.acessoAte,
  });

  final String nome;
  final String? email;
  final String? usuarioId;
  final String? nomeCondominio;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? plano;
  final DateTime? acessoAte;

  @override
  Widget build(BuildContext context) {
    final local = _localizacaoLabel;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PerfilHeader(nome: nome, local: local),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: _ProfileStats(
                  usuarioId: usuarioId,
                  acessoAte: acessoAte,
                  plano: plano,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SettingsSection(
                      title: 'Ajustes de Conta',
                      children: [
                        _SettingRow(
                          title: 'Meu Condomínio',
                          subtitle: local,
                          icon: Icons.domain_rounded,
                          bgColor: const Color(
                            0xFFE8DCC4,
                          ).withValues(alpha: 0.32),
                          iconColor: const Color(0xFF8D7E64),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MeuCondominioPage(
                                  usuarioId: usuarioId,
                                  nomeCondominio: nomeCondominio,
                                  unidadeId: unidadeId,
                                  unidadeLabel: unidadeLabel,
                                ),
                              ),
                            );
                          },
                        ),
                        _SettingRow(
                          title: 'Plano',
                          subtitle: _planoLabel,
                          icon: Icons.workspace_premium_rounded,
                          bgColor: const Color(
                            0xFFD4A5A5,
                          ).withValues(alpha: 0.20),
                          iconColor: const Color(0xFFA67373),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingsSection(
                      title: 'Preferências',
                      children: [
                        const _SettingRow(
                          title: 'Notificações',
                          subtitle: 'Push e avisos de chamados',
                          icon: Icons.notifications_none_rounded,
                          bgColor: Color(0x26A8B5A0),
                          iconColor: Color(0xFF6B7A63),
                        ),
                        _SettingRow(
                          title: 'Email e Segurança',
                          subtitle: 'Alterar e-mail ou senha',
                          icon: Icons.shield_outlined,
                          bgColor: const Color(0x52E8DCC4),
                          iconColor: const Color(0xFF8D7E64),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => EmailSegurancaPage(
                                  emailAtual: email,
                                  usuarioId: usuarioId,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SettingsSection(
                      title: 'Suporte',
                      children: const [
                        _SettingRow(
                          title: 'Central de Ajuda',
                          subtitle: 'FAQ e contato com suporte',
                          icon: Icons.support_agent_rounded,
                          bgColor: Color(0x33D4A5A5),
                          iconColor: Color(0xFFA67373),
                        ),
                        _SettingRow(
                          title: 'Versão do App',
                          subtitle: 'v0.1.0',
                          icon: Icons.info_outline_rounded,
                          bgColor: secondaryBackgroundColor,
                          iconColor: secondaryTextColor,
                          showArrow: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: errorColor,
                    side: BorderSide(color: errorColor.withValues(alpha: 0.35)),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sair da conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _localizacaoLabel {
    if (nomeCondominio == null || nomeCondominio!.isEmpty) {
      final unidade = unidadeDisplay(
        unidadeLabel: unidadeLabel,
        unidadeId: unidadeId,
      );
      return unidade.isEmpty ? 'Residência' : 'Residência • $unidade';
    }

    final unidade = unidadeDisplay(
      unidadeLabel: unidadeLabel,
      unidadeId: unidadeId,
    );
    if (unidade.isEmpty) {
      return nomeCondominio!;
    }

    return '$nomeCondominio • $unidade';
  }

  String get _planoLabel {
    final nomePlano = switch (plano) {
      'admin' => 'Administrador',
      'gratis' => 'Gratuito',
      'pago' => 'Pago',
      'condominio' => 'Condomínio',
      _ => 'Cadastro ativo',
    };

    if (acessoAte == null) {
      return nomePlano;
    }

    return '$nomePlano até ${_formatarData(acessoAte!)}';
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }
}

class _PerfilHeader extends StatelessWidget {
  const _PerfilHeader({required this.nome, required this.local});

  final String nome;
  final String local;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        children: [
          Container(
            height: 280,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundColor, Color(0xFFE8DCC4)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x144A453E),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 78,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1F4A453E),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryColor,
                    child: Text(
                      _iniciais(nome),
                      style: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  nome,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home_rounded,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        local,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'RS';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({this.usuarioId, this.acessoAte, this.plano});

  final String? usuarioId;
  final DateTime? acessoAte;
  final String? plano;

  @override
  Widget build(BuildContext context) {
    final planoAtivo = plano == null || plano!.isEmpty ? 'Ativo' : plano!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: usuarioId == null
                ? null
                : FirebaseFirestore.instance
                      .collection('chamados')
                      .where('usuarioId', isEqualTo: usuarioId)
                      .snapshots(),
            builder: (context, snapshot) {
              final total = snapshot.data?.docs.length.toString() ?? '0';
              return _ProfileStat(value: total, label: 'Chamados');
            },
          ),
        ),
        Container(width: 1, height: 36, color: dividerColor),
        Expanded(
          child: _ProfileStat(
            value: _validadeLabel,
            label: planoAtivo == 'pago' ? 'Acesso' : 'Plano',
          ),
        ),
      ],
    );
  }

  String get _validadeLabel {
    if (acessoAte == null) {
      return 'Ativo';
    }

    final hoje = DateTime.now();
    final dias = acessoAte!.difference(hoje).inDays;
    if (dias <= 0) return 'Hoje';
    if (dias < 30) return '$dias dias';
    if (dias < 365) return '${(dias / 30).floor()} meses';
    return '${(dias / 365).floor()} anos';
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: secondaryTextColor),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.showArrow = true,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: surfaceColor,
        elevation: 1,
        shadowColor: const Color(0x0D4A453E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: dividerColor),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: showArrow
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: secondaryTextColor,
                )
              : null,
        ),
      ),
    );
  }
}
