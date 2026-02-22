import 'dart:convert';
import 'dart:io';
import 'package:serpro_integra_contador_api/src/util/print.dart';

/// Implementação nativa para Desktop/Mobile - suporta operações de arquivo
class ArquivoUtils {
  /// Salva um arquivo em base64 em um arquivo local
  static Future<bool> salvarArquivo(String pdfBase64, String nomeDoArquivo) async {
    try {
      if (pdfBase64.isEmpty) {
        throw Exception('PDF base64 vazio');
      }
      if (nomeDoArquivo.isEmpty) {
        throw Exception('Nome do arquivo vazio');
      }
      if (pdfBase64.length < 100) {
        throw Exception('string base64 muito pequeno');
      }
      if (!nomeDoArquivo.contains('.')) {
        throw Exception('Nome do arquivo não contém extensão');
      }
      final extensao = nomeDoArquivo.split('.').last;
      if (extensao.isEmpty) {
        throw Exception('Extensão vazia');
      }
      final bytes = base64Decode(pdfBase64);
      if (!Directory("arquivos").existsSync()) {
        Directory("arquivos").createSync();
      }
      if (!Directory("arquivos/$extensao").existsSync()) {
        Directory("arquivos/$extensao").createSync();
      }
      final arquivo = File('arquivos/$extensao/$nomeDoArquivo');
      await arquivo.writeAsBytes(bytes);
      return true;
    } catch (e) {
      printE('Erro ao salvar arquivo: $e');
      return false;
    }
  }
}
