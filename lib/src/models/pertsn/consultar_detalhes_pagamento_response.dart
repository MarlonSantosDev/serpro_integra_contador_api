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
}

class DetalhesPagamentoData {
  final String numeroDas;
  final String codigoBarras;
  final double valorPagoArrecadacao;
  final int dataArrecadacao;
  final String bancoAgencia;
  final List<PagamentoDebito> pagamentosDebitos;

  DetalhesPagamentoData({
    required this.numeroDas,
    required this.codigoBarras,
    required this.valorPagoArrecadacao,
    required this.dataArrecadacao,
    required this.bancoAgencia,
    required this.pagamentosDebitos,
  });

  factory DetalhesPagamentoData.fromJson(String jsonString) {
    final json = jsonString as Map<String, dynamic>;
    return DetalhesPagamentoData(
      numeroDas: json['numeroDas'].toString(),
      codigoBarras: json['codigoBarras'].toString(),
      valorPagoArrecadacao: double.parse(json['valorPagoArrecadacao'].toString()),
      dataArrecadacao: int.parse(json['dataArrecadacao'].toString()),
      bancoAgencia: json['bancoAgencia'].toString(),
      pagamentosDebitos: (json['pagamentosDebitos'] as List? ?? []).map((e) => PagamentoDebito.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroDas': numeroDas,
      'codigoBarras': codigoBarras,
      'valorPagoArrecadacao': valorPagoArrecadacao,
      'dataArrecadacao': dataArrecadacao,
      'bancoAgencia': bancoAgencia,
      'pagamentosDebitos': pagamentosDebitos.map((e) => e.toJson()).toList(),
    };
  }

  /// Formata a data de arrecadação (AAAAMMDD)
  String get dataArrecadacaoFormatada {
    final dataStr = dataArrecadacao.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Formata o valor pago na arrecadação
  String get valorPagoArrecadacaoFormatado {
    return 'R\$ ${valorPagoArrecadacao.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se há pagamentos de débitos
  bool get temPagamentosDebitos {
    return pagamentosDebitos.isNotEmpty;
  }

  /// Quantidade de débitos pagos
  int get quantidadeDebitosPagos {
    return pagamentosDebitos.length;
  }

  /// Valor total dos débitos pagos
  double get valorTotalDebitosPagos {
    return pagamentosDebitos.fold(0.0, (sum, debito) => sum + debito.valorPago);
  }

  /// Formata o valor total dos débitos pagos
  String get valorTotalDebitosPagosFormatado {
    return 'R\$ ${valorTotalDebitosPagos.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class PagamentoDebito {
  final int periodoApuracao;
  final int vencimento;
  final String numeroProcesso;
  final String tributo;
  final String enteFederado;
  final double valorPago;
  final List<DiscriminacaoDebito> discriminacaoDebitos;

  PagamentoDebito({
    required this.periodoApuracao,
    required this.vencimento,
    required this.numeroProcesso,
    required this.tributo,
    required this.enteFederado,
    required this.valorPago,
    required this.discriminacaoDebitos,
  });

  factory PagamentoDebito.fromJson(Map<String, dynamic> json) {
    return PagamentoDebito(
      periodoApuracao: int.parse(json['periodoApuracao'].toString()),
      vencimento: int.parse(json['vencimento'].toString()),
      numeroProcesso: json['numeroProcesso'].toString(),
      tributo: json['tributo'].toString(),
      enteFederado: json['enteFederado'].toString(),
      valorPago: double.parse(json['valorPago'].toString()),
      discriminacaoDebitos: (json['discriminacaoDebitos'] as List? ?? [])
          .map((e) => DiscriminacaoDebito.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'vencimento': vencimento,
      'numeroProcesso': numeroProcesso,
      'tributo': tributo,
      'enteFederado': enteFederado,
      'valorPago': valorPago,
      'discriminacaoDebitos': discriminacaoDebitos.map((e) => e.toJson()).toList(),
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

  /// Formata o valor pago
  String get valorPagoFormatado {
    return 'R\$ ${valorPago.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se há discriminação de débitos
  bool get temDiscriminacaoDebitos {
    return discriminacaoDebitos.isNotEmpty;
  }

  /// Quantidade de discriminações de débitos
  int get quantidadeDiscriminacoes {
    return discriminacaoDebitos.length;
  }
}

class DiscriminacaoDebito {
  final String codigoReceita;
  final String descricaoReceita;
  final double valorPrincipal;
  final double valorMulta;
  final double valorJuros;
  final double valorTotal;

  DiscriminacaoDebito({
    required this.codigoReceita,
    required this.descricaoReceita,
    required this.valorPrincipal,
    required this.valorMulta,
    required this.valorJuros,
    required this.valorTotal,
  });

  factory DiscriminacaoDebito.fromJson(Map<String, dynamic> json) {
    return DiscriminacaoDebito(
      codigoReceita: json['codigoReceita'].toString(),
      descricaoReceita: json['descricaoReceita'].toString(),
      valorPrincipal: double.parse(json['valorPrincipal'].toString()),
      valorMulta: double.parse(json['valorMulta'].toString()),
      valorJuros: double.parse(json['valorJuros'].toString()),
      valorTotal: double.parse(json['valorTotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigoReceita': codigoReceita,
      'descricaoReceita': descricaoReceita,
      'valorPrincipal': valorPrincipal,
      'valorMulta': valorMulta,
      'valorJuros': valorJuros,
      'valorTotal': valorTotal,
    };
  }

  /// Formata o valor principal
  String get valorPrincipalFormatado {
    return 'R\$ ${valorPrincipal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor da multa
  String get valorMultaFormatado {
    return 'R\$ ${valorMulta.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor dos juros
  String get valorJurosFormatado {
    return 'R\$ ${valorJuros.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor total
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se há multa
  bool get temMulta {
    return valorMulta > 0;
  }

  /// Verifica se há juros
  bool get temJuros {
    return valorJuros > 0;
  }

  /// Obtém a descrição resumida
  String get descricaoResumida {
    return '$codigoReceita - $descricaoReceita';
  }
}
