import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'unidade_display.dart';

class MeuCondominioPage extends StatefulWidget {
  const MeuCondominioPage({
    super.key,
    required this.usuarioId,
    this.nomeCondominio,
    this.unidadeId,
    this.unidadeLabel,
  });

  final String? usuarioId;
  final String? nomeCondominio;
  final String? unidadeId;
  final String? unidadeLabel;

  @override
  State<MeuCondominioPage> createState() => _MeuCondominioPageState();
}

class _MeuCondominioPageState extends State<MeuCondominioPage> {
  final _formKey = GlobalKey<FormState>();
  final _apartamentoController = TextEditingController();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _apartamentoController.text = unidadeDisplay(
      unidadeLabel: widget.unidadeLabel,
      unidadeId: widget.unidadeId,
    );
  }

  @override
  void dispose() {
    _apartamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nomeCondominio = widget.nomeCondominio ?? 'Residência';
    final unidadeTecnica = widget.unidadeId == null || widget.unidadeId!.isEmpty
        ? 'Não informado'
        : widget.unidadeId!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Meu Condomínio'),
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(32),
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
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nomeCondominio,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unidade atual: ${_apartamentoController.text.isEmpty ? 'Não informada' : _apartamentoController.text}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _CondominioSection(
                  title: 'Apartamento',
                  children: [
                    TextFormField(
                      controller: _apartamentoController,
                      decoration: const InputDecoration(
                        labelText: 'Número ou identificação',
                        hintText: 'Ex: Apto 102, Bloco B • 402',
                        prefixIcon: Icon(Icons.door_front_door_rounded),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: _validarApartamento,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _salvar(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Esse é o texto que aparecerá para você nos chamados e nos ajustes.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _CondominioSection(
                  title: 'Identificador técnico',
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          size: 20,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            unidadeTecnica,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: primaryTextColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Esse ID continua igual no banco para não quebrar vínculos existentes.',
                      style: Theme.of(context).textTheme.bodySmall,
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
                    onPressed: _salvando || widget.usuarioId == null
                        ? null
                        : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(_salvando ? 'Salvando...' : 'Salvar unidade'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final usuarioId = widget.usuarioId;
    if (usuarioId == null || usuarioId.isEmpty) {
      _mostrarErro('Não foi possível identificar o usuário.');
      return;
    }

    setState(() => _salvando = true);

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioId)
          .set({
            'unidadeLabel': _apartamentoController.text.trim(),
            'unidadeAtualizadaEm': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apartamento atualizado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(_apartamentoController.text.trim());
    } catch (error) {
      _mostrarErro('Não foi possível salvar: $error');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  String? _validarApartamento(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o apartamento';
    }
    if (value.trim().length < 2) {
      return 'Informe uma identificação válida';
    }
    return null;
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _CondominioSection extends StatelessWidget {
  const _CondominioSection({required this.title, required this.children});

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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
