import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';

class SitfisService {
  final ApiClient _apiClient;

  SitfisService(this._apiClient);

  Future<dynamic> solicitarProtocolo(String ni) async {
    final request = BaseRequest(
      contribuinteNumero: ni,
      pedidoDados: PedidoDados(idSistema: 'SITFIS', idServico: 'SOLICITARPROTOCOLO91', dados: ''),
    );

    final response = await _apiClient.post('/', request);
    return response;
  }

  Future<dynamic> emitirRelatorio(String ni, String protocolo) async {
    final request = BaseRequest(
      contribuinteNumero: ni,
      pedidoDados: PedidoDados(idSistema: 'SITFIS', idServico: 'RELATORIOSITFIS92', dados: jsonEncode({'protocoloRelatorio': protocolo})),
    );

    final response = await _apiClient.post('/', request);
    return response;
  }
}
