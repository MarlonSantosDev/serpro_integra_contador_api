import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgmei/gerar_das_response.dart';

class PgmeiService {
  final ApiClient _apiClient;

  PgmeiService(this._apiClient);

  Future<GerarDasResponse> gerarDas(String cnpj, String periodoApuracao) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000100', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000100', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'GERARDASPDF21', dados: jsonEncode({'periodoApuracao': periodoApuracao})),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }
}
