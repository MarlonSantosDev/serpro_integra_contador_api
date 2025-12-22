import 'dart:convert';

/// Modelo de entrada para serviços RELPMEI
/// Baseado no padrão dos outros serviços como PGMEI, PGdasd, etc.
class RelpmeiRequest {
  /// Dados específicos do serviço em formato JSON stringificado
  final String dados;

  RelpmeiRequest({required this.dados});

  /// Converte para JSON string para uso nos dados do pedido
  String toJsonString() {
    return dados;
  }

  Map<String, dynamic> toJson() {
    return {'dados': dados};
  }
}

/// Request específico para consultar pedidos de parcelamento (PEDIDOSPARC233)
class ConsultarPedidosRelpmeiRequest extends RelpmeiRequest {
  ConsultarPedidosRelpmeiRequest()
    : super(dados: ''); // Sem parâmetros específicos
}

/// Request específico para consultar parcelamento específico (OBTERPARC234)
class ConsultarParcelamentoRelpmeiRequest extends RelpmeiRequest {
  /// Número do parcelamento a ser consultado
  final int numeroParcelamento;

  ConsultarParcelamentoRelpmeiRequest({required this.numeroParcelamento})
    : super(dados: jsonEncode({'numeroParcelamento': numeroParcelamento}));

  @override
  Map<String, dynamic> toJson() {
    return {'dados': dados, 'numeroParcelamento': numeroParcelamento};
  }
}

/// Request específico para consultar parcelas para impressão (PARCELASPARAGERAR232)
class ConsultarParcelasImpressaoRelpmeiRequest extends RelpmeiRequest {
  ConsultarParcelasImpressaoRelpmeiRequest()
    : super(dados: ''); // Sem parâmetros específicos
}

/// Request específico para consultar detalhes de pagamento (DETPAGTOPARC235)
class ConsultarDetalhesPagamentoRelpmeiRequest extends RelpmeiRequest {
  /// Número do parcelamento
  final int numeroParcelamento;

  /// Ano/mês da parcela no formato AAAAMM
  final int anoMesParcela;

  ConsultarDetalhesPagamentoRelpmeiRequest({
    required this.numeroParcelamento,
    required this.anoMesParcela,
  }) : super(
         dados: jsonEncode({
           'numeroParcelamento': numeroParcelamento,
           'anoMesParcela': anoMesParcela,
         }),
       );

  @override
  Map<String, dynamic> toJson() {
    return {
      'dados': dados,
      'numeroParcelamento': numeroParcelamento,
      'anoMesParcela': anoMesParcela,
    };
  }
}

/// Request específico para emitir DAS (GERARDAS231)
class EmitirDasRelpmeiRequest extends RelpmeiRequest {
  /// Período da parcela para emissão do DAS no formato AAAAMM
  final int parcelaParaEmitir;

  EmitirDasRelpmeiRequest({required this.parcelaParaEmitir})
    : super(dados: jsonEncode({'parcelaParaEmitir': parcelaParaEmitir}));

  @override
  Map<String, dynamic> toJson() {
    return {'dados': dados, 'parcelaParaEmitir': parcelaParaEmitir};
  }
}
