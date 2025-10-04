import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/consultar_pedidos_response.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/consultar_parcelamento_response.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/consultar_parcelas_response.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/consultar_detalhes_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/emitir_das_response.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/relpsn_validations.dart';
import 'package:serpro_integra_contador_api/src/models/relpsn/relpsn_errors.dart';

/// Serviço para integração com o sistema RELPSN (Parcelamento do Simples Nacional)
///
/// Este serviço permite:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos específicos
/// - Consultar parcelas disponíveis
/// - Consultar detalhes de pagamento
/// - Emitir DAS para parcelas
class RelpsnService {
  final ApiClient _apiClient;

  RelpsnService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento do tipo PARCSN ESPECIAL
  ///
  /// Retorna uma lista de todos os parcelamentos ativos do contribuinte.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await relpsnService.consultarPedidos();
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
      pedidoDados: PedidoDados(idSistema: 'RELPSN', idServico: 'PEDIDOSPARC193', dados: ''),
    );

    final response = await _apiClient.post('/Consultar', request);
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
  /// final response = await relpsnService.consultarParcelamento(123456);
  /// if (response.sucesso) {
  ///   final parcelamento = response.dadosParsed;
  ///   print('Situação: ${parcelamento?.situacao}');
  ///   print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
  /// }
  /// ```
  Future<ConsultarParcelamentoResponse> consultarParcelamento(int numeroParcelamento) async {
    // Validação do parâmetro
    final validacao = RelpsnValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacao != null) {
      throw ArgumentError(validacao);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'RELPSN', idServico: 'OBTERPARC174', dados: numeroParcelamento.toString()),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarParcelamentoResponse.fromJson(response);
  }

  /// Consulta as parcelas disponíveis para um parcelamento específico
  ///
  /// [numeroParcelamento] - Número do parcelamento
  ///
  /// Retorna uma lista de parcelas disponíveis para emissão de DAS.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await relpsnService.consultarParcelas(123456);
  /// if (response.sucesso) {
  ///   final parcelas = response.dadosParsed?.listaParcelas ?? [];
  ///   for (final parcela in parcelas) {
  ///     print('Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
  ///   }
  /// }
  /// ```
  Future<ConsultarParcelasResponse> consultarParcelasParaImpressao() async {
    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'RELPSN', idServico: 'PARCELASPARAGERAR192', dados: ""),
    );

    final response = await _apiClient.post('/Consultar', request);
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
  /// final response = await relpsnService.consultarDetalhesPagamento(123456, 202401);
  /// if (response.sucesso) {
  ///   final detalhes = response.dadosParsed;
  ///   print('DAS: ${detalhes?.numeroDas}');
  ///   print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
  /// }
  /// ```
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(int numeroParcelamento, int anoMesParcela) async {
    // Validação dos parâmetros
    final validacaoParcelamento = RelpsnValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacaoParcelamento != null) {
      throw ArgumentError(validacaoParcelamento);
    }

    final validacaoAnoMes = RelpsnValidations.validarAnoMesParcela(anoMesParcela);
    if (validacaoAnoMes != null) {
      throw ArgumentError(validacaoAnoMes);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'RELPSN', idServico: 'DETPAGTOPARC195', dados: '$numeroParcelamento|$anoMesParcela'),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarDetalhesPagamentoResponse.fromJson(response);
  }

  /// Emite o DAS (Documento de Arrecadação do Simples Nacional) para uma parcela específica
  ///
  /// [numeroParcelamento] - Número do parcelamento
  /// [parcelaParaEmitir] - Parcela para emitir no formato AAAAMM
  ///
  /// Retorna o DAS em formato PDF (Base64) para impressão e pagamento.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await relpsnService.emitirDas(123456, 202401);
  /// if (response.sucesso && response.pdfGeradoComSucesso) {
  ///   final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  ///   // Salvar ou exibir o PDF
  ///   print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
  /// }
  /// ```
  Future<EmitirDasResponse> emitirDas(int parcelaParaEmitir) async {
    final validacaoParcela = RelpsnValidations.validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacaoParcela != null) {
      throw ArgumentError(validacaoParcela);
    }

    // Validação adicional: prazo para emissão
    final validacaoPrazo = RelpsnValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
    if (validacaoPrazo != null) {
      throw ArgumentError(validacaoPrazo);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'RELPSN', idServico: 'GERARDAS191', dados: '{"parcelaParaEmitir": $parcelaParaEmitir}'),
    );

    final response = await _apiClient.post('/Emitir', request);
    return EmitirDasResponse.fromJson(response);
  }

  /// Analisa erros específicos do RELPSN e retorna informações detalhadas
  ///
  /// [codigo] - Código do erro retornado pela API
  /// [mensagem] - Mensagem de erro retornada pela API
  ///
  /// Exemplo de uso:
  /// ```dart
  /// try {
  ///   final response = await relpsnService.consultarParcelamento(123456);
  /// } catch (e) {
  ///   if (e is RelpsnError) {
  ///     final analysis = relpsnService.analyzeError(e.codigo, e.mensagem);
  ///     print('Erro: ${analysis.summary}');
  ///     print('Ação recomendada: ${analysis.recommendedAction}');
  ///   }
  /// }
  /// ```
  RelpsnErrorAnalysis analyzeError(String codigo, String mensagem) {
    return RelpsnErrors.analyzeError(codigo, mensagem);
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  ///
  /// [codigo] - Código do erro a ser verificado
  ///
  /// Exemplo de uso:
  /// ```dart
  /// if (relpsnService.isKnownError('[Aviso-RELPSN-ER_E001]')) {
  ///   print('Erro conhecido do RELPSN');
  /// }
  /// ```
  bool isKnownError(String codigo) {
    return RelpsnErrors.isKnownError(codigo);
  }

  /// Obtém informações sobre um erro específico do RELPSN
  ///
  /// [codigo] - Código do erro
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final errorInfo = relpsnService.getErrorInfo('[Aviso-RELPSN-ER_E001]');
  /// if (errorInfo != null) {
  ///   print('Tipo: ${errorInfo.tipo}');
  ///   print('Mensagem: ${errorInfo.mensagem}');
  ///   print('Ação: ${errorInfo.acao}');
  /// }
  /// ```
  RelpsnErrorInfo? getErrorInfo(String codigo) {
    return RelpsnErrors.getErrorInfo(codigo);
  }

  /// Obtém todos os erros de aviso do RELPSN
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final avisos = relpsnService.getAvisos();
  /// for (final aviso in avisos) {
  ///   print('Aviso: ${aviso.codigo} - ${aviso.mensagem}');
  /// }
  /// ```
  List<RelpsnErrorInfo> getAvisos() {
    return RelpsnErrors.getAvisos();
  }

  /// Obtém todos os erros de entrada incorreta do RELPSN
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final errosEntrada = relpsnService.getEntradasIncorretas();
  /// for (final erro in errosEntrada) {
  ///   print('Erro de entrada: ${erro.codigo} - ${erro.mensagem}');
  /// }
  /// ```
  List<RelpsnErrorInfo> getEntradasIncorretas() {
    return RelpsnErrors.getEntradasIncorretas();
  }

  /// Obtém todos os erros gerais do RELPSN
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final erros = relpsnService.getErros();
  /// for (final erro in erros) {
  ///   print('Erro: ${erro.codigo} - ${erro.mensagem}');
  /// }
  /// ```
  List<RelpsnErrorInfo> getErros() {
    return RelpsnErrors.getErros();
  }

  /// Valida um número de parcelamento
  ///
  /// [numeroParcelamento] - Número do parcelamento a ser validado
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final validacao = relpsnService.validarNumeroParcelamento(123456);
  /// if (validacao != null) {
  ///   print('Erro de validação: $validacao');
  /// }
  /// ```
  String? validarNumeroParcelamento(int? numeroParcelamento) {
    return RelpsnValidations.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida um ano/mês de parcela
  ///
  /// [anoMesParcela] - Ano/mês da parcela no formato AAAAMM
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final validacao = relpsnService.validarAnoMesParcela(202401);
  /// if (validacao != null) {
  ///   print('Erro de validação: $validacao');
  /// }
  /// ```
  String? validarAnoMesParcela(int? anoMesParcela) {
    return RelpsnValidations.validarAnoMesParcela(anoMesParcela);
  }

  /// Valida uma parcela para emissão
  ///
  /// [parcelaParaEmitir] - Parcela para emitir no formato AAAAMM
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final validacao = relpsnService.validarParcelaParaEmitir(202401);
  /// if (validacao != null) {
  ///   print('Erro de validação: $validacao');
  /// }
  /// ```
  String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    return RelpsnValidations.validarParcelaParaEmitir(parcelaParaEmitir);
  }

  /// Valida o prazo para emissão de uma parcela
  ///
  /// [parcelaParaEmitir] - Parcela para emitir no formato AAAAMM
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final validacao = relpsnService.validarPrazoEmissaoParcela(202401);
  /// if (validacao != null) {
  ///   print('Erro de prazo: $validacao');
  /// }
  /// ```
  String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    return RelpsnValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
  }
}
