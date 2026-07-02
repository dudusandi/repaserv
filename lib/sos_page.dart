import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class SosPage extends StatefulWidget {
  const SosPage({
    super.key,
    this.nomeCondominio,
    this.identificacao,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
  });

  final String? nomeCondominio;
  final String? identificacao;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  String? _emergenciaSelecionada;
  bool _salvando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SosHero(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selecione a Emergência',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: secondaryTextColor),
                        ),
                        const SizedBox(height: 12),
                        ..._emergencias.map(
                          (emergencia) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _EmergencyActionCard(
                              emergencia: emergencia,
                              selected:
                                  _emergenciaSelecionada == emergencia.label,
                              onTap: () => setState(
                                () => _emergenciaSelecionada = emergencia.label,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: errorColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _emergenciaSelecionada == null || _salvando
                            ? null
                            : _chamarSos,
                        icon: const Icon(Icons.call_rounded),
                        label: Text(
                          _salvando ? 'Chamando...' : 'Chamar SOS Agora',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A4A453E),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chamarSos() async {
    final emergencia = _emergencias.firstWhere(
      (item) => item.label == _emergenciaSelecionada,
    );
    final agora = DateTime.now();

    setState(() => _salvando = true);

    try {
      await FirebaseFirestore.instance.collection('chamados').add({
        'tipoServico': emergencia.label,
        'descricao': 'SOS Emergência: ${emergencia.subtitle}',
        'fotos': <String>[],
        'urgencia': 'alta',
        'status': 'aberto',
        'origem': 'sos',
        'atendimentoImediato': true,
        'usuarioId': widget.usuarioId,
        'nomeUsuario': widget.identificacao,
        'condominioId': widget.condominioId,
        'nomeCondominio': widget.nomeCondominio,
        'unidadeId': widget.unidadeId,
        'unidadeLabel': widget.unidadeLabel,
        'dataAgendada': Timestamp.fromDate(agora),
        'horario': 'Imediato',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS chamado com urgência alta.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível chamar SOS: $error'),
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
}

class _SosHero extends StatelessWidget {
  const _SosHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [Color(0x33E8DCC4), backgroundColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: errorColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F4A453E),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emergency_share_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'SOS Emergência',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resposta Imediata 24 horas',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EmergencyActionCard extends StatelessWidget {
  const _EmergencyActionCard({
    required this.emergencia,
    required this.selected,
    required this.onTap,
  });

  final _EmergencyOption emergencia;
  final bool selected;
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
            border: Border.all(color: selected ? errorColor : dividerColor),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: emergencia.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emergencia.icon,
                  color: emergencia.iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emergencia.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emergencia.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? errorColor : secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyOption {
  const _EmergencyOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

const _emergencias = [
  _EmergencyOption(
    label: 'Vazamento de Água',
    subtitle: 'Cano estourado ou inundação',
    icon: Icons.water_drop_rounded,
    backgroundColor: Color(0xFFE3F2FD),
    iconColor: Color(0xFF1976D2),
  ),
  _EmergencyOption(
    label: 'Problemas Elétricos',
    subtitle: 'Cheiro de queimado ou faíscas',
    icon: Icons.flash_on_rounded,
    backgroundColor: Color(0xFFFFF3E0),
    iconColor: Color(0xFFF57C00),
  ),
  _EmergencyOption(
    label: 'Chaveiro',
    subtitle: 'Trancado fora da residência',
    icon: Icons.key_rounded,
    backgroundColor: Color(0xFFF3E5F5),
    iconColor: Color(0xFF7B1FA2),
  ),
  _EmergencyOption(
    label: 'Vazamento de Gás',
    subtitle: 'Cheiro de gás ou falha no aquecedor',
    icon: Icons.air_rounded,
    backgroundColor: Color(0xFFE8F5E9),
    iconColor: Color(0xFF388E3C),
  ),
];
