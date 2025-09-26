import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/dte/dte_response.dart';

class DteService {
  final ApiClient _apiClient;

  DteService(this._apiClient);

  Future<DteResponse> declarar(String cnpj, String dados) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'DTE',
        idServico: 'declarar',
        dados: dados,
      ),
    );

    final response = await _apiClient.post('/', request);
    return DteResponse.fromJson(response);
  }
}
