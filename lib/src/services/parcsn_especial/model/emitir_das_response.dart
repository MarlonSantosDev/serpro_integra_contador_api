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

  /// Verifica se há dados de DAS disponíveis
  bool get temDadosDas => dados != null;

  /// Verifica se o PDF foi gerado com sucesso
  bool get pdfGeradoComSucesso {
    return dados?.docArrecadacaoPdfB64.isNotEmpty ?? false;
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf {
    return dados?.docArrecadacaoPdfB64.length ?? 0;
  }

  /// Tamanho do PDF formatado (KB/MB)
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

  /// Converte o PDF Base64 para bytes
  List<int>? get pdfBytes {
    if (dados?.docArrecadacaoPdfB64.isEmpty ?? true) return null;

    try {
      return base64Decode(dados!.docArrecadacaoPdfB64);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'EmitirDasResponse(status: $status, mensagens: ${mensagens.length}, pdfGerado: $pdfGeradoComSucesso, tamanho: $tamanhoPdfFormatado)';
  }
}

class DasData {
  final String docArrecadacaoPdfB64;

  DasData({required this.docArrecadacaoPdfB64});

  factory DasData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return DasData(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
  }

  /// Converte o PDF Base64 para bytes
  List<int>? get pdfBytes {
    if (docArrecadacaoPdfB64.isEmpty) return null;

    try {
      return base64Decode(docArrecadacaoPdfB64);
    } catch (e) {
      return null;
    }
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf {
    return docArrecadacaoPdfB64.length;
  }

  /// Tamanho do PDF formatado (KB/MB)
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

  /// Verifica se o PDF está vazio
  bool get isVazio => docArrecadacaoPdfB64.isEmpty;

  /// Verifica se o PDF tem conteúdo válido
  bool get temConteudoValido {
    if (isVazio) return false;

    try {
      base64Decode(docArrecadacaoPdfB64);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return 'DasData(tamanho: $tamanhoPdfFormatado, valido: $temConteudoValido)';
  }
}
