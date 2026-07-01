import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const List<String> kServicosPrestador = [
  'Elétrica',
  'Hidráulica',
  'Construção e Reforma',
  'Pintura',
  'Marcenaria e Móveis',
  'Vidraçaria',
  'Serralheria',
  'Climatização',
  'Eletrodomésticos',
  'Limpeza',
  'Jardinagem',
  'Piscinas',
  'Segurança Eletrônica',
  'Portões e Interfones',
  'Informática',
  'Chaveiro',
  'Impermeabilização',
];

class CadastroPrestadorPage extends StatefulWidget {
  const CadastroPrestadorPage({super.key});

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

      await FirebaseFirestore.instance.collection('prestadores_pendentes').add({
        'nome': _nomeController.text.trim(),
        'empresa': _empresaController.text.trim(),
        'cnpj': _cnpjController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'servicos': servicos,
        'emergencia': _emergencia,
        'status': 'pendente',
        'criadoEm': FieldValue.serverTimestamp(),
      });

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
        const SnackBar(
          content: Text('Cadastro enviado com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nao foi possivel cadastrar: $error'),
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
      return 'Campo obrigatorio';
    }
    return null;
  }

  String? _validarServicos(List<String>? value) {
    if (_servicosSelecionados.isEmpty) {
      return 'Selecione pelo menos um servico';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/logo.png',
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Cadastro de Prestador de Serviço',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 640;
                            final fieldWidth = isWide
                                ? (constraints.maxWidth - 16) / 2
                                : constraints.maxWidth;

                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: TextFormField(
                                    controller: _nomeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nome',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: _validarObrigatorio,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: TextFormField(
                                    controller: _empresaController,
                                    decoration: const InputDecoration(
                                      labelText: 'Empresa',
                                      prefixIcon: Icon(Icons.business_outlined),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    validator: _validarObrigatorio,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: TextFormField(
                                    controller: _cnpjController,
                                    decoration: const InputDecoration(
                                      labelText: 'CNPJ',
                                      prefixIcon: Icon(Icons.badge_outlined),
                                    ),
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    validator: _validarObrigatorio,
                                  ),
                                ),
                                SizedBox(
                                  width: fieldWidth,
                                  child: TextFormField(
                                    controller: _telefoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Telefone',
                                      prefixIcon: Icon(Icons.phone_outlined),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    validator: _validarObrigatorio,
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth,
                                  child: FormField<List<String>>(
                                    validator: _validarServicos,
                                    builder: (field) {
                                      return InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'Serviços',
                                          errorText: field.errorText,
                                          border: const OutlineInputBorder(),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                12,
                                                16,
                                                12,
                                                8,
                                              ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 0,
                                            children: kServicosPrestador.map((
                                              servico,
                                            ) {
                                              final selecionado =
                                                  _servicosSelecionados
                                                      .contains(servico);

                                              return SizedBox(
                                                width: isWide
                                                    ? (constraints.maxWidth -
                                                              32) /
                                                          3
                                                    : constraints.maxWidth,
                                                child: CheckboxListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  dense: true,
                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,
                                                  title: Text(servico),
                                                  value: selecionado,
                                                  onChanged: _salvando
                                                      ? null
                                                      : (value) {
                                                          setState(() {
                                                            if (value ??
                                                                false) {
                                                              _servicosSelecionados
                                                                  .add(servico);
                                                            } else {
                                                              _servicosSelecionados
                                                                  .remove(
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
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Atende emergência'),
                          subtitle: const Text(
                            'Marque apenas se tiver disponibilidade 24 horas.',
                          ),
                          value: _emergencia,
                          onChanged: _salvando
                              ? null
                              : (value) => setState(() => _emergencia = value),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _salvando ? null : _salvarPrestador,
                          icon: _salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _salvando ? 'Salvando...' : 'Cadastrar prestador',
                          ),
                        ),
                      ],
                    ),
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
