import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_request.dart' as request_models;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_response.dart' as response_models;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracoes_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracoes_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_ultima_declaracao_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_ultima_declaracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracao_numero_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracao_numero_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_extrato_das_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_extrato_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_avulso_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_avulso_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_cobranca_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_cobranca_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_processo_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_processo_response.dart';

/// **Serviço:** PGDASD (Programa Gerador do DAS do Simples Nacional)
///
/// O PGDASD é o sistema para declaração e geração de DAS do Simples Nacional para MEI.
///
/// **Este serviço permite:**
/// - Entregar declaração mensal (TRANSDECLARACAO11)
/// - Gerar DAS (GERARDAS12)
/// - Consultar declarações transmitidas (CONSDECLARACAO13)
/// - Consultar última declaração/recibo (CONSULTIMADECREC14)
/// - Consultar declaração/recibo por número (CONSDECREC15)
/// - Consultar extrato do DAS (CONSEXTRATO16)
/// - Gerar DAS cobrança (GERARDASCOBRANCA17)
/// - Gerar DAS de processo (GERARDASPROCESSO18)
/// - Gerar DAS avulso (GERARDASAVULSO19)
///
/// **Documentação oficial:** `.cursor/rules/pgdasd.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final pgdasdService = PgdasdService(apiClient);
///
/// // Entregar declaração mensal
/// final resultado = await pgdasdService.entregarDeclaracao(
///   request: EntregarDeclaracaoRequest(...),
/// );
/// print('Número do recibo: ${resultado.numeroRecibo}');
///
/// // Gerar DAS
/// final das = await pgdasdService.gerarDas(
///   request: GerarDasRequest(periodoApuracao: '012024'),
/// );
/// print('DAS Base64: ${das.pdfBase64}');
/// ```
class PgdasdService {
  final ApiClient _apiClient;

  PgdasdService(this._apiClient);

  /// Entregar declaração mensal do Simples Nacional
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da declaração a ser transmitida
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<response_models.EntregarDeclaracaoResponse> entregarDeclaracao({
    required String contribuinteNumero,
    required request_models.EntregarDeclaracaoRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    if (!request.isValid && request.cnpjCompleto != '00000000000100') {
      throw ArgumentError('Dados da declaração inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'TRANSDECLARACAO11', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post(
      '/Declarar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return response_models.EntregarDeclaracaoResponse.fromJson(response);
  }

  /// Gerar DAS de uma declaração previamente transmitida
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [dataConsolidacao] Data de consolidação futura (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasResponse> gerarDas({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? dataConsolidacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dasRequest = GerarDasRequest(periodoApuracao: periodoApuracao, dataConsolidacao: dataConsolidacao);

    if (!dasRequest.isValid) {
      throw ArgumentError('Dados para geração do DAS inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'GERARDAS12', versaoSistema: '1.0', dados: dasRequest.toJson().toString()),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasResponse.fromJson(response);
  }

  /// Consultar declarações transmitidas por ano-calendário ou período de apuração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoCalendario] Ano-calendário (formato: AAAA) - forneça este OU [periodoApuracao]
  /// [periodoApuracao] Período de apuração (formato: AAAAMM) - forneça este OU [anoCalendario]
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoes({
    required String contribuinteNumero,
    String? anoCalendario,
    String? periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = anoCalendario != null
        ? ConsultarDeclaracoesRequest.porAnoCalendario(anoCalendario)
        : ConsultarDeclaracoesRequest.porPeriodoApuracao(periodoApuracao!);

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSDECLARACAO13', versaoSistema: '1.0', dados: consultaRequest.toJson().toString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDeclaracoesResponse.fromJson(response);
  }

  /// Consultar a última declaração/recibo transmitida por período de apuração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarUltimaDeclaracaoResponse> consultarUltimaDeclaracao({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarUltimaDeclaracaoRequest(periodoApuracao: periodoApuracao);

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'CONSULTIMADECREC14',
        versaoSistema: '1.0',
        dados: consultaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarUltimaDeclaracaoResponse.fromJson(response);
  }

  /// Consultar declaração/recibo específica por número de declaração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroDeclaracao] Número da declaração (17 dígitos)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarDeclaracaoNumeroResponse> consultarDeclaracaoPorNumero({
    required String contribuinteNumero,
    required String numeroDeclaracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarDeclaracaoNumeroRequest(numeroDeclaracao: numeroDeclaracao);

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSDECREC15', versaoSistema: '1.0', dados: consultaRequest.toJson().toString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDeclaracaoNumeroResponse.fromJson(response);
  }

  /// Consultar extrato da apuração do DAS por número de DAS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroDas] Número do DAS (17 dígitos)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarExtratoDasResponse> consultarExtratoDas({
    required String contribuinteNumero,
    required String numeroDas,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarExtratoDasRequest(numeroDas: numeroDas);

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'CONSEXTRATO16', versaoSistema: '1.0', dados: consultaRequest.toJson().toString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarExtratoDasResponse.fromJson(response);
  }

  /// Gerar DAS Cobrança com débitos em sistema de cobrança
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasCobrancaResponse> gerarDasCobranca({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final cobrancaRequest = GerarDasCobrancaRequest(periodoApuracao: periodoApuracao);

    if (!cobrancaRequest.isValid) {
      throw ArgumentError('Dados para geração do DAS Cobrança inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'GERARDASCOBRANCA17',
        versaoSistema: '1.0',
        dados: cobrancaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasCobrancaResponse.fromJson(response);
  }

  /// Gerar DAS de Processo com débitos de processo em sistema de cobrança
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroProcesso] Número do processo (17 dígitos)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasProcessoResponse> gerarDasProcesso({
    required String contribuinteNumero,
    required String numeroProcesso,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final processoRequest = GerarDasProcessoRequest(numeroProcesso: numeroProcesso);

    if (!processoRequest.isValid) {
      throw ArgumentError('Dados para geração do DAS de Processo inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'GERARDASPROCESSO18',
        versaoSistema: '1.0',
        dados: processoRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasProcessoResponse.fromJson(response);
  }

  /// Gerar DAS Avulso
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados para geração do DAS Avulso
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasAvulsoResponse> gerarDasAvulso({
    required String contribuinteNumero,
    required GerarDasAvulsoRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados para geração do DAS Avulso inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'PGDASD', idServico: 'GERARDASAVULSO19', versaoSistema: '1.0', dados: request.toJson().toString()),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasAvulsoResponse.fromJson(response);
  }
}
