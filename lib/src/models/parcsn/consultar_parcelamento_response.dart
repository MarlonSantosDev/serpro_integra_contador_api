import 'dart:convert';
import 'mensagem.dart';

class ConsultarParcelamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarParcelamentoResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarParcelamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarParcelamentoResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Dados parseados do JSON string
  ParcelamentoDetalhado? get dadosParsed {
    try {
      final dadosJson = dados;
      final parsed = ParcelamentoDetalhado.fromJson(dadosJson);
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

  /// Verifica se há dados de parcelamento disponíveis
  bool get temDadosParcelamento => dadosParsed != null;

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
  final List<ConsolidacaoOriginal> consolidacoesOriginais;
  final List<AlteracaoDivida> alteracoesDivida;
  final List<DemonstrativoPagamento> demonstrativosPagamento;

  ParcelamentoDetalhado({
    required this.numero,
    required this.dataDoPedido,
    required this.situacao,
    required this.dataDaSituacao,
    required this.consolidacoesOriginais,
    required this.alteracoesDivida,
    required this.demonstrativosPagamento,
  });

  factory ParcelamentoDetalhado.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ParcelamentoDetalhado(
      numero: json['numero'] as int,
      dataDoPedido: json['dataDoPedido'] as int,
      situacao: json['situacao'] as String,
      dataDaSituacao: json['dataDaSituacao'] as int,
      consolidacoesOriginais:
          (json['consolidacoesOriginais'] as List?)?.map((e) => ConsolidacaoOriginal.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      alteracoesDivida: (json['alteracoesDivida'] as List?)?.map((e) => AlteracaoDivida.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      demonstrativosPagamento:
          (json['demonstrativosPagamento'] as List?)?.map((e) => DemonstrativoPagamento.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'dataDoPedido': dataDoPedido,
      'situacao': situacao,
      'dataDaSituacao': dataDaSituacao,
      'consolidacoesOriginais': consolidacoesOriginais.map((e) => e.toJson()).toList(),
      'alteracoesDivida': alteracoesDivida.map((e) => e.toJson()).toList(),
      'demonstrativosPagamento': demonstrativosPagamento.map((e) => e.toJson()).toList(),
    };
  }

  /// Data do pedido formatada (DD/MM/AAAA)
  String get dataDoPedidoFormatada {
    final data = dataDoPedido.toString();
    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
    }
    return data;
  }

  /// Data da situação formatada (DD/MM/AAAA)
  String get dataDaSituacaoFormatada {
    final data = dataDaSituacao.toString();
    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
    }
    return data;
  }

  /// Verifica se o parcelamento está ativo
  bool get isAtivo => !situacao.toLowerCase().contains('encerrado');

  /// Verifica se o parcelamento está encerrado
  bool get isEncerrado => situacao.toLowerCase().contains('encerrado');

  @override
  String toString() {
    return 'ParcelamentoDetalhado(numero: $numero, situacao: $situacao, consolidacoes: ${consolidacoesOriginais.length})';
  }
}

class ConsolidacaoOriginal {
  final int numero;
  final String tipo;
  final List<DetalhesConsolidacao> detalhes;

  ConsolidacaoOriginal({required this.numero, required this.tipo, required this.detalhes});

  factory ConsolidacaoOriginal.fromJson(Map<String, dynamic> json) {
    return ConsolidacaoOriginal(
      numero: json['numero'] as int,
      tipo: json['tipo'] as String,
      detalhes: (json['detalhes'] as List).map((e) => DetalhesConsolidacao.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo, 'detalhes': detalhes.map((e) => e.toJson()).toList()};
  }
}

class DetalhesConsolidacao {
  final String competencia;
  final double valorPrincipal;
  final double valorMulta;
  final double valorJuros;
  final double valorTotal;

  DetalhesConsolidacao({
    required this.competencia,
    required this.valorPrincipal,
    required this.valorMulta,
    required this.valorJuros,
    required this.valorTotal,
  });

  factory DetalhesConsolidacao.fromJson(Map<String, dynamic> json) {
    return DetalhesConsolidacao(
      competencia: json['competencia'] as String,
      valorPrincipal: (json['valorPrincipal'] as num).toDouble(),
      valorMulta: (json['valorMulta'] as num).toDouble(),
      valorJuros: (json['valorJuros'] as num).toDouble(),
      valorTotal: (json['valorTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competencia': competencia,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorTotal': valorTotal,
    };
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }
}

class AlteracaoDivida {
  final int numero;
  final String tipo;
  final List<DetalhesAlteracaoDivida> detalhes;

  AlteracaoDivida({required this.numero, required this.tipo, required this.detalhes});

  factory AlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return AlteracaoDivida(
      numero: json['numero'] as int,
      tipo: json['tipo'] as String,
      detalhes: (json['detalhes'] as List).map((e) => DetalhesAlteracaoDivida.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo, 'detalhes': detalhes.map((e) => e.toJson()).toList()};
  }
}

class DetalhesAlteracaoDivida {
  final String competencia;
  final double valorPrincipal;
  final double valorMulta;
  final double valorJuros;
  final double valorTotal;

  DetalhesAlteracaoDivida({
    required this.competencia,
    required this.valorPrincipal,
    required this.valorMulta,
    required this.valorJuros,
    required this.valorTotal,
  });

  factory DetalhesAlteracaoDivida.fromJson(Map<String, dynamic> json) {
    return DetalhesAlteracaoDivida(
      competencia: json['competencia'] as String,
      valorPrincipal: (json['valorPrincipal'] as num).toDouble(),
      valorMulta: (json['valorMulta'] as num).toDouble(),
      valorJuros: (json['valorJuros'] as num).toDouble(),
      valorTotal: (json['valorTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competencia': competencia,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorTotal': valorTotal,
    };
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }
}

class DemonstrativoPagamento {
  final int numero;
  final String tipo;
  final List<DetalhesDemonstrativoPagamento> detalhes;

  DemonstrativoPagamento({required this.numero, required this.tipo, required this.detalhes});

  factory DemonstrativoPagamento.fromJson(Map<String, dynamic> json) {
    return DemonstrativoPagamento(
      numero: json['numero'] as int,
      tipo: json['tipo'] as String,
      detalhes: (json['detalhes'] as List).map((e) => DetalhesDemonstrativoPagamento.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'numero': numero, 'tipo': tipo, 'detalhes': detalhes.map((e) => e.toJson()).toList()};
  }
}

class DetalhesDemonstrativoPagamento {
  final String competencia;
  final double valorPrincipal;
  final double valorMulta;
  final double valorJuros;
  final double valorTotal;

  DetalhesDemonstrativoPagamento({
    required this.competencia,
    required this.valorPrincipal,
    required this.valorMulta,
    required this.valorJuros,
    required this.valorTotal,
  });

  factory DetalhesDemonstrativoPagamento.fromJson(Map<String, dynamic> json) {
    return DetalhesDemonstrativoPagamento(
      competencia: json['competencia'] as String,
      valorPrincipal: (json['valorPrincipal'] as num).toDouble(),
      valorMulta: (json['valorMulta'] as num).toDouble(),
      valorJuros: (json['valorJuros'] as num).toDouble(),
      valorTotal: (json['valorTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competencia': competencia,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorTotal': valorTotal,
    };
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }
}
