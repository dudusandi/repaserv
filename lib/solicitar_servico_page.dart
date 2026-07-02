import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class SolicitarServicoPage extends StatefulWidget {
  const SolicitarServicoPage({
    super.key,
    required this.servico,
    required this.icon,
    required this.color,
    this.nomeCondominio,
    this.identificacao,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
  });

  final String servico;
  final IconData icon;
  final Color color;
  final String? nomeCondominio;
  final String? identificacao;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;

  @override
  State<SolicitarServicoPage> createState() => _SolicitarServicoPageState();
}

class _SolicitarServicoPageState extends State<SolicitarServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();

  late DateTime _dataSelecionada;
  late TimeOfDay _horaSelecionada;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = DateTime.now();
    _horaSelecionada = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  String get _dataLabel {
    return '${_diaSemana(_dataSelecionada.weekday)}, '
        '${_dataSelecionada.day.toString().padLeft(2, '0')} '
        '${_mes(_dataSelecionada.month)}';
  }

  String get _horaLabel {
    final fim = _horaSelecionada.replacing(
      hour: (_horaSelecionada.hour + 2).clamp(0, 23),
    );

    return '${_formatarHora(_horaSelecionada)} - ${_formatarHora(fim)}';
  }

  @override
  Widget build(BuildContext context) {
    final localPrincipal = widget.nomeCondominio ?? 'Residência';
    final localDetalhe = widget.identificacao ?? 'Local vinculado ao cadastro';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ServicoHeader(
                servico: widget.servico,
                icon: widget.icon,
                color: widget.color,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _descricaoController,
                        decoration: const InputDecoration(
                          labelText: 'O que está acontecendo',
                          hintText: 'Exemplo: vazamento na torneira',
                          alignLabelWithHint: true,
                        ),
                        minLines: 4,
                        maxLines: 4,
                        validator: _validarObrigatorio,
                      ),
                      const SizedBox(height: 16),
                      _FotoPlaceholder(onTap: () {}),
                      const SizedBox(height: 32),
                      _FormSectionHeader(title: 'Qual a data?'),
                      const SizedBox(height: 16),
                      _InfoPickerTile(
                        icon: Icons.calendar_today_rounded,
                        label: 'Data',
                        value: _dataLabel,
                        onTap: _selecionarData,
                      ),
                      const SizedBox(height: 16),
                      _InfoPickerTile(
                        icon: Icons.schedule_rounded,
                        label: 'Horário',
                        value: _horaLabel,
                        onTap: _selecionarHora,
                      ),
                      const SizedBox(height: 32),
                      _FormSectionHeader(title: 'Localização'),
                      const SizedBox(height: 16),
                      _LocationTile(
                        title: localPrincipal,
                        subtitle: localDetalhe,
                        onChange: () {},
                      ),
                      const SizedBox(height: 32),
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
                          onPressed: _salvando ? null : _solicitar,
                          icon: const Icon(Icons.send_rounded),
                          label: Text(
                            _salvando ? 'Solicitando...' : 'Solicitar',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Você será notificado quando aceitarem o serviço',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _solicitar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    try {
      await FirebaseFirestore.instance.collection('chamados').add({
        'tipoServico': widget.servico,
        'descricao': _descricaoController.text.trim(),
        'fotos': <String>[],
        'urgencia': 'normal',
        'status': 'aberto',
        'usuarioId': widget.usuarioId,
        'nomeUsuario': widget.identificacao,
        'condominioId': widget.condominioId,
        'nomeCondominio': widget.nomeCondominio,
        'unidadeId': widget.unidadeId,
        'unidadeLabel': widget.unidadeLabel,
        'dataAgendada': Timestamp.fromDate(
          DateTime(
            _dataSelecionada.year,
            _dataSelecionada.month,
            _dataSelecionada.day,
            _horaSelecionada.hour,
            _horaSelecionada.minute,
          ),
        ),
        'horario': _horaLabel,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado criado com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível criar o chamado: $error'),
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

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: hoje.add(const Duration(days: 120)),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (data == null || !mounted) {
      return;
    }

    setState(() => _dataSelecionada = data);
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
      helpText: 'Selecione o horário',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (hora == null || !mounted) {
      return;
    }

    setState(() => _horaSelecionada = hora);
  }

  String? _validarObrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String _diaSemana(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Segunda-feira',
      DateTime.tuesday => 'Terça-feira',
      DateTime.wednesday => 'Quarta-feira',
      DateTime.thursday => 'Quinta-feira',
      DateTime.friday => 'Sexta-feira',
      DateTime.saturday => 'Sábado',
      _ => 'Domingo',
    };
  }

  String _mes(int month) {
    return switch (month) {
      1 => 'Janeiro',
      2 => 'Fevereiro',
      3 => 'Março',
      4 => 'Abril',
      5 => 'Maio',
      6 => 'Junho',
      7 => 'Julho',
      8 => 'Agosto',
      9 => 'Setembro',
      10 => 'Outubro',
      11 => 'Novembro',
      _ => 'Dezembro',
    };
  }

  String _formatarHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }
}

class _ServicoHeader extends StatelessWidget {
  const _ServicoHeader({
    required this.servico,
    required this.icon,
    required this.color,
  });

  final String servico;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x4DA8B5A0), Color(0x33E8DCC4)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.80),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: 'Voltar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solicitar Serviço',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servico,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FotoPlaceholder extends StatelessWidget {
  const _FotoPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_rounded, color: secondaryTextColor),
              const SizedBox(width: 8),
              Text(
                'Adicione Fotos',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: secondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSectionHeader extends StatelessWidget {
  const _FormSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoPickerTile extends StatelessWidget {
  const _InfoPickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _InfoContainer(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: primaryTextColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: secondaryTextColor),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: primaryTextColor),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more_rounded, color: primaryTextColor),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.title,
    required this.subtitle,
    required this.onChange,
  });

  final String title;
  final String subtitle;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return _InfoContainer(
      onTap: onChange,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: primaryTextColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: const Text('Mudar')),
        ],
      ),
    );
  }
}

class _InfoContainer extends StatelessWidget {
  const _InfoContainer({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: dividerColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
