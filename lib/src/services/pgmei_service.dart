import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import '../models/pgmei/gerar_das_response.dart';
import '../models/pgmei/gerar_das_codigo_barras_response.dart';
import '../models/pgmei/atualizar_beneficio_response.dart';
import '../models/pgmei/consultar_divida_ativa_response.dart';
import '../models/pgmei/pgmei_requests.dart';
import '../util/document_utils.dart';
import '../util/pgmei_validator.dart';

/// Serviço para integração com PGMEI (Programa Gerador do DAS para o MEI)
///
/// Oferece funcionalidades para:
/// - GERARDASPDF21: Gerar DAS com PDF completa
/// - GERARDASCODBARRA22: Gerar DAS apenas com código de barras
/// - ATUBENEFICIO23: Atualizar benefícios
/// - DIVIDAATIVA24: Consultar dívida ativa
class PgmeiService {
  final ApiClient _apiClient;

  PgmeiService(this._apiClient);

  /// GERARDASPDF21 - Gerar DAS com PDF completo
  ///
  /// Gera o Documento de Arrecadação do Simples Nacional com PDF completo
  /// para contribuintes MEI (Microempreendedor Individual)
  ///
  /// [cnpj] CNPJ do contribuinte MEI
  /// [periodoApuracao] Período no formato AAAAMM
  /// [dataConsolidacao] Data de consolidação no formato AAAAMMDD (opcional)
  /// [contratanteNumero] CNPJ da empresa contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor (opcional)
  Future<GerarDasResponse> gerarDas({
    required String cnpj,
    required String periodoApuracao,
    String? dataConsolidacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validações de entrada
    DocumentUtils.validateCNPJ(cnpj);
    PgmeiValidator.validatePeriodoApuracao(periodoApuracao);
    if (dataConsolidacao != null) {
      PgmeiValidator.validateDataConsolidacao(dataConsolidacao);
    }

    // Criação dos dados de entrada
    final requestData = GerarDasRequest(periodoApuracao: periodoApuracao, dataConsolidacao: dataConsolidacao);

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'GERARDASPDF21', versaoSistema: '1.0', dados: requestData.toJsonString()),
    );

    // Chamada à API
    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

    return GerarDasResponse.fromJson(response);
  }

  /// GERARDASCODBARRA22 - Gerar DAS apenas com código de barras
  ///
  /// Gera o Documento de Arrecadação do Simples Nacional contendo apenas
  /// código de barras, sem PDF, para contribuintes MEI
  ///
  /// [cnpj] CNPJ do contribuinte MEI
  /// [periodoApuracao] Período no formato AAAAMM
  /// [dataConsolidacao] Data de consolidação no formato AAAAMMDD (opcional)
  /// [contratanteNumero] CNPJ da empresa contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor (opcional)
  Future<GerarDasCodigoBarrasResponse> gerarDasCodigoBarras({
    required String cnpj,
    required String periodoApuracao,
    String? dataConsolidacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validações de entrada
    DocumentUtils.validateCNPJ(cnpj);
    PgmeiValidator.validatePeriodoApuracao(periodoApuracao);
    if (dataConsolidacao != null) {
      PgmeiValidator.validateDataConsolidacao(dataConsolidacao);
    }

    // Criação dos dados de entrada
    final requestData = GerarDasRequest(periodoApuracao: periodoApuracao, dataConsolidacao: dataConsolidacao);

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'GERARDASCODBARRA22', versaoSistema: '1.0', dados: requestData.toJsonString()),
    );

    // Chamada à API
    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

    return GerarDasCodigoBarrasResponse.fromJson(response);
  }

  /// ATUBENEFICIO23 - Atualizar Benefício
  ///
  /// Permite registrar benefício para determinada apuração do PGMEI
  ///
  /// [cnpj] CNPJ do contribuinte MEI
  /// [anoCalendario] Ano calendário no formato AAAA
  /// [beneficios] Lista de informações de benefícios por período
  /// [contratanteNumero] CNPJ da empresa contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor (opcional)
  Future<AtualizarBeneficioResponse> atualizarBeneficio({
    required String cnpj,
    required int anoCalendario,
    required List<InfoBeneficio> beneficios,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validações de entrada
    DocumentUtils.validateCNPJ(cnpj);
    PgmeiValidator.validateAnoCalendarioInt(anoCalendario);
    PgmeiValidator.validateInfoBeneficio(beneficios);

    // Criação dos dados de entrada
    final requestData = AtualizarBeneficioRequest(anoCalendario: anoCalendario, infoBeneficio: beneficios);

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'ATUBENEFICIO23', versaoSistema: '1.0', dados: requestData.toJsonString()),
    );

    // Chamada à API
    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

    return AtualizarBeneficioResponse.fromJson(response);
  }

  /// DIVIDAATIVA24 - Consultar Dívida Ativa
  ///
  /// Consulta se o contribuinte está em dívida ativa
  ///
  /// [cnpj] CNPJ do contribuinte MEI
  /// [anoCalendario] Ano calendário no formato AAAA
  /// [contratanteNumero] CNPJ da empresa contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor (opcional)
  Future<ConsultarDividaAtivaResponse> consultarDividaAtiva({
    required String cnpj,
    required String anoCalendario,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validações de entrada
    DocumentUtils.validateCNPJ(cnpj);
    PgmeiValidator.validateAnoCalendario(anoCalendario);

    // Criação dos dados de entrada
    final requestData = ConsultarDividaAtivaRequest(anoCalendario: anoCalendario);

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PGMEI', idServico: 'DIVIDAATIVA24', versaoSistema: '1.0', dados: requestData.toJsonString()),
    );

    // Chamada à API
    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarDividaAtivaResponse.fromJson(response);
  }

  // ============================
  // MÉTODOS DE CONVENIÊNCIA
  // ============================

  /// Wrapper simplificado para atualizar benefício com período único
  ///
  /// Para casos simples onde se atualiza apenas um período
  Future<AtualizarBeneficioResponse> atualizarBeneficioPeriodoUnico({
    required String cnpj,
    required int anoCalendario,
    required String periodoApuracao,
    required bool indicadorBeneficio,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final beneficios = [InfoBeneficio(periodoApuracao: periodoApuracao, indicadorBeneficio: indicadorBeneficio)];

    return atualizarBeneficio(
      cnpj: cnpj,
      anoCalendario: anoCalendario,
      beneficios: beneficios,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }
}
