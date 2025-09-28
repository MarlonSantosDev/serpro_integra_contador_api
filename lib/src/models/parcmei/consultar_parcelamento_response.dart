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
          (json['mensagens'] as List?)
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

  /// Dados parseados do JSON string
  ParcelamentoDetalhado? get dadosParsed {
    try {
      if (dados.isEmpty) return null;
      final parsed = ParcelamentoDetalhado.fromJson(dados);
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

  /// Valor total consolidado formatado
  String get valorTotalConsolidadoFormatado {
    final dadosParsed = this.dadosParsed;
    final valor =
        dadosParsed?.consolidacaoOriginal?.valorTotalConsolidado ?? 0.0;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Quantidade de parcelas
  int get quantidadeParcelas {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.consolidacaoOriginal?.quantidadeParcelas ?? 0;
  }

  /// Valor da parcela básica formatado
  String get parcelaBasicaFormatada {
    final dadosParsed = this.dadosParsed;
    final valor = dadosParsed?.consolidacaoOriginal?.parcelaBasica ?? 0.0;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Quantidade de pagamentos realizados
  int get quantidadePagamentos {
    final dadosParsed = this.dadosParsed;
    return dadosParsed?.demonstrativoPagamentos.length ?? 0;
  }

  /// Valor total pago formatado
  String get valorTotalPagoFormatado {
    final dadosParsed = this.dadosParsed;
    final total =
        dadosParsed?.demonstrativoPagamentos.fold<double>(
          0.0,
          (sum, pagamento) => sum + pagamento.valorPago,
        ) ??
        0.0;
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class ParcelamentoDetalhado {
  final int numero;
  final int dataDoPedido;
  final String situacao;
  final int dataDaSituacao;
  final ConsolidacaoOriginal? consolidacaoOriginal;
  final List<AlteracaoDivida> alteracoesDivida;
  final List<DemonstrativoPagamento> demonstrativoPagamentos;

  ParcelamentoDetalhado({
    required this.numero,
    required this.dataDoPedido,
    required this.situacao,
    required this.dataDaSituacao,
    this.consolidacaoOriginal,
    required this.alteracoesDivida,
    required this.demonstrativoPagamentos,
  });

  factory ParcelamentoDetalhado.fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonString as Map<String, dynamic>;

      return ParcelamentoDetalhado(
        numero: int.tryParse(json['numero']?.toString() ?? '0') ?? 0,
        dataDoPedido:
            int.tryParse(json['dataDoPedido']?.toString() ?? '0') ?? 0,
        situacao: json['situacao']?.toString() ?? '',
        dataDaSituacao:
            int.tryParse(json['dataDaSituacao']?.toString() ?? '0') ?? 0,
        consolidacaoOriginal: json['consolidacaoOriginal'] != null
            ? ConsolidacaoOriginal.fromJson(
                json['consolidacaoOriginal'] as Map<String, dynamic>,
              )
            : null,
        alteracoesDivida:
            (json['alteracoesDivida'] as List?)
                ?.map(
                  (e) => AlteracaoDivida.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        demonstrativoPagamentos:
            (json['demonstrativoPagamentos'] as List?)
                ?.map(
                  (e) => DemonstrativoPagamento.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
      );
    } catch (e) {
      return ParcelamentoDetalhado(
        numero: 0,
        dataDoPedido: 0,
        situacao: '',
        dataDaSituacao: 0,
        alteracoesDivida: [],
        demonstrativoPagamentos: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'dataDoPedido': dataDoPedido,
      'situacao': situacao,
      'dataDaSituacao': dataDaSituacao,
      'consolidacaoOriginal': consolidacaoOriginal?.toJson(),
      'alteracoesDivida': alteracoesDivida.map((e) => e.toJson()).toList(),
      'demonstrativoPagamentos': demonstrativoPagamentos
          .map((e) => e.toJson())
          .toList(),
    };
  }

  /// Formata a data do pedido (AAAAMMDD)
  String get dataDoPedidoFormatada {
    final dataStr = dataDoPedido.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata a data da situação (AAAAMMDD)
  String get dataDaSituacaoFormatada {
    final dataStr = dataDaSituacao.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Verifica se o parcelamento está ativo
  bool get isAtivo => situacao.toLowerCase().contains('em parcelamento');

  /// Verifica se o parcelamento está encerrado
  bool get isEncerrado => situacao.toLowerCase().contains('encerrado');

  /// Verifica se há alterações de dívida
  bool get temAlteracoesDivida => alteracoesDivida.isNotEmpty;

  /// Verifica se há pagamentos realizados
  bool get temPagamentos => demonstrativoPagamentos.isNotEmpty;
}

class ConsolidacaoOriginal {
  final double valorTotalConsolidado;
  final int quantidadeParcelas;
  final double primeiraParcela;
  final double parcelaBasica;
  final int dataConsolidacao;
  final List<DetalhesConsolidacao> detalhesConsolidacao;

  ConsolidacaoOriginal({
    required this.valorTotalConsolidado,
    required this.quantidadeParcelas,
    required this.primeiraParcela,
    required this.parcelaBasica,
    required this.dataConsolidacao,
    required this.detalhesConsolidacao,
  });

  factory ConsolidacaoOriginal.fromJson(Map<String, dynamic> json) {
    return ConsolidacaoOriginal(
      valorTotalConsolidado:
          double.tryParse(json['valorTotalConsolidado']?.toString() ?? '0') ??
          0.0,
      quantidadeParcelas:
          int.tryParse(json['quantidadeParcelas']?.toString() ?? '0') ?? 0,
      primeiraParcela:
          double.tryParse(json['primeiraParcela']?.toString() ?? '0') ?? 0.0,
      parcelaBasica:
          double.tryParse(json['parcelaBasica']?.toString() ?? '0') ?? 0.0,
      dataConsolidacao:
          int.tryParse(json['dataConsolidacao']?.toString() ?? '0') ?? 0,
      detalhesConsolidacao:
          (json['detalhesConsolidacao'] as List?)
              ?.map(
                (e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidado': valorTotalConsolidado,
      'quantidadeParcelas': quantidadeParcelas,
      'primeiraParcela': primeiraParcela,
      'parcelaBasica': parcelaBasica,
      'dataConsolidacao': dataConsolidacao,
      'detalhesConsolidacao': detalhesConsolidacao
          .map((e) => e.toJson())
          .toList(),
    };
  }

  /// Formata a data de consolidação (AAAAMMDDHHMMSS)
  String get dataConsolidacaoFormatada {
    final dataStr = dataConsolidacao.toString();
    if (dataStr.length == 14) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)} ${dataStr.substring(8, 10)}:${dataStr.substring(10, 12)}:${dataStr.substring(12, 14)}';
    }
    return dataStr;
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
      periodoApuracao:
          int.tryParse(json['periodoApuracao']?.toString() ?? '0') ?? 0,
      vencimento: int.tryParse(json['vencimento']?.toString() ?? '0') ?? 0,
      numeroProcesso: json['numeroProcesso']?.toString() ?? '',
      saldoDevedorOriginal:
          double.tryParse(json['saldoDevedorOriginal']?.toString() ?? '0') ??
          0.0,
      valorAtualizado:
          double.tryParse(json['valorAtualizado']?.toString() ?? '0') ?? 0.0,
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

  /// Formata o período de apuração (AAAAMM)
  String get periodoApuracaoFormatado {
    final periodoStr = periodoApuracao.toString();
    if (periodoStr.length == 6) {
      return '${periodoStr.substring(0, 4)}/${periodoStr.substring(4, 6)}';
    }
    return periodoStr;
  }

  /// Formata a data de vencimento (AAAAMMDD)
  String get vencimentoFormatado {
    final dataStr = vencimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }
}

class AlteracaoDivida {
  final double valorTotalConsolidado;
  final int parcelasRemanescentes;
  final double parcelaBasica;
  final int dataAlteracaoDivida;
  final List<DetalhesAlteracaoDivida> detalhesAlteracaoDivida;

  AlteracaoDivida({
    required this.valorTotalConsolidado,
    required this.parcelasRemanescentes,
    required this.parcelaBasica,
    required this.dataAlteracaoDivida,
    required this.detalhesAlteracaoDivida,
  });

  factory AlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return AlteracaoDivida(
      valorTotalConsolidado:
          double.tryParse(json['valorTotalConsolidado']?.toString() ?? '0') ??
          0.0,
      parcelasRemanescentes:
          int.tryParse(json['parcelasRemanescentes']?.toString() ?? '0') ?? 0,
      parcelaBasica:
          double.tryParse(json['parcelaBasica']?.toString() ?? '0') ?? 0.0,
      dataAlteracaoDivida:
          int.tryParse(json['dataAlteracaoDivida']?.toString() ?? '0') ?? 0,
      detalhesAlteracaoDivida:
          (json['detalhesAlteracaoDivida'] as List?)
              ?.map(
                (e) =>
                    DetalhesAlteracaoDivida.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidado': valorTotalConsolidado,
      'parcelasRemanescentes': parcelasRemanescentes,
      'parcelaBasica': parcelaBasica,
      'dataAlteracaoDivida': dataAlteracaoDivida,
      'detalhesAlteracaoDivida': detalhesAlteracaoDivida
          .map((e) => e.toJson())
          .toList(),
    };
  }

  /// Formata a data de alteração de dívida (AAAAMMDD)
  String get dataAlteracaoDividaFormatada {
    final dataStr = dataAlteracaoDivida.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }
}

class DetalhesAlteracaoDivida {
  final int periodoApuracao;
  final int vencimento;
  final String numeroProcesso;
  final double saldoDevedorOriginal;
  final double valorAtualizado;

  DetalhesAlteracaoDivida({
    required this.periodoApuracao,
    required this.vencimento,
    required this.numeroProcesso,
    required this.saldoDevedorOriginal,
    required this.valorAtualizado,
  });

  factory DetalhesAlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return DetalhesAlteracaoDivida(
      periodoApuracao:
          int.tryParse(json['periodoApuracao']?.toString() ?? '0') ?? 0,
      vencimento: int.tryParse(json['vencimento']?.toString() ?? '0') ?? 0,
      numeroProcesso: json['numeroProcesso']?.toString() ?? '',
      saldoDevedorOriginal:
          double.tryParse(json['saldoDevedorOriginal']?.toString() ?? '0') ??
          0.0,
      valorAtualizado:
          double.tryParse(json['valorAtualizado']?.toString() ?? '0') ?? 0.0,
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

  /// Formata o período de apuração (AAAAMM)
  String get periodoApuracaoFormatado {
    final periodoStr = periodoApuracao.toString();
    if (periodoStr.length == 6) {
      return '${periodoStr.substring(0, 4)}/${periodoStr.substring(4, 6)}';
    }
    return periodoStr;
  }

  /// Formata a data de vencimento (AAAAMMDD)
  String get vencimentoFormatado {
    final dataStr = vencimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
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
      mesDaParcela: int.tryParse(json['mesDaParcela']?.toString() ?? '0') ?? 0,
      vencimentoDoDas:
          int.tryParse(json['vencimentoDoDas']?.toString() ?? '0') ?? 0,
      dataDeArrecadacao:
          int.tryParse(json['dataDeArrecadacao']?.toString() ?? '0') ?? 0,
      valorPago: double.tryParse(json['valorPago']?.toString() ?? '0') ?? 0.0,
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

  /// Formata o mês da parcela (AAAAMM)
  String get mesDaParcelaFormatado {
    final mesStr = mesDaParcela.toString();
    if (mesStr.length == 6) {
      return '${mesStr.substring(0, 4)}/${mesStr.substring(4, 6)}';
    }
    return mesStr;
  }

  /// Formata a data de vencimento do DAS (AAAAMMDD)
  String get vencimentoDoDasFormatado {
    final dataStr = vencimentoDoDas.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata a data de arrecadação (AAAAMMDD)
  String get dataDeArrecadacaoFormatada {
    final dataStr = dataDeArrecadacao.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata o valor pago
  String get valorPagoFormatado {
    return 'R\$ ${valorPago.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
