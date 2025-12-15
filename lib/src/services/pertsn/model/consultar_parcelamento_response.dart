import 'dart:convert';
import 'mensagem.dart';

class ConsultarParcelamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ParcelamentoDetalhado? dados;

  ConsultarParcelamentoResponse({required this.status, required this.mensagens, this.dados});

  factory ConsultarParcelamentoResponse.fromJson(Map<String, dynamic> json) {
    ParcelamentoDetalhado? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        dadosParsed = ParcelamentoDetalhado.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return ConsultarParcelamentoResponse(
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
    final json = jsonString as Map<String, dynamic>;
    return ParcelamentoDetalhado(
      numero: int.parse(json['numero'].toString()),
      dataDoPedido: int.parse(json['dataDoPedido'].toString()),
      situacao: json['situacao'].toString(),
      dataDaSituacao: int.parse(json['dataDaSituacao'].toString()),
      consolidacaoOriginal: json['consolidacaoOriginal'] != null
          ? ConsolidacaoOriginal.fromJson(json['consolidacaoOriginal'] as Map<String, dynamic>)
          : null,
      alteracoesDivida: (json['alteracoesDivida'] as List? ?? []).map((e) => AlteracaoDivida.fromJson(e as Map<String, dynamic>)).toList(),
      demonstrativoPagamentos: (json['demonstrativoPagamentos'] as List? ?? [])
          .map((e) => DemonstrativoPagamento.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'dataDoPedido': dataDoPedido,
      'situacao': situacao,
      'dataDaSituacao': dataDaSituacao,
      'consolidacaoOriginal': consolidacaoOriginal?.toJson(),
      'alteracoesDivida': alteracoesDivida.map((e) => e.toJson()).toList(),
      'demonstrativoPagamentos': demonstrativoPagamentos.map((e) => e.toJson()).toList(),
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

  /// Valor total consolidado da dívida
  double get valorTotalConsolidado {
    return consolidacaoOriginal?.valorConsolidadoDaDivida ?? 0.0;
  }

  /// Valor total consolidado da entrada
  double get valorTotalEntrada {
    return consolidacaoOriginal?.valorTotalConsolidadoDaEntrada ?? 0.0;
  }

  /// Quantidade de parcelas de entrada
  int get quantidadeParcelasEntrada {
    return consolidacaoOriginal?.quantidadeParcelasDeEntrada ?? 0;
  }

  /// Valor da parcela de entrada
  double get valorParcelaEntrada {
    return consolidacaoOriginal?.parcelaDeEntrada ?? 0.0;
  }
}

class ConsolidacaoOriginal {
  final double valorTotalConsolidadoDaEntrada;
  final int quantidadeParcelasDeEntrada;
  final double parcelaDeEntrada;
  final int dataConsolidacao;
  final double valorConsolidadoDaDivida;
  final List<DetalhesConsolidacao> detalhesConsolidacao;

  ConsolidacaoOriginal({
    required this.valorTotalConsolidadoDaEntrada,
    required this.quantidadeParcelasDeEntrada,
    required this.parcelaDeEntrada,
    required this.dataConsolidacao,
    required this.valorConsolidadoDaDivida,
    required this.detalhesConsolidacao,
  });

  factory ConsolidacaoOriginal.fromJson(Map<String, dynamic> json) {
    return ConsolidacaoOriginal(
      valorTotalConsolidadoDaEntrada: double.parse(json['valorTotalConsolidadoDaEntrada'].toString()),
      quantidadeParcelasDeEntrada: int.parse(json['quantidadeParcelasDeEntrada'].toString()),
      parcelaDeEntrada: double.parse(json['parcelaDeEntrada'].toString()),
      dataConsolidacao: int.parse(json['dataConsolidacao'].toString()),
      valorConsolidadoDaDivida: double.parse(json['valorConsolidadoDaDivida'].toString()),
      detalhesConsolidacao: (json['detalhesConsolidacao'] as List).map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidadoDaEntrada': valorTotalConsolidadoDaEntrada,
      'quantidadeParcelasDeEntrada': quantidadeParcelasDeEntrada,
      'parcelaDeEntrada': parcelaDeEntrada,
      'dataConsolidacao': dataConsolidacao,
      'valorConsolidadoDaDivida': valorConsolidadoDaDivida,
      'detalhesConsolidacao': detalhesConsolidacao.map((e) => e.toJson()).toList(),
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
      periodoApuracao: int.parse(json['periodoApuracao'].toString()),
      vencimento: int.parse(json['vencimento'].toString()),
      numeroProcesso: json['numeroProcesso'].toString(),
      saldoDevedorOriginal: double.parse(json['saldoDevedorOriginal'].toString()),
      valorAtualizado: double.parse(json['valorAtualizado'].toString()),
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
    final vencimentoStr = vencimento.toString();
    if (vencimentoStr.length == 8) {
      return '${vencimentoStr.substring(0, 4)}-${vencimentoStr.substring(4, 6)}-${vencimentoStr.substring(6, 8)}';
    }
    return vencimentoStr;
  }
}

/// Representa uma alteração de dívida no parcelamento PERTSN.
/// 
/// Contém informações sobre valores consolidados, parcelas remanescentes
/// e detalhes da alteração da dívida.
class AlteracaoDivida {
  final double totalConsolidado;
  final int parcelasRemanescentes;
  final double parcelaBasica;
  final int dataAlteracaoDivida;
  final double valorConsolidadoPrincipal;
  final List<DetalhesAlteracaoDivida> detalhesAlteracaoDivida;

  AlteracaoDivida({
    required this.totalConsolidado,
    required this.parcelasRemanescentes,
    required this.parcelaBasica,
    required this.dataAlteracaoDivida,
    required this.valorConsolidadoPrincipal,
    required this.detalhesAlteracaoDivida,
  });

  /// Cria uma instância de [AlteracaoDivida] a partir de um mapa JSON.
  factory AlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return AlteracaoDivida(
      totalConsolidado: double.parse(json['totalConsolidado'].toString()),
      parcelasRemanescentes: int.parse(json['parcelasRemanescentes'].toString()),
      parcelaBasica: double.parse(json['parcelaBasica'].toString()),
      dataAlteracaoDivida: int.parse(json['dataAlteracaoDivida'].toString()),
      valorConsolidadoPrincipal: double.parse(json['valorConsolidadoPrincipal'].toString()),
      detalhesAlteracaoDivida: (json['detalhesAlteracaoDivida'] as List)
          .map((e) => DetalhesAlteracaoDivida.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalConsolidado': totalConsolidado,
      'parcelasRemanescentes': parcelasRemanescentes,
      'parcelaBasica': parcelaBasica,
      'dataAlteracaoDivida': dataAlteracaoDivida,
      'valorConsolidadoPrincipal': valorConsolidadoPrincipal,
      'detalhesAlteracaoDivida': detalhesAlteracaoDivida.map((e) => e.toJson()).toList(),
    };
  }

  /// Formata a data de alteração da dívida (AAAAMMDDHHMM)
  String get dataAlteracaoDividaFormatada {
    final dataStr = dataAlteracaoDivida.toString();
    if (dataStr.length == 12) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)} ${dataStr.substring(8, 10)}:${dataStr.substring(10, 12)}';
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
      periodoApuracao: int.parse(json['periodoApuracao'].toString()),
      vencimento: int.parse(json['vencimento'].toString()),
      numeroProcesso: json['numeroProcesso'].toString(),
      saldoDevedorOriginal: double.parse(json['saldoDevedorOriginal'].toString()),
      valorAtualizado: double.parse(json['valorAtualizado'].toString()),
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
    final vencimentoStr = vencimento.toString();
    if (vencimentoStr.length == 8) {
      return '${vencimentoStr.substring(0, 4)}-${vencimentoStr.substring(4, 6)}-${vencimentoStr.substring(6, 8)}';
    }
    return vencimentoStr;
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
      mesDaParcela: int.parse(json['mesDaParcela'].toString()),
      vencimentoDoDas: int.parse(json['vencimentoDoDas'].toString()),
      dataDeArrecadacao: int.parse(json['dataDeArrecadacao'].toString()),
      valorPago: double.parse(json['valorPago'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'mesDaParcela': mesDaParcela, 'vencimentoDoDas': vencimentoDoDas, 'dataDeArrecadacao': dataDeArrecadacao, 'valorPago': valorPago};
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
    final vencimentoStr = vencimentoDoDas.toString();
    if (vencimentoStr.length == 8) {
      return '${vencimentoStr.substring(0, 4)}-${vencimentoStr.substring(4, 6)}-${vencimentoStr.substring(6, 8)}';
    }
    return vencimentoStr;
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

