import 'dart:convert';
import 'dart:io';

class PdfFileUtils {
  static Future<bool> salvarPdf(String pdfBase64, String nomeDoArquivo) async {
    if (pdfBase64.isEmpty) {
      return false;
    }

    try {
      final bytes = base64Decode(pdfBase64);
      if (!Directory('pdfs').existsSync()) {
        Directory('pdfs').createSync();
      }
      final arquivo = File('pdfs/$nomeDoArquivo');
      await arquivo.writeAsBytes(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }
}
