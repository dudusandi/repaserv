import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'cadastro_prestadores.dart';

enum _LoginIdentificacao { casa, condominio }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _entrando = false;
  bool _ocultarSenha = true;
  _LoginIdentificacao _identificacao = _LoginIdentificacao.casa;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _entrando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensagemErroLogin(error)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _entrando = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Entrar',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Escolha sua identificação',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      _OpcaoIdentificacaoCard(
                        titulo: 'Casa',
                        subtitulo: 'Acesse usando seu ID pessoal',
                        icon: Icons.cottage_rounded,
                        selecionado: _identificacao == _LoginIdentificacao.casa,
                        onTap: () => setState(
                          () => _identificacao = _LoginIdentificacao.casa,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _OpcaoIdentificacaoCard(
                        titulo: 'Condomínio',
                        subtitulo: 'Acesse usando ID do condomínio',
                        icon: Icons.apartment_rounded,
                        selecionado:
                            _identificacao == _LoginIdentificacao.condominio,
                        onTap: () => setState(
                          () => _identificacao = _LoginIdentificacao.condominio,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Usuário ou E-mail',
                          hintText: 'Digite seu usuário',
                          prefixIcon: Icon(Icons.person_rounded),
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
                          prefixIcon: const Icon(Icons.lock_rounded),
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
                      const SizedBox(height: 32),
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _PrestadorAcessoCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CadastroPrestadorPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Precisa de ajuda?',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Suporte',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: primaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ],
                      ),
                    ],
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

class _OpcaoIdentificacaoCard extends StatelessWidget {
  const _OpcaoIdentificacaoCard({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.selecionado,
    required this.onTap,
  });

  final String titulo;
  final String subtitulo;
  final IconData icon;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: selecionado ? primaryColor : dividerColor,
            ),
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
                  color: selecionado
                      ? primaryColor.withValues(alpha: 0.10)
                      : secondaryBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selecionado ? primaryColor : secondaryTextColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                selecionado
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: primaryColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrestadorAcessoCard extends StatelessWidget {
  const _PrestadorAcessoCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.engineering_rounded,
            color: secondaryTextColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Você é um Prestador?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: primaryTextColor),
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('Entrar Aqui')),
        ],
      ),
    );
  }
}
