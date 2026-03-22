import 'dart:convert';

/// Extracts plain text from a Quill Delta JSON string.
///
/// If [content] is valid Delta JSON (a JSON array of insert operations),
/// returns the concatenated plain text. Otherwise returns [content] as-is.
/// The result is trimmed of trailing whitespace.
String deltaToPlainText(String content) {
  try {
    final String trimmed = content.trim();
    if (!trimmed.startsWith('[')) return content;

    final dynamic decoded = jsonDecode(trimmed);
    if (decoded is! List) return content;

    final StringBuffer buffer = StringBuffer();
    for (final dynamic op in decoded) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        final dynamic insert = op['insert'];
        if (insert is String) {
          buffer.write(insert);
        }
      }
    }
    return buffer.toString().trim();
  } catch (_) {
    return content;
  }
}
