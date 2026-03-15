class ChatTextFormatter {
  static String sanitizeAssistantText(String text) {
    var cleaned = text.trim();

    cleaned = cleaned.replaceAllMapped(RegExp(r'```[\s\S]*?```'), (match) {
      final block = match.group(0) ?? '';
      return block.replaceAll('```', '').trim();
    });

    cleaned = cleaned
        .replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*>\s?', multiLine: true), '')
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('`', '')
        .replaceAll('*', '')
        .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '- ')
        .replaceAll(RegExp(r'\r\n?'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    return cleaned;
  }
}
