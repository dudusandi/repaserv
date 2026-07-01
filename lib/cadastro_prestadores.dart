import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final _funcaoController = TextEditingController();

  bool _emergencia = false;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _empresaController.dispose();
    _cnpjController.dispose();
    _telefoneController.dispose();
    _funcaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarPrestador() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await FirebaseFirestore.instance.collection('prestadores').add({
        'nome': _nomeController.text.trim(),
        'empresa': _empresaController.text.trim(),
        'cnpj': _cnpjController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'funcao': _funcaoController.text.trim(),
        'emergencia': _emergencia,
        'ativo': true,
      });

      if (!mounted) return;

      _formKey.currentState!.reset();
      _nomeController.clear();
      _empresaController.clear();
      _cnpjController.clear();
      _telefoneController.clear();
      _funcaoController.clear();
      setState(() => _emergencia = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prestador cadastrado com sucesso.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Cadastro de prestadores'),
        centerTitle: false,
      ),
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
                        Text(
                          'Novo prestador',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Preencha os dados para liberar o fornecedor na base do RepaServ.',
                          style: Theme.of(context).textTheme.bodyMedium,
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
                                  child: TextFormField(
                                    controller: _funcaoController,
                                    decoration: const InputDecoration(
                                      labelText: 'Funcao / servico',
                                      prefixIcon: Icon(Icons.handyman_outlined),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    validator: _validarObrigatorio,
                                    onFieldSubmitted: (_) => _salvarPrestador(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Atende emergencia'),
                          subtitle: const Text(
                            'Marque quando o prestador puder ser acionado fora do fluxo comum.',
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
