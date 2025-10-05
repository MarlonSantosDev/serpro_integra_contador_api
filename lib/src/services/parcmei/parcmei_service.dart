import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/consultar_pedidos_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/consultar_parcelamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/consultar_parcelas_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/consultar_detalhes_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/emitir_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/parcmei_validations.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei/model/parcmei_errors.dart';

/// Serviço para integração com o sistema PARCMEI (Parcelamento do MEI)
///
/// Este serviço permite:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos específicos
/// - Consultar parcelas disponíveis para impressão
/// - Consultar detalhes de pagamento
/// - Emitir DAS para parcelas
class ParcmeiService {
  final ApiClient _apiClient;

  ParcmeiService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento do tipo PARCMEI
  ///
  /// Retorna uma lista de todos os parcelamentos ativos do contribuinte.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcmeiService.consultarPedidos();
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
      pedidoDados: PedidoDados(idSistema: 'PARCMEI', idServico: 'PEDIDOSPARC203', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcmeiService.consultarParcelamento(1);
  /// if (response.sucesso) {
  ///   final parcelamento = response.dadosParsed;
  ///   print('Situação: ${parcelamento?.situacao}');
  ///   print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
  ///   print('Valor total: ${response.valorTotalConsolidadoFormatado}');
  /// }
  /// ```
  Future<ConsultarParcelamentoResponse> consultarParcelamento(int numeroParcelamento) async {
    // Validação do parâmetro
    final validacao = ParcmeiValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacao != null) {
      throw ArgumentError(validacao);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCMEI',
        idServico: 'OBTERPARC204',
        versaoSistema: '1.0',
        dados: '{"numeroParcelamento": $numeroParcelamento}',
      ),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ConsultarParcelamentoResponse.fromJson(response);
  }

  /// Consulta as parcelas disponíveis para impressão
  ///
  /// Retorna uma lista de parcelas disponíveis para emissão de DAS.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcmeiService.consultarParcelas();
  /// if (response.sucesso) {
  ///   final parcelas = response.dadosParsed?.listaParcelas ?? [];
  ///   for (final parcela in parcelas) {
  ///     print('Parcela ${parcela.parcelaFormatada}: ${parcela.valorFormatado}');
  ///   }
  ///   print('Valor total: ${response.valorTotalParcelasFormatado}');
  /// }
  /// ```
  Future<ConsultarParcelasResponse> consultarParcelas() async {
    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(idSistema: 'PARCMEI', idServico: 'PARCELASPARAGERAR202', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcmeiService.consultarDetalhesPagamento(1, 202107);
  /// if (response.sucesso) {
  ///   final detalhes = response.dadosParsed;
  ///   print('DAS: ${detalhes?.numeroDas}');
  ///   print('Valor pago: ${response.valorPagoArrecadacaoFormatado}');
  ///   print('Data de pagamento: ${response.dataPagamentoFormatada}');
  /// }
  /// ```
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(int numeroParcelamento, int anoMesParcela) async {
    // Validação dos parâmetros
    final validacaoParcelamento = ParcmeiValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacaoParcelamento != null) {
      throw ArgumentError(validacaoParcelamento);
    }

    final validacaoAnoMes = ParcmeiValidations.validarAnoMesParcela(anoMesParcela);
    if (validacaoAnoMes != null) {
      throw ArgumentError(validacaoAnoMes);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCMEI',
        idServico: 'DETPAGTOPARC205',
        versaoSistema: '1.0',
        dados: '{"numeroParcelamento": $numeroParcelamento, "anoMesParcela": $anoMesParcela}',
      ),
    );

    final response = await _apiClient.post('/Consultar', request);
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
  /// final response = await parcmeiService.emitirDas(202107);
  /// if (response.sucesso && response.pdfGeradoComSucesso) {
  ///   final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  ///   final pdfBytes = response.pdfBytes;
  ///   // Salvar ou exibir o PDF
  ///   print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
  /// }
  /// ```
  Future<EmitirDasResponse> emitirDas(int parcelaParaEmitir) async {
    // Validação dos parâmetros
    final validacaoParcela = ParcmeiValidations.validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacaoParcela != null) {
      throw ArgumentError(validacaoParcela);
    }

    // Validação adicional: prazo para emissão
    final validacaoPrazo = ParcmeiValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
    if (validacaoPrazo != null) {
      throw ArgumentError(validacaoPrazo);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCMEI',
        idServico: 'GERARDAS201',
        versaoSistema: '1.0',
        dados: '{"parcelaParaEmitir": $parcelaParaEmitir}',
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return EmitirDasResponse.fromJson(response);
  }

  /// Analisa erros específicos do PARCMEI e retorna informações detalhadas
  ParcmeiErrorAnalysis analyzeError(String codigo, String mensagem) {
    return ParcmeiErrors.analyzeError(codigo, mensagem);
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  bool isKnownError(String codigo) {
    return ParcmeiErrors.isKnownError(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCMEI
  ParcmeiErrorInfo? getErrorInfo(String codigo) {
    return ParcmeiErrors.getErrorInfo(codigo);
  }

  /// Obtém todos os erros de aviso do PARCMEI
  List<ParcmeiErrorInfo> getAvisos() {
    return ParcmeiErrors.getAvisos();
  }

  /// Obtém todos os erros de entrada incorreta do PARCMEI
  List<ParcmeiErrorInfo> getEntradasIncorretas() {
    return ParcmeiErrors.getEntradasIncorretas();
  }

  /// Obtém todos os erros gerais do PARCMEI
  List<ParcmeiErrorInfo> getErros() {
    return ParcmeiErrors.getErros();
  }

  /// Obtém todos os sucessos do PARCMEI
  List<ParcmeiErrorInfo> getSucessos() {
    return ParcmeiErrors.getSucessos();
  }

  /// Valida um número de parcelamento
  String? validarNumeroParcelamento(int? numeroParcelamento) {
    return ParcmeiValidations.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida um ano/mês de parcela
  String? validarAnoMesParcela(int? anoMesParcela) {
    return ParcmeiValidations.validarAnoMesParcela(anoMesParcela);
  }

  /// Valida uma parcela para emissão
  String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    return ParcmeiValidations.validarParcelaParaEmitir(parcelaParaEmitir);
  }

  /// Valida o prazo para emissão de uma parcela
  String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    return ParcmeiValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
  }

  /// Valida o CNPJ do contribuinte
  String? validarCnpjContribuinte(String? cnpj) {
    return ParcmeiValidations.validarCnpjContribuinte(cnpj);
  }

  /// Valida o tipo de contribuinte
  String? validarTipoContribuinte(int? tipoContribuinte) {
    return ParcmeiValidations.validarTipoContribuinte(tipoContribuinte);
  }

  /// Valida se a parcela está disponível para emissão
  String? validarParcelaDisponivelParaEmissao(int parcelaParaEmitir) {
    return ParcmeiValidations.validarParcelaDisponivelParaEmissao(parcelaParaEmitir);
  }

  /// Valida um período de apuração
  String? validarPeriodoApuracao(int? periodoApuracao) {
    return ParcmeiValidations.validarPeriodoApuracao(periodoApuracao);
  }

  /// Valida uma data no formato AAAAMMDD
  String? validarDataFormato(int? data) {
    return ParcmeiValidations.validarDataFormato(data);
  }

  /// Valida uma data/hora no formato AAAAMMDDHHMMSS
  String? validarDataHoraFormato(int? dataHora) {
    return ParcmeiValidations.validarDataHoraFormato(dataHora);
  }

  /// Valida um valor monetário
  String? validarValorMonetario(double? valor) {
    return ParcmeiValidations.validarValorMonetario(valor);
  }

  /// Valida um número de parcela
  String? validarNumeroParcela(String? numeroParcela) {
    return ParcmeiValidations.validarNumeroParcela(numeroParcela);
  }

  /// Valida um banco/agência
  String? validarBancoAgencia(String? bancoAgencia) {
    return ParcmeiValidations.validarBancoAgencia(bancoAgencia);
  }

  /// Valida um número de DAS
  String? validarNumeroDas(String? numeroDas) {
    return ParcmeiValidations.validarNumeroDas(numeroDas);
  }

  /// Valida um número de processo
  String? validarNumeroProcesso(String? processo) {
    return ParcmeiValidations.validarNumeroProcesso(processo);
  }

  /// Valida um tributo
  String? validarTributo(String? tributo) {
    return ParcmeiValidations.validarTributo(tributo);
  }

  /// Valida um ente federado
  String? validarEnteFederado(String? enteFederado) {
    return ParcmeiValidations.validarEnteFederado(enteFederado);
  }

  /// Valida uma situação de parcelamento
  String? validarSituacaoParcelamento(String? situacao) {
    return ParcmeiValidations.validarSituacaoParcelamento(situacao);
  }

  /// Valida um PDF Base64
  String? validarPdfBase64(String? pdfBase64) {
    return ParcmeiValidations.validarPdfBase64(pdfBase64);
  }

  /// Valida um sistema
  String? validarSistema(String? sistema) {
    return ParcmeiValidations.validarSistema(sistema);
  }

  /// Valida um serviço
  String? validarServico(String? servico) {
    return ParcmeiValidations.validarServico(servico);
  }

  /// Valida uma versão de sistema
  String? validarVersaoSistema(String? versaoSistema) {
    return ParcmeiValidations.validarVersaoSistema(versaoSistema);
  }

  /// Valida um número de parcelamento no formato específico do PARCMEI
  String? validarNumeroParcelamentoFormato(int? numeroParcelamento) {
    return ParcmeiValidations.validarNumeroParcelamentoFormato(numeroParcelamento);
  }

  /// Valida um período de apuração dentro de um range válido
  String? validarPeriodoApuracaoRange(int? periodoApuracao) {
    return ParcmeiValidations.validarPeriodoApuracaoRange(periodoApuracao);
  }
}
