import 'dart:convert';
import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  EmitirDasResponse({required this.status, required this.mensagens, required this.dados});

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    return EmitirDasResponse(
      status: json['status']?.toString() ?? '',
      mensagens: (json['mensagens'] as List?)?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: json['dados']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Dados parseados do JSON string
  DasData? get dadosParsed {
    try {
      if (dados.isEmpty) return null;
      final parsed = DasData.fromJson(dados);
      return parsed;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se a requisição foi bem-sucedida
  bool get sucesso => status == '200';

  /// Mensagem principal de sucesso ou erro
  String get mensagemPrincipal {
    if (mensagens.isNotEmpty) {
      return mensagens.first.texto;
    }
    return sucesso ? 'Requisição efetuada com sucesso.' : 'Erro na requisição.';
  }

  /// Verifica se o PDF foi gerado com sucesso
  bool get pdfGeradoComSucesso {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.docArrecadacaoPdfB64.isNotEmpty ?? false;
  }

  /// Bytes do PDF decodificado
  List<int>? get pdfBytes {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed?.docArrecadacaoPdfB64.isEmpty ?? true) return null;

    try {
      return base64Decode(dadosParsed!.docArrecadacaoPdfB64);
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
      'base64_length': dadosParsed?.docArrecadacaoPdfB64.length ?? 0,
    };
  }
}

class DasData {
  final String docArrecadacaoPdfB64;

  DasData({required this.docArrecadacaoPdfB64});

  factory DasData.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonString as Map<String, dynamic>;

      return DasData(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64']?.toString() ?? '');
    } catch (e) {
      return DasData(docArrecadacaoPdfB64: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }

  /// Verifica se o PDF está presente
  bool get temPdf => docArrecadacaoPdfB64.isNotEmpty;

  /// Tamanho da string Base64
  int get tamanhoBase64 => docArrecadacaoPdfB64.length;

  /// Tamanho estimado do PDF em bytes (Base64 é ~33% maior que o original)
  int get tamanhoEstimadoPdf => (docArrecadacaoPdfB64.length * 0.75).round();

  /// Verifica se a string Base64 é válida
  bool get base64Valido {
    if (docArrecadacaoPdfB64.isEmpty) return false;

    try {
      base64Decode(docArrecadacaoPdfB64);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Primeiros caracteres da string Base64 (para debug)
  String get base64Preview {
    if (docArrecadacaoPdfB64.isEmpty) return '';
    return docArrecadacaoPdfB64.length > 50 ? '${docArrecadacaoPdfB64.substring(0, 50)}...' : docArrecadacaoPdfB64;
  }

  /// Verifica se parece ser um PDF válido (começa com JVBERi0x que é %PDF em Base64)
  bool get parecePdfValido {
    if (docArrecadacaoPdfB64.isEmpty) return false;

    // %PDF em Base64 é JVBERi0x
    return docArrecadacaoPdfB64.startsWith('JVBERi0x');
  }
}
