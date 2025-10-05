import 'mensagem.dart';

class ConsultarParcelamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarParcelamentoResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarParcelamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelamentoResponse(
      status: json['status']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dados: json['dados']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados,
    };
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
      numero: int.parse(json['numero'].toString()),
      dataDoPedido: int.parse(json['dataDoPedido'].toString()),
      situacao: json['situacao']?.toString() ?? '',
      dataDaSituacao: int.parse(json['dataDaSituacao'].toString()),
      consolidacaoOriginal: json['consolidacaoOriginal'] != null
          ? ConsolidacaoOriginal.fromJson(
              json['consolidacaoOriginal'] as Map<String, dynamic>,
            )
          : null,
      consolidacoesRestanteDivida:
          (json['consolidacoesRestanteDivida'] as List<dynamic>?)
              ?.map((e) => RestanteDivida.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      demonstrativoPagamentos:
          (json['demonstrativoPagamentos'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DemonstrativoPagamento.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'dataDoPedido': dataDoPedido,
      'situacao': situacao,
      'dataDaSituacao': dataDaSituacao,
      'consolidacaoOriginal': consolidacaoOriginal?.toJson(),
      'consolidacoesRestanteDivida': consolidacoesRestanteDivida
          .map((e) => e.toJson())
          .toList(),
      'demonstrativoPagamentos': demonstrativoPagamentos
          .map((e) => e.toJson())
          .toList(),
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
      valorTotalConsolidadoDaEntrada: (num.parse(
        json['valorTotalConsolidadoDaEntrada'].toString(),
      )).toDouble(),
      quantidadeParcelasDaEntrada: int.parse(
        json['quantidadeParcelasDaEntrada'].toString(),
      ),
      parcelaBasicaDaEntrada: (num.parse(
        json['parcelaBasicaDaEntrada'].toString(),
      )).toDouble(),
      dataConsolidacao: int.parse(json['dataConsolidacao'].toString()),
      valorTotalConsolidadoDaDivida: (num.parse(
        json['valorTotalConsolidadoDaDivida'].toString(),
      )).toDouble(),
      detalhesConsolidacao:
          (json['detalhesConsolidacao'] as List<dynamic>?)
              ?.map(
                (e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidadoDaEntrada': valorTotalConsolidadoDaEntrada,
      'quantidadeParcelasDaEntrada': quantidadeParcelasDaEntrada,
      'parcelaBasicaDaEntrada': parcelaBasicaDaEntrada,
      'dataConsolidacao': dataConsolidacao,
      'valorTotalConsolidadoDaDivida': valorTotalConsolidadoDaDivida,
      'detalhesConsolidacao': detalhesConsolidacao
          .map((e) => e.toJson())
          .toList(),
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
      periodoApuracao: int.parse(json['periodoApuracao'].toString()),
      vencimento: int.parse(json['vencimento'].toString()),
      numeroProcesso: json['numeroProcesso']?.toString() ?? '',
      saldoDevedorOriginal: (num.parse(
        json['saldoDevedorOriginal'].toString(),
      )).toDouble(),
      valorAtualizado: (num.parse(
        json['valorAtualizado'].toString(),
      )).toDouble(),
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
      valorTotalConsolidadoDivida: (num.parse(
        json['valorTotalConsolidadoDivida'].toString(),
      )).toDouble(),
      parcelasRemanescentes: int.parse(
        json['parcelasRemanescentes'].toString(),
      ),
      parcelaBasica: (num.parse(json['parcelaBasica'].toString())).toDouble(),
      dataConfirmacaoConsolidacao: int.parse(
        json['dataConfirmacaoConsolidacao'].toString(),
      ),
      detalhesConsolidacao:
          (json['detalhesConsolidacao'] as List<dynamic>?)
              ?.map(
                (e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidadoDivida': valorTotalConsolidadoDivida,
      'parcelasRemanescentes': parcelasRemanescentes,
      'parcelaBasica': parcelaBasica,
      'dataConfirmacaoConsolidacao': dataConfirmacaoConsolidacao,
      'detalhesConsolidacao': detalhesConsolidacao
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class DemonstrativoPagamento {
  final int mesDaParcela;
  final int vencimentoDoDas;
  final int dataDeArrecadacao;
  final double valorPago;

  DemonstrativoPagamento({
    required this.mesDaParcela,
    required this.vencimentoDoDas,
    required this.dataDeArrecadacao,
    required this.valorPago,
  });

  factory DemonstrativoPagamento.fromJson(Map<String, dynamic> json) {
    return DemonstrativoPagamento(
      mesDaParcela: int.parse(json['mesDaParcela'].toString()),
      vencimentoDoDas: int.parse(json['vencimentoDoDas'].toString()),
      dataDeArrecadacao: int.parse(json['dataDeArrecadacao'].toString()),
      valorPago: (num.parse(json['valorPago'].toString())).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mesDaParcela': mesDaParcela,
      'vencimentoDoDas': vencimentoDoDas,
      'dataDeArrecadacao': dataDeArrecadacao,
      'valorPago': valorPago,
    };
  }
}
