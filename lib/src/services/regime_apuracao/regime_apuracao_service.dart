import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/efetuar_opcao_request.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/efetuar_opcao_response.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/consultar_anos_response.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/consultar_opcao_request.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/consultar_opcao_response.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/consultar_resolucao_request.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/consultar_resolucao_response.dart';
import 'package:serpro_integra_contador_api/src/services/regime_apuracao/model/regime_apuracao_enums.dart';

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
  /// [anoOpcao] Ano da opção (YYYY)
  /// [tipoRegime] Tipo do regime (TipoRegime.competencia ou TipoRegime.caixa)
  /// [deAcordoResolucao] Confirmação obrigatória para efetivar a opção
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<EfetuarOpcaoRegimeResponse> efetuarOpcaoRegime({
    required String contribuinteNumero,
    required int anoOpcao,
    required TipoRegime tipoRegime,
    required bool deAcordoResolucao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return efetuarOpcaoRegimeWithRequest(
      contribuinteNumero: contribuinteNumero,
      request: EfetuarOpcaoRegimeRequest(
        anoOpcao: anoOpcao,
        tipoRegime: tipoRegime.codigo,
        descritivoRegime: tipoRegime.descricao,
        deAcordoResolucao: deAcordoResolucao,
      ),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Efetuar opção pelo regime de apuração de receitas (versão com objeto request)
  ///
  /// Este serviço permite que empresas optantes pelo Simples Nacional
  /// efetuem a opção anual pelo regime de apuração (Competência ou Caixa).
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados da opção pelo regime de apuração
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<EfetuarOpcaoRegimeResponse> efetuarOpcaoRegimeWithRequest({
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
}
