import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/dctfweb/dctfweb_response.dart';

class DctfWebService {
  final ApiClient _apiClient;

  DctfWebService(this._apiClient);

  Future<DctfWebResponse> gerarDarf(String cnpj, String periodoApuracao) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(
        idSistema: 'DCTFWEB',
        idServico: 'GERAR_DARF_DECLARACAO_ANDAMENTO',
        dados: jsonEncode({'periodoApuracao': periodoApuracao}),
      ),
    );

    final response = await _apiClient.post('/', request);
    return DctfWebResponse.fromJson(response);
  }
}
