import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'model/gerar_das_response.dart';
import 'model/gerar_das_codigo_barras_response.dart';
import 'model/atualizar_beneficio_response.dart';
import 'model/consultar_divida_ativa_response.dart';
import 'model/pgmei_requests.dart';
import '../../util/validacoes_utils.dart';
import 'model/pgmei_validations.dart';

/// **Serviço:** PGMEI (Programa Gerador do DAS para o MEI)
///
/// Serviço para geração e consulta de DAS (Documento de Arrecadação do Simples Nacional)
/// para contribuintes Microempreendedores Individuais (MEI).
///
/// **Este serviço permite:**
/// - GERARDASPDF21: Gerar DAS com PDF completo
/// - GERARDASCODBARRA22: Gerar DAS apenas com código de barras
/// - ATUBENEFICIO23: Atualizar informações de benefícios
/// - DIVIDAATIVA24: Consultar dívida ativa do MEI
///
/// **Documentação oficial:** `.cursor/rules/pgmei.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final pgmeiService = PgmeiService(apiClient);
///
/// // Gerar DAS com PDF
/// final das = await pgmeiService.gerarDas(
///   cnpj: '12345678000190',
///   periodoApuracao: '202403',
/// );
/// print('PDF: ${das.pdfBase64}');
/// ```
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
    ValidacoesUtils.validateCNPJ(cnpj);
    final validacaoPeriodo = PgmeiValidations.validarPeriodoApuracao(
      periodoApuracao,
    );
    if (validacaoPeriodo != null) throw ArgumentError(validacaoPeriodo);
    if (dataConsolidacao != null) {
      final validacao = PgmeiValidations.validarDataConsolidacao(
        dataConsolidacao,
      );
      if (validacao != null) throw ArgumentError(validacao);
    }

    // Criação dos dados de entrada
    final requestData = GerarDasRequest(
      periodoApuracao: periodoApuracao,
      dataConsolidacao: dataConsolidacao,
    );

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'GERARDASPDF21',
        versaoSistema: '1.0',
        dados: requestData.toJsonString(),
      ),
    );

    // Chamada à API
    final response = await _apiClient.post(
      '/Emitir',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

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
    ValidacoesUtils.validateCNPJ(cnpj);
    final validacaoPeriodo = PgmeiValidations.validarPeriodoApuracao(
      periodoApuracao,
    );
    if (validacaoPeriodo != null) throw ArgumentError(validacaoPeriodo);
    if (dataConsolidacao != null) {
      final validacao = PgmeiValidations.validarDataConsolidacao(
        dataConsolidacao,
      );
      if (validacao != null) throw ArgumentError(validacao);
    }

    // Criação dos dados de entrada
    final requestData = GerarDasRequest(
      periodoApuracao: periodoApuracao,
      dataConsolidacao: dataConsolidacao,
    );

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'GERARDASCODBARRA22',
        versaoSistema: '1.0',
        dados: requestData.toJsonString(),
      ),
    );

    // Chamada à API
    final response = await _apiClient.post(
      '/Emitir',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

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
    ValidacoesUtils.validateCNPJ(cnpj);
    // Valida ano (1900-2099)
    if (anoCalendario < 1900 || anoCalendario > 2099) {
      throw ArgumentError('Ano calendário deve estar entre 1900 e 2099');
    }

    // Verifica se não é ano muito futuro
    final anoAtual = DateTime.now().year;
    if (anoCalendario > anoAtual + 1) {
      print('Aviso: Ano calendário é futuro ($anoCalendario)');
    }
    final validacaoBeneficios = PgmeiValidations.validarInfoBeneficio(
      beneficios,
    );
    if (validacaoBeneficios != null) throw ArgumentError(validacaoBeneficios);

    // Criação dos dados de entrada
    final requestData = AtualizarBeneficioRequest(
      anoCalendario: anoCalendario,
      infoBeneficio: beneficios,
    );

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'ATUBENEFICIO23',
        versaoSistema: '1.0',
        dados: requestData.toJsonString(),
      ),
    );

    // Chamada à API
    final response = await _apiClient.post(
      '/Emitir',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

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
    ValidacoesUtils.validateCNPJ(cnpj);

    if (anoCalendario.isEmpty) {
      throw ArgumentError('Ano calendário não pode estar vazio');
    }

    // Verifica se tem exatamente 4 caracteres
    if (anoCalendario.length != 4) {
      throw ArgumentError('Ano calendário deve ter formato AAAA');
    }

    // Verifica se são apenas números
    if (!RegExp(r'^\d{4}$').hasMatch(anoCalendario)) {
      throw ArgumentError(
        'Ano calendário deve conter apenas números no formato AAAA',
      );
    }

    // Valida ano (1900-2099)
    final ano = int.parse(anoCalendario);
    if (ano < 1900 || ano > 2099) {
      throw ArgumentError('Ano calendário deve estar entre 1900 e 2099');
    }

    // Verifica se não é ano muito futuro
    final anoAtual = DateTime.now().year;
    if (ano > anoAtual + 1) {
      print('Aviso: Ano calendário é futuro ($anoCalendario)');
    }

    // Criação dos dados de entrada
    final requestData = ConsultarDividaAtivaRequest(
      anoCalendario: anoCalendario,
    );

    // Montagem da requisição
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGMEI',
        idServico: 'DIVIDAATIVA24',
        versaoSistema: '1.0',
        dados: requestData.toJsonString(),
      ),
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
    final beneficios = [
      InfoBeneficio(
        periodoApuracao: periodoApuracao,
        indicadorBeneficio: indicadorBeneficio,
      ),
    ];

    return atualizarBeneficio(
      cnpj: cnpj,
      anoCalendario: anoCalendario,
      beneficios: beneficios,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }
}
