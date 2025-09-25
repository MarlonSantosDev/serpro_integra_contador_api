import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/declarar_response.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_request.dart' as request_models;
import 'package:serpro_integra_contador_api/src/models/pgdasd/entregar_declaracao_response.dart' as response_models;
import 'package:serpro_integra_contador_api/src/models/pgdasd/gerar_das_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/gerar_das_response.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_declaracoes_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_declaracoes_response.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_ultima_declaracao_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_ultima_declaracao_response.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_declaracao_numero_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_declaracao_numero_response.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_extrato_das_request.dart';
import 'package:serpro_integra_contador_api/src/models/pgdasd/consultar_extrato_das_response.dart';

/// Serviço para integração com PGDASD (Programa Gerador do DAS do Simples Nacional)
///
/// Implementa todos os serviços disponíveis do Integra PGDASD:
/// - Entregar Declaração Mensal (TRANSDECLARACAO11)
/// - Gerar DAS (GERARDAS12)
/// - Consultar Declarações Transmitidas (CONSDECLARACAO13)
/// - Consultar Última Declaração/Recibo (CONSULTIMADECREC14)
/// - Consultar Declaração/Recibo por Número (CONSDECREC15)
/// - Consultar Extrato do DAS (CONSEXTRATO16)
class PgdasdService {
  final ApiClient _apiClient;

  PgdasdService(this._apiClient);

  /// Entregar declaração mensal do Simples Nacional
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da declaração a ser transmitida
  Future<response_models.EntregarDeclaracaoResponse> entregarDeclaracao({
    required String contribuinteNumero,
    required request_models.EntregarDeclaracaoRequest request,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da declaração inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'TRANSDECLARACAO11', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post('/Emitir', baseRequest);
    return response_models.EntregarDeclaracaoResponse.fromJson(response);
  }

  /// Gerar DAS de uma declaração previamente transmitida
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados para geração do DAS
  Future<GerarDasResponse> gerarDas({required String contribuinteNumero, required GerarDasRequest request}) async {
    if (!request.isValid) {
      throw ArgumentError('Dados para geração do DAS inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'GERARDAS12', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post('/Emitir', baseRequest);
    return GerarDasResponse.fromJson(response);
  }

  /// Consultar declarações transmitidas por ano-calendário ou período de apuração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da consulta
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoes({
    required String contribuinteNumero,
    required ConsultarDeclaracoesRequest request,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSDECLARACAO13', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post('/Consultar', baseRequest);
    return ConsultarDeclaracoesResponse.fromJson(response);
  }

  /// Consultar a última declaração/recibo transmitida por período de apuração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da consulta
  Future<ConsultarUltimaDeclaracaoResponse> consultarUltimaDeclaracao({
    required String contribuinteNumero,
    required ConsultarUltimaDeclaracaoRequest request,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSULTIMADECREC14', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post('/Consultar', baseRequest);
    return ConsultarUltimaDeclaracaoResponse.fromJson(response);
  }

  /// Consultar declaração/recibo específica por número de declaração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da consulta
  Future<ConsultarDeclaracaoNumeroResponse> consultarDeclaracaoPorNumero({
    required String contribuinteNumero,
    required ConsultarDeclaracaoNumeroRequest request,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSDECREC15', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post('/Consultar', baseRequest);
    return ConsultarDeclaracaoNumeroResponse.fromJson(response);
  }

  /// Consultar extrato da apuração do DAS por número de DAS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da consulta
  Future<ConsultarExtratoDasResponse> consultarExtratoDas({required String contribuinteNumero, required ConsultarExtratoDasRequest request}) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSEXTRATO16', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post('/Consultar', baseRequest);
    return ConsultarExtratoDasResponse.fromJson(response);
  }

  // ===== MÉTODOS DE CONVENIÊNCIA =====

  /// Entregar declaração com dados simplificados
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [declaracao] Dados da declaração
  /// [transmitir] Se true, transmite a declaração; se false, apenas calcula valores
  /// [compararValores] Se true, compara valores enviados com calculados
  Future<response_models.EntregarDeclaracaoResponse> entregarDeclaracaoSimples({
    required String cnpj,
    required int periodoApuracao,
    required request_models.Declaracao declaracao,
    bool transmitir = true,
    bool compararValores = false,
    List<request_models.ValorDevido>? valoresParaComparacao,
  }) async {
    final request = request_models.EntregarDeclaracaoRequest(
      cnpjCompleto: cnpj,
      pa: periodoApuracao,
      indicadorTransmissao: transmitir,
      indicadorComparacao: compararValores,
      declaracao: declaracao,
      valoresParaComparacao: valoresParaComparacao,
    );

    return entregarDeclaracao(contribuinteNumero: cnpj, request: request);
  }

  /// Gerar DAS com dados simplificados
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [dataConsolidacao] Data de consolidação futura (opcional)
  Future<GerarDasResponse> gerarDasSimples({required String cnpj, required String periodoApuracao, String? dataConsolidacao}) async {
    final request = GerarDasRequest(periodoApuracao: periodoApuracao, dataConsolidacao: dataConsolidacao);

    return gerarDas(contribuinteNumero: cnpj, request: request);
  }

  /// Consultar declarações por ano-calendário
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [anoCalendario] Ano-calendário (formato: AAAA)
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoesPorAno({required String cnpj, required String anoCalendario}) async {
    final request = ConsultarDeclaracoesRequest.porAnoCalendario(anoCalendario);

    return consultarDeclaracoes(contribuinteNumero: cnpj, request: request);
  }

  /// Consultar declarações por período de apuração
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoesPorPeriodo({required String cnpj, required String periodoApuracao}) async {
    final request = ConsultarDeclaracoesRequest.porPeriodoApuracao(periodoApuracao);

    return consultarDeclaracoes(contribuinteNumero: cnpj, request: request);
  }

  /// Consultar última declaração por período
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  Future<ConsultarUltimaDeclaracaoResponse> consultarUltimaDeclaracaoPorPeriodo({required String cnpj, required String periodoApuracao}) async {
    final request = ConsultarUltimaDeclaracaoRequest(periodoApuracao: periodoApuracao);

    return consultarUltimaDeclaracao(contribuinteNumero: cnpj, request: request);
  }

  /// Consultar declaração por número
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [numeroDeclaracao] Número da declaração (17 dígitos)
  Future<ConsultarDeclaracaoNumeroResponse> consultarDeclaracaoPorNumeroSimples({required String cnpj, required String numeroDeclaracao}) async {
    final request = ConsultarDeclaracaoNumeroRequest(numeroDeclaracao: numeroDeclaracao);

    return consultarDeclaracaoPorNumero(contribuinteNumero: cnpj, request: request);
  }

  /// Consultar extrato do DAS
  ///
  /// [cnpj] CNPJ do contribuinte (usado para contratante, autor e contribuinte)
  /// [numeroDas] Número do DAS (17 dígitos)
  Future<ConsultarExtratoDasResponse> consultarExtratoDasSimples({required String cnpj, required String numeroDas}) async {
    final request = ConsultarExtratoDasRequest(numeroDas: numeroDas);

    return consultarExtratoDas(contribuinteNumero: cnpj, request: request);
  }

  // ===== MÉTODO LEGADO (MANTIDO PARA COMPATIBILIDADE) =====

  /// Método legado mantido para compatibilidade com versões anteriores
  ///
  /// **DEPRECIADO**: Use `entregarDeclaracaoSimples()` ou `entregarDeclaracao()` em vez deste método
  @Deprecated('Use entregarDeclaracaoSimples() ou entregarDeclaracao() em vez deste método')
  Future<DeclararResponse> declarar(String cnpj, String dados) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'declarar', dados: dados),
    );

    final response = await _apiClient.post('/', request);
    return DeclararResponse.fromJson(response);
  }
}
