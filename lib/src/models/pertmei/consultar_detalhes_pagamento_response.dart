import 'mensagem.dart';

class ConsultarDetalhesPagamentoResponse {
  final String status;
  final List<Mensagem> mensagens;
  final String dados;

  ConsultarDetalhesPagamentoResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarDetalhesPagamentoResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarDetalhesPagamentoResponse(
      status: json['status']?.toString() ?? '',
      mensagens:
          (json['mensagens'] as List<dynamic>?)
              ?.map((e) => Mensagem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dados: json['dados']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados,
    };
  }

  /// Retorna os dados parseados como objeto detalhes de pagamento
  DetalhesPagamento? get detalhesPagamento {
    try {
      if (dados.isEmpty) return null;

      // Em implementação real, seria feito parsing do JSON string
      // Por enquanto retornamos null - seria implementado com dart:convert
      return null;
    } catch (e) {
      return null;
    }
  }
}

class DetalhesPagamento {
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

  DetalhesPagamento({
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

  factory DetalhesPagamento.fromJson(Map<String, dynamic> json) {
    return DetalhesPagamento(
      numeroDas: json['numeroDas']?.toString() ?? '',
      dataVencimento: int.parse(json['dataVencimento'].toString()),
      paDasGerado: int.parse(json['paDasGerado'].toString()),
      geradoEm: json['geradoEm']?.toString() ?? '',
      numeroParcelamento: json['numeroParcelamento']?.toString() ?? '',
      numeroParcela: json['numeroParcela']?.toString() ?? '',
      dataLimiteAcolhimento: int.parse(
        json['dataLimiteAcolhimento'].toString(),
      ),
      pagamentoDebitos:
          (json['pagamentoDebitos'] as List<dynamic>?)
              ?.map((e) => PagamentoDebito.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dataPagamento: int.parse(json['dataPagamento'].toString()),
      bancoAgencia: json['bancoAgencia']?.toString() ?? '',
      valorPagoArrecadacao: (num.parse(
        json['valorPagoArrecadacao'].toString(),
      )).toDouble(),
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
}

class PagamentoDebito {
  final int paDebito;
  final String processo;
  final List<DiscriminacaoDebito> discriminacoesDebito;

  PagamentoDebito({
    required this.paDebito,
    required this.processo,
    required this.discriminacoesDebito,
  });

  factory PagamentoDebito.fromJson(Map<String, dynamic> json) {
    return PagamentoDebito(
      paDebito: int.parse(json['paDebito'].toString()),
      processo: json['processo']?.toString() ?? '',
      discriminacoesDebito:
          (json['discriminacoesDebito'] as List<dynamic>?)
              ?.map(
                (e) => DiscriminacaoDebito.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paDebito': paDebito,
      'processo': processo,
      'discriminacoesDebito': discriminacoesDebito
          .map((e) => e.toJson())
          .toList(),
    };
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
      principal: (num.parse(json['principal'].toString())).toDouble(),
      multa: (num.parse(json['multa'].toString())).toDouble(),
      juros: (num.parse(json['juros'].toString())).toDouble(),
      total: (num.parse(json['total'].toString())).toDouble(),
      enteFederadoDestino: json['enteFederadoDestino']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tributo': tributo,
      'principal': principal,
      'multa': multa,
      'juros': juros,
      'total': total,
      'enteFederadoDestino': enteFederadoDestino,
    };
  }
}
