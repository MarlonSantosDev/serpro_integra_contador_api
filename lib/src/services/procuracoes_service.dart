import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/procuracoes/procuracoes_response.dart';

class ProcuracoesService {
  final ApiClient _apiClient;

  ProcuracoesService(this._apiClient);

  Future<ProcuracoesResponse> obterProcuracao(String cnpj) async {
    final request = BaseRequest(
      contratante: Contratante(numero: '00000000000000', tipo: 2),
      autorPedidoDados: AutorPedidoDados(numero: '00000000000000', tipo: 2),
      contribuinte: Contribuinte(numero: cnpj, tipo: 2),
      pedidoDados: PedidoDados(
        idSistema: 'PROCURACOES',
        idServico: 'OBTERPROCURACAO41',
        dados: '',
      ),
    );

    final response = await _apiClient.post('/', request);
    return ProcuracoesResponse.fromJson(response);
  }
}
