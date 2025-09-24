import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/declarar_response.dart';

class PgdasdService {
  final ApiClient _apiClient;

  PgdasdService(this._apiClient);

  Future<DeclararResponse> declarar(String cnpj, String dados) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'declarar', dados: dados),
    );

    final response = await _apiClient.post('/', request);
    return DeclararResponse.fromJson(response);
  }
}
