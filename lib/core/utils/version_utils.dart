int compareVersion(String a, String b) {
  final aParts = _normalizeVersion(a);
  final bParts = _normalizeVersion(b);
  final maxLength = aParts.length > bParts.length ? aParts.length : bParts.length;

  for (var i = 0; i < maxLength; i++) {
    final left = i < aParts.length ? aParts[i] : 0;
    final right = i < bParts.length ? bParts[i] : 0;
    if (left > right) return 1;
    if (left < right) return -1;
  }
  return 0;
}

List<int> _normalizeVersion(String value) {
  final normalized = value
      .split('+')
      .first
      .replaceAll(RegExp(r'[^0-9.]'), '')
      .split('.')
      .where((part) => part.isNotEmpty)
      .map((part) => int.tryParse(part) ?? 0)
      .toList();

  if (normalized.isEmpty) return [0];
  return normalized;
}
