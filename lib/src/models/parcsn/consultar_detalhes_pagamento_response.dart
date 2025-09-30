import 'dart:convert';
import 'mensagem.dart';
import '../../util/formatter_utils.dart';

class ConsultarDetalhesPagamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarDetalhesPagamentoResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarDetalhesPagamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDetalhesPagamentoResponse(
      status: json['status'].toString(),
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados};
  }

  /// Dados parseados do JSON string
  DetalhesPagamentoData? get dadosParsed {
    try {
      final dadosJson = dados;
      final parsed = DetalhesPagamentoData.fromJson(dadosJson);
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

  /// Verifica se há dados de pagamento disponíveis
  bool get temDadosPagamento => dadosParsed != null;

  @override
  String toString() {
    return 'ConsultarDetalhesPagamentoResponse(status: $status, mensagens: ${mensagens.length}, temDados: $temDadosPagamento)';
  }
}

class DetalhesPagamentoData {
  final String numeroDas;
  final String codigoBarras;
  final double valorPagoArrecadacao;
  final String dataPagamento;
  final List<PagamentoDebito> pagamentosDebitos;

  DetalhesPagamentoData({
    required this.numeroDas,
    required this.codigoBarras,
    required this.valorPagoArrecadacao,
    required this.dataPagamento,
    required this.pagamentosDebitos,
  });

  factory DetalhesPagamentoData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return DetalhesPagamentoData(
      numeroDas: json['numeroDas'].toString(),
      codigoBarras: json['codigoBarras'].toString(),
      valorPagoArrecadacao: (num.parse(json['valorPagoArrecadacao'].toString())).toDouble(),
      dataPagamento: json['dataPagamento'].toString(),
      pagamentosDebitos: (json['pagamentosDebitos'] as List?)?.map((e) => PagamentoDebito.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'codigoBarras': codigoBarras,
      'valorPagoArrecadacao': valorPagoArrecadacao,
      'dataPagamento': dataPagamento,
      'pagamentosDebitos': pagamentosDebitos.map((e) => e.toJson()).toList(),
    };
  }

  /// Valor pago formatado como moeda brasileira
  String get valorPagoArrecadacaoFormatado {
    return FormatterUtils.formatCurrency(valorPagoArrecadacao);
  }

  /// Data de pagamento formatada (DD/MM/AAAA)
  String get dataPagamentoFormatada {
    if (dataPagamento.length == 8) {
      return FormatterUtils.formatDateFromString(dataPagamento);
    }
    return dataPagamento;
  }

  /// Verifica se há pagamentos de débitos
  bool get temPagamentosDebitos => pagamentosDebitos.isNotEmpty;

  /// Quantidade de débitos pagos
  int get quantidadeDebitosPagos => pagamentosDebitos.length;

  @override
  String toString() {
    return 'DetalhesPagamentoData(numeroDas: $numeroDas, valorPago: $valorPagoArrecadacaoFormatado, debitos: $quantidadeDebitosPagos)';
  }
}

class PagamentoDebito {
  final String competencia;
  final String tipoDebito;
  final double valorPrincipal;
  final double valorMulta;
  final double valorJuros;
  final double valorTotal;
  final List<DiscriminacaoDebito> discriminacoes;

  PagamentoDebito({
    required this.competencia,
    required this.tipoDebito,
    required this.valorPrincipal,
    required this.valorMulta,
    required this.valorJuros,
    required this.valorTotal,
    required this.discriminacoes,
  });

  factory PagamentoDebito.fromJson(Map<String, dynamic> json) {
    return PagamentoDebito(
      competencia: json['competencia'].toString(),
      tipoDebito: json['tipoDebito'].toString(),
      valorPrincipal: (num.parse(json['valorPrincipal'].toString())).toDouble(),
      valorMulta: (num.parse(json['valorMulta'].toString())).toDouble(),
      valorJuros: (num.parse(json['valorJuros'].toString())).toDouble(),
      valorTotal: (num.parse(json['valorTotal'].toString())).toDouble(),
      discriminacoes: (json['discriminacoes'] as List?)?.map((e) => DiscriminacaoDebito.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competencia': competencia,
      'tipoDebito': tipoDebito,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorTotal': valorTotal,
      'discriminacoes': discriminacoes.map((e) => e.toJson()).toList(),
    };
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalFormatado {
    return FormatterUtils.formatCurrency(valorTotal);
  }

  /// Valor principal formatado como moeda brasileira
  String get valorPrincipalFormatado {
    return FormatterUtils.formatCurrency(valorPrincipal);
  }

  /// Valor da multa formatado como moeda brasileira
  String get valorMultaFormatado {
    return FormatterUtils.formatCurrency(valorMulta);
  }

  /// Valor dos juros formatado como moeda brasileira
  String get valorJurosFormatado {
    return FormatterUtils.formatCurrency(valorJuros);
  }

  /// Verifica se há discriminações
  bool get temDiscriminacoes => discriminacoes.isNotEmpty;

  @override
  String toString() {
    return 'PagamentoDebito(competencia: $competencia, tipo: $tipoDebito, valor: $valorTotalFormatado)';
  }
}

class DiscriminacaoDebito {
  final String codigo;
  final String descricao;
  final double valor;

  DiscriminacaoDebito({required this.codigo, required this.descricao, required this.valor});

  factory DiscriminacaoDebito.fromJson(Map<String, dynamic> json) {
    return DiscriminacaoDebito(
      codigo: json['codigo'].toString(),
      descricao: json['descricao'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'descricao': descricao, 'valor': valor};
  }

  /// Valor formatado como moeda brasileira
  String get valorFormatado {
    return FormatterUtils.formatCurrency(valor);
  }

  @override
  String toString() {
    return 'DiscriminacaoDebito(codigo: $codigo, descricao: $descricao, valor: $valorFormatado)';
  }
}
