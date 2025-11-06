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
        dadosParsed = DasData.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return EmitirDasResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: dadosParsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados != null ? jsonEncode(dados!.toJson()) : '',
    };
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
    return dados?.docArrecadacaoPdfB64.isNotEmpty ?? false;
  }

  /// Obtém o tamanho do PDF em bytes
  int get tamanhoPdf {
    if (dados == null) return 0;

    final pdfBase64 = dados!.docArrecadacaoPdfB64;
    if (pdfBase64.isEmpty) return 0;

    // Calcula o tamanho aproximado do PDF em bytes
    // Base64 tem aproximadamente 4/3 do tamanho original
    return (pdfBase64.length * 3 / 4).round();
  }

  /// Formata o tamanho do PDF
  String get tamanhoPdfFormatado {
    final tamanho = tamanhoPdf;
    if (tamanho == 0) return '0 bytes';

    if (tamanho < 1024) {
      return '$tamanho bytes';
    } else if (tamanho < 1024 * 1024) {
      return '${(tamanho / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanho / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Obtém o PDF em formato Base64
  String? get pdfBase64 {
    return dados?.docArrecadacaoPdfB64;
  }

  /// Verifica se há PDF disponível
  bool get temPdf {
    final pdf = pdfBase64;
    return pdf != null && pdf.isNotEmpty;
  }

  /// Obtém informações sobre o PDF
  String get infoPdf {
    if (!temPdf) {
      return 'PDF não disponível';
    }

    return 'PDF disponível - Tamanho: $tamanhoPdfFormatado';
  }
}

class DasData {
  final String docArrecadacaoPdfB64;

  DasData({required this.docArrecadacaoPdfB64});

  factory DasData.fromJson(String jsonString) {
    final json = jsonString as Map<String, dynamic>;
    return DasData(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }

  /// Verifica se o PDF está disponível
  bool get temPdf {
    return docArrecadacaoPdfB64.isNotEmpty;
  }

  /// Obtém o tamanho do PDF em bytes
  int get tamanhoPdf {
    if (docArrecadacaoPdfB64.isEmpty) return 0;

    // Calcula o tamanho aproximado do PDF em bytes
    // Base64 tem aproximadamente 4/3 do tamanho original
    return (docArrecadacaoPdfB64.length * 3 / 4).round();
  }

  /// Formata o tamanho do PDF
  String get tamanhoPdfFormatado {
    final tamanho = tamanhoPdf;
    if (tamanho == 0) return '0 bytes';

    if (tamanho < 1024) {
      return '$tamanho bytes';
    } else if (tamanho < 1024 * 1024) {
      return '${(tamanho / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanho / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Obtém informações sobre o PDF
  String get infoPdf {
    if (!temPdf) {
      return 'PDF não disponível';
    }

    return 'PDF disponível - Tamanho: $tamanhoPdfFormatado';
  }

  /// Verifica se o PDF é válido (começa com o header PDF)
  bool get isPdfValido {
    if (docArrecadacaoPdfB64.isEmpty) return false;

    try {
      // Decodifica o Base64 e verifica se começa com o header PDF
      final uri = Uri.dataFromString(docArrecadacaoPdfB64, mimeType: 'application/pdf');
      final bytes = uri.data?.contentAsBytes();
      if (bytes == null) return false;

      final header = String.fromCharCodes(bytes.take(4));
      return header == '%PDF';
    } catch (e) {
      return false;
    }
  }

  /// Obtém o tipo MIME do documento
  String get tipoMime {
    if (isPdfValido) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }

  /// Obtém a extensão do arquivo
  String get extensaoArquivo {
    if (isPdfValido) {
      return '.pdf';
    }
    return '.bin';
  }

  /// Obtém sugestão de nome de arquivo
  String get nomeArquivoSugerido {
    final agora = DateTime.now();
    final timestamp = agora.millisecondsSinceEpoch;
    return 'DAS_PERTSN_$timestamp$extensaoArquivo';
  }
}
