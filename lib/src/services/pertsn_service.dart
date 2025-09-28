import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/consultar_pedidos_response.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/consultar_parcelamento_response.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/consultar_parcelas_response.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/consultar_detalhes_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/emitir_das_response.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/pertsn_validations.dart';
import 'package:serpro_integra_contador_api/src/models/pertsn/pertsn_errors.dart';

/// Serviço para integração com o sistema PERTSN (Parcelamento do Simples Nacional)
///
/// Este serviço permite:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos específicos
/// - Consultar parcelas disponíveis para impressão
/// - Consultar detalhes de pagamento
/// - Emitir DAS para parcelas
class PertsnService {
  final ApiClient _apiClient;

  PertsnService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento do tipo PERTSN
  ///
  /// Retorna uma lista de todos os parcelamentos ativos do contribuinte.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await pertsnService.consultarPedidos();
  /// if (response.sucesso) {
  ///   final parcelamentos = response.dadosParsed?.parcelamentos ?? [];
  ///   for (final parcela in parcelamentos) {
  ///     print('Parcelamento ${parcela.numero}: ${parcela.situacao}');
  ///   }
  /// }
  /// ```
  Future<ConsultarPedidosResponse> consultarPedidos() async {
    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'PERTSN', idServico: 'PEDIDOSPARC183', versaoSistema: '1.0', dados: ''),
    );

    final response = await _apiClient.post('/pertsn/Consultar', request);
    return ConsultarPedidosResponse.fromJson(response);
  }

  /// Consulta informações detalhadas de um parcelamento específico
  ///
  /// [numeroParcelamento] - Número do parcelamento a ser consultado
  ///
  /// Retorna informações completas sobre o parcelamento, incluindo:
  /// - Consolidação original
  /// - Alterações de dívida
  /// - Demonstrativo de pagamentos
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await pertsnService.consultarParcelamento(9102);
  /// if (response.sucesso) {
  ///   final parcelamento = response.dadosParsed;
  ///   print('Situação: ${parcelamento?.situacao}');
  ///   print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
  /// }
  /// ```
  Future<ConsultarParcelamentoResponse> consultarParcelamento(int numeroParcelamento) async {
    // Validação do parâmetro
    final validacao = PertsnValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacao != null) {
      throw ArgumentError(validacao);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PERTSN',
        idServico: 'OBTERPARC184',
        versaoSistema: '1.0',
        dados: '{"numeroParcelamento": $numeroParcelamento}',
      ),
    );

    final response = await _apiClient.post('/pertsn/Consultar', request);
    return ConsultarParcelamentoResponse.fromJson(response);
  }

  /// Consulta as parcelas disponíveis para impressão
  ///
  /// Retorna uma lista de parcelas disponíveis para emissão de DAS.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await pertsnService.consultarParcelas();
  /// if (response.sucesso) {
  ///   final parcelas = response.dadosParsed?.listaParcelas ?? [];
  ///   for (final parcela in parcelas) {
  ///     print('Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
  ///   }
  /// }
  /// ```
  Future<ConsultarParcelasResponse> consultarParcelas() async {
    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'PERTSN', idServico: 'PARCELASPARAGERAR182', versaoSistema: '1.0', dados: ''),
    );

    final response = await _apiClient.post('/pertsn/Consultar', request);
    return ConsultarParcelasResponse.fromJson(response);
  }

  /// Consulta os detalhes de pagamento de uma parcela específica
  ///
  /// [numeroParcelamento] - Número do parcelamento
  /// [anoMesParcela] - Ano/mês da parcela no formato AAAAMM
  ///
  /// Retorna informações detalhadas sobre o pagamento da parcela, incluindo:
  /// - Dados do DAS
  /// - Detalhes dos débitos pagos
  /// - Informações de arrecadação
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await pertsnService.consultarDetalhesPagamento(9102, 201806);
  /// if (response.sucesso) {
  ///   final detalhes = response.dadosParsed;
  ///   print('DAS: ${detalhes?.numeroDas}');
  ///   print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
  /// }
  /// ```
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(int numeroParcelamento, int anoMesParcela) async {
    // Validação dos parâmetros
    final validacaoParcelamento = PertsnValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacaoParcelamento != null) {
      throw ArgumentError(validacaoParcelamento);
    }

    final validacaoAnoMes = PertsnValidations.validarAnoMesParcela(anoMesParcela);
    if (validacaoAnoMes != null) {
      throw ArgumentError(validacaoAnoMes);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PERTSN',
        idServico: 'DETPAGTOPARC185',
        versaoSistema: '1.0',
        dados: '{"numeroParcelamento": $numeroParcelamento, "anoMesParcela": $anoMesParcela}',
      ),
    );

    final response = await _apiClient.post('/pertsn/Consultar', request);
    return ConsultarDetalhesPagamentoResponse.fromJson(response);
  }

  /// Emite o DAS (Documento de Arrecadação do Simples Nacional) para uma parcela específica
  ///
  /// [parcelaParaEmitir] - Parcela para emitir no formato AAAAMM
  ///
  /// Retorna o DAS em formato PDF (Base64) para impressão e pagamento.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await pertsnService.emitirDas(202301);
  /// if (response.sucesso && response.pdfGeradoComSucesso) {
  ///   final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  ///   // Salvar ou exibir o PDF
  ///   print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
  /// }
  /// ```
  Future<EmitirDasResponse> emitirDas(int parcelaParaEmitir) async {
    // Validação dos parâmetros
    final validacaoParcela = PertsnValidations.validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacaoParcela != null) {
      throw ArgumentError(validacaoParcela);
    }

    // Validação adicional: prazo para emissão
    final validacaoPrazo = PertsnValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
    if (validacaoPrazo != null) {
      throw ArgumentError(validacaoPrazo);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PERTSN',
        idServico: 'GERARDAS181',
        versaoSistema: '1.0',
        dados: '{"parcelaParaEmitir": $parcelaParaEmitir}',
      ),
    );

    final response = await _apiClient.post('/pertsn/Emitir', request);
    return EmitirDasResponse.fromJson(response);
  }

  /// Analisa erros específicos do PERTSN e retorna informações detalhadas
  PertsnErrorAnalysis analyzeError(String codigo, String mensagem) {
    return PertsnErrors.analyzeError(codigo, mensagem);
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  bool isKnownError(String codigo) {
    return PertsnErrors.isKnownError(codigo);
  }

  /// Obtém informações sobre um erro específico do PERTSN
  PertsnErrorInfo? getErrorInfo(String codigo) {
    return PertsnErrors.getErrorInfo(codigo);
  }

  /// Obtém todos os erros de aviso do PERTSN
  List<PertsnErrorInfo> getAvisos() {
    return PertsnErrors.getAvisos();
  }

  /// Obtém todos os erros de entrada incorreta do PERTSN
  List<PertsnErrorInfo> getEntradasIncorretas() {
    return PertsnErrors.getEntradasIncorretas();
  }

  /// Obtém todos os erros gerais do PERTSN
  List<PertsnErrorInfo> getErros() {
    return PertsnErrors.getErros();
  }

  /// Obtém todos os sucessos do PERTSN
  List<PertsnErrorInfo> getSucessos() {
    return PertsnErrors.getSucessos();
  }

  /// Valida um número de parcelamento
  String? validarNumeroParcelamento(int? numeroParcelamento) {
    return PertsnValidations.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida um ano/mês de parcela
  String? validarAnoMesParcela(int? anoMesParcela) {
    return PertsnValidations.validarAnoMesParcela(anoMesParcela);
  }

  /// Valida uma parcela para emissão
  String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    return PertsnValidations.validarParcelaParaEmitir(parcelaParaEmitir);
  }

  /// Valida o prazo para emissão de uma parcela
  String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    return PertsnValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
  }

  /// Valida o CNPJ do contribuinte
  String? validarCnpjContribuinte(String? cnpj) {
    return PertsnValidations.validarCnpjContribuinte(cnpj);
  }

  /// Valida o tipo de contribuinte
  String? validarTipoContribuinte(int? tipoContribuinte) {
    return PertsnValidations.validarTipoContribuinte(tipoContribuinte);
  }
}
