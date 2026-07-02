String formatarUnidadeId(String? unidadeId) {
  final valor = unidadeId?.trim();
  if (valor == null || valor.isEmpty) {
    return '';
  }

  final palavrasPequenas = {'a', 'ao', 'da', 'de', 'do', 'e'};

  return valor
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((parte) => parte.isNotEmpty)
      .map((parte) {
        final lower = parte.toLowerCase();
        if (RegExp(r'^\d+[a-z]?$').hasMatch(lower)) {
          return lower.toUpperCase();
        }
        if (palavrasPequenas.contains(lower)) {
          return lower;
        }
        return '${lower.substring(0, 1).toUpperCase()}${lower.substring(1)}';
      })
      .join(' ');
}

String unidadeDisplay({String? unidadeLabel, String? unidadeId}) {
  final label = unidadeLabel?.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }

  return formatarUnidadeId(unidadeId);
}
