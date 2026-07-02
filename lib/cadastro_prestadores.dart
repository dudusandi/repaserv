import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

const List<String> kServicosPrestador = [
  'Elétrica',
  'Hidráulica',
  'Construção Geral',
  'Pintura',
  'Marcenaria',
  'Vidraçaria',
  'Serralheria',
  'Climatização',
  'Limpeza',
  'Jardinagem',
  'Piscinas',
  'Segurança Eletrônica',
  'Portões e Interfones',
  'Informática',
  'Chaveiro',
];

class CadastroPrestadorPage extends StatefulWidget {
  const CadastroPrestadorPage({super.key, this.cadastroAdmin = false});

  final bool cadastroAdmin;

  @override
  State<CadastroPrestadorPage> createState() => _CadastroPrestadorPageState();
}

class _CadastroPrestadorPageState extends State<CadastroPrestadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _empresaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _telefoneController = TextEditingController();

  final Set<String> _servicosSelecionados = {};
  bool _emergencia = false;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _empresaController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarPrestador() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      final servicos = kServicosPrestador
          .where(_servicosSelecionados.contains)
          .toList(growable: false);

      final collection = widget.cadastroAdmin
          ? 'prestadores'
          : 'prestadores_pendentes';

      final payload = {
        'nome': _nomeController.text.trim(),
        'empresa': _empresaController.text.trim(),
        'cnpj': _cnpjController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'servicos': servicos,
        'emergencia': _emergencia,
        'criadoEm': FieldValue.serverTimestamp(),
      };

      if (widget.cadastroAdmin) {
        payload.addAll({'ativo': true});
      } else {
        payload.addAll({'status': 'pendente'});
      }

      await FirebaseFirestore.instance.collection(collection).add(payload);

      if (!mounted) return;

      _formKey.currentState!.reset();
      _nomeController.clear();
      _empresaController.clear();
      _cnpjController.clear();
      _telefoneController.clear();
      setState(() {
        _servicosSelecionados.clear();
        _emergencia = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cadastroAdmin
                ? 'Prestador cadastrado com sucesso.'
                : 'Cadastro enviado com sucesso.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível cadastrar: $error'),
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

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _validarServicos(List<String>? value) {
    if (_servicosSelecionados.isEmpty) {
      return 'Selecione pelo menos um serviço';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CadastroPrestadorHeader(cadastroAdmin: widget.cadastroAdmin),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FormSection(
                        title: 'Dados do prestador',
                        children: [
                          TextFormField(
                            controller: _nomeController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validarObrigatorio,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _empresaController,
                            decoration: const InputDecoration(
                              labelText: 'Empresa',
                              prefixIcon: Icon(Icons.business_outlined),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validarObrigatorio,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cnpjController,
                            decoration: const InputDecoration(
                              labelText: 'CNPJ',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: _validarObrigatorio,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telefoneController,
                            decoration: const InputDecoration(
                              labelText: 'Telefone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            validator: _validarObrigatorio,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _FormSection(
                        title: 'Serviços',
                        subtitle: 'Selecione todas as categorias atendidas.',
                        children: [
                          FormField<List<String>>(
                            validator: _validarServicos,
                            builder: (field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: kServicosPrestador.map((servico) {
                                      final selecionado = _servicosSelecionados
                                          .contains(servico);

                                      return _ServicoChoice(
                                        label: servico,
                                        selected: selecionado,
                                        enabled: !_salvando,
                                        onTap: () {
                                          setState(() {
                                            if (selecionado) {
                                              _servicosSelecionados.remove(
                                                servico,
                                              );
                                            } else {
                                              _servicosSelecionados.add(
                                                servico,
                                              );
                                            }
                                          });
                                          field.didChange(
                                            kServicosPrestador
                                                .where(
                                                  _servicosSelecionados
                                                      .contains,
                                                )
                                                .toList(),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  if (field.errorText != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      field.errorText!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _EmergenciaCard(
                        value: _emergencia,
                        enabled: !_salvando,
                        onChanged: (value) =>
                            setState(() => _emergencia = value),
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
                          onPressed: _salvando ? null : _salvarPrestador,
                          icon: _salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            _salvando ? 'Salvando...' : 'Cadastrar prestador',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CadastroPrestadorHeader extends StatelessWidget {
  const _CadastroPrestadorHeader({required this.cadastroAdmin});

  final bool cadastroAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: dividerColor),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Material(
                  color: surfaceColor.withValues(alpha: 0.82),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const Spacer(),
                Image.asset('assets/logo.png', height: 52, fit: BoxFit.contain),
              ],
            ),
            const Spacer(),
            Text(
              cadastroAdmin ? 'Novo prestador' : 'Cadastro de Prestador',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              cadastroAdmin
                  ? 'Cadastre um profissional já aprovado para atender chamados.'
                  : 'Envie seus dados para avaliação e liberação na plataforma.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
            color: Color(0x0D4A453E),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ServicoChoice extends StatelessWidget {
  const _ServicoChoice({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? primaryColor : secondaryBackgroundColor;

    return Material(
      color: color.withValues(alpha: selected ? 0.22 : 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected ? primaryColor : dividerColor,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                size: 18,
                color: selected ? primaryTextColor : secondaryTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: primaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergenciaCard extends StatelessWidget {
  const _EmergenciaCard({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: dividerColor),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: errorColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emergency_share_rounded, color: errorColor),
        ),
        title: const Text('Atende emergência'),
        subtitle: const Text(
          'Marque apenas se tiver disponibilidade 24 horas.',
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
