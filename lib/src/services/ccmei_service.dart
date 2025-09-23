import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/ccmei/consultar_dados_ccmei_response.dart';
import 'package:serpro_integra_contador_api/src/models/ccmei/emitir_ccmei_response.dart';

class CcmeiService {
  final ApiClient _apiClient;

  CcmeiService(this._apiClient);

  Future<EmitirCcmeiResponse> emitirCcmei(String cnpj) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(
        idSistema: 'CCMEI',
        idServico: 'EMITIRCCMEI121',
        dados: '',
      ),
    );

    final response = await _apiClient.post('/', request);
    return EmitirCcmeiResponse.fromJson(response);
  }

  Future<ConsultarDadosCcmeiResponse> consultarDadosCcmei(String cnpj) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(
        idSistema: 'CCMEI',
        idServico: 'DADOSCCMEI122',
        dados: '',
      ),
    );

    final response = await _apiClient.post('/', request);
    return ConsultarDadosCcmeiResponse.fromJson(response);
  }

  Future<dynamic> consultarSituacaoCadastral(String cpf) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cpf, tipo: 1),
      pedidoDados: PedidoDados(
        idSistema: 'CCMEI',
        idServico: 'CCMEISITCADASTRAL123',
        dados: '',
      ),
    );

    final response = await _apiClient.post('/', request);
    return response;
  }
}
