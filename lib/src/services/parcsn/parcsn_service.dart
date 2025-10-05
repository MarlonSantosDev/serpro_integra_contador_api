import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/consultar_pedidos_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/consultar_parcelamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/consultar_detalhes_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/consultar_parcelas_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/emitir_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/parcsn_validations.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn/model/parcsn_errors.dart';

/// Serviço para integração com o sistema PARCSN (Parcelamento do Simples Nacional)
///
/// Este serviço permite:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos específicos
/// - Consultar parcelas disponíveis para impressão
/// - Consultar detalhes de pagamento
/// - Emitir DAS para parcelas
class ParcsnService {
  final ApiClient _apiClient;

  ParcsnService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento do tipo PARCSN ORDINÁRIO
  ///
  /// Retorna uma lista de todos os parcelamentos do contribuinte.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcsnService.consultarPedidos();
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
      pedidoDados: PedidoDados(idSistema: 'PARCSN', idServico: 'PEDIDOSPARC163', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcsnService.consultarParcelamento(1);
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
        idSistema: 'PARCSN',
        idServico: 'OBTERPARC164',
        versaoSistema: '1.0',
        dados: '{"numeroParcelamento": $numeroParcelamento}',
      ),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarParcelamentoResponse.fromJson(response);
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
  /// final response = await parcsnService.consultarDetalhesPagamento(1, 201612);
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
        idSistema: 'PARCSN',
        idServico: 'DETPAGTOPARC165',
        versaoSistema: '1.0',
        dados: '{"numeroParcelamento": $numeroParcelamento, "anoMesParcela": $anoMesParcela}',
      ),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarDetalhesPagamentoResponse.fromJson(response);
  }

  /// Consulta as parcelas disponíveis para impressão de DAS
  ///
  /// Retorna uma lista de parcelas disponíveis para emissão de DAS.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcsnService.consultarParcelas();
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
      pedidoDados: PedidoDados(idSistema: 'PARCSN', idServico: 'PARCELASPARAGERAR162', versaoSistema: '1.0', dados: ''),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarParcelasResponse.fromJson(response);
  }

  /// Emite o DAS (Documento de Arrecadação do Simples Nacional) para uma parcela específica
  ///
  /// [parcelaParaEmitir] - Parcela para emitir no formato AAAAMM
  ///
  /// Retorna o DAS em formato PDF (Base64) para impressão e pagamento.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcsnService.emitirDas(202306);
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
        idSistema: 'PARCSN',
        idServico: 'GERARDAS161',
        versaoSistema: '1.0',
        dados: '{"parcelaParaEmitir": $parcelaParaEmitir}',
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return EmitirDasResponse.fromJson(response);
  }

  /// Analisa erros específicos do PARCSN e retorna informações detalhadas
  PertsnErrorAnalysis analyzeError(String codigo, String mensagem) {
    return PertsnErrors.analyzeError(codigo, mensagem);
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  bool isKnownError(String codigo) {
    return PertsnErrors.isKnownError(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCSN
  PertsnErrorInfo? getErrorInfo(String codigo) {
    return PertsnErrors.getErrorInfo(codigo);
  }

  /// Obtém todos os erros de aviso do PARCSN
  List<PertsnErrorInfo> getAvisos() {
    return PertsnErrors.getAvisos();
  }

  /// Obtém todos os erros de entrada incorreta do PARCSN
  List<PertsnErrorInfo> getEntradasIncorretas() {
    return PertsnErrors.getEntradasIncorretas();
  }

  /// Obtém todos os erros gerais do PARCSN
  List<PertsnErrorInfo> getErros() {
    return PertsnErrors.getErros();
  }

  /// Obtém todos os sucessos do PARCSN
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
