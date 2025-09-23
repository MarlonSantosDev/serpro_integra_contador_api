import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/caixa_postal/caixa_postal_response.dart';

class CaixaPostalService {
  final ApiClient _apiClient;

  CaixaPostalService(this._apiClient);

  Future<CaixaPostalResponse> consultarMensagens(String ni) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: ni, tipo: ni.length == 11 ? 1 : 2),
      pedidoDados: PedidoDados(
        idSistema: 'caixa-postal',
        idServico: 'consultar-mensagens',
        dados: '',
      ),
    );

    final response = await _apiClient.post('/', request);
    return CaixaPostalResponse.fromJson(response);
  }
}
