import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/caixa_postal/caixa_postal_response.dart';

class CaixaPostalService {
  final ApiClient _apiClient;

  CaixaPostalService(this._apiClient);

  Future<CaixaPostalResponse> consultarMensagens(String ni) async {
    final request = BaseRequest(
      contribuinteNumero: ni,
      pedidoDados: PedidoDados(idSistema: 'CAIXAPOSTAL', idServico: 'consultar-mensagens', dados: ''),
    );

    final response = await _apiClient.post('/', request);
    return CaixaPostalResponse.fromJson(response);
  }
}
