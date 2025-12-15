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
        final dadosJson = jsonDecode(dadosStr) as Map<String, dynamic>;
        dadosParsed = ParcelamentoDetalhado.fromJson(dadosJson);
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
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados != null ? jsonEncode(dados!.toJson()) : ''};
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

  factory ParcelamentoDetalhado.fromJson(Map<String, dynamic> json) {
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

  /// Valor total consolidado formatado
  String get valorTotalConsolidadoFormatado {
    return consolidacaoOriginal?.valorTotalConsolidadoFormatado ?? '0,00';
  }

  /// Quantidade de parcelas
  int get quantidadeParcelas {
    return consolidacaoOriginal?.quantidadeParcelas ?? 0;
  }

  /// Valor da parcela básica formatado
  String get parcelaBasicaFormatada {
    return consolidacaoOriginal?.parcelaBasicaFormatada ?? '0,00';
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
      valorTotalConsolidado: double.parse(json['valorTotalConsolidado'].toString()),
      quantidadeParcelas: int.parse(json['quantidadeParcelas'].toString()),
      primeiraParcela: double.parse(json['primeiraParcela'].toString()),
      parcelaBasica: double.parse(json['parcelaBasica'].toString()),
      dataConsolidacao: int.parse(json['dataConsolidacao'].toString()),
      detalhesConsolidacao: (json['detalhesConsolidacao'] as List).map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidado': valorTotalConsolidado,
      'quantidadeParcelas': quantidadeParcelas,
      'primeiraParcela': primeiraParcela,
      'parcelaBasica': parcelaBasica,
      'dataConsolidacao': dataConsolidacao,
      'detalhesConsolidacao': detalhesConsolidacao.map((e) => e.toJson()).toList(),
    };
  }

  /// Valor total consolidado formatado
  String get valorTotalConsolidadoFormatado {
    return 'R\$ ${valorTotalConsolidado.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Primeira parcela formatada
  String get primeiraParcelaFormatada {
    return 'R\$ ${primeiraParcela.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Parcela básica formatada
  String get parcelaBasicaFormatada {
    return 'R\$ ${parcelaBasica.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Data de consolidação formatada (AAAAMMDDHHMMSS)
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
      numeroProcesso: json['numeroProcesso']?.toString() ?? '',
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

  /// Período de apuração formatado (AAAAMM)
  String get periodoApuracaoFormatado {
    final periodoStr = periodoApuracao.toString();
    if (periodoStr.length == 6) {
      return '${periodoStr.substring(0, 4)}/${periodoStr.substring(4, 6)}';
    }
    return periodoStr;
  }

  /// Data de vencimento formatada (AAAAMMDD)
  String get vencimentoFormatado {
    final dataStr = vencimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Saldo devedor original formatado
  String get saldoDevedorOriginalFormatado {
    return 'R\$ ${saldoDevedorOriginal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Valor atualizado formatado
  String get valorAtualizadoFormatado {
    return 'R\$ ${valorAtualizado.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

/// Representa uma alteração de dívida no parcelamento PARCMEI Especial.
///
/// Contém informações sobre valores consolidados, parcelas remanescentes
/// e detalhes da alteração da dívida.
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

  /// Cria uma instância de [AlteracaoDivida] a partir de um mapa JSON.
  factory AlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return AlteracaoDivida(
      valorTotalConsolidado: double.parse(json['valorTotalConsolidado'].toString()),
      parcelasRemanescentes: int.parse(json['parcelasRemanescentes'].toString()),
      parcelaBasica: double.parse(json['parcelaBasica'].toString()),
      dataAlteracaoDivida: int.parse(json['dataAlteracaoDivida'].toString()),
      detalhesAlteracaoDivida: (json['detalhesAlteracaoDivida'] as List)
          .map((e) => DetalhesAlteracaoDivida.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valorTotalConsolidado': valorTotalConsolidado,
      'parcelasRemanescentes': parcelasRemanescentes,
      'parcelaBasica': parcelaBasica,
      'dataAlteracaoDivida': dataAlteracaoDivida,
      'detalhesAlteracaoDivida': detalhesAlteracaoDivida.map((e) => e.toJson()).toList(),
    };
  }

  /// Valor total consolidado formatado
  String get valorTotalConsolidadoFormatado {
    return 'R\$ ${valorTotalConsolidado.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Parcela básica formatada
  String get parcelaBasicaFormatada {
    return 'R\$ ${parcelaBasica.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Data de alteração formatada (AAAAMMDD)
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
      periodoApuracao: int.parse(json['periodoApuracao'].toString()),
      vencimento: int.parse(json['vencimento'].toString()),
      numeroProcesso: json['numeroProcesso']?.toString() ?? '',
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

  /// Período de apuração formatado (AAAAMM)
  String get periodoApuracaoFormatado {
    final periodoStr = periodoApuracao.toString();
    if (periodoStr.length == 6) {
      return '${periodoStr.substring(0, 4)}/${periodoStr.substring(4, 6)}';
    }
    return periodoStr;
  }

  /// Data de vencimento formatada (AAAAMMDD)
  String get vencimentoFormatado {
    final dataStr = vencimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Saldo devedor original formatado
  String get saldoDevedorOriginalFormatado {
    return 'R\$ ${saldoDevedorOriginal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Valor atualizado formatado
  String get valorAtualizadoFormatado {
    return 'R\$ ${valorAtualizado.toStringAsFixed(2).replaceAll('.', ',')}';
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

  /// Mês da parcela formatado (AAAAMM)
  String get mesDaParcelaFormatado {
    final mesStr = mesDaParcela.toString();
    if (mesStr.length == 6) {
      return '${mesStr.substring(0, 4)}/${mesStr.substring(4, 6)}';
    }
    return mesStr;
  }

  /// Data de vencimento do DAS formatada (AAAAMMDD)
  String get vencimentoDoDasFormatado {
    final dataStr = vencimentoDoDas.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Data de arrecadação formatada (AAAAMMDD)
  String get dataDeArrecadacaoFormatada {
    final dataStr = dataDeArrecadacao.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Valor pago formatado
  String get valorPagoFormatado {
    return 'R\$ ${valorPago.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
