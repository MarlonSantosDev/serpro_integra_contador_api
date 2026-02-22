import 'dart:convert';
import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final DasData? dados;

  EmitirDasResponse({required this.status, required this.mensagens, this.dados});

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    DasData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        // Se dadosJson já é um JSON válido, usa diretamente
        if (dadosStr.startsWith('{')) {
          final Map<String, dynamic> jsonMap = jsonDecode(dadosStr);
          dadosParsed = DasData(docArrecadacaoPdfB64: jsonMap['docArrecadacaoPdfB64'].toString());
        } else {
          // Caso contrário, tenta parsear como string
          dadosParsed = DasData.fromJson(dadosStr);
        }
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return EmitirDasResponse(status: json['status'].toString(), mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(), dados: dadosParsed);
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados != null ? jsonEncode(dados!.toJson()) : ''};
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
    return sucesso && dados?.docArrecadacaoPdfB64 != null && dados!.docArrecadacaoPdfB64.isNotEmpty;
  }

  /// Retorna o tamanho do PDF em bytes
  int? get tamanhoPdfBytes {
    final pdfBase64 = dados?.docArrecadacaoPdfB64;
    if (pdfBase64 == null || pdfBase64.isEmpty) return null;

    // Calcula o tamanho aproximado do PDF em bytes
    // Base64 usa 4 caracteres para representar 3 bytes
    return (pdfBase64.length * 3) ~/ 4;
  }

  /// Retorna o tamanho do PDF formatado
  String? get tamanhoPdfFormatado {
    final tamanho = tamanhoPdfBytes;
    if (tamanho == null) return null;

    if (tamanho < 1024) {
      return '$tamanho bytes';
    } else if (tamanho < 1024 * 1024) {
      return '${(tamanho / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanho / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

class DasData {
  final String docArrecadacaoPdfB64;

  DasData({required this.docArrecadacaoPdfB64});

  factory DasData.fromJson(String jsonString) {
    final Map<String, dynamic> json = {"docArrecadacaoPdfB64": jsonString};
    return DasData(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }

  /// Verifica se o PDF está disponível
  bool get pdfDisponivel => docArrecadacaoPdfB64.isNotEmpty;

  /// Retorna os primeiros caracteres do PDF Base64 para debug
  String get pdfPreview {
    if (docArrecadacaoPdfB64.isEmpty) return 'PDF não disponível';
    return 'PDF Base64: ${docArrecadacaoPdfB64.substring(0, docArrecadacaoPdfB64.length > 50 ? 50 : docArrecadacaoPdfB64.length)}...';
  }

  /// Retorna informações sobre o PDF
  Map<String, dynamic> get pdfInfo {
    return {'disponivel': pdfDisponivel, 'tamanho_caracteres': docArrecadacaoPdfB64.length, 'tamanho_bytes_aproximado': (docArrecadacaoPdfB64.length * 3) ~/ 4, 'preview': pdfPreview};
  }
}
