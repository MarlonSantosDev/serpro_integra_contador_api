import 'mensagem.dart';

class EmitirDasResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  EmitirDasResponse({required this.status, required this.mensagens, required this.dados});

  factory EmitirDasResponse.fromJson(Map<String, dynamic> json) {
    return EmitirDasResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Dados parseados do JSON string
  DasData? get dadosParsed {
    try {
      final dadosJson = dados;
      final parsed = DasData.fromJson(dadosJson as Map<String, dynamic>);
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
    return sucesso && dadosParsed?.docArrecadacaoPdfB64.isNotEmpty == true;
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed?.docArrecadacaoPdfB64.isNotEmpty == true) {
      try {
        // Base64 tem aproximadamente 4/3 do tamanho original
        return (dadosParsed!.docArrecadacaoPdfB64.length * 3) ~/ 4;
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
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.docArrecadacaoPdfB64.isNotEmpty == true;
  }

  /// Obtém o PDF como bytes
  List<int>? get pdfBytes {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed?.docArrecadacaoPdfB64.isNotEmpty == true) {
      try {
        // Converte Base64 para bytes
        return Uri.dataFromString(dadosParsed!.docArrecadacaoPdfB64, mimeType: 'application/pdf').data?.contentAsBytes();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Verifica se o PDF é válido
  bool get pdfValido {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed?.docArrecadacaoPdfB64.isNotEmpty == true) {
      try {
        // Verifica se é um Base64 válido
        Uri.dataFromString(dadosParsed!.docArrecadacaoPdfB64, mimeType: 'application/pdf');
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
    return DasData(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64']?.toString() ?? '');
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
      return Uri.dataFromString(docArrecadacaoPdfB64, mimeType: 'application/pdf').data?.contentAsBytes();
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
