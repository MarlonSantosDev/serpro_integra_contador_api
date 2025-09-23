import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/declarar_response.dart';

class PgdasdService {
  final ApiClient _apiClient;

  PgdasdService(this._apiClient);

  Future<DeclararResponse> declarar(String cnpj, String dados) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'declarar',
        dados: dados,
      ),
    );

    final response = await _apiClient.post('/', request);
    return DeclararResponse.fromJson(response);
  }
}
