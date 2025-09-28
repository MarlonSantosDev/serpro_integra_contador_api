import 'dart:convert';
import '../base/base_request.dart';

/// Request para emitir relatório de situação fiscal
class EmitirRelatorioRequest extends BaseRequest {
  EmitirRelatorioRequest({required String contribuinteNumero, required String protocoloRelatorio})
    : super(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(
          idSistema: 'SITFIS',
          idServico: 'RELATORIOSITFIS92',
          versaoSistema: '2.0',
          dados: jsonEncode({'protocoloRelatorio': protocoloRelatorio}),
        ),
      );
}
