import 'dart:convert';
import 'package:serpro_integra_contador_api/src/util/print.dart';
import 'relpmei_base_response.dart';

/// Modelo de resposta para consultar pedidos de parcelamento (PEDIDOSPARC233)
class ConsultarPedidosRelpmeiResponse extends RelpmeiBaseResponse {
  ConsultarPedidosRelpmeiResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como lista de parcelamentos
  List<ParcelamentoRelpmei>? get parcelamentos {
    try {
      if (dados.isEmpty) return [];

      final dadosMap = jsonDecode(dados) as Map<String, dynamic>;
      final parcelamentosList = dadosMap['parcelamentos'] as List?;

      if (parcelamentosList == null) return [];

      return parcelamentosList.map((p) => ParcelamentoRelpmei.fromJson(p)).toList();
    } catch (e) {
      printE('Erro ao parsear parcelamentos: $e');
      return null;
    }
  }

  factory ConsultarPedidosRelpmeiResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarPedidosRelpmeiResponse(status: int.parse(json['status'].toString()), mensagens: (json['mensagens'] as List).map((m) => MensagemRelpmei.fromJson(m)).toList(), dados: json['dados'].toString());
  }
}

/// Modelo de resposta para consultar parcelamento específico (OBTERPARC234)
class ConsultarParcelamentoRelpmeiResponse extends RelpmeiBaseResponse {
  ConsultarParcelamentoRelpmeiResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como parcelamento específico
  ParcelamentoDetalhadoRelpmei? get parcelamento {
    try {
      if (dados.isEmpty) return null;

      final dadosMap = jsonDecode(dados) as Map<String, dynamic>;
      return ParcelamentoDetalhadoRelpmei.fromJson(dadosMap);
    } catch (e) {
      printE('Erro ao parsear parcelamento: $e');
      return null;
    }
  }

  factory ConsultarParcelamentoRelpmeiResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelamentoRelpmeiResponse(status: int.parse(json['status'].toString()), mensagens: (json['mensagens'] as List).map((m) => MensagemRelpmei.fromJson(m)).toList(), dados: json['dados'].toString());
  }
}

/// Modelo de resposta para consultar parcelas para impressão (PARCELASPARAGERAR232)
class ConsultarParcelasImpressaoRelpmeiResponse extends RelpmeiBaseResponse {
  ConsultarParcelasImpressaoRelpmeiResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como lista de parcelas disponíveis
  List<ParcelaDisponivelRelpmei>? get parcelasDisponiveis {
    try {
      if (dados.isEmpty) return [];

      final dadosMap = jsonDecode(dados) as Map<String, dynamic>;
      final parcelasList = dadosMap['listaParcelas'] as List?;

      if (parcelasList == null) return [];

      return parcelasList.map((p) => ParcelaDisponivelRelpmei.fromJson(p)).toList();
    } catch (e) {
      printE('Erro ao parsear parcelas disponíveis: $e');
      return null;
    }
  }

  factory ConsultarParcelasImpressaoRelpmeiResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelasImpressaoRelpmeiResponse(status: int.parse(json['status'].toString()), mensagens: (json['mensagens'] as List).map((m) => MensagemRelpmei.fromJson(m)).toList(), dados: json['dados'].toString());
  }
}

/// Modelo de resposta para consultar detalhes de pagamento (DETPAGTOPARC235)
class ConsultarDetalhesPagamentoRelpmeiResponse extends RelpmeiBaseResponse {
  ConsultarDetalhesPagamentoRelpmeiResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como detalhes de pagamento
  DetalhesPagamentoRelpmei? get detalhesPagamento {
    try {
      if (dados.isEmpty) return null;

      final dadosMap = jsonDecode(dados) as Map<String, dynamic>;
      return DetalhesPagamentoRelpmei.fromJson(dadosMap);
    } catch (e) {
      printE('Erro o parsear detalhes de pagamento: $e');
      return null;
    }
  }

  factory ConsultarDetalhesPagamentoRelpmeiResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDetalhesPagamentoRelpmeiResponse(status: int.parse(json['status'].toString()), mensagens: (json['mensagens'] as List).map((m) => MensagemRelpmei.fromJson(m)).toList(), dados: json['dados'].toString());
  }
}

/// Modelo de resposta para emitir DAS (GERARDAS231)
class EmitirDasRelpmeiResponse extends RelpmeiBaseResponse {
  EmitirDasRelpmeiResponse({required super.status, required super.mensagens, required super.dados});

  /// Parse dos dados como DAS emitido
  DasEmitidoRelpmei? get dasEmitido {
    try {
      if (dados.isEmpty) return null;

      final dadosMap = jsonDecode(dados) as Map<String, dynamic>;
      return DasEmitidoRelpmei.fromJson(dadosMap);
    } catch (e) {
      printE('Erro ao parsear DAS emitido: $e');
      return null;
    }
  }

  factory EmitirDasRelpmeiResponse.fromJson(Map<String, dynamic> json) {
    return EmitirDasRelpmeiResponse(status: int.parse(json['status'].toString()), mensagens: (json['mensagens'] as List).map((m) => MensagemRelpmei.fromJson(m)).toList(), dados: json['dados'].toString());
  }
}

// ==================================================================
// MODELOS DE DADOS SEGUINDO ESTRUTURA DA DOCUMENTAÇÃO SERPRO
// ==================================================================

/// Modelo para Parcelamento RELPMEI
class ParcelamentoRelpmei {
  final int numero;
  final int dataDoPedido; // Formato: AAAAMMDD
  final String situacao;
  final int dataDaSituacao; // Formato: AAAAMMDD

  ParcelamentoRelpmei({required this.numero, required this.dataDoPedido, required this.situacao, required this.dataDaSituacao});

  factory ParcelamentoRelpmei.fromJson(Map<String, dynamic> json) {
    return ParcelamentoRelpmei(numero: json['numero'] as int? ?? 0, dataDoPedido: json['dataDoPedido'] as int? ?? 0, situacao: json['situacao']?.toString() ?? '', dataDaSituacao: json['dataDaSituacao'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() => {'numero': numero, 'dataDoPedido': dataDoPedido, 'situacao': situacao, 'dataDaSituacao': dataDaSituacao};
}

/// Modelo para Parcelamento Detalhado RELPMEI
class ParcelamentoDetalhadoRelpmei {
  final int numero;
  final int dataDoPedido;
  final String situacao;
  final int dataDaSituacao;
  final ConsolidacaoRelpmei? consolidacaoOriginal;

  ParcelamentoDetalhadoRelpmei({required this.numero, required this.dataDoPedido, required this.situacao, required this.dataDaSituacao, this.consolidacaoOriginal});

  factory ParcelamentoDetalhadoRelpmei.fromJson(Map<String, dynamic> json) {
    return ParcelamentoDetalhadoRelpmei(numero: json['numero'] as int? ?? 0, dataDoPedido: json['dataDoPedido'] as int? ?? 0, situacao: json['situacao']?.toString() ?? '', dataDaSituacao: json['dataDaSituacao'] as int? ?? 0, consolidacaoOriginal: json['consolidacaoOriginal'] != null ? ConsolidacaoRelpmei.fromJson(json['consolidacaoOriginal']) : null);
  }

  Map<String, dynamic> toJson() => {'numero': numero, 'dataDoPedido': dataDoPedido, 'situacao': situacao, 'dataDaSituacao': dataDaSituacao, 'consolidacaoOriginal': consolidacaoOriginal?.toJson()};
}

/// Modelo para Consolidação RELPMEI
class ConsolidacaoRelpmei {
  final double valorTotalConsolidadoDeEntrada;
  final int quantidadeParcelasDeEntrada;
  final double parcelaDeEntrada;
  final int dataConsolidacao; // Formato: AAAAMMDDHHMMSS

  ConsolidacaoRelpmei({required this.valorTotalConsolidadoDeEntrada, required this.quantidadeParcelasDeEntrada, required this.parcelaDeEntrada, required this.dataConsolidacao});

  factory ConsolidacaoRelpmei.fromJson(Map<String, dynamic> json) {
    return ConsolidacaoRelpmei(valorTotalConsolidadoDeEntrada: (json['valorTotalConsolidadoDeEntrada'] as num?)?.toDouble() ?? 0.0, quantidadeParcelasDeEntrada: json['quantidadeParcelasDeEntrada'] as int? ?? 0, parcelaDeEntrada: (json['parcelaDeEntrada'] as num?)?.toDouble() ?? 0.0, dataConsolidacao: json['dataConsolidacao'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() => {'valorTotalConsolidadoDeEntrada': valorTotalConsolidadoDeEntrada, 'quantidadeParcelasDeEntrada': quantidadeParcelasDeEntrada, 'parcelaDeEntrada': parcelaDeEntrada, 'dataConsolidacao': dataConsolidacao};
}

/// Modelo para Parcela Disponívvel RELPMEI
class ParcelaDisponivelRelpmei {
  final int parcela; // Formato: AAAAMM
  final double valor;

  ParcelaDisponivelRelpmei({required this.parcela, required this.valor});

  factory ParcelaDisponivelRelpmei.fromJson(Map<String, dynamic> json) {
    return ParcelaDisponivelRelpmei(parcela: json['parcela'] as int? ?? 0, valor: (json['valor'] as num?)?.toDouble() ?? 0.0);
  }

  Map<String, dynamic> toJson() => {'parcela': parcela, 'valor': valor};
}

/// Modelo para Detalhes de Pagamento RELPMEI
class DetalhesPagamentoRelpmei {
  final String numeroDas;
  final int dataVencimento; // Formato: AAAAMMDD
  final String paDasGerado; // Período apuração: AAAAMM
  final String geradoEm; // Formato: AAAAMMDDHHMMSS
  final String numeroParcelamento;
  final String numeroParcela;
  final int dataLimiteAcolhimento; // Formato: AAAAMMDD
  final int dataPagamento; // Formato: AAAAMMDD
  final String bancoAgencia;
  final double valorPagoArrecadacao;

  DetalhesPagamentoRelpmei({required this.numeroDas, required this.dataVencimento, required this.paDasGerado, required this.geradoEm, required this.numeroParcelamento, required this.numeroParcela, required this.dataLimiteAcolhimento, required this.dataPagamento, required this.bancoAgencia, required this.valorPagoArrecadacao});

  factory DetalhesPagamentoRelpmei.fromJson(Map<String, dynamic> json) {
    return DetalhesPagamentoRelpmei(numeroDas: json['numeroDas']?.toString() ?? '', dataVencimento: json['dataVencimento'] as int? ?? 0, paDasGerado: json['paDasGerado']?.toString() ?? '', geradoEm: json['geradoEm']?.toString() ?? '', numeroParcelamento: json['numeroParcelamento']?.toString() ?? '', numeroParcela: json['numeroParcela']?.toString() ?? '', dataLimiteAcolhimento: json['dataLimiteAcolhimento'] as int? ?? 0, dataPagamento: json['dataPagamento'] as int? ?? 0, bancoAgencia: json['bancoAgencia']?.toString() ?? '', valorPagoArrecadacao: (json['valorPagoArrecadacao'] as num?)?.toDouble() ?? 0.0);
  }

  Map<String, dynamic> toJson() => {'numeroDas': numeroDas, 'dataVencimento': dataVencimento, 'paDasGerado': paDasGerado, 'geradoEm': geradoEm, 'numeroParcelamento': numeroParcelamento, 'numeroParcela': numeroParcela, 'dataLimiteAcolhimento': dataLimiteAcolhimento, 'dataPagamento': dataPagamento, 'bancoAgencia': bancoAgencia, 'valorPagoArrecadacao': valorPagoArrecadacao};
}

/// Modelo para DAS Emitido RELPMEI
class DasEmitidoRelpmei {
  final String docArrecadacaoPdfB64; // PDF em Base64

  DasEmitidoRelpmei({required this.docArrecadacaoPdfB64});

  factory DasEmitidoRelpmei.fromJson(Map<String, dynamic> json) {
    return DasEmitidoRelpmei(docArrecadacaoPdfB64: json['docArrecadacaoPdfB64']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {'docArrecadacaoPdfB64': docArrecadacaoPdfB64};
}
