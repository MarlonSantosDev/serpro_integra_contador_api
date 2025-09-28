import 'dart:convert';
import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgmei/gerar_das_response.dart';
import 'package:serpro_integra_contador_api/src/util/validation_utils.dart';

class PgmeiService {
  final ApiClient _apiClient;

  PgmeiService(this._apiClient);

  Future<GerarDasResponse> gerarDas(String cnpj, String periodoApuracao) async {
    // Validações
    ValidationUtils.validateCNPJ(cnpj);
    ValidationUtils.validatePeriodo(periodoApuracao);

    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'GERARDASPDF21',
        versaoSistema: '1.0',
        dados: jsonEncode({'periodoApuracao': periodoApuracao}),
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }

  Future<GerarDasResponse> gerarDasCodigoDeBarras(String cnpj, String periodoApuracao) async {
    // Validações
    ValidationUtils.validateCNPJ(cnpj);
    ValidationUtils.validatePeriodo(periodoApuracao);

    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'GERARDASCODBARRA22',
        versaoSistema: '1.0',
        dados: jsonEncode({'periodoApuracao': periodoApuracao}),
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }

  Future<GerarDasResponse> atualizarBeneficio(String cnpj, String periodoApuracao) async {
    // Validações
    ValidationUtils.validateCNPJ(cnpj);
    ValidationUtils.validatePeriodo(periodoApuracao);

    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'ATUBENEFICIO23',
        versaoSistema: '1.0',
        dados: jsonEncode({'periodoApuracao': periodoApuracao}),
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return GerarDasResponse.fromJson(response);
  }

  Future<GerarDasResponse> consultarDividaAtiva(String cnpj, String ano) async {
    // Validações
    ValidationUtils.validateCNPJ(cnpj);
    ValidationUtils.validateAno(ano);

    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'DIVIDAATIVA24', versaoSistema: '1.0', dados: jsonEncode({'anoCalendario': ano})),
    );

    final response = await _apiClient.post('/Consultar', request);
    return GerarDasResponse.fromJson(response);
  }
}
