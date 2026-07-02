import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class EmailSegurancaPage extends StatefulWidget {
  const EmailSegurancaPage({super.key, this.emailAtual, this.usuarioId});

  final String? emailAtual;
  final String? usuarioId;

  @override
  State<EmailSegurancaPage> createState() => _EmailSegurancaPageState();
}

class _EmailSegurancaPageState extends State<EmailSegurancaPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _salvando = false;
  bool _mostrarSenhaAtual = false;
  bool _mostrarNovaSenha = false;
  bool _mostrarConfirmacao = false;

  @override
  void initState() {
    super.initState();
    _emailController.text =
        widget.emailAtual ?? FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Email e Segurança'),
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
                  'Acesso da conta',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Use sua senha atual para confirmar alterações de e-mail ou senha.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _SecuritySection(
                  title: 'E-mail',
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Novo e-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validarEmailOpcional,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ao trocar o e-mail, o Firebase enviará uma confirmação para o novo endereço.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SecuritySection(
                  title: 'Senha',
                  children: [
                    TextFormField(
                      controller: _novaSenhaController,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _mostrarNovaSenha
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          onPressed: () => setState(
                            () => _mostrarNovaSenha = !_mostrarNovaSenha,
                          ),
                          icon: Icon(
                            _mostrarNovaSenha
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                      obscureText: !_mostrarNovaSenha,
                      textInputAction: TextInputAction.next,
                      validator: _validarNovaSenha,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmarSenhaController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nova senha',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        suffixIcon: IconButton(
                          tooltip: _mostrarConfirmacao
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          onPressed: () => setState(
                            () => _mostrarConfirmacao = !_mostrarConfirmacao,
                          ),
                          icon: Icon(
                            _mostrarConfirmacao
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                      obscureText: !_mostrarConfirmacao,
                      textInputAction: TextInputAction.next,
                      validator: _validarConfirmacao,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SecuritySection(
                  title: 'Confirmação',
                  children: [
                    TextFormField(
                      controller: _senhaAtualController,
                      decoration: InputDecoration(
                        labelText: 'Senha atual',
                        prefixIcon: const Icon(Icons.verified_user_outlined),
                        suffixIcon: IconButton(
                          tooltip: _mostrarSenhaAtual
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          onPressed: () => setState(
                            () => _mostrarSenhaAtual = !_mostrarSenhaAtual,
                          ),
                          icon: Icon(
                            _mostrarSenhaAtual
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                      obscureText: !_mostrarSenhaAtual,
                      textInputAction: TextInputAction.done,
                      validator: _validarSenhaAtual,
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
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _salvando ? 'Salvando...' : 'Salvar alterações',
                    ),
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

    final user = FirebaseAuth.instance.currentUser;
    final emailAtual = user?.email;
    if (user == null || emailAtual == null || emailAtual.isEmpty) {
      _mostrarErro('Não foi possível identificar o usuário logado.');
      return;
    }

    final novoEmail = _emailController.text.trim();
    final novaSenha = _novaSenhaController.text.trim();
    final alterarEmail = novoEmail.isNotEmpty && novoEmail != emailAtual;
    final alterarSenha = novaSenha.isNotEmpty;

    if (!alterarEmail && !alterarSenha) {
      _mostrarErro('Informe um novo e-mail ou uma nova senha.');
      return;
    }

    setState(() => _salvando = true);

    try {
      final credencial = EmailAuthProvider.credential(
        email: emailAtual,
        password: _senhaAtualController.text,
      );
      await user.reauthenticateWithCredential(credencial);

      if (alterarSenha) {
        await user.updatePassword(novaSenha);
      }

      if (alterarEmail) {
        await user.verifyBeforeUpdateEmail(novoEmail);
        await _registrarEmailPendente(user.uid, novoEmail);
      }

      if (!mounted) return;

      final mensagem = alterarEmail
          ? 'Confira o novo e-mail para confirmar a alteração.'
          : 'Senha alterada com sucesso.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
      );

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      _mostrarErro(_traduzirErroAuth(error));
    } catch (error) {
      _mostrarErro('Não foi possível salvar: $error');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _registrarEmailPendente(String uid, String novoEmail) async {
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'emailPendente': novoEmail,
      'emailPendenteEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String? _validarEmailOpcional(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    if (!email.contains('@') || !email.contains('.')) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validarNovaSenha(String? value) {
    final senha = value?.trim() ?? '';
    if (senha.isEmpty) return null;
    if (senha.length < 6) {
      return 'Use pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmacao(String? value) {
    final novaSenha = _novaSenhaController.text.trim();
    final confirmacao = value?.trim() ?? '';
    if (novaSenha.isEmpty && confirmacao.isEmpty) return null;
    if (confirmacao != novaSenha) {
      return 'As senhas não conferem';
    }
    return null;
  }

  String? _validarSenhaAtual(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha atual';
    }
    return null;
  }

  String _traduzirErroAuth(FirebaseAuthException error) {
    return switch (error.code) {
      'wrong-password' || 'invalid-credential' => 'Senha atual inválida.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'invalid-email' => 'E-mail inválido.',
      'weak-password' => 'A nova senha é fraca.',
      'requires-recent-login' => 'Confirme a senha atual e tente novamente.',
      _ => error.message ?? 'Não foi possível salvar as alterações.',
    };
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

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.title, required this.children});

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
