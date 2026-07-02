import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

class AdminCondominiosPage extends StatelessWidget {
  const AdminCondominiosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Condomínios'),
        backgroundColor: backgroundColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CadastroCondominioPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cadastrar'),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('condominios')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const _EstadoListaCondominios(
                icon: Icons.error_outline_rounded,
                title: 'Não foi possível carregar',
                subtitle: 'Tente novamente em alguns instantes.',
              );
            }

            final condominios = snapshot.data?.docs ?? [];

            if (condominios.isEmpty) {
              return const _EstadoListaCondominios(
                icon: Icons.apartment_rounded,
                title: 'Nenhum condomínio cadastrado',
                subtitle:
                    'Use o botão cadastrar para gerar o primeiro convite.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
              itemCount: condominios.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = condominios[index];
                final data = doc.data();

                return _CondominioCard(condominioId: doc.id, data: data);
              },
            );
          },
        ),
      ),
    );
  }
}

class CadastroCondominioPage extends StatefulWidget {
  const CadastroCondominioPage({super.key, this.condominioId, this.dados});

  final String? condominioId;
  final Map<String, dynamic>? dados;

  bool get editando => condominioId != null;

  @override
  State<CadastroCondominioPage> createState() => _CadastroCondominioPageState();
}

class _CadastroCondominioPageState extends State<CadastroCondominioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailResponsavelController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _totalApartamentosController = TextEditingController();

  bool _salvando = false;
  String? _linkConvite;

  @override
  void initState() {
    super.initState();

    final dados = widget.dados;
    if (dados == null) return;

    _nomeController.text = dados['nome']?.toString() ?? '';
    _emailResponsavelController.text =
        dados['emailResponsavel']?.toString() ?? '';
    _enderecoController.text = dados['endereco']?.toString() ?? '';
    _totalApartamentosController.text =
        dados['totalApartamentos']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailResponsavelController.dispose();
    _enderecoController.dispose();
    _totalApartamentosController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      if (widget.editando) {
        await FirebaseFirestore.instance
            .collection('condominios')
            .doc(widget.condominioId)
            .update({
              'nome': _nomeController.text.trim(),
              'emailResponsavel': _emailResponsavelController.text.trim(),
              'endereco': _enderecoController.text.trim(),
              'totalApartamentos': int.parse(
                _totalApartamentosController.text.trim(),
              ),
              'atualizadoEm': FieldValue.serverTimestamp(),
            });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Condomínio atualizado.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final condominioRef = firestore.collection('condominios').doc();
      final conviteRef = firestore.collection('convites').doc();
      final emailResponsavel = _emailResponsavelController.text.trim();

      final batch = firestore.batch();

      batch.set(condominioRef, {
        'nome': _nomeController.text.trim(),
        'emailResponsavel': emailResponsavel,
        'endereco': _enderecoController.text.trim(),
        'totalApartamentos': int.parse(
          _totalApartamentosController.text.trim(),
        ),
        'ativo': true,
        'plano': 'condominio',
        'acessoLiberado': true,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      batch.set(conviteRef, {
        'tipo': 'condominio_admin',
        'condominioId': condominioRef.id,
        'email': emailResponsavel,
        'usado': false,
        'expiraEm': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'criadoEm': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;

      setState(() => _linkConvite = _montarLinkConvite(conviteRef.id));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convite do condomínio gerado com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
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

  String? _validarInteiro(String? value) {
    final obrigatorio = _validarObrigatorio(value);
    if (obrigatorio != null) {
      return obrigatorio;
    }

    final numero = int.tryParse(value!.trim());
    if (numero == null || numero < 1) {
      return 'Informe um número válido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.editando ? 'Editar condomínio' : 'Cadastrar condomínio',
        ),
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
                  widget.editando ? 'Dados do condomínio' : 'Gerar convite',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.editando
                      ? 'Atualize as informações principais do condomínio.'
                      : 'Cadastre o condomínio e envie o link para o responsável criar a senha.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _AdminSection(
                  title: 'Informações',
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do condomínio',
                        prefixIcon: Icon(Icons.apartment_rounded),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _validarObrigatorio,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailResponsavelController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail do responsável',
                        prefixIcon: Icon(Icons.email_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalApartamentosController,
                      decoration: const InputDecoration(
                        labelText: 'Total de apartamentos',
                        prefixIcon: Icon(Icons.door_front_door_rounded),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: _validarInteiro,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enderecoController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço',
                        prefixIcon: Icon(Icons.location_on_rounded),
                      ),
                      minLines: 2,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      validator: _validarObrigatorio,
                      onFieldSubmitted: (_) => _salvar(),
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
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            widget.editando
                                ? Icons.save_rounded
                                : Icons.link_rounded,
                          ),
                    label: Text(
                      _salvando
                          ? 'Salvando...'
                          : widget.editando
                          ? 'Salvar alterações'
                          : 'Gerar convite',
                    ),
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

class DetalheCondominioPage extends StatelessWidget {
  const DetalheCondominioPage({
    super.key,
    required this.condominioId,
    required this.dados,
  });

  final String condominioId;
  final Map<String, dynamic> dados;

  @override
  Widget build(BuildContext context) {
    final nome = dados['nome']?.toString() ?? 'Condomínio sem nome';
    final endereco = dados['endereco']?.toString() ?? 'Endereço não informado';
    final totalApartamentos = dados['totalApartamentos']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Condomínio'),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CadastroCondominioPage(
                    condominioId: condominioId,
                    dados: dados,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(nome, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(endereco, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('condominioId', isEqualTo: condominioId)
                  .snapshots(),
              builder: (context, snapshot) {
                final usuarios = snapshot.data?.docs.length;

                return Row(
                  children: [
                    Expanded(
                      child: _ResumoCard(
                        icon: Icons.people_rounded,
                        label: 'Usuários',
                        value: usuarios == null ? '...' : usuarios.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumoCard(
                        icon: Icons.door_front_door_rounded,
                        label: 'Apartamentos',
                        value: totalApartamentos,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _DetalheInfoCard(
              icon: Icons.email_rounded,
              label: 'Responsável',
              value:
                  dados['emailResponsavel']?.toString() ??
                  'E-mail não informado',
            ),
            const SizedBox(height: 12),
            _DetalheInfoCard(
              icon: Icons.verified_rounded,
              label: 'Status',
              value: dados['ativo'] == true ? 'Ativo' : 'Inativo',
            ),
          ],
        ),
      ),
    );
  }
}

class _CondominioCard extends StatelessWidget {
  const _CondominioCard({required this.condominioId, required this.data});

  final String condominioId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final nome = data['nome']?.toString() ?? 'Condomínio sem nome';
    final emailResponsavel = data['emailResponsavel']?.toString();
    final endereco = data['endereco']?.toString();
    final ativo = data['ativo'] == true;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalheCondominioPage(
                condominioId: condominioId,
                dados: data,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment_rounded, color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: Theme.of(context).textTheme.titleMedium),
                    if (emailResponsavel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        emailResponsavel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (endereco != null && endereco.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        endereco,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_CondominioAction>(
                tooltip: 'Ações',
                onSelected: (action) =>
                    _executarAcao(context, action, condominioId, data),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _CondominioAction.abrir,
                    child: Text('Abrir'),
                  ),
                  PopupMenuItem(
                    value: _CondominioAction.editar,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: _CondominioAction.remover,
                    child: Text('Remover'),
                  ),
                ],
              ),
              Chip(
                label: Text(ativo ? 'Ativo' : 'Inativo'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executarAcao(
    BuildContext context,
    _CondominioAction action,
    String condominioId,
    Map<String, dynamic> data,
  ) async {
    switch (action) {
      case _CondominioAction.abrir:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                DetalheCondominioPage(condominioId: condominioId, dados: data),
          ),
        );
        return;
      case _CondominioAction.editar:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                CadastroCondominioPage(condominioId: condominioId, dados: data),
          ),
        );
        return;
      case _CondominioAction.remover:
        await _removerCondominio(context, condominioId);
        return;
    }
  }

  Future<void> _removerCondominio(
    BuildContext context,
    String condominioId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover condomínio?'),
          content: const Text(
            'O condomínio será removido da lista. Usuários vinculados não serão apagados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('condominios')
          .doc(condominioId)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condomínio removido.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível remover: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

enum _CondominioAction { abrir, editar, remover }

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DetalheInfoCard extends StatelessWidget {
  const _DetalheInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoListaCondominios extends StatelessWidget {
  const _EstadoListaCondominios({
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
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
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
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Link gerado',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            link,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: primaryTextColor),
          ),
          const SizedBox(height: 12),
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
