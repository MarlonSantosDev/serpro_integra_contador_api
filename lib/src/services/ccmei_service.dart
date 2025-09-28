import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/ccmei/consultar_dados_ccmei_response.dart';
import 'package:serpro_integra_contador_api/src/models/ccmei/consultar_situacao_cadastral_ccmei_response.dart';
import 'package:serpro_integra_contador_api/src/models/ccmei/emitir_ccmei_response.dart';

class CcmeiService {
  final ApiClient _apiClient;

  CcmeiService(this._apiClient);

  Future<EmitirCcmeiResponse> emitirCcmei(String cnpj) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'CCMEI', idServico: 'EMITIRCCMEI121', dados: ''),
    );

    final response = await _apiClient.post('/Emitir', request);
    return EmitirCcmeiResponse.fromJson(response);
  }

  Future<ConsultarDadosCcmeiResponse> consultarDadosCcmei(String cnpj) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'CCMEI', idServico: 'DADOSCCMEI122', versaoSistema: '1.0', dados: ''),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarDadosCcmeiResponse.fromJson(response);
  }

  Future<ConsultarSituacaoCadastralCcmeiResponse> consultarSituacaoCadastral(String cpf) async {
    final request = BaseRequest(
      contribuinteNumero: cpf,
      pedidoDados: PedidoDados(idSistema: 'CCMEI', idServico: 'CCMEISITCADASTRAL123', versaoSistema: '1.0', dados: ''),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarSituacaoCadastralCcmeiResponse.fromJson(response);
  }
}
