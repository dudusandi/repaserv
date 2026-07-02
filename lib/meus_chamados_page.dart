import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'unidade_display.dart';

class MeusChamadosPage extends StatelessWidget {
  const MeusChamadosPage({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Meus chamados'),
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('chamados')
              .where('usuarioId', isEqualTo: usuarioId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const _EstadoChamados(
                icon: Icons.error_outline_rounded,
                title: 'Não foi possível carregar',
                subtitle: 'Tente novamente em alguns instantes.',
              );
            }

            final chamados = [...snapshot.data?.docs ?? []];
            chamados.sort((a, b) {
              final aData = a.data()['criadoEm'];
              final bData = b.data()['criadoEm'];
              final aDate = aData is Timestamp ? aData.toDate() : DateTime(0);
              final bDate = bData is Timestamp ? bData.toDate() : DateTime(0);
              return bDate.compareTo(aDate);
            });

            if (chamados.isEmpty) {
              return const _EstadoChamados(
                icon: Icons.assignment_outlined,
                title: 'Nenhum chamado ainda',
                subtitle:
                    'Quando você solicitar um serviço, ele aparecerá aqui.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              itemCount: chamados.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = chamados[index];
                return _ChamadoCard(chamadoId: doc.id, data: doc.data());
              },
            );
          },
        ),
      ),
    );
  }
}

class DetalheChamadoPage extends StatelessWidget {
  const DetalheChamadoPage({super.key, required this.chamadoId});

  final String chamadoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('chamados')
              .doc(chamadoId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data?.exists != true) {
              return const _EstadoChamados(
                icon: Icons.error_outline_rounded,
                title: 'Chamado não encontrado',
                subtitle: 'Não foi possível abrir os detalhes desse chamado.',
              );
            }

            final chamado = snapshot.data!.data() ?? {};
            final condominioId = chamado['condominioId']?.toString();
            if (condominioId == null || condominioId.isEmpty) {
              return _DetalheChamadoContent(chamado: chamado);
            }

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('condominios')
                  .doc(condominioId)
                  .get(),
              builder: (context, condominioSnapshot) {
                return _DetalheChamadoContent(
                  chamado: chamado,
                  condominio: condominioSnapshot.data?.data(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChamadoCard extends StatelessWidget {
  const _ChamadoCard({required this.chamadoId, required this.data});

  final String chamadoId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final status = data['status']?.toString() ?? 'aberto';
    final podeCancelar = status == 'aberto' || status == 'em_analise';
    final dataAgendada = data['dataAgendada'];
    final dataLabel = dataAgendada is Timestamp
        ? _formatarData(dataAgendada.toDate())
        : 'Data não definida';

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalheChamadoPage(chamadoId: chamadoId),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.build_rounded, color: primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['tipoServico']?.toString() ?? 'Serviço',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['descricao']?.toString() ?? 'Sem descrição',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 16),
              _ChamadoInfoRow(
                icon: Icons.calendar_today_rounded,
                text:
                    '$dataLabel • ${data['horario']?.toString() ?? 'Horário não definido'}',
              ),
              if (data['nomeCondominio'] != null) ...[
                const SizedBox(height: 8),
                _ChamadoInfoRow(
                  icon: Icons.apartment_rounded,
                  text: data['nomeCondominio'].toString(),
                ),
              ],
              if (podeCancelar) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _confirmarCancelamento(context),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar chamado'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarCancelamento(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar chamado?'),
          content: const Text(
            'Essa ação mudará o status do chamado para cancelado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancelar chamado'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('chamados')
          .doc(chamadoId)
          .update({
            'status': 'cancelado',
            'canceladoEm': FieldValue.serverTimestamp(),
          });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado cancelado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível cancelar: $error'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _DetalheChamadoContent extends StatelessWidget {
  const _DetalheChamadoContent({required this.chamado, this.condominio});

  final Map<String, dynamic> chamado;
  final Map<String, dynamic>? condominio;

  @override
  Widget build(BuildContext context) {
    final status = chamado['status']?.toString() ?? 'aberto';
    final categoria = chamado['tipoServico']?.toString() ?? 'Serviço';
    final descricao = chamado['descricao']?.toString() ?? 'Sem descrição';
    final nomeCondominio =
        chamado['nomeCondominio']?.toString() ??
        condominio?['nome']?.toString() ??
        'Residência';
    final unidade = unidadeDisplay(
      unidadeLabel: chamado['unidadeLabel']?.toString(),
      unidadeId: chamado['unidadeId']?.toString(),
    );
    final endereco =
        condominio?['endereco']?.toString() ??
        chamado['endereco']?.toString() ??
        'Endereço não informado';
    final fotos = _extrairFotos(chamado);
    final criadoEm = chamado['criadoEm'];
    final chamadoQuando = criadoEm is Timestamp
        ? _formatarMomento(criadoEm.toDate())
        : 'Chamado criado';
    final localResumo = unidade.isEmpty
        ? nomeCondominio
        : '$nomeCondominio • $unidade';

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _DetalheHeader(
              titulo: categoria,
              status: status,
              subtitle: chamadoQuando,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MapaEnderecoCard(
                    endereco: endereco,
                    localResumo: localResumo,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _JobInfoCard(
                          label: 'Categoria',
                          value: categoria,
                          icon: Icons.build_rounded,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _JobInfoCard(
                          label: 'Status',
                          value: _StatusChip.labelStatus(status),
                          icon: Icons.verified_rounded,
                          color: _StatusChip.statusColor(status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DescricaoFotosCard(descricao: descricao, fotos: fotos),
                  const SizedBox(height: 20),
                  _MoradorCard(chamado: chamado, localResumo: localResumo),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _DetalheBottomBar(endereco: endereco),
        ),
      ],
    );
  }

  List<String> _extrairFotos(Map<String, dynamic> data) {
    final raw = data['fotos'] ?? data['fotoUrls'] ?? data['fotosUrls'];
    if (raw is! List) {
      return [];
    }

    return raw
        .map((item) => item?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
}

class _DetalheHeader extends StatelessWidget {
  const _DetalheHeader({
    required this.titulo,
    required this.status,
    required this.subtitle,
  });

  final String titulo;
  final String status;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: secondaryBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -80,
                  top: -90,
                  child: _HeaderCircle(
                    size: 200,
                    color: const Color(0xFFE8DCC4).withValues(alpha: 0.24),
                  ),
                ),
                Positioned(
                  right: -50,
                  bottom: -45,
                  child: _HeaderCircle(
                    size: 150,
                    color: primaryColor.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      child: IconButton(
                        tooltip: 'Voltar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapaEnderecoCard extends StatelessWidget {
  const _MapaEnderecoCard({required this.endereco, required this.localResumo});

  final String endereco;
  final String localResumo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: dividerColor),
      ),
      child: Stack(
        children: [
          const _MapaDecorativo(),
          Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: errorColor,
                size: 34,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: primaryTextColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localResumo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: primaryTextColor),
                        ),
                        Text(
                          endereco,
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
          ),
        ],
      ),
    );
  }
}

class _DescricaoFotosCard extends StatelessWidget {
  const _DescricaoFotosCard({required this.descricao, required this.fotos});

  final String descricao;
  final List<String> fotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            descricao,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: primaryTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _FotosChamado(fotos: fotos),
        ],
      ),
    );
  }
}

class _FotosChamado extends StatelessWidget {
  const _FotosChamado({required this.fotos});

  final List<String> fotos;

  @override
  Widget build(BuildContext context) {
    if (fotos.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined, color: secondaryTextColor),
            const SizedBox(width: 8),
            Text(
              'Nenhuma foto adicionada',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              fotos[index],
              width: 84,
              height: 84,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 84,
                  height: 84,
                  color: secondaryBackgroundColor,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: secondaryTextColor,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MoradorCard extends StatelessWidget {
  const _MoradorCard({required this.chamado, required this.localResumo});

  final Map<String, dynamic> chamado;
  final String localResumo;

  @override
  Widget build(BuildContext context) {
    final nome = chamado['nomeUsuario']?.toString() ?? 'Solicitante';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryColor.withValues(alpha: 0.12),
            child: Text(
              _iniciais(nome),
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  localResumo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'CH';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return '${partes.first.substring(0, 1)}${partes.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _JobInfoCard extends StatelessWidget {
  const _JobInfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetalheBottomBar extends StatelessWidget {
  const _DetalheBottomBar({required this.endereco});

  final String endereco;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: dividerColor)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x264A453E),
            blurRadius: 40,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: dividerColor),
            ),
            child: const Icon(Icons.directions_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(endereco),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.map_rounded),
              label: const Text('Ver endereço'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChamadoInfoRow extends StatelessWidget {
  const _ChamadoInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: secondaryTextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  static Color statusColor(String status) {
    return switch (status) {
      'cancelado' => errorColor,
      'concluido' => const Color(0xFF8FA991),
      'em_andamento' || 'aceito' => const Color(0xFF9BB5C2),
      _ => primaryColor,
    };
  }

  static String labelStatus(String status) {
    return switch (status) {
      'em_analise' => 'Em análise',
      'aceito' => 'Aceito',
      'em_andamento' => 'Em andamento',
      'concluido' => 'Concluído',
      'cancelado' => 'Cancelado',
      _ => 'Aberto',
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);

    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.14),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      label: Text(
        labelStatus(status),
        style: TextStyle(
          color: status == 'cancelado' ? errorColor : primaryTextColor,
        ),
      ),
    );
  }
}

class _EstadoChamados extends StatelessWidget {
  const _EstadoChamados({
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
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCircle extends StatelessWidget {
  const _HeaderCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MapaDecorativo extends StatelessWidget {
  const _MapaDecorativo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapaDecorativoPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _MapaDecorativoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = dividerColor.withValues(alpha: 0.75)
      ..strokeWidth = 1;
    final routePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.55)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var x = -40.0; x < size.width + 40; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x + 70, size.height), gridPaint);
    }

    for (var y = 18.0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 18), gridPaint);
    }

    final path = Path()
      ..moveTo(26, size.height - 30)
      ..quadraticBezierTo(size.width * 0.30, 86, size.width * 0.52, 96)
      ..quadraticBezierTo(size.width * 0.74, 108, size.width - 34, 34);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _formatarData(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year}';
}

String _formatarMomento(DateTime data) {
  return '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year} às '
      '${data.hour.toString().padLeft(2, '0')}:'
      '${data.minute.toString().padLeft(2, '0')}';
}
