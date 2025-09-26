import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/procuracoes/procuracoes_response.dart';

class ProcuracoesService {
  final ApiClient _apiClient;

  ProcuracoesService(this._apiClient);

  Future<ProcuracoesResponse> obterProcuracao(
    String cnpj, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PROCURACOES',
        idServico: 'OBTERPROCURACAO41',
        dados: '',
      ),
    );

    final response = await _apiClient.post(
      '/',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ProcuracoesResponse.fromJson(response);
  }
}
