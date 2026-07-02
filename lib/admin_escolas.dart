import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

class AdminEscolasPage extends StatelessWidget {
  const AdminEscolasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Escolas'),
        backgroundColor: backgroundColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CadastroEscolaPage()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gerar link'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('escolas').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const _EstadoListaEscolas(
                icon: Icons.error_outline_rounded,
                title: 'Não foi possível carregar',
                subtitle: 'Tente novamente em alguns instantes.',
              );
            }

            final escolas = snapshot.data?.docs ?? [];

            if (escolas.isEmpty) {
              return const _EstadoListaEscolas(
                icon: Icons.school_rounded,
                title: 'Nenhuma escola cadastrada',
                subtitle:
                    'Use o botão gerar link para cadastrar a primeira escola.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
              itemCount: escolas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final data = escolas[index].data();

                return _EscolaCard(
                  nome: data['nome']?.toString() ?? 'Escola sem nome',
                  codigoInep: data['codigoInep']?.toString(),
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

class CadastroEscolaPage extends StatefulWidget {
  const CadastroEscolaPage({super.key});

  @override
  State<CadastroEscolaPage> createState() => _CadastroEscolaPageState();
}

class _CadastroEscolaPageState extends State<CadastroEscolaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeEscolaController = TextEditingController();
  final _codigoInepController = TextEditingController();
  final _emailGerenteController = TextEditingController();

  bool _gerando = false;
  String? _linkConvite;

  @override
  void dispose() {
    _nomeEscolaController.dispose();
    _codigoInepController.dispose();
    _emailGerenteController.dispose();
    super.dispose();
  }

  Future<void> _gerarConvite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _gerando = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final escolaRef = firestore.collection('escolas').doc();
      final conviteRef = firestore.collection('convites').doc();
      final emailGerente = _emailGerenteController.text.trim();

      final batch = firestore.batch();

      batch.set(escolaRef, {
        'nome': _nomeEscolaController.text.trim(),
        'codigoInep': _codigoInepController.text.trim(),
        'emailGerente': emailGerente,
        'ativo': true,
        'plano': 'gratis',
        'acessoLiberado': true,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      batch.set(conviteRef, {
        'tipo': 'escola',
        'escolaId': escolaRef.id,
        'email': emailGerente,
        'usado': false,
        'expiraEm': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'criadoEm': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      final link = _montarLinkConvite(conviteRef.id);

      if (!mounted) return;

      setState(() => _linkConvite = link);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convite gerado com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível gerar o convite: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _gerando = false);
      }
    }
  }

  String _montarLinkConvite(String conviteId) {
    final base = Uri.base.origin;
    return '$base/convite?id=$conviteId';
  }

  Future<void> _copiarLink() async {
    final link = _linkConvite;
    if (link == null) return;

    await Clipboard.setData(ClipboardData(text: link));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    final obrigatorio = _validarObrigatorio(value);
    if (obrigatorio != null) {
      return obrigatorio;
    }

    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'E-mail inválido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Convite para escola'),
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Gerar acesso gratuito',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cadastre a escola e gere um link para o gerente criar a senha.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _AdminSection(
                  title: 'Dados da escola',
                  children: [
                    TextFormField(
                      controller: _nomeEscolaController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da escola',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _validarObrigatorio,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codigoInepController,
                      decoration: const InputDecoration(
                        labelText: 'Código INEP',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: _validarObrigatorio,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AdminSection(
                  title: 'Gerente da escola',
                  children: [
                    TextFormField(
                      controller: _emailGerenteController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail do gerente',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: _validarEmail,
                      onFieldSubmitted: (_) => _gerarConvite(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _gerando ? null : _gerarConvite,
                    icon: _gerando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.link_rounded),
                    label: Text(_gerando ? 'Gerando...' : 'Gerar convite'),
                  ),
                ),
                if (_linkConvite != null) ...[
                  const SizedBox(height: 24),
                  _ConviteGeradoCard(link: _linkConvite!, onCopy: _copiarLink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EscolaCard extends StatelessWidget {
  const _EscolaCard({required this.nome, required this.ativo, this.codigoInep});

  final String nome;
  final bool ativo;
  final String? codigoInep;

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.school_rounded, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: Theme.of(context).textTheme.titleMedium),
                if (codigoInep != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'INEP $codigoInep',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Chip(
            label: Text(ativo ? 'Ativa' : 'Inativa'),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _EstadoListaEscolas extends StatelessWidget {
  const _EstadoListaEscolas({
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

class _AdminSection extends StatelessWidget {
  const _AdminSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ConviteGeradoCard extends StatelessWidget {
  const _ConviteGeradoCard({required this.link, required this.onCopy});

  final String link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Link do convite',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SelectableText(link),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copiar link'),
          ),
        ],
      ),
    );
  }
}
