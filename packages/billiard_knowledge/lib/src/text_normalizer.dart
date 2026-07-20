String normalizeKnowledgeText(String input) {
  const source =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const target =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  final lower = input.toLowerCase();
  final out = StringBuffer();
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    final index = source.indexOf(character);
    if (index >= 0) {
      out.write(target[index]);
    } else if (RegExp(r'[a-z0-9]').hasMatch(character)) {
      out.write(character);
    } else {
      out.write(' ');
    }
  }
  return out.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
