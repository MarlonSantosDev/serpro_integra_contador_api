import 'mensagem.dart';

class ConsultarParcelamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarParcelamentoResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarParcelamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelamentoResponse(
      status: json['status'] as String? ?? '',
      mensagens: (json['mensagens'] as List<dynamic>?)?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      dados: json['dados'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Retorna os dados parseados como objeto parcelamento detalhado
  ParcelamentoDetalhado? get parcelamentoDetalhado {
    try {
      if (dados.isEmpty) return null;

      // Em implementação real, seria feito parsing do JSON string
      // Por enquanto retornamos null - seria implementado com dart:convert
      return null;
    } catch (e) {
      return null;
    }
  }
}

class ParcelamentoDetalhado {
  final int numero;
  final int dataDoPedido;
  final String situacao;
  final int dataDaSituacao;
  final ConsolidacaoOriginal? consolidacaoOriginal;
  final List<RestanteDivida> consolidacoesRestanteDivida;
  final List<DemonstrativoPagamento> demonstrativoPagamentos;

  ParcelamentoDetalhado({
    required this.numero,
    required this.dataDoPedido,
    required this.situacao,
    required this.dataDaSituacao,
    this.consolidacaoOriginal,
    required this.consolidacoesRestanteDivida,
    required this.demonstrativoPagamentos,
  });

  factory ParcelamentoDetalhado.fromJson(Map<String, dynamic> json) {
    return ParcelamentoDetalhado(
      numero: json['numero'] as int? ?? 0,
      dataDoPedido: json['dataDoPedido'] as int? ?? 0,
      situacao: json['situacao'] as String? ?? '',
      dataDaSituacao: json['dataDaSituacao'] as int? ?? 0,
      consolidacaoOriginal: json['consolidacaoOriginal'] != null
          ? ConsolidacaoOriginal.fromJson(json['consolidacaoOriginal'] as Map<String, dynamic>)
          : null,
      consolidacoesRestanteDivida:
          (json['consolidacoesRestanteDivida'] as List<dynamic>?)?.map((e) => RestanteDivida.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      demonstrativoPagamentos:
          (json['demonstrativoPagamentos'] as List<dynamic>?)?.map((e) => DemonstrativoPagamento.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'dataDoPedido': dataDoPedido,
      'situacao': situacao,
      'dataDaSituacao': dataDaSituacao,
      'consolidacaoOriginal': consolidacaoOriginal?.toJson(),
      'consolidacoesRestanteDivida': consolidacoesRestanteDivida.map((e) => e.toJson()).toList(),
      'demonstrativoPagamentos': demonstrativoPagamentos.map((e) => e.toJson()).toList(),
    };
  }
}

class ConsolidacaoOriginal {
  final double valorTotalConsolidadoDaEntrada;
  final int quantidadeParcelasDaEntrada;
  final double parcelaBasicaDaEntrada;
  final int dataConsolidacao;
  final double valorTotalConsolidadoDaDivida;
  final List<DetalhesConsolidacao> detalhesConsolidacao;

  ConsolidacaoOriginal({
    required this.valorTotalConsolidadoDaEntrada,
    required this.quantidadeParcelasDaEntrada,
    required this.parcelaBasicaDaEntrada,
    required this.dataConsolidacao,
    required this.valorTotalConsolidadoDaDivida,
    required this.detalhesConsolidacao,
  });

  factory ConsolidacaoOriginal.fromJson(Map<String, dynamic> json) {
    return ConsolidacaoOriginal(
      valorTotalConsolidadoDaEntrada: (json['valorTotalConsolidadoDaEntrada'] as num?)?.toDouble() ?? 0.0,
      quantidadeParcelasDaEntrada: json['quantidadeParcelasDaEntrada'] as int? ?? 0,
      parcelaBasicaDaEntrada: (json['parcelaBasicaDaEntrada'] as num?)?.toDouble() ?? 0.0,
      dataConsolidacao: json['dataConsolidacao'] as int? ?? 0,
      valorTotalConsolidadoDaDivida: (json['valorTotalConsolidadoDaDivida'] as num?)?.toDouble() ?? 0.0,
      detalhesConsolidacao:
          (json['detalhesConsolidacao'] as List<dynamic>?)?.map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidadoDaEntrada': valorTotalConsolidadoDaEntrada,
      'quantidadeParcelasDaEntrada': quantidadeParcelasDaEntrada,
      'parcelaBasicaDaEntrada': parcelaBasicaDaEntrada,
      'dataConsolidacao': dataConsolidacao,
      'valorTotalConsolidadoDaDivida': valorTotalConsolidadoDaDivida,
      'detalhesConsolidacao': detalhesConsolidacao.map((e) => e.toJson()).toList(),
    };
  }
}

class DetalhesConsolidacao {
  final int periodoApuracao;
  final int vencimento;
  final String numeroProcesso;
  final double saldoDevedorOriginal;
  final double valorAtualizado;

  DetalhesConsolidacao({
    required this.periodoApuracao,
    required this.vencimento,
    required this.numeroProcesso,
    required this.saldoDevedorOriginal,
    required this.valorAtualizado,
  });

  factory DetalhesConsolidacao.fromJson(Map<String, dynamic> json) {
    return DetalhesConsolidacao(
      periodoApuracao: json['periodoApuracao'] as int? ?? 0,
      vencimento: json['vencimento'] as int? ?? 0,
      numeroProcesso: json['numeroProcesso'] as String? ?? '',
      saldoDevedorOriginal: (json['saldoDevedorOriginal'] as num?)?.toDouble() ?? 0.0,
      valorAtualizado: (json['valorAtualizado'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'vencimento': vencimento,
      'numeroProcesso': numeroProcesso,
      'saldoDevedorOriginal': saldoDevedorOriginal,
      'valorAtualizado': valorAtualizado,
    };
  }
}

class RestanteDivida {
  final double valorTotalConsolidadoDivida;
  final int parcelasRemanescentes;
  final double parcelaBasica;
  final int dataConfirmacaoConsolidacao;
  final List<DetalhesConsolidacao> detalhesConsolidacao;

  RestanteDivida({
    required this.valorTotalConsolidadoDivida,
    required this.parcelasRemanescentes,
    required this.parcelaBasica,
    required this.dataConfirmacaoConsolidacao,
    required this.detalhesConsolidacao,
  });

  factory RestanteDivida.fromJson(Map<String, dynamic> json) {
    return RestanteDivida(
      valorTotalConsolidadoDivida: (json['valorTotalConsolidadoDivida'] as num?)?.toDouble() ?? 0.0,
      parcelasRemanescentes: json['parcelasRemanescentes'] as int? ?? 0,
      parcelaBasica: (json['parcelaBasica'] as num?)?.toDouble() ?? 0.0,
      dataConfirmacaoConsolidacao: json['dataConfirmacaoConsolidacao'] as int? ?? 0,
      detalhesConsolidacao:
          (json['detalhesConsolidacao'] as List<dynamic>?)?.map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidadoDivida': valorTotalConsolidadoDivida,
      'parcelasRemanescentes': parcelasRemanescentes,
      'parcelaBasica': parcelaBasica,
      'dataConfirmacaoConsolidacao': dataConfirmacaoConsolidacao,
      'detalhesConsolidacao': detalhesConsolidacao.map((e) => e.toJson()).toList(),
    };
  }
}

class DemonstrativoPagamento {
  final int mesDaParcela;
  final int vencimentoDoDas;
  final int dataDeArrecadacao;
  final double valorPago;

  DemonstrativoPagamento({required this.mesDaParcela, required this.vencimentoDoDas, required this.dataDeArrecadacao, required this.valorPago});

  factory DemonstrativoPagamento.fromJson(Map<String, dynamic> json) {
    return DemonstrativoPagamento(
      mesDaParcela: json['mesDaParcela'] as int? ?? 0,
      vencimentoDoDas: json['vencimentoDoDas'] as int? ?? 0,
      dataDeArrecadacao: json['dataDeArrecadacao'] as int? ?? 0,
      valorPago: (json['valorPago'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mesDaParcela': mesDaParcela, 'vencimentoDoDas': vencimentoDoDas, 'dataDeArrecadacao': dataDeArrecadacao, 'valorPago': valorPago};
  }
}
