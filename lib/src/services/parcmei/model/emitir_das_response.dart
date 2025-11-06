import 'dart:convert';
import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final DasData? dados;
  final bool sucesso;
  final String mensagemPrincipal;
  final bool pdfGeradoComSucesso;

  EmitirDasResponse({
    required this.status,
    required this.mensagens,
    this.dados,
    required this.sucesso,
    required this.mensagemPrincipal,
    required this.pdfGeradoComSucesso,
  });

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    DasData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        dadosParsed = DasData.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    final statusStr = json['status']?.toString() ?? '';
    final mensagensList = (json['mensagens'] as List?)?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    final sucesso = statusStr == '200';
    final mensagemPrincipal = mensagensList.isNotEmpty
        ? mensagensList.first.texto
        : (sucesso ? 'Requisição efetuada com sucesso.' : 'Erro na requisição.');
    final pdfGeradoComSucesso = dadosParsed?.docArrecadacaoPdfB64.isNotEmpty ?? false;

    return EmitirDasResponse(
      status: statusStr,
      mensagens: mensagensList,
      dados: dadosParsed,
      sucesso: sucesso,
      mensagemPrincipal: mensagemPrincipal,
      pdfGeradoComSucesso: pdfGeradoComSucesso,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados != null ? jsonEncode(dados!.toJson()) : ''};
  }

  /// Bytes do PDF decodificado
  List<int>? get pdfBytes {
    if (dados?.docArrecadacaoPdfB64.isEmpty ?? true) return null;

    try {
      return base64Decode(dados!.docArrecadacaoPdfB64);
    } catch (e) {
      return null;
    }
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdfBytes {
    final bytes = pdfBytes;
    return bytes?.length ?? 0;
  }

  /// Tamanho do PDF formatado
  String get tamanhoPdfFormatado {
    final bytes = tamanhoPdfBytes;
    if (bytes == 0) return '0 bytes';

    if (bytes < 1024) {
      return '$bytes bytes';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Verifica se o PDF é válido (começa com %PDF)
  bool get pdfValido {
    final bytes = pdfBytes;
    if (bytes == null || bytes.length < 4) return false;

    final header = String.fromCharCodes(bytes.take(4));
    return header == '%PDF';
  }

  /// Hash do PDF para verificação de integridade
  String? get pdfHash {
    final bytes = pdfBytes;
    if (bytes == null) return null;

    // Hash simples usando o tamanho e primeiros bytes
    final hash = bytes.length.toString() + bytes.take(10).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return hash.substring(0, 16);
  }

  /// Informações do PDF
  Map<String, dynamic>? get pdfInfo {
    if (!pdfGeradoComSucesso) return null;

    return {
      'tamanho_bytes': tamanhoPdfBytes,
      'tamanho_formatado': tamanhoPdfFormatado,
      'eh_valido': pdfValido,
      'hash': pdfHash,
      'base64_length': dados?.docArrecadacaoPdfB64.length ?? 0,
    };
  }
}

class DasData {
  final String docArrecadacaoPdfB64;
  final bool temPdf;
  final int tamanhoBase64;
  final int tamanhoEstimadoPdf;
  final bool base64Valido;
  final String base64Preview;
  final bool parecePdfValido;

  DasData({
    required this.docArrecadacaoPdfB64,
    required this.temPdf,
    required this.tamanhoBase64,
    required this.tamanhoEstimadoPdf,
    required this.base64Valido,
    required this.base64Preview,
    required this.parecePdfValido,
  });

  factory DasData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonString as Map<String, dynamic>;
      final docArrecadacaoPdfB64 = json['docArrecadacaoPdfB64']?.toString() ?? '';

      final temPdf = docArrecadacaoPdfB64.isNotEmpty;
      final tamanhoBase64 = docArrecadacaoPdfB64.length;
      final tamanhoEstimadoPdf = (docArrecadacaoPdfB64.length * 0.75).round();

      bool base64Valido = false;
      if (docArrecadacaoPdfB64.isNotEmpty) {
        try {
          base64Decode(docArrecadacaoPdfB64);
          base64Valido = true;
        } catch (e) {
          base64Valido = false;
        }
      }

      final base64Preview = docArrecadacaoPdfB64.isEmpty
          ? ''
          : (docArrecadacaoPdfB64.length > 50 ? '${docArrecadacaoPdfB64.substring(0, 50)}...' : docArrecadacaoPdfB64);

      final parecePdfValido = docArrecadacaoPdfB64.isNotEmpty && docArrecadacaoPdfB64.startsWith('JVBERi0x');

      return DasData(
        docArrecadacaoPdfB64: docArrecadacaoPdfB64,
        temPdf: temPdf,
        tamanhoBase64: tamanhoBase64,
        tamanhoEstimadoPdf: tamanhoEstimadoPdf,
        base64Valido: base64Valido,
        base64Preview: base64Preview,
        parecePdfValido: parecePdfValido,
      );
    } catch (e) {
      return DasData(
        docArrecadacaoPdfB64: '',
        temPdf: false,
        tamanhoBase64: 0,
        tamanhoEstimadoPdf: 0,
        base64Valido: false,
        base64Preview: '',
        parecePdfValido: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }
}
