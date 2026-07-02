import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'cadastro_prestadores.dart';

class LoginPrestadorPage extends StatefulWidget {
  const LoginPrestadorPage({super.key});

  @override
  State<LoginPrestadorPage> createState() => _LoginPrestadorPageState();
}

class _LoginPrestadorPageState extends State<LoginPrestadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _identificadorController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _entrando = false;
  bool _ocultarSenha = true;
  bool _biometriaAtiva = true;

  @override
  void dispose() {
    _identificadorController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final identificador = _identificadorController.text.trim();
    if (!identificador.contains('@')) {
      _mostrarErro('Por enquanto, entre com o e-mail cadastrado.');
      return;
    }

    setState(() => _entrando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: identificador,
        password: _senhaController.text,
      );
    } on FirebaseAuthException catch (error) {
      _mostrarErro(_mensagemErroLogin(error));
    } finally {
      if (mounted) {
        setState(() => _entrando = false);
      }
    }
  }

  Future<void> _recuperarSenha() async {
    final email = _identificadorController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _mostrarErro('Informe seu e-mail para recuperar a senha.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enviamos um link de recuperação para seu e-mail.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (error) {
      _mostrarErro(_mensagemErroLogin(error));
    }
  }

  String _mensagemErroLogin(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Usuário desativado.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'E-mail ou senha inválidos.',
      _ => 'Não foi possível entrar. Tente novamente.',
    };
  }

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      child: IconButton(
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Text(
                      'Ajuda',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: primaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Área do Prestador',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse sua conta para gerenciar chamados e serviços pendentes.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _identificadorController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail ou CPF',
                    hintText: 'ex: joao.silva@email.com',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validarObrigatorio,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _ocultarSenha
                          ? 'Mostrar senha'
                          : 'Ocultar senha',
                      onPressed: () =>
                          setState(() => _ocultarSenha = !_ocultarSenha),
                      icon: Icon(
                        _ocultarSenha
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                    ),
                  ),
                  obscureText: _ocultarSenha,
                  textInputAction: TextInputAction.done,
                  validator: _validarObrigatorio,
                  onFieldSubmitted: (_) => _entrar(),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _recuperarSenha,
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _entrando ? null : _entrar,
                    child: _entrando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar na Plataforma'),
                  ),
                ),
                const SizedBox(height: 28),
                const _DividerLabel(label: 'OU'),
                const SizedBox(height: 28),
                _BiometriaCard(
                  active: _biometriaAtiva,
                  onChanged: (value) => setState(() => _biometriaAtiva = value),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CadastroPrestadorPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.engineering_rounded),
                  label: const Text('Cadastrar como prestador'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }
}

class _BiometriaCard extends StatelessWidget {
  const _BiometriaCard({required this.active, required this.onChanged});

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.fingerprint_rounded,
            color: secondaryTextColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acesso Biométrico',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Use sua digital para entrar mais rápido',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(value: active, onChanged: onChanged),
        ],
      ),
    );
  }
}
