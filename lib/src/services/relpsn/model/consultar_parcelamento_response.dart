import 'dart:convert';
import 'mensagem.dart';

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
          .map((e) => Mensagem.fromJson(e))
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
    final json = jsonDecode(jsonString);
    return ParcelamentoDetalhado(
      numero: int.parse(json['numero'].toString()),
      dataDoPedido: int.parse(json['dataDoPedido'].toString()),
      situacao: json['situacao'].toString(),
      dataDaSituacao: int.parse(json['dataDaSituacao'].toString()),
      consolidacaoOriginal: json['consolidacaoOriginal'] != null
          ? ConsolidacaoOriginal.fromJson(json['consolidacaoOriginal'])
          : null,
      alteracoesDivida: (json['alteracoesDivida'] as List)
          .map((e) => AlteracaoDivida.fromJson(e))
          .toList(),
      demonstrativoPagamentos: (json['demonstrativoPagamentos'] as List)
          .map((e) => DemonstrativoPagamento.fromJson(e))
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
}

class ConsolidacaoOriginal {
  final double valorTotalConsolidadoDeEntrada;
  final int dataConsolidacao;
  final double parcelaDeEntrada;
  final int quantidadeParcelasDeEntrada;
  final double valorConsolidadoDivida;
  final List<DetalhesConsolidacao> detalhesConsolidacao;

  ConsolidacaoOriginal({
    required this.valorTotalConsolidadoDeEntrada,
    required this.dataConsolidacao,
    required this.parcelaDeEntrada,
    required this.quantidadeParcelasDeEntrada,
    required this.valorConsolidadoDivida,
    required this.detalhesConsolidacao,
  });

  factory ConsolidacaoOriginal.fromJson(Map<String, dynamic> json) {
    return ConsolidacaoOriginal(
      valorTotalConsolidadoDeEntrada: (double.parse(
        json['valorTotalConsolidadoDeEntrada'].toString(),
      )),
      dataConsolidacao: int.parse(json['dataConsolidacao'].toString()),
      parcelaDeEntrada: (double.parse(json['parcelaDeEntrada'].toString())),
      quantidadeParcelasDeEntrada: int.parse(
        json['quantidadeParcelasDeEntrada'].toString(),
      ),
      valorConsolidadoDivida: (double.parse(
        json['valorConsolidadoDivida'].toString(),
      )),
      detalhesConsolidacao: (json['detalhesConsolidacao'] as List)
          .map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidadoDeEntrada': valorTotalConsolidadoDeEntrada,
      'dataConsolidacao': dataConsolidacao,
      'parcelaDeEntrada': parcelaDeEntrada,
      'quantidadeParcelasDeEntrada': quantidadeParcelasDeEntrada,
      'valorConsolidadoDivida': valorConsolidadoDivida,
      'detalhesConsolidacao': detalhesConsolidacao
          .map((e) => e.toJson())
          .toList(),
    };
  }

  /// Formata a data da consolidação (AAAAMMDDHHMMSS)
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

/// Representa uma alteração de dívida no parcelamento RELPSN.
///
/// Contém informações sobre consolidação de débitos, valores remanescentes
/// e parcelas relacionadas à alteração.
class AlteracaoDivida {
  final int dataAlteracaoDivida;
  final String identificadorConsolidacao;
  final double saldoDevedorOriginalSemReducoes;
  final double valorRemanescenteComReducoes;
  final double partePrevidenciaria;
  final double demaisDebitos;
  final List<DetalhesConsolidacao> detalhesConsolidacao;
  final List<ParcelaAlteracao> parcelasAlteracao;

  AlteracaoDivida({
    required this.dataAlteracaoDivida,
    required this.identificadorConsolidacao,
    required this.saldoDevedorOriginalSemReducoes,
    required this.valorRemanescenteComReducoes,
    required this.partePrevidenciaria,
    required this.demaisDebitos,
    required this.detalhesConsolidacao,
    required this.parcelasAlteracao,
  });

  /// Cria uma instância de [AlteracaoDivida] a partir de um mapa JSON.
  ///
  /// Converte automaticamente o identificador de consolidação numérico
  /// para sua descrição textual correspondente.
  factory AlteracaoDivida.fromJson(Map<String, dynamic> json) {
    // Converter identificadorConsolidacao numérico para valor descritivo
    final identificadorStr =
        json['identificadorConsolidacao']?.toString() ?? '';
    final identificadorConsolidacao = switch (identificadorStr) {
      '1' => 'Consolidação do restante da dívida',
      '2' => 'Reconsolidação por alteração de débitos no sistema de cobrança',
      _ => 'Identificador desconhecido',
    };

    return AlteracaoDivida(
      dataAlteracaoDivida: int.parse(json['dataAlteracaoDivida'].toString()),
      identificadorConsolidacao: identificadorConsolidacao,
      saldoDevedorOriginalSemReducoes: (num.parse(
        json['saldoDevedorOriginalSemReducoes'].toString(),
      )).toDouble(),
      valorRemanescenteComReducoes: (num.parse(
        json['valorRemanescenteComReducoes'].toString(),
      )).toDouble(),
      partePrevidenciaria: (num.parse(
        json['partePrevidenciaria'].toString(),
      )).toDouble(),
      demaisDebitos: (num.parse(json['demaisDebitos'].toString())).toDouble(),
      detalhesConsolidacao: (json['detalhesConsolidacao'] as List)
          .map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>))
          .toList(),
      parcelasAlteracao: (json['parcelasAlteracao'] as List)
          .map((e) => ParcelaAlteracao.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataAlteracaoDivida': dataAlteracaoDivida,
      'identificadorConsolidacao': identificadorConsolidacao,
      'saldoDevedorOriginalSemReducoes': saldoDevedorOriginalSemReducoes,
      'valorRemanescenteComReducoes': valorRemanescenteComReducoes,
      'partePrevidenciaria': partePrevidenciaria,
      'demaisDebitos': demaisDebitos,
      'detalhesConsolidacao': detalhesConsolidacao
          .map((e) => e.toJson())
          .toList(),
      'parcelasAlteracao': parcelasAlteracao.map((e) => e.toJson()).toList(),
    };
  }

  /// Formata a data da alteração de dívida (AAAAMMDDHHMM)
  String get dataAlteracaoDividaFormatada {
    final dataStr = dataAlteracaoDivida.toString();
    if (dataStr.length == 12) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)} ${dataStr.substring(8, 10)}:${dataStr.substring(10, 12)}';
    }
    return dataStr;
  }

  /// Descrição do identificador de consolidação (mantido para compatibilidade)
  String get identificadorConsolidacaoDescricao => identificadorConsolidacao;
}

class ParcelaAlteracao {
  final String faixaParcelas;
  final int parcelaInicial;
  final int vencimentoInicial;
  final double parcelaBasica;

  ParcelaAlteracao({
    required this.faixaParcelas,
    required this.parcelaInicial,
    required this.vencimentoInicial,
    required this.parcelaBasica,
  });

  factory ParcelaAlteracao.fromJson(Map<String, dynamic> json) {
    return ParcelaAlteracao(
      faixaParcelas: json['faixaParcelas'].toString(),
      parcelaInicial: int.parse(json['parcelaInicial'].toString()),
      vencimentoInicial: int.parse(json['vencimentoInicial'].toString()),
      parcelaBasica: (num.parse(json['parcelaBasica'].toString())).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faixaParcelas': faixaParcelas,
      'parcelaInicial': parcelaInicial,
      'vencimentoInicial': vencimentoInicial,
      'parcelaBasica': parcelaBasica,
    };
  }

  /// Formata a parcela inicial (AAAAMM)
  String get parcelaInicialFormatada {
    final parcelaStr = parcelaInicial.toString();
    if (parcelaStr.length == 6) {
      return '${parcelaStr.substring(0, 4)}/${parcelaStr.substring(4, 6)}';
    }
    return parcelaStr;
  }

  /// Formata a data de vencimento inicial (AAAAMMDD)
  String get vencimentoInicialFormatado {
    final dataStr = vencimentoInicial.toString();
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
}
