import 'dart:convert';
import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final DasData? dados;

  EmitirDasResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    DasData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        final dadosJson = jsonDecode(dadosStr) as Map<String, dynamic>;
        dadosParsed = DasData.fromJson(dadosJson);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return EmitirDasResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List)
          .map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
          .toList(),
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
    return sucesso && dados?.docArrecadacaoPdfB64.isNotEmpty == true;
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf {
    if (dados?.docArrecadacaoPdfB64.isNotEmpty == true) {
      try {
        // Base64 tem aproximadamente 4/3 do tamanho original
        return (dados!.docArrecadacaoPdfB64.length * 3) ~/ 4;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// Tamanho do PDF formatado
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

  /// Verifica se há PDF disponível para download
  bool get temPdfDisponivel {
    return dados?.docArrecadacaoPdfB64.isNotEmpty == true;
  }

  /// Obtém o PDF como bytes
  List<int>? get pdfBytes {
    if (dados?.docArrecadacaoPdfB64.isNotEmpty == true) {
      try {
        // Converte Base64 para bytes
        return Uri.dataFromString(
          dados!.docArrecadacaoPdfB64,
          mimeType: 'application/pdf',
        ).data?.contentAsBytes();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Verifica se o PDF é válido
  bool get pdfValido {
    if (dados?.docArrecadacaoPdfB64.isNotEmpty == true) {
      try {
        // Verifica se é um Base64 válido
        Uri.dataFromString(
          dados!.docArrecadacaoPdfB64,
          mimeType: 'application/pdf',
        );
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}

class DasData {
  final String docArrecadacaoPdfB64;

  DasData({required this.docArrecadacaoPdfB64});

  factory DasData.fromJson(Map<String, dynamic> json) {
    return DasData(
      docArrecadacaoPdfB64: json['docArrecadacaoPdfB64']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }

  /// Verifica se o PDF está disponível
  bool get temPdf => docArrecadacaoPdfB64.isNotEmpty;

  /// Tamanho do PDF em bytes (aproximado)
  int get tamanhoBytes {
    if (docArrecadacaoPdfB64.isEmpty) return 0;
    try {
      // Base64 tem aproximadamente 4/3 do tamanho original
      return (docArrecadacaoPdfB64.length * 3) ~/ 4;
    } catch (e) {
      return 0;
    }
  }

  /// Tamanho formatado
  String get tamanhoFormatado {
    final tamanho = tamanhoBytes;
    if (tamanho == 0) return '0 bytes';

    if (tamanho < 1024) {
      return '$tamanho bytes';
    } else if (tamanho < 1024 * 1024) {
      return '${(tamanho / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(tamanho / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Converte o PDF Base64 para bytes
  List<int>? get pdfBytes {
    if (docArrecadacaoPdfB64.isEmpty) return null;

    try {
      return Uri.dataFromString(
        docArrecadacaoPdfB64,
        mimeType: 'application/pdf',
      ).data?.contentAsBytes();
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o Base64 é válido
  bool get isBase64Valido {
    if (docArrecadacaoPdfB64.isEmpty) return false;

    try {
      Uri.dataFromString(docArrecadacaoPdfB64, mimeType: 'application/pdf');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtém o tipo MIME do documento
  String get mimeType => 'application/pdf';

  /// Obtém a extensão do arquivo
  String get extensao => 'pdf';

  /// Gera um nome de arquivo sugerido
  String get nomeArquivoSugerido {
    final agora = DateTime.now();
    return 'DAS_PARCMEI_ESP_${agora.year}${agora.month.toString().padLeft(2, '0')}${agora.day.toString().padLeft(2, '0')}_${agora.hour.toString().padLeft(2, '0')}${agora.minute.toString().padLeft(2, '0')}.pdf';
  }
}
