import 'dart:convert';
import 'mensagem.dart';

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
  final int dataVencimento;
  final int paDasGerado;
  final String geradoEm;
  final String numeroParcelamento;
  final String numeroParcela;
  final int dataLimiteAcolhimento;
  final List<PagamentoDebito> pagamentoDebitos;
  final int dataPagamento;
  final String bancoAgencia;
  final double valorPagoArrecadacao;

  DetalhesPagamentoData({
    required this.numeroDas,
    required this.dataVencimento,
    required this.paDasGerado,
    required this.geradoEm,
    required this.numeroParcelamento,
    required this.numeroParcela,
    required this.dataLimiteAcolhimento,
    required this.pagamentoDebitos,
    required this.dataPagamento,
    required this.bancoAgencia,
    required this.valorPagoArrecadacao,
  });

  factory DetalhesPagamentoData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return DetalhesPagamentoData(
      numeroDas: json['numeroDas'] as String,
      dataVencimento: json['dataVencimento'] as int,
      paDasGerado: json['paDasGerado'] as int,
      geradoEm: json['geradoEm'] as String,
      numeroParcelamento: json['numeroParcelamento'] as String,
      numeroParcela: json['numeroParcela'] as String,
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'] as int,
      pagamentoDebitos: (json['pagamentoDebitos'] as List).map((e) => PagamentoDebito.fromJson(e as Map<String, dynamic>)).toList(),
      dataPagamento: json['dataPagamento'] as int,
      bancoAgencia: json['bancoAgencia'] as String,
      valorPagoArrecadacao: (json['valorPagoArrecadacao'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'dataVencimento': dataVencimento,
      'paDasGerado': paDasGerado,
      'geradoEm': geradoEm,
      'numeroParcelamento': numeroParcelamento,
      'numeroParcela': numeroParcela,
      'dataLimiteAcolhimento': dataLimiteAcolhimento,
      'pagamentoDebitos': pagamentoDebitos.map((e) => e.toJson()).toList(),
      'dataPagamento': dataPagamento,
      'bancoAgencia': bancoAgencia,
      'valorPagoArrecadacao': valorPagoArrecadacao,
    };
  }

  /// Data de vencimento formatada (DD/MM/AAAA)
  String get dataVencimentoFormatada {
    final data = dataVencimento.toString();
    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
    }
    return data;
  }

  /// Período de apuração do DAS gerado formatado (MM/AAAA)
  String get paDasGeradoFormatado {
    final pa = paDasGerado.toString();
    if (pa.length == 6) {
      return '${pa.substring(4, 6)}/${pa.substring(0, 4)}';
    }
    return pa;
  }

  /// Data limite para acolhimento formatada (DD/MM/AAAA)
  String get dataLimiteAcolhimentoFormatada {
    final data = dataLimiteAcolhimento.toString();
    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
    }
    return data;
  }

  /// Data do pagamento formatada (DD/MM/AAAA)
  String get dataPagamentoFormatada {
    final data = dataPagamento.toString();
    if (data.length == 8) {
      return '${data.substring(6, 8)}/${data.substring(4, 6)}/${data.substring(0, 4)}';
    }
    return data;
  }

  /// Valor pago na arrecadação formatado como moeda brasileira
  String get valorPagoArrecadacaoFormatado {
    return 'R\$ ${valorPagoArrecadacao.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Verifica se o pagamento foi realizado
  bool get isPago => dataPagamento > 0;

  @override
  String toString() {
    return 'DetalhesPagamentoData(numeroDas: $numeroDas, parcela: $numeroParcela, valor: $valorPagoArrecadacaoFormatado)';
  }
}

class PagamentoDebito {
  final int paDebito;
  final String processo;
  final List<DiscriminacaoDebito> discriminacoesDebito;

  PagamentoDebito({required this.paDebito, required this.processo, required this.discriminacoesDebito});

  factory PagamentoDebito.fromJson(Map<String, dynamic> json) {
    return PagamentoDebito(
      paDebito: json['paDebito'] as int,
      processo: json['processo'] as String,
      discriminacoesDebito: (json['discriminacoesDebito'] as List).map((e) => DiscriminacaoDebito.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'paDebito': paDebito, 'processo': processo, 'discriminacoesDebito': discriminacoesDebito.map((e) => e.toJson()).toList()};
  }

  /// Período de apuração do débito formatado (MM/AAAA)
  String get paDebitoFormatado {
    final pa = paDebito.toString();
    if (pa.length == 6) {
      return '${pa.substring(4, 6)}/${pa.substring(0, 4)}';
    }
    return pa;
  }

  /// Valor total de todos os débitos discriminados
  double get valorTotalDebitos {
    return discriminacoesDebito.fold(0.0, (sum, debito) => sum + debito.total);
  }

  /// Valor total formatado como moeda brasileira
  String get valorTotalDebitosFormatado {
    return 'R\$ ${valorTotalDebitos.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  @override
  String toString() {
    return 'PagamentoDebito(pa: $paDebitoFormatado, processo: $processo, discriminacoes: ${discriminacoesDebito.length})';
  }
}

class DiscriminacaoDebito {
  final String tributo;
  final double principal;
  final double multa;
  final double juros;
  final double total;
  final String enteFederadoDestino;

  DiscriminacaoDebito({
    required this.tributo,
    required this.principal,
    required this.multa,
    required this.juros,
    required this.total,
    required this.enteFederadoDestino,
  });

  factory DiscriminacaoDebito.fromJson(Map<String, dynamic> json) {
    return DiscriminacaoDebito(
      tributo: json['tributo'] as String,
      principal: (json['principal'] as num).toDouble(),
      multa: (json['multa'] as num).toDouble(),
      juros: (json['juros'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      enteFederadoDestino: json['enteFederadoDestino'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tributo': tributo, 'principal': principal, 'multa': multa, 'juros': juros, 'total': total, 'enteFederadoDestino': enteFederadoDestino};
  }

  /// Valor principal formatado como moeda brasileira
  String get principalFormatado {
    return 'R\$ ${principal.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Valor da multa formatado como moeda brasileira
  String get multaFormatada {
    return 'R\$ ${multa.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Valor dos juros formatado como moeda brasileira
  String get jurosFormatados {
    return 'R\$ ${juros.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  /// Valor total formatado como moeda brasileira
  String get totalFormatado {
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',').replaceAll(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), r'$1.')}';
  }

  @override
  String toString() {
    return 'DiscriminacaoDebito(tributo: $tributo, total: $totalFormatado, destino: $enteFederadoDestino)';
  }
}
