import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/relpmei/relpmei_requests.dart';
import 'package:serpro_integra_contador_api/src/models/relpmei/relpmei_responses.dart';

/// Serviço para integração com RELPMEI (Regime Especial de Regularização Tributária para o Microempreendedor Individual)
///
/// Implementa todos os serviços disponíveis do Integra RELPMEI:
/// - Consultar Pedidos de Parcelamento (PEDIDOSPARC233)
/// - Consultar Parcelamento Específico (OBTERPARC234)
/// - Consultar Parcelas para Impressão (PARCELASPARAGERAR232)
/// - Consultar Detalhes de Pagamento (DETPAGTOPARC235)
/// - Emitir DAS (GERARDAS231)
class RelpmeiService {
  final ApiClient _apiClient;

  RelpmeiService(this._apiClient);

  /// Consultar Pedidos de Parcelamento (PEDIDOSPARC233)
  ///
  /// Este serviço retorna uma lista contendo todos os parcelamentos
  /// do tipo RELPMEI para um contribuinte.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte (obrigatório para RELPMEI)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarPedidosRelpmeiResponse> consultarPedidos({
    required String contribuinteNumero,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarPedidosWithRequest(
      contribuinteNumero: contribuinteNumero,
      request: ConsultarPedidosRelpmeiRequest(),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Versão com request específico para consultar pedidos de parcelamento
  Future<ConsultarPedidosRelpmeiResponse> consultarPedidosWithRequest({
    required String contribuinteNumero,
    required ConsultarPedidosRelpmeiRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'PEDIDOSPARC233', versaoSistema: '1.0', dados: request.toJsonString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarPedidosRelpmeiResponse.fromJson(response);
  }

  /// Consultar Parcelamento Específico (OBTERPARC234)
  ///
  /// Esta consulta retorna informações de um parcelamento específico
  /// na modalidade RELPMEI.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroParcelamento] Número do parcelamento a ser consultado
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional)
  Future<ConsultarParcelamentoRelpmeiResponse> consultarParcelamento({
    required String contribuinteNumero,
    required int numeroParcelamento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarParcelamentoWithRequest(
      contribuinteNumero: contribuinteNumero,
      request: ConsultarParcelamentoRelpmeiRequest(numeroParcelamento: numeroParcelamento),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Versão com request específico para consultar parcelamento específico
  Future<ConsultarParcelamentoRelpmeiResponse> consultarParcelamentoWithRequest({
    required String contribuinteNumero,
    required ConsultarParcelamentoRelpmeiRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'OBTERPARC234', versaoSistema: '1.0', dados: request.toJsonString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarParcelamentoRelpmeiResponse.fromJson(response);
  }

  /// Consultar Parcelas para Impressão (PARCELASPARAGERAR232)
  ///
  /// Esta consulta retorna parcelas disponíveis para impressão do DAS
  /// na modalidade RELPMEI.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional)
  Future<ConsultarParcelasImpressaoRelpmeiResponse> consultarParcelasImpressao({
    required String contribuinteNumero,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarParcelasImpressaoWithRequest(
      contribuinteNumero: contribuinteNumero,
      request: ConsultarParcelasImpressaoRelpmeiRequest(),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Versão com request específico para consultar parcelas para impressão
  Future<ConsultarParcelasImpressaoRelpmeiResponse> consultarParcelasImpressaoWithRequest({
    required String contribuinteNumero,
    required ConsultarParcelasImpressaoRelpmeiRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'PARCELASPARAGERAR232', versaoSistema: '1.0', dados: request.toJsonString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarParcelasImpressaoRelpmeiResponse.fromJson(response);
  }

  /// Consultar Detalhes de Pagamento (DETPAGTOPARC235)
  ///
  /// Esta consulta retorna informações detalhadas de pagamento
  /// de uma parcela na modalidade RELPMEI.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroParcelamento] Número do parcelamento
  /// [anoMesParcela] Mês da parcela paga (AAAAMM)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional)
  Future<ConsultarDetalhesPagamentoRelpmeiResponse> consultarDetalhesPagamento({
    required String contribuinteNumero,
    required int numeroParcelamento,
    required int anoMesParcela,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return consultarDetalhesPagamentoWithRequest(
      contribuinteNumero: contribuinteNumero,
      request: ConsultarDetalhesPagamentoRelpmeiRequest(numeroParcelamento: numeroParcelamento, anoMesParcela: anoMesParcela),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Versão com request específico para consultar detalhes de pagamento
  Future<ConsultarDetalhesPagamentoRelpmeiResponse> consultarDetalhesPagamentoWithRequest({
    required String contribuinteNumero,
    required ConsultarDetalhesPagamentoRelpmeiRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'DETPAGTOPARC235', versaoSistema: '1.0', dados: request.toJsonString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarDetalhesPagamentoRelpmeiResponse.fromJson(response);
  }

  /// Emitir DAS (GERARDAS231)
  ///
  /// Este serviço realiza a emissão de DAS para a modalidade RELPMEI.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [parcelaParaEmitir] Período da parcela para emissão do DAS (AAAAMM)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional)
  Future<EmitirDasRelpmeiResponse> emitirDas({
    required String contribuinteNumero,
    required int parcelaParaEmitir,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return emitirDasWithRequest(
      contribuinteNumero: contribuinteNumero,
      request: EmitirDasRelpmeiRequest(parcelaParaEmitir: parcelaParaEmitir),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Versão com request específico para emitir DAS
  Future<EmitirDasRelpmeiResponse> emitirDasWithRequest({
    required String contribuinteNumero,
    required EmitirDasRelpmeiRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'RELPMEI', idServico: 'GERARDAS231', versaoSistema: '1.0', dados: request.toJsonString()),
    );

    // Nota: DAS usa endpoint Emitir, não Consultar
    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return EmitirDasRelpmeiResponse.fromJson(response);
  }
}
