import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/defis/transmitir_declaracao_request.dart';
import 'package:serpro_integra_contador_api/src/models/defis/transmitir_declaracao_response.dart';

class DefisService {
  final ApiClient _apiClient;

  DefisService(this._apiClient);

  Future<TransmitirDeclaracaoResponse> transmitirDeclaracao(String cnpj, TransmitirDeclaracaoRequest declaracaoData) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(idSistema: 'DEFIS', idServico: 'transmitir-declaracao', dados: jsonEncode(declaracaoData.toJson())),
    );

    final response = await _apiClient.post('/', request);
    return TransmitirDeclaracaoResponse.fromJson(response);
  }
}
