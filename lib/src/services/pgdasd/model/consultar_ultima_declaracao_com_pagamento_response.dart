import 'consultar_ultima_declaracao_response.dart';

/// Modelo de resposta para consultar última declaração com informação de pagamento
///
/// Estende [ConsultarUltimaDeclaracaoResponse] adicionando informação de pagamento do DAS
class ConsultarUltimaDeclaracaoComPagamentoResponse
    extends ConsultarUltimaDeclaracaoResponse {
  /// Status de pagamento do DAS correspondente ao período
  /// - true = pago ou não consta DAS (assume pago se não encontrado)
  /// - false = não consta pagamento
  ///
  /// Default: true (assume pago se DAS não for encontrado)
  final bool dasPago;

  ConsultarUltimaDeclaracaoComPagamentoResponse({
    required super.status,
    required super.mensagens,
    super.dados,
    required this.dasPago,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['dasPago'] = dasPago;
    return json;
  }

  /// Factory constructor para criar a partir da resposta base
  ///
  /// [baseResponse] Resposta de consultarUltimaDeclaracao
  /// [dasPago] Status de pagamento do DAS
  factory ConsultarUltimaDeclaracaoComPagamentoResponse.fromBase({
    required ConsultarUltimaDeclaracaoResponse baseResponse,
    required bool dasPago,
  }) {
    return ConsultarUltimaDeclaracaoComPagamentoResponse(
      status: baseResponse.status,
      mensagens: baseResponse.mensagens,
      dados: baseResponse.dados,
      dasPago: dasPago,
    );
  }
}
