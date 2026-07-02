import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'servicos_catalogo.dart';
import 'solicitar_servico_page.dart';

class TodosServicosPage extends StatelessWidget {
  const TodosServicosPage({
    super.key,
    required this.identificacao,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
    this.nomeCondominio,
  });

  final String identificacao;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? nomeCondominio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ServicosHeader(
                nomeCondominio: nomeCondominio,
                identificacao: identificacao,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              sliver: SliverList.separated(
                itemCount: todosServicos.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _ServicoCompletoTile(
                    servico: todosServicos[index],
                    identificacao: identificacao,
                    usuarioId: usuarioId,
                    condominioId: condominioId,
                    unidadeId: unidadeId,
                    unidadeLabel: unidadeLabel,
                    nomeCondominio: nomeCondominio,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicosHeader extends StatelessWidget {
  const _ServicosHeader({required this.identificacao, this.nomeCondominio});

  final String identificacao;
  final String? nomeCondominio;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: surfaceColor.withValues(alpha: 0.80),
                    shape: BoxShape.circle,
                    border: Border.all(color: dividerColor),
                  ),
                  child: IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    nomeCondominio ?? identificacao,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: primaryTextColor),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Todos os Serviços',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Escolha uma categoria para solicitar atendimento.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicoCompletoTile extends StatelessWidget {
  const _ServicoCompletoTile({
    required this.servico,
    required this.identificacao,
    this.usuarioId,
    this.condominioId,
    this.unidadeId,
    this.unidadeLabel,
    this.nomeCondominio,
  });

  final AppServico servico;
  final String identificacao;
  final String? usuarioId;
  final String? condominioId;
  final String? unidadeId;
  final String? unidadeLabel;
  final String? nomeCondominio;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SolicitarServicoPage(
                servico: servico.label,
                icon: servico.icon,
                color: servico.color,
                nomeCondominio: nomeCondominio,
                identificacao: identificacao,
                usuarioId: usuarioId,
                condominioId: condominioId,
                unidadeId: unidadeId,
                unidadeLabel: unidadeLabel,
              ),
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
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: servico.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(servico.icon, color: servico.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servico.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      servico.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
