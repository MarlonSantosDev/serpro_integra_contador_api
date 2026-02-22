import '../../../base/base_request.dart';

/// Request para solicitar protocolo do relatório de situação fiscal
class SolicitarProtocoloRequest extends BaseRequest {
  SolicitarProtocoloRequest({required super.contribuinteNumero})
    : super(
        pedidoDados: PedidoDados(
          idSistema: 'SITFIS',
          idServico: 'SOLICITARPROTOCOLO91',
          versaoSistema: '1.0',
          dados: '', // Campo dados deve ser enviado vazio
        ),
      );
}
