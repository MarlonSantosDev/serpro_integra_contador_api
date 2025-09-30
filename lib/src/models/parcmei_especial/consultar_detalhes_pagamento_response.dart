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
      final parsed = DetalhesPagamentoData.fromJson(dadosJson as Map<String, dynamic>);
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

  factory DetalhesPagamentoData.fromJson(Map<String, dynamic> json) {
    return DetalhesPagamentoData(
      numeroDas: json['numeroDas']?.toString() ?? '',
      dataVencimento: int.parse(json['dataVencimento'].toString()),
      paDasGerado: int.parse(json['paDasGerado'].toString()),
      geradoEm: json['geradoEm']?.toString() ?? '',
      numeroParcelamento: json['numeroParcelamento']?.toString() ?? '',
      numeroParcela: json['numeroParcela']?.toString() ?? '',
      dataLimiteAcolhimento: int.parse(json['dataLimiteAcolhimento'].toString()),
      pagamentoDebitos: (json['pagamentoDebitos'] as List).map((e) => PagamentoDebito.fromJson(e as Map<String, dynamic>)).toList(),
      dataPagamento: int.parse(json['dataPagamento'].toString()),
      bancoAgencia: json['bancoAgencia']?.toString() ?? '',
      valorPagoArrecadacao: double.parse(json['valorPagoArrecadacao'].toString()),
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

  /// Data de vencimento formatada (AAAAMMDD)
  String get dataVencimentoFormatada {
    final dataStr = dataVencimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Período de apuração do DAS formatado (AAAAMM)
  String get paDasGeradoFormatado {
    final paStr = paDasGerado.toString();
    if (paStr.length == 6) {
      return '${paStr.substring(0, 4)}/${paStr.substring(4, 6)}';
    }
    return paStr;
  }

  /// Data limite para acolhimento formatada (AAAAMMDD)
  String get dataLimiteAcolhimentoFormatada {
    final dataStr = dataLimiteAcolhimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Data de pagamento formatada (AAAAMMDD)
  String get dataPagamentoFormatada {
    final dataStr = dataPagamento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Valor pago arrecadado formatado
  String get valorPagoArrecadacaoFormatado {
    return 'R\$ ${valorPagoArrecadacao.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se o pagamento foi realizado
  bool get isPago => dataPagamento > 0;

  /// Verifica se está dentro do prazo de acolhimento
  bool get isDentroPrazoAcolhimento {
    final hoje = DateTime.now();
    final dataLimiteStr = dataLimiteAcolhimento.toString();

    if (dataLimiteStr.length == 8) {
      final ano = int.parse(dataLimiteStr.substring(0, 4));
      final mes = int.parse(dataLimiteStr.substring(4, 6));
      final dia = int.parse(dataLimiteStr.substring(6, 8));
      final dataLimite = DateTime(ano, mes, dia);

      return hoje.isBefore(dataLimite) || hoje.isAtSameMomentAs(dataLimite);
    }

    return false;
  }
}

class PagamentoDebito {
  final int paDebito;
  final String processo;
  final List<DiscriminacaoDebito> discriminacoesDebito;

  PagamentoDebito({required this.paDebito, required this.processo, required this.discriminacoesDebito});

  factory PagamentoDebito.fromJson(Map<String, dynamic> json) {
    return PagamentoDebito(
      paDebito: int.parse(json['paDebito'].toString()),
      processo: json['processo']?.toString() ?? '',
      discriminacoesDebito: (json['discriminacoesDebito'] as List).map((e) => DiscriminacaoDebito.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'paDebito': paDebito, 'processo': processo, 'discriminacoesDebito': discriminacoesDebito.map((e) => e.toJson()).toList()};
  }

  /// Período de apuração do débito formatado (AAAAMM)
  String get paDebitoFormatado {
    final paStr = paDebito.toString();
    if (paStr.length == 6) {
      return '${paStr.substring(0, 4)}/${paStr.substring(4, 6)}';
    }
    return paStr;
  }

  /// Valor total das discriminações
  double get valorTotal {
    return discriminacoesDebito.fold(0.0, (sum, disc) => sum + disc.total);
  }

  /// Valor total formatado
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
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
      tributo: json['tributo']?.toString() ?? '',
      principal: double.parse(json['principal'].toString()),
      multa: double.parse(json['multa'].toString()),
      juros: double.parse(json['juros'].toString()),
      total: double.parse(json['total'].toString()),
      enteFederadoDestino: json['enteFederadoDestino']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'tributo': tributo, 'principal': principal, 'multa': multa, 'juros': juros, 'total': total, 'enteFederadoDestino': enteFederadoDestino};
  }

  /// Valor principal formatado
  String get principalFormatado {
    return 'R\$ ${principal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Valor da multa formatado
  String get multaFormatada {
    return 'R\$ ${multa.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Valor dos juros formatado
  String get jurosFormatado {
    return 'R\$ ${juros.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Valor total formatado
  String get totalFormatado {
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se há multa
  bool get temMulta => multa > 0;

  /// Verifica se há juros
  bool get temJuros => juros > 0;

  /// Percentual da multa sobre o principal
  double get percentualMulta {
    if (principal == 0) return 0.0;
    return (multa / principal) * 100;
  }

  /// Percentual dos juros sobre o principal
  double get percentualJuros {
    if (principal == 0) return 0.0;
    return (juros / principal) * 100;
  }
}

