import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/consultar_pedidos_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/consultar_parcelamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/consultar_parcelas_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/consultar_detalhes_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/emitir_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/parcmei_especial_validations.dart';
import 'package:serpro_integra_contador_api/src/services/parcmei_especial/model/parcmei_especial_errors.dart';

/// Serviço para integração com o sistema PARCMEI-ESP (Parcelamento do MEI Especial)
///
/// Este serviço permite:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos específicos
/// - Consultar parcelas disponíveis para impressão
/// - Consultar detalhes de pagamento
/// - Emitir DAS para parcelas
class ParcmeiEspecialService {
  final ApiClient _apiClient;

  ParcmeiEspecialService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento do tipo PARCMEI-ESP
  ///
  /// Retorna uma lista de todos os parcelamentos ativos do contribuinte.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcmeiEspecialService.consultarPedidos();
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
      pedidoDados: PedidoDados(idSistema: 'PARCMEI-ESP', idServico: 'PEDIDOSPARC213', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcmeiEspecialService.consultarParcelamento(9001);
  /// if (response.sucesso) {
  ///   final parcelamento = response.dadosParsed;
  ///   print('Situação: ${parcelamento?.situacao}');
  ///   print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
  ///   print('Valor total: ${parcelamento?.valorTotalConsolidadoFormatado}');
  /// }
  /// ```
  Future<ConsultarParcelamentoResponse> consultarParcelamento(int numeroParcelamento) async {
    // Validação do parâmetro
    final validacao = ParcmeiEspecialValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacao != null) {
      throw ArgumentError(validacao);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCMEI-ESP',
        idServico: 'OBTERPARC214',
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
  /// final response = await parcmeiEspecialService.consultarParcelas();
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
      pedidoDados: PedidoDados(idSistema: 'PARCMEI-ESP', idServico: 'PARCELASPARAGERAR212', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcmeiEspecialService.consultarDetalhesPagamento(9001, 202111);
  /// if (response.sucesso) {
  ///   final detalhes = response.dadosParsed;
  ///   print('DAS: ${detalhes?.numeroDas}');
  ///   print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
  ///   print('Data de pagamento: ${detalhes?.dataPagamentoFormatada}');
  /// }
  /// ```
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(int numeroParcelamento, int anoMesParcela) async {
    // Validação dos parâmetros
    final validacaoParcelamento = ParcmeiEspecialValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacaoParcelamento != null) {
      throw ArgumentError(validacaoParcelamento);
    }

    final validacaoAnoMes = ParcmeiEspecialValidations.validarAnoMesParcela(anoMesParcela);
    if (validacaoAnoMes != null) {
      throw ArgumentError(validacaoAnoMes);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCMEI-ESP',
        idServico: 'DETPAGTOPARC215',
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
  /// final response = await parcmeiEspecialService.emitirDas(202107);
  /// if (response.sucesso && response.pdfGeradoComSucesso) {
  ///   final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  ///   final pdfBytes = response.pdfBytes;
  ///   // Salvar ou exibir o PDF
  ///   print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
  /// }
  /// ```
  Future<EmitirDasResponse> emitirDas(int parcelaParaEmitir) async {
    // Validação dos parâmetros
    final validacaoParcela = ParcmeiEspecialValidations.validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacaoParcela != null) {
      throw ArgumentError(validacaoParcela);
    }

    // Validação adicional: prazo para emissão
    final validacaoPrazo = ParcmeiEspecialValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
    if (validacaoPrazo != null) {
      throw ArgumentError(validacaoPrazo);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCMEI-ESP',
        idServico: 'GERARDAS211',
        versaoSistema: '1.0',
        dados: '{"parcelaParaEmitir": $parcelaParaEmitir}',
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return EmitirDasResponse.fromJson(response);
  }

  /// Analisa erros específicos do PARCMEI-ESP e retorna informações detalhadas
  ParcmeiEspecialErrorAnalysis analyzeError(String codigo, String mensagem) {
    return ParcmeiEspecialErrors.analyzeError(codigo, mensagem);
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  bool isKnownError(String codigo) {
    return ParcmeiEspecialErrors.isKnownError(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCMEI-ESP
  ParcmeiEspecialErrorInfo? getErrorInfo(String codigo) {
    return ParcmeiEspecialErrors.getErrorInfo(codigo);
  }

  /// Obtém todos os erros de aviso do PARCMEI-ESP
  List<ParcmeiEspecialErrorInfo> getAvisos() {
    return ParcmeiEspecialErrors.getAvisos();
  }

  /// Obtém todos os erros de entrada incorreta do PARCMEI-ESP
  List<ParcmeiEspecialErrorInfo> getEntradasIncorretas() {
    return ParcmeiEspecialErrors.getEntradasIncorretas();
  }

  /// Obtém todos os erros gerais do PARCMEI-ESP
  List<ParcmeiEspecialErrorInfo> getErros() {
    return ParcmeiEspecialErrors.getErros();
  }

  /// Obtém todos os sucessos do PARCMEI-ESP
  List<ParcmeiEspecialErrorInfo> getSucessos() {
    return ParcmeiEspecialErrors.getSucessos();
  }

  /// Valida um número de parcelamento
  String? validarNumeroParcelamento(int? numeroParcelamento) {
    return ParcmeiEspecialValidations.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida um ano/mês de parcela
  String? validarAnoMesParcela(int? anoMesParcela) {
    return ParcmeiEspecialValidations.validarAnoMesParcela(anoMesParcela);
  }

  /// Valida uma parcela para emissão
  String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    return ParcmeiEspecialValidations.validarParcelaParaEmitir(parcelaParaEmitir);
  }

  /// Valida o prazo para emissão de uma parcela
  String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    return ParcmeiEspecialValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
  }

  /// Valida o CNPJ do contribuinte
  String? validarCnpjContribuinte(String? cnpj) {
    return ParcmeiEspecialValidations.validarCnpjContribuinte(cnpj);
  }

  /// Valida o tipo de contribuinte
  String? validarTipoContribuinte(int? tipoContribuinte) {
    return ParcmeiEspecialValidations.validarTipoContribuinte(tipoContribuinte);
  }

  /// Valida se a parcela está disponível para emissão
  String? validarParcelaDisponivelParaEmissao(int parcelaParaEmitir) {
    return ParcmeiEspecialValidations.validarParcelaDisponivelParaEmissao(parcelaParaEmitir);
  }

  /// Valida um período de apuração
  String? validarPeriodoApuracao(int? periodoApuracao) {
    return ParcmeiEspecialValidations.validarPeriodoApuracao(periodoApuracao);
  }

  /// Valida uma data no formato AAAAMMDD
  String? validarDataFormato(int? data) {
    return ParcmeiEspecialValidations.validarDataFormato(data);
  }

  /// Valida uma data/hora no formato AAAAMMDDHHMMSS
  String? validarDataHoraFormato(int? dataHora) {
    return ParcmeiEspecialValidations.validarDataHoraFormato(dataHora);
  }

  /// Valida um valor monetário
  String? validarValorMonetario(double? valor) {
    return ParcmeiEspecialValidations.validarValorMonetario(valor);
  }

  /// Valida um número de parcela
  String? validarNumeroParcela(String? numeroParcela) {
    return ParcmeiEspecialValidations.validarNumeroParcela(numeroParcela);
  }

  /// Valida um banco/agência
  String? validarBancoAgencia(String? bancoAgencia) {
    return ParcmeiEspecialValidations.validarBancoAgencia(bancoAgencia);
  }

  /// Valida um número de DAS
  String? validarNumeroDas(String? numeroDas) {
    return ParcmeiEspecialValidations.validarNumeroDas(numeroDas);
  }

  /// Valida um número de processo
  String? validarNumeroProcesso(String? processo) {
    return ParcmeiEspecialValidations.validarNumeroProcesso(processo);
  }

  /// Valida um tributo
  String? validarTributo(String? tributo) {
    return ParcmeiEspecialValidations.validarTributo(tributo);
  }

  /// Valida um ente federado
  String? validarEnteFederado(String? enteFederado) {
    return ParcmeiEspecialValidations.validarEnteFederado(enteFederado);
  }

  /// Valida uma situação de parcelamento
  String? validarSituacaoParcelamento(String? situacao) {
    return ParcmeiEspecialValidations.validarSituacaoParcelamento(situacao);
  }

  /// Valida um PDF Base64
  String? validarPdfBase64(String? pdfBase64) {
    return ParcmeiEspecialValidations.validarPdfBase64(pdfBase64);
  }

  /// Valida um sistema
  String? validarSistema(String? sistema) {
    return ParcmeiEspecialValidations.validarSistema(sistema);
  }

  /// Valida um serviço
  String? validarServico(String? servico) {
    return ParcmeiEspecialValidations.validarServico(servico);
  }

  /// Valida uma versão de sistema
  String? validarVersaoSistema(String? versaoSistema) {
    return ParcmeiEspecialValidations.validarVersaoSistema(versaoSistema);
  }

  /// Valida um número de parcelamento no formato específico do PARCMEI-ESP
  String? validarNumeroParcelamentoFormato(int? numeroParcelamento) {
    return ParcmeiEspecialValidations.validarNumeroParcelamentoFormato(numeroParcelamento);
  }

  /// Valida um período de apuração dentro de um range válido
  String? validarPeriodoApuracaoRange(int? periodoApuracao) {
    return ParcmeiEspecialValidations.validarPeriodoApuracaoRange(periodoApuracao);
  }
}
