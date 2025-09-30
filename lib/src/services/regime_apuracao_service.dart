import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/efetuar_opcao_request.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/efetuar_opcao_response.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/consultar_anos_response.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/consultar_opcao_request.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/consultar_opcao_response.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/consultar_resolucao_request.dart';
import 'package:serpro_integra_contador_api/src/models/regime_apuracao/consultar_resolucao_response.dart';

/// Serviço para integração com Regime de Apuração do Simples Nacional
///
/// Implementa todos os serviços disponíveis do Integra REGIMEAPURACAO:
/// - Efetuar Opção pelo Regime de Apuração (EFETUAROPCAOREGIME101)
/// - Consultar Anos Calendários (CONSULTARANOSCALENDARIOS102)
/// - Consultar Opção pelo Regime de Apuração (CONSULTAROPCAOREGIME103)
/// - Consultar Resolução para o Regime de Caixa (CONSULTARRESOLUCAO104)
class RegimeApuracaoService {
  final ApiClient _apiClient;

  RegimeApuracaoService(this._apiClient);

  /// Efetuar opção pelo regime de apuração de receitas
  ///
  /// Este serviço permite que empresas optantes pelo Simples Nacional
  /// efetuem a opção anual pelo regime de apuração (Competência ou Caixa).
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da opção pelo regime de apuração
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<EfetuarOpcaoRegimeResponse> efetuarOpcaoRegime({
    required String contribuinteNumero,
    required EfetuarOpcaoRegimeRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da opção pelo regime inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'REGIMEAPURACAO',
        idServico: 'EFETUAROPCAOREGIME101',
        versaoSistema: '1.0',
        dados: request.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Declarar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return EfetuarOpcaoRegimeResponse.fromJson(response);
  }

  /// Consultar todas as opções pelo Regime de Apuração de Receitas efetivadas
  ///
  /// Este serviço retorna uma lista de todos os anos calendários com
  /// opções de regime efetivadas para o contribuinte.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarAnosCalendariosResponse> consultarAnosCalendarios({
    required String contribuinteNumero,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'REGIMEAPURACAO',
        idServico: 'CONSULTARANOSCALENDARIOS102',
        versaoSistema: '1.0',
        dados: '', // Este serviço não requer parâmetros
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarAnosCalendariosResponse.fromJson(response);
  }

  /// Consultar a opção pelo regime de apuração de receitas a partir de um ano calendário
  ///
  /// Este serviço permite consultar informações detalhadas sobre uma opção
  /// de regime específica para um ano calendário.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da consulta por ano calendário
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarOpcaoRegimeResponse> consultarOpcaoRegime({
    required String contribuinteNumero,
    required ConsultarOpcaoRegimeRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'REGIMEAPURACAO',
        idServico: 'CONSULTAROPCAOREGIME103',
        versaoSistema: '1.0',
        dados: request.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarOpcaoRegimeResponse.fromJson(response);
  }

  /// Consultar a resolução para o regime de Caixa
  ///
  /// Este serviço retorna o texto da resolução específica para o regime de caixa,
  /// fornecendo a base legal para a opção.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da consulta da resolução
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarResolucaoResponse> consultarResolucao({
    required String contribuinteNumero,
    required ConsultarResolucaoRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados da consulta da resolução inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'REGIMEAPURACAO',
        idServico: 'CONSULTARRESOLUCAO104',
        versaoSistema: '1.0',
        dados: request.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarResolucaoResponse.fromJson(response);
  }

  // Métodos de conveniência

  /// Efetuar opção pelo regime de competência
  ///
  /// Método de conveniência para efetuar opção pelo regime de competência
  Future<EfetuarOpcaoRegimeResponse> efetuarOpcaoCompetencia({
    required String contribuinteNumero,
    required int anoOpcao,
    bool deAcordoResolucao = true,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EfetuarOpcaoRegimeRequest.competencia(anoOpcao: anoOpcao, deAcordoResolucao: deAcordoResolucao);

    return efetuarOpcaoRegime(
      contribuinteNumero: contribuinteNumero,
      request: request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Efetuar opção pelo regime de caixa
  ///
  /// Método de conveniência para efetuar opção pelo regime de caixa
  Future<EfetuarOpcaoRegimeResponse> efetuarOpcaoCaixa({
    required String contribuinteNumero,
    required int anoOpcao,
    bool deAcordoResolucao = true,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EfetuarOpcaoRegimeRequest.caixa(anoOpcao: anoOpcao, deAcordoResolucao: deAcordoResolucao);

    return efetuarOpcaoRegime(
      contribuinteNumero: contribuinteNumero,
      request: request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consultar opção de regime por ano (método de conveniência)
  ///
  /// Método de conveniência para consultar opção de regime por ano
  Future<ConsultarOpcaoRegimeResponse> consultarOpcaoPorAno({
    required String contribuinteNumero,
    required int anoCalendario,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ConsultarOpcaoRegimeRequest(anoCalendario: anoCalendario);

    return consultarOpcaoRegime(
      contribuinteNumero: contribuinteNumero,
      request: request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consultar resolução por ano (método de conveniência)
  ///
  /// Método de conveniência para consultar resolução por ano
  Future<ConsultarResolucaoResponse> consultarResolucaoPorAno({
    required String contribuinteNumero,
    required int anoCalendario,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ConsultarResolucaoRequest(anoCalendario: anoCalendario);

    return consultarResolucao(
      contribuinteNumero: contribuinteNumero,
      request: request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }
}
