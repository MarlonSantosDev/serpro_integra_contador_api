import 'dart:convert';
import '../../../base/base_request.dart';

/// Request para emitir relatório de situação fiscal
class EmitirRelatorioRequest extends BaseRequest {
  EmitirRelatorioRequest({required super.contribuinteNumero, required String protocoloRelatorio})
    : super(
        pedidoDados: PedidoDados(idSistema: 'SITFIS', idServico: 'RELATORIOSITFIS92', versaoSistema: '1.0', dados: jsonEncode({'protocoloRelatorio': protocoloRelatorio})),
      );
}
