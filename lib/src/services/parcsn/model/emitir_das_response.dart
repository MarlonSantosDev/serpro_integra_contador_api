import 'dart:convert';
import 'mensagem.dart';
import '../../../util/formatador_utils.dart';

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
        dadosParsed = DasData.fromJson(dadosStr);
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

  /// Verifica se há dados de DAS disponíveis
  bool get temDadosDas => dados != null;

  /// Verifica se o PDF foi gerado com sucesso
  bool get pdfGeradoComSucesso {
    return dados?.docArrecadacaoPdfB64 != null &&
        dados!.docArrecadacaoPdfB64.isNotEmpty;
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf {
    if (dados?.docArrecadacaoPdfB64 != null) {
      return dados!.docArrecadacaoPdfB64.length;
    }
    return 0;
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

  /// Número do DAS gerado
  String? get numeroDas {
    return dados?.numeroDas;
  }

  /// Código de barras do DAS
  String? get codigoBarras {
    return dados?.codigoBarras;
  }

  /// Valor do DAS
  double? get valorDas {
    return dados?.valor;
  }

  /// Valor do DAS formatado como moeda brasileira
  String? get valorDasFormatado {
    final valor = valorDas;
    if (valor == null) return null;
    return FormatadorUtils.formatCurrency(valor);
  }

  /// Data de vencimento do DAS
  String? get dataVencimento {
    return dados?.dataVencimento;
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String? get dataVencimentoFormatada {
    final data = dataVencimento;
    if (data == null || data.isEmpty) return null;

    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  @override
  String toString() {
    return 'EmitirDasResponse(status: $status, mensagens: ${mensagens.length}, pdfGerado: $pdfGeradoComSucesso, tamanho: $tamanhoPdfFormatado)';
  }
}

class DasData {
  final String numeroDas;
  final String codigoBarras;
  final double valor;
  final String dataVencimento;
  final String docArrecadacaoPdfB64;

  DasData({
    required this.numeroDas,
    required this.codigoBarras,
    required this.valor,
    required this.dataVencimento,
    required this.docArrecadacaoPdfB64,
  });

  factory DasData.fromJson(String jsonString) {
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return DasData(
      numeroDas: json['numeroDas'].toString(),
      codigoBarras: json['codigoBarras'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
      dataVencimento: json['dataVencimento'].toString(),
      docArrecadacaoPdfB64: json['docArrecadacaoPdfB64'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'codigoBarras': codigoBarras,
      'valor': valor,
      'dataVencimento': dataVencimento,
      'docArrecadacaoPdfB64': docArrecadacaoPdfB64,
    };
  }

  /// Valor formatado como moeda brasileira
  String get valorFormatado {
    return FormatadorUtils.formatCurrency(valor);
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String get dataVencimentoFormatada {
    if (dataVencimento.length == 8) {
      return FormatadorUtils.formatDateFromString(dataVencimento);
    }
    return dataVencimento;
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf => docArrecadacaoPdfB64.length;

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

  /// Verifica se o PDF está disponível
  bool get temPdf => docArrecadacaoPdfB64.isNotEmpty;

  @override
  String toString() {
    return 'DasData(numeroDas: $numeroDas, valor: $valorFormatado, vencimento: $dataVencimentoFormatada, tamanhoPdf: $tamanhoPdfFormatado)';
  }
}
