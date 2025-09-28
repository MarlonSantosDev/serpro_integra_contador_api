import 'mensagem.dart';

class ConsultarDetalhesPagamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarDetalhesPagamentoResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarDetalhesPagamentoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDetalhesPagamentoResponse(
      status: json['status'] as String,
      mensagens: (json['mensagens'] as List).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList(),
      dados: json['dados'] as String,
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
    final json = jsonString as Map<String, dynamic>;
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

  /// Formata a data de vencimento (AAAAMMDD)
  String get dataVencimentoFormatada {
    final dataStr = dataVencimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata o período de apuração do DAS gerado (AAAAMM)
  String get paDasGeradoFormatado {
    final paStr = paDasGerado.toString();
    if (paStr.length == 6) {
      return '${paStr.substring(0, 4)}/${paStr.substring(4, 6)}';
    }
    return paStr;
  }

  /// Formata a data de geração (AAAAMMDDHHMMSS)
  String get geradoEmFormatado {
    if (geradoEm.length == 14) {
      return '${geradoEm.substring(0, 4)}-${geradoEm.substring(4, 6)}-${geradoEm.substring(6, 8)} ${geradoEm.substring(8, 10)}:${geradoEm.substring(10, 12)}:${geradoEm.substring(12, 14)}';
    }
    return geradoEm;
  }

  /// Formata a data limite para acolhimento (AAAAMMDD)
  String get dataLimiteAcolhimentoFormatada {
    final dataStr = dataLimiteAcolhimento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata a data do pagamento (AAAAMMDD)
  String get dataPagamentoFormatada {
    final dataStr = dataPagamento.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata o valor pago para exibição
  String get valorPagoArrecadacaoFormatado {
    return 'R\$ ${valorPagoArrecadacao.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Retorna o total de débitos pagos
  double get totalDebitosPagos {
    return pagamentoDebitos.fold(0.0, (sum, debito) => sum + debito.totalDebitos);
  }

  /// Retorna o total de tributos pagos
  double get totalTributosPagos {
    return pagamentoDebitos.fold(0.0, (sum, debito) => sum + debito.discriminacoesDebito.fold(0.0, (sumDisc, disc) => sumDisc + disc.total));
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

  /// Formata o período de apuração do débito (AAAAMM)
  String get paDebitoFormatado {
    final paStr = paDebito.toString();
    if (paStr.length == 6) {
      return '${paStr.substring(0, 4)}/${paStr.substring(4, 6)}';
    }
    return paStr;
  }

  /// Retorna o total de débitos deste período
  double get totalDebitos {
    return discriminacoesDebito.fold(0.0, (sum, disc) => sum + disc.total);
  }

  /// Retorna o total de principal
  double get totalPrincipal {
    return discriminacoesDebito.fold(0.0, (sum, disc) => sum + disc.principal);
  }

  /// Retorna o total de multa
  double get totalMulta {
    return discriminacoesDebito.fold(0.0, (sum, disc) => sum + disc.multa);
  }

  /// Retorna o total de juros
  double get totalJuros {
    return discriminacoesDebito.fold(0.0, (sum, disc) => sum + disc.juros);
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

  /// Formata o valor principal para exibição
  String get principalFormatado {
    return 'R\$ ${principal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor da multa para exibição
  String get multaFormatada {
    return 'R\$ ${multa.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor dos juros para exibição
  String get jurosFormatados {
    return 'R\$ ${juros.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor total para exibição
  String get totalFormatado {
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Retorna uma descrição completa do débito
  String get descricaoCompleta {
    return '$tributo - Principal: ${principalFormatado}, Multa: ${multaFormatada}, Juros: ${jurosFormatados}, Total: ${totalFormatado} - $enteFederadoDestino';
  }

  /// Calcula o percentual de multa sobre o principal
  double get percentualMulta {
    if (principal == 0) return 0.0;
    return (multa / principal) * 100;
  }

  /// Calcula o percentual de juros sobre o principal
  double get percentualJuros {
    if (principal == 0) return 0.0;
    return (juros / principal) * 100;
  }
}
