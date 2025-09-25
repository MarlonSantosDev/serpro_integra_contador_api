import 'dart:convert';
import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgmei/gerar_das_response.dart';

class PgmeiService {
  final ApiClient _apiClient;

  PgmeiService(this._apiClient);

  Future<GerarDasResponse> gerarDas(String cnpj, String periodoApuracao) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'GERARDASPDF21', dados: jsonEncode({'periodoApuracao': periodoApuracao})),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }

  Future<GerarDasResponse> gerarDasCodigoDeBarras(String cnpj, String periodoApuracao) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'GERARDASCODBARRA22', dados: jsonEncode({'periodoApuracao': periodoApuracao})),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }

  Future<GerarDasResponse> AtualizarBeneficio(String cnpj, String periodoApuracao) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'ATUBENEFICIO23', dados: jsonEncode({'periodoApuracao': periodoApuracao})),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }

  Future<GerarDasResponse> ConsultarDividaAtiva(String cnpj, String ano) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'DIVIDAATIVA24', dados: jsonEncode({'anoCalendario': ano})),
    );

    final response = await _apiClient.post('/Consultar', request);
    return GerarDasResponse.fromJson(response);
  }
}
