import 'dart:convert';
import 'mensagem.dart';
import '../../../util/formatador_utils.dart';

class ConsultarParcelamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final ParcelamentoDetalhado? dados;

  ConsultarParcelamentoResponse({
    required this.status,
    required this.mensagens,
    this.dados,
  });

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

  /// Verifica se há dados de parcelamento disponíveis
  bool get temDadosParcelamento => dados != null;

  @override
  String toString() {
    return 'ConsultarParcelamentoResponse(status: $status, mensagens: ${mensagens.length}, temDados: $temDadosParcelamento)';
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
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return ParcelamentoDetalhado(
      numero: int.parse(json['numero'].toString()),
      dataDoPedido: int.parse(json['dataDoPedido'].toString()),
      situacao: json['situacao'].toString(),
      dataDaSituacao: int.parse(json['dataDaSituacao'].toString()),
      consolidacaoOriginal: json['consolidacaoOriginal'] != null
          ? ConsolidacaoOriginal.fromJson(
              json['consolidacaoOriginal'] as Map<String, dynamic>,
            )
          : null,
      alteracoesDivida:
          (json['alteracoesDivida'] as List?)
              ?.map((e) => AlteracaoDivida.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      demonstrativoPagamentos:
          (json['demonstrativoPagamentos'] as List?)
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
      'alteracoesDivida': alteracoesDivida.map((e) => e.toJson()).toList(),
      'demonstrativoPagamentos': demonstrativoPagamentos
          .map((e) => e.toJson())
          .toList(),
    };
  }

  /// Data do pedido formatada (DD/MM/AAAA)
  String get dataDoPedidoFormatada {
    final data = dataDoPedido.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Data da situação formatada (DD/MM/AAAA)
  String get dataDaSituacaoFormatada {
    final data = dataDaSituacao.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Verifica se o parcelamento está ativo
  bool get isAtivo => !situacao.toLowerCase().contains('encerrado');

  /// Verifica se o parcelamento está encerrado
  bool get isEncerrado => situacao.toLowerCase().contains('encerrado');

  @override
  String toString() {
    return 'ParcelamentoDetalhado(numero: $numero, situacao: $situacao, consolidacao: ${consolidacaoOriginal != null})';
  }
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
      valorTotalConsolidado: (num.parse(
        json['valorTotalConsolidado'].toString(),
      )).toDouble(),
      quantidadeParcelas: int.parse(json['quantidadeParcelas'].toString()),
      primeiraParcela: (num.parse(
        json['primeiraParcela'].toString(),
      )).toDouble(),
      parcelaBasica: (num.parse(json['parcelaBasica'].toString())).toDouble(),
      dataConsolidacao: int.parse(json['dataConsolidacao'].toString()),
      detalhesConsolidacao: (json['detalhesConsolidacao'] as List)
          .map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>))
          .toList(),
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

  /// Valor total consolidado formatado como moeda brasileira
  String get valorTotalConsolidadoFormatado {
    return FormatadorUtils.formatCurrency(valorTotalConsolidado);
  }

  /// Primeira parcela formatada como moeda brasileira
  String get primeiraParcelaFormatada {
    return FormatadorUtils.formatCurrency(primeiraParcela);
  }

  /// Parcela básica formatada como moeda brasileira
  String get parcelaBasicaFormatada {
    return FormatadorUtils.formatCurrency(parcelaBasica);
  }

  /// Data da consolidação formatada (DD/MM/AAAA HH:MM:SS)
  String get dataConsolidacaoFormatada {
    final data = dataConsolidacao.toString();
    if (data.length == 14) {
      final ano = data.substring(0, 4);
      final mes = data.substring(4, 6);
      final dia = data.substring(6, 8);
      final hora = data.substring(8, 10);
      final minuto = data.substring(10, 12);
      final segundo = data.substring(12, 14);
      return '$dia/$mes/$ano $hora:$minuto:$segundo';
    }
    return data;
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

  /// Período de apuração formatado (MM/AAAA)
  String get periodoApuracaoFormatado {
    final periodo = periodoApuracao.toString();
    if (periodo.length == 6) {
      return '${periodo.substring(4, 6)}/${periodo.substring(0, 4)}';
    }
    return periodo;
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String get vencimentoFormatado {
    final data = vencimento.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Saldo devedor original formatado como moeda brasileira
  String get saldoDevedorOriginalFormatado {
    return FormatadorUtils.formatCurrency(saldoDevedorOriginal);
  }

  /// Valor atualizado formatado como moeda brasileira
  String get valorAtualizadoFormatado {
    return FormatadorUtils.formatCurrency(valorAtualizado);
  }
}

/// Representa uma alteração de dívida no parcelamento PARCSN Especial.
///
/// Contém informações sobre valores consolidados, parcelas remanescentes
/// e detalhes da consolidação.
class AlteracaoDivida {
  final double valorTotalConsolidado;
  final int parcelasRemanescentes;
  final double parcelaBasica;
  final int dataAlteracaoDivida;
  final List<DetalhesConsolidacao> detalhesConsolidacao;

  AlteracaoDivida({
    required this.valorTotalConsolidado,
    required this.parcelasRemanescentes,
    required this.parcelaBasica,
    required this.dataAlteracaoDivida,
    required this.detalhesConsolidacao,
  });

  /// Cria uma instância de [AlteracaoDivida] a partir de um mapa JSON.
  factory AlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return AlteracaoDivida(
      valorTotalConsolidado: (num.parse(
        json['valorTotalConsolidado'].toString(),
      )).toDouble(),
      parcelasRemanescentes: int.parse(
        json['parcelasRemanescentes'].toString(),
      ),
      parcelaBasica: (num.parse(json['parcelaBasica'].toString())).toDouble(),
      dataAlteracaoDivida: int.parse(json['dataAlteracaoDivida'].toString()),
      detalhesConsolidacao: (json['detalhesConsolidacao'] as List)
          .map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidado': valorTotalConsolidado,
      'parcelasRemanescentes': parcelasRemanescentes,
      'parcelaBasica': parcelaBasica,
      'dataAlteracaoDivida': dataAlteracaoDivida,
      'detalhesConsolidacao': detalhesConsolidacao
          .map((e) => e.toJson())
          .toList(),
    };
  }

  /// Valor total consolidado formatado como moeda brasileira
  String get valorTotalConsolidadoFormatado {
    return FormatadorUtils.formatCurrency(valorTotalConsolidado);
  }

  /// Parcela básica formatada como moeda brasileira
  String get parcelaBasicaFormatada {
    return FormatadorUtils.formatCurrency(parcelaBasica);
  }

  /// Data da alteração de dívida formatada (DD/MM/AAAA)
  String get dataAlteracaoDividaFormatada {
    final data = dataAlteracaoDivida.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
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

  /// Mês da parcela formatado (MM/AAAA)
  String get mesDaParcelaFormatado {
    final mes = mesDaParcela.toString();
    if (mes.length == 6) {
      return '${mes.substring(4, 6)}/${mes.substring(0, 4)}';
    }
    return mes;
  }

  /// Data de vencimento do DAS formatada (DD/MM/AAAA)
  String get vencimentoDoDasFormatado {
    final data = vencimentoDoDas.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Data de arrecadação formatada (DD/MM/AAAA)
  String get dataDeArrecadacaoFormatada {
    final data = dataDeArrecadacao.toString();
    if (data.length == 8) {
      return FormatadorUtils.formatDateFromString(data);
    }
    return data;
  }

  /// Valor pago formatado como moeda brasileira
  String get valorPagoFormatado {
    return FormatadorUtils.formatCurrency(valorPago);
  }
}
