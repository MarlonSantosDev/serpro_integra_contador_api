import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/consultar_pedidos_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/consultar_parcelamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/consultar_detalhes_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/consultar_parcelas_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/emitir_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/parcsn_especial_validations.dart';
import 'package:serpro_integra_contador_api/src/services/parcsn_especial/model/parcsn_especial_errors.dart';

/// **Serviço:** PARCSN-ESP (Parcelamento Especial do Simples Nacional)
///
/// O PARCSN-ESP é uma modalidade especial de parcelamento de débitos do Simples Nacional.
///
/// **Este serviço permite:**
/// - Consultar pedidos de parcelamento (PEDIDOSPARC91)
/// - Consultar parcelamento específico (OBTERPARC92)
/// - Consultar parcelas para impressão (PARCELASPARAGERAR90)
/// - Consultar detalhes de pagamento (DETPAGTOPARC93)
/// - Emitir DAS para parcelas (GERARDAS89)
///
/// **Documentação oficial:** `.cursor/rules/parcsn_especial.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final parcsnEspecialService = ParcsnEspecialService(apiClient);
///
/// // Consultar pedidos
/// final pedidos = await parcsnEspecialService.consultarPedidos();
/// print('Total de parcelamentos: ${pedidos.parcelamentos?.length}');
///
/// // Emitir DAS de uma parcela
/// final das = await parcsnEspecialService.emitirDas(
///   numeroParcelamento: 123456,
///   numeroParcela: 1,
/// );
/// print('DAS Base64: ${das.pdfBase64}');
/// ```
class ParcsnEspecialService {
  final ApiClient _apiClient;

  ParcsnEspecialService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento do tipo PARCSN ESPECIAL
  ///
  /// Retorna uma lista de todos os parcelamentos especiais do contribuinte.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final response = await parcsnEspecialService.consultarPedidos();
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
      pedidoDados: PedidoDados(idSistema: 'PARCSN-ESP', idServico: 'PEDIDOSPARC173', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcsnEspecialService.consultarParcelamento(9001);
  /// if (response.sucesso) {
  ///   final parcelamento = response.dadosParsed;
  ///   print('Situação: ${parcelamento?.situacao}');
  ///   print('Data do pedido: ${parcelamento?.dataDoPedidoFormatada}');
  /// }
  /// ```
  Future<ConsultarParcelamentoResponse> consultarParcelamento(int numeroParcelamento) async {
    // Validação do parâmetro
    final validacao = ParcsnEspecialValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacao != null) {
      throw ArgumentError(validacao);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCSN-ESP',
        idServico: 'OBTERPARC174',
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
  /// final response = await parcsnEspecialService.consultarDetalhesPagamento(9001, 201612);
  /// if (response.sucesso) {
  ///   final detalhes = response.dadosParsed;
  ///   print('DAS: ${detalhes?.numeroDas}');
  ///   print('Valor pago: ${detalhes?.valorPagoArrecadacaoFormatado}');
  /// }
  /// ```
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(int numeroParcelamento, int anoMesParcela) async {
    // Validação dos parâmetros
    final validacaoParcelamento = ParcsnEspecialValidations.validarNumeroParcelamento(numeroParcelamento);
    if (validacaoParcelamento != null) {
      throw ArgumentError(validacaoParcelamento);
    }

    final validacaoAnoMes = ParcsnEspecialValidations.validarAnoMesParcela(anoMesParcela);
    if (validacaoAnoMes != null) {
      throw ArgumentError(validacaoAnoMes);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCSN-ESP',
        idServico: 'DETPAGTOPARC175',
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
  /// final response = await parcsnEspecialService.consultarParcelas();
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
      pedidoDados: PedidoDados(idSistema: 'PARCSN-ESP', idServico: 'PARCELASPARAGERAR172', versaoSistema: '1.0', dados: ''),
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
  /// final response = await parcsnEspecialService.emitirDas(202306);
  /// if (response.sucesso && response.pdfGeradoComSucesso) {
  ///   final pdfBase64 = response.dadosParsed?.docArrecadacaoPdfB64;
  ///   // Salvar ou exibir o PDF
  ///   print('PDF gerado com sucesso! Tamanho: ${response.tamanhoPdfFormatado}');
  /// }
  /// ```
  Future<EmitirDasResponse> emitirDas(int parcelaParaEmitir) async {
    // Validação dos parâmetros
    final validacaoParcela = ParcsnEspecialValidations.validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacaoParcela != null) {
      throw ArgumentError(validacaoParcela);
    }

    // Validação adicional: prazo para emissão
    final validacaoPrazo = ParcsnEspecialValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
    if (validacaoPrazo != null) {
      throw ArgumentError(validacaoPrazo);
    }

    final request = BaseRequest(
      contribuinteNumero: '00000000000000', // Será substituído pelo CNPJ do contribuinte
      pedidoDados: PedidoDados(
        idSistema: 'PARCSN-ESP',
        idServico: 'GERARDAS171',
        versaoSistema: '1.0',
        dados: '{"parcelaParaEmitir": $parcelaParaEmitir}',
      ),
    );

    final response = await _apiClient.post('/Emitir', request);
    return EmitirDasResponse.fromJson(response);
  }

  /// Analisa erros específicos do PARCSN-ESP e retorna informações detalhadas
  ParcsnEspecialErrorAnalysis analyzeError(String codigo, String mensagem) {
    return ParcsnEspecialErrors.analyzeError(codigo, mensagem);
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  bool isKnownError(String codigo) {
    return ParcsnEspecialErrors.isKnownError(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCSN-ESP
  ParcsnEspecialErrorInfo? getErrorInfo(String codigo) {
    return ParcsnEspecialErrors.getErrorInfo(codigo);
  }

  /// Obtém todos os erros de aviso do PARCSN-ESP
  List<ParcsnEspecialErrorInfo> getAvisos() {
    return ParcsnEspecialErrors.getAvisos();
  }

  /// Obtém todos os erros de entrada incorreta do PARCSN-ESP
  List<ParcsnEspecialErrorInfo> getEntradasIncorretas() {
    return ParcsnEspecialErrors.getEntradasIncorretas();
  }

  /// Obtém todos os erros gerais do PARCSN-ESP
  List<ParcsnEspecialErrorInfo> getErros() {
    return ParcsnEspecialErrors.getErros();
  }

  /// Obtém todos os sucessos do PARCSN-ESP
  List<ParcsnEspecialErrorInfo> getSucessos() {
    return ParcsnEspecialErrors.getSucessos();
  }

  /// Valida um número de parcelamento
  String? validarNumeroParcelamento(int? numeroParcelamento) {
    return ParcsnEspecialValidations.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida um ano/mês de parcela
  String? validarAnoMesParcela(int? anoMesParcela) {
    return ParcsnEspecialValidations.validarAnoMesParcela(anoMesParcela);
  }

  /// Valida uma parcela para emissão
  String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    return ParcsnEspecialValidations.validarParcelaParaEmitir(parcelaParaEmitir);
  }

  /// Valida o prazo para emissão de uma parcela
  String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    return ParcsnEspecialValidations.validarPrazoEmissaoParcela(parcelaParaEmitir);
  }

  /// Valida o CNPJ do contribuinte
  String? validarCnpjContribuinte(String? cnpj) {
    return ParcsnEspecialValidations.validarCnpjContribuinte(cnpj);
  }

  /// Valida o tipo de contribuinte
  String? validarTipoContribuinte(int? tipoContribuinte) {
    return ParcsnEspecialValidations.validarTipoContribuinte(tipoContribuinte);
  }
}
