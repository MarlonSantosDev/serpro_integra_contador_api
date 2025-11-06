import 'dart:convert';
import 'mensagem.dart';

class ConsultarDetalhesPagamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final DetalhesPagamentoData? dados;

  ConsultarDetalhesPagamentoResponse({required this.status, required this.mensagens, this.dados});

  factory ConsultarDetalhesPagamentoResponse.fromJson(Map<String, dynamic> json) {
    DetalhesPagamentoData? dadosParsed;
    try {
      final dadosStr = json['dados']?.toString() ?? '';
      if (dadosStr.isNotEmpty) {
        dadosParsed = DetalhesPagamentoData.fromJson(dadosStr);
      }
    } catch (e) {
      // Se não conseguir fazer parse, mantém dados como null
    }

    return ConsultarDetalhesPagamentoResponse(
      status: json['status']?.toString() ?? '',
      mensagens: (json['mensagens'] as List?)?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
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

  /// Valor total pago formatado
  String get valorPagoArrecadacaoFormatado {
    final valor = dados?.valorPagoArrecadacao ?? 0.0;
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Data de pagamento formatada
  String get dataPagamentoFormatada {
    final data = dados?.dataPagamento ?? 0;
    final dataStr = data.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Data de vencimento formatada
  String get dataVencimentoFormatada {
    final data = dados?.dataVencimento ?? 0;
    final dataStr = data.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Data limite para acolhimento formatada
  String get dataLimiteAcolhimentoFormatada {
    final data = dados?.dataLimiteAcolhimento ?? 0;
    final dataStr = data.toString();
    if (dataStr.length == 8) {
      return '${dataStr.substring(0, 4)}-${dataStr.substring(4, 6)}-${dataStr.substring(6, 8)}';
    }
    return dataStr;
  }

  /// Período de apuração do DAS formatado
  String get paDasGeradoFormatado {
    final periodo = dados?.paDasGerado ?? 0;
    final periodoStr = periodo.toString();
    if (periodoStr.length == 6) {
      return '${periodoStr.substring(0, 4)}/${periodoStr.substring(4, 6)}';
    }
    return periodoStr;
  }

  /// Verifica se o pagamento foi realizado
  bool get pagamentoRealizado {
    return dados?.dataPagamento != null && dados!.dataPagamento > 0;
  }

  /// Verifica se o pagamento está em atraso
  bool get pagamentoEmAtraso {
    if (!pagamentoRealizado) return false;

    final vencimento = dados?.dataVencimento ?? 0;
    final pagamento = dados?.dataPagamento ?? 0;

    return pagamento > vencimento;
  }

  /// Quantidade de débitos pagos
  int get quantidadeDebitos {
    return dados?.pagamentoDebitos.length ?? 0;
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
    try {
      final Map<String, dynamic> json = jsonString as Map<String, dynamic>;

      return DetalhesPagamentoData(
        numeroDas: json['numeroDas']?.toString() ?? '',
        dataVencimento: int.tryParse(json['dataVencimento']?.toString() ?? '0') ?? 0,
        paDasGerado: int.tryParse(json['paDasGerado']?.toString() ?? '0') ?? 0,
        geradoEm: json['geradoEm']?.toString() ?? '',
        numeroParcelamento: json['numeroParcelamento']?.toString() ?? '',
        numeroParcela: json['numeroParcela']?.toString() ?? '',
        dataLimiteAcolhimento: int.tryParse(json['dataLimiteAcolhimento']?.toString() ?? '0') ?? 0,
        pagamentoDebitos: (json['pagamentoDebitos'] as List?)?.map((e) => PagamentoDebito.fromJson(e as Map<String, dynamic>)).toList() ?? [],
        dataPagamento: int.tryParse(json['dataPagamento']?.toString() ?? '0') ?? 0,
        bancoAgencia: json['bancoAgencia']?.toString() ?? '',
        valorPagoArrecadacao: double.tryParse(json['valorPagoArrecadacao']?.toString() ?? '0') ?? 0.0,
      );
    } catch (e) {
      return DetalhesPagamentoData(
        numeroDas: '',
        dataVencimento: 0,
        paDasGerado: 0,
        geradoEm: '',
        numeroParcelamento: '',
        numeroParcela: '',
        dataLimiteAcolhimento: 0,
        pagamentoDebitos: [],
        dataPagamento: 0,
        bancoAgencia: '',
        valorPagoArrecadacao: 0.0,
      );
    }
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

  /// Formata a data de geração (AAAAMMDDHHMMSS)
  String get geradoEmFormatado {
    if (geradoEm.length == 14) {
      return '${geradoEm.substring(0, 4)}-${geradoEm.substring(4, 6)}-${geradoEm.substring(6, 8)} ${geradoEm.substring(8, 10)}:${geradoEm.substring(10, 12)}:${geradoEm.substring(12, 14)}';
    }
    return geradoEm;
  }

  /// Valor total dos débitos formatado
  String get valorTotalDebitosFormatado {
    final total = pagamentoDebitos.fold<double>(
      0.0,
      (sum, debito) => sum + debito.discriminacoesDebito.fold<double>(0.0, (debitoSum, discriminacao) => debitoSum + discriminacao.total),
    );
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class PagamentoDebito {
  final int paDebito;
  final String processo;
  final List<DiscriminacaoDebito> discriminacoesDebito;

  PagamentoDebito({required this.paDebito, required this.processo, required this.discriminacoesDebito});

  factory PagamentoDebito.fromJson(Map<String, dynamic> json) {
    return PagamentoDebito(
      paDebito: int.tryParse(json['paDebito']?.toString() ?? '0') ?? 0,
      processo: json['processo']?.toString() ?? '',
      discriminacoesDebito:
          (json['discriminacoesDebito'] as List?)?.map((e) => DiscriminacaoDebito.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'paDebito': paDebito, 'processo': processo, 'discriminacoesDebito': discriminacoesDebito.map((e) => e.toJson()).toList()};
  }

  /// Formata o período de apuração do débito (AAAAMM)
  String get paDebitoFormatado {
    final periodoStr = paDebito.toString();
    if (periodoStr.length == 6) {
      return '${periodoStr.substring(0, 4)}/${periodoStr.substring(4, 6)}';
    }
    return periodoStr;
  }

  /// Valor total do débito formatado
  String get valorTotalDebitoFormatado {
    final total = discriminacoesDebito.fold<double>(0.0, (sum, disc) => sum + disc.total);
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
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
      principal: double.tryParse(json['principal']?.toString() ?? '0') ?? 0.0,
      multa: double.tryParse(json['multa']?.toString() ?? '0') ?? 0.0,
      juros: double.tryParse(json['juros']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      enteFederadoDestino: json['enteFederadoDestino']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'tributo': tributo, 'principal': principal, 'multa': multa, 'juros': juros, 'total': total, 'enteFederadoDestino': enteFederadoDestino};
  }

  /// Formata o valor principal
  String get principalFormatado {
    return 'R\$ ${principal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor da multa
  String get multaFormatada {
    return 'R\$ ${multa.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor dos juros
  String get jurosFormatados {
    return 'R\$ ${juros.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor total
  String get totalFormatado {
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se há multa aplicada
  bool get temMulta => multa > 0;

  /// Verifica se há juros aplicados
  bool get temJuros => juros > 0;

  /// Percentual de multa sobre o principal
  double get percentualMulta {
    if (principal == 0) return 0.0;
    return (multa / principal) * 100;
  }

  /// Percentual de juros sobre o principal
  double get percentualJuros {
    if (principal == 0) return 0.0;
    return (juros / principal) * 100;
  }
}

