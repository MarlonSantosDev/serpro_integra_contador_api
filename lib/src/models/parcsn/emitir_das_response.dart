import 'dart:convert';
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
      final parsed = DasData.fromJson(dadosJson);
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

  /// Verifica se há dados de DAS disponíveis
  bool get temDadosDas => dadosParsed != null;

  /// Verifica se o PDF foi gerado com sucesso
  bool get pdfGeradoComSucesso {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.docArrecadacaoPdfB64 != null && dadosParsed!.docArrecadacaoPdfB64.isNotEmpty;
  }

  /// Tamanho do PDF em bytes
  int get tamanhoPdf {
    final dadosParsed = this.dadosParsed;
    if (dadosParsed?.docArrecadacaoPdfB64 != null) {
      return dadosParsed!.docArrecadacaoPdfB64.length;
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
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.numeroDas;
  }

  /// Código de barras do DAS
  String? get codigoBarras {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.codigoBarras;
  }

  /// Valor do DAS
  double? get valorDas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.valor;
  }

  /// Valor do DAS formatado como moeda brasileira
  String? get valorDasFormatado {
    final valor = valorDas;
    if (valor == null) return null;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Data de vencimento do DAS
  String? get dataVencimento {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.dataVencimento;
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String? get dataVencimentoFormatada {
    final data = dataVencimento;
    if (data == null || data.isEmpty) return null;

    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
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
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
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
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String get dataVencimentoFormatada {
    if (dataVencimento.length == 8) {
      return '${dataVencimento.substring(6, 8)}/${dataVencimento.substring(4, 6)}/${dataVencimento.substring(0, 4)}';
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
