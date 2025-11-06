import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/pertmei/model/pertmei_response.dart';

/// **Serviço:** PERTMEI (Parcelamento Especial de Regularização Tributária para MEI)
///
/// O PERTMEI é uma modalidade especial de parcelamento para regularização tributária de MEI.
///
/// **Este serviço permite:**
/// - Consultar pedidos de parcelamento (PEDIDOSPARC243)
/// - Consultar parcelamento específico (OBTERPARC244)
/// - Consultar parcelas para impressão (PARCELASPARAGERAR242)
/// - Consultar detalhes de pagamento (DETPAGTOPARC245)
/// - Emitir DAS para parcelas (GERARDAS241)
///
/// **Documentação oficial:** `.cursor/rules/pertmei.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final pertmeiService = PertmeiService(apiClient);
///
/// // Consultar pedidos
/// final pedidos = await pertmeiService.consultarPedidos('12345678000190');
/// print('Total de parcelamentos: ${pedidos.parcelamentos?.length}');
///
/// // Emitir DAS de uma parcela
/// final das = await pertmeiService.emitirDas(
///   numeroParcelamento: 123456,
///   numeroParcela: 1,
/// );
/// print('DAS Base64: ${das.pdfBase64}');
/// ```
class PertmeiService {
  final ApiClient _apiClient;

  PertmeiService(this._apiClient);

  /// Consulta todos os pedidos de parcelamento na modalidade PERTMEI para um contribuinte
  ///
  /// [contribuinteNumero] - CNPJ do contribuinte (obrigatório)
  ///
  /// Retorna lista de parcelamentos encontrados ou erro detalhado
  Future<ConsultarPedidosResponse> consultarPedidos(String contribuinteNumero) async {
    try {
      // Validação dos dados obrigatórios
      if (contribuinteNumero.isEmpty) {
        return ConsultarPedidosResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'CNPJ do contribuinte é obrigatório')],
          dados: null,
        );
      }

      final request = BaseRequest(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(idSistema: 'PERTMEI', idServico: 'PEDIDOSPARC223', versaoSistema: '1.0', dados: ''),
      );

      final response = await _apiClient.post('/Consultar', request);
      return ConsultarPedidosResponse.fromJson(response);
    } catch (e) {
      return ConsultarPedidosResponse(
        status: '500',
        mensagens: [Mensagem(codigo: '[Erro-PERTMEI-INTERNAL]', texto: 'Erro interno: $e')],
        dados: null,
      );
    }
  }

  /// Consulta um determinado parcelamento na modalidade PERTMEI
  ///
  /// [contribuinteNumero] - CNPJ do contribuinte (obrigatório)
  /// [numeroParcelamento] - Número do parcelamento que se deseja consultar (obrigatório)
  ///
  /// Retorna informações detalhadas do parcelamento ou erro detalhado
  Future<ConsultarParcelamentoResponse> consultarParcelamento(String contribuinteNumero, int numeroParcelamento) async {
    try {
      // Validação dos dados obrigatórios
      if (contribuinteNumero.isEmpty) {
        return ConsultarParcelamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'CNPJ do contribuinte é obrigatório')],
          dados: null,
        );
      }

      if (numeroParcelamento <= 0) {
        return ConsultarParcelamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Número do parcelamento deve ser maior que zero')],
          dados: null,
        );
      }

      final request = BaseRequest(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(
          idSistema: 'PERTMEI',
          idServico: 'OBTERPARC224',
          versaoSistema: '1.0',
          dados: jsonEncode({'numeroParcelamento': numeroParcelamento}),
        ),
      );

      final response = await _apiClient.post('/Consultar', request);
      return ConsultarParcelamentoResponse.fromJson(response);
    } catch (e) {
      return ConsultarParcelamentoResponse(
        status: '500',
        mensagens: [Mensagem(codigo: '[Erro-PERTMEI-INTERNAL]', texto: 'Erro interno: $e')],
        dados: null,
      );
    }
  }

  /// Consulta as parcelas disponíveis para impressão de DAS na modalidade PERTMEI
  ///
  /// [contribuinteNumero] - CNPJ do contribuinte (obrigatório)
  ///
  /// Retorna lista de parcelas disponíveis para geração do DAS ou erro detalhado
  Future<ConsultarParcelasResponse> consultarParcelasParaImpressao(String contribuinteNumero) async {
    try {
      // Validação dos dados obrigatórios
      if (contribuinteNumero.isEmpty) {
        return ConsultarParcelasResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'CNPJ do contribuinte é obrigatório')],
          dados: null,
        );
      }

      final request = BaseRequest(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(idSistema: 'PERTMEI', idServico: 'PARCELASPARAGERAR222', versaoSistema: '1.0', dados: ''),
      );

      final response = await _apiClient.post('/Consultar', request);
      return ConsultarParcelasResponse.fromJson(response);
    } catch (e) {
      return ConsultarParcelasResponse(
        status: '500',
        mensagens: [Mensagem(codigo: '[Erro-PERTMEI-INTERNAL]', texto: 'Erro interno: $e')],
        dados: null,
      );
    }
  }

  /// Consulta detalhes de pagamento na modalidade PERTMEI
  ///
  /// [contribuinteNumero] - CNPJ do contribuinte (obrigatório)
  /// [numeroParcelamento] - Número do parcelamento (obrigatório)
  /// [anoMesParcela] - Mês da parcela paga no formato AAAAMM (obrigatório)
  ///
  /// Retorna informações detalhadas de pagamento de uma parcela ou erro detalhado
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(String contribuinteNumero, int numeroParcelamento, int anoMesParcela) async {
    try {
      // Validação dos dados obrigatórios
      if (contribuinteNumero.isEmpty) {
        return ConsultarDetalhesPagamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'CNPJ do contribuinte é obrigatório')],
          dados: null,
        );
      }

      if (numeroParcelamento <= 0) {
        return ConsultarDetalhesPagamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Número do parcelamento deve ser maior que zero')],
          dados: null,
        );
      }

      if (anoMesParcela < 202001 || anoMesParcela > 209912) {
        return ConsultarDetalhesPagamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Ano/mês da parcela deve estar no formato AAAAMM (ex: 202306)')],
          dados: null,
        );
      }

      final request = BaseRequest(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(
          idSistema: 'PERTMEI',
          idServico: 'DETPAGTOPARC225',
          versaoSistema: '1.0',
          dados: jsonEncode({'numeroParcelamento': numeroParcelamento, 'anoMesParcela': anoMesParcela}),
        ),
      );

      final response = await _apiClient.post('/Consultar', request);
      return ConsultarDetalhesPagamentoResponse.fromJson(response);
    } catch (e) {
      return ConsultarDetalhesPagamentoResponse(
        status: '500',
        mensagens: [Mensagem(codigo: '[Erro-PERTMEI-INTERNAL]', texto: 'Erro interno: $e')],
        dados: null,
      );
    }
  }

  /// Emite documento de arrecadação na modalidade PERTMEI
  ///
  /// [contribuinteNumero] - CNPJ do contribuinte (obrigatório)
  /// [parcelaParaEmitir] - Ano e mês da parcela para emitir o DAS no formato AAAAMM (obrigatório)
  ///
  /// Retorna PDF do DAS em formato base64 ou erro detalhado
  Future<EmitirDasResponse> emitirDas(String contribuinteNumero, int parcelaParaEmitir) async {
    try {
      // Validação dos dados obrigatórios
      if (contribuinteNumero.isEmpty) {
        return EmitirDasResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'CNPJ do contribuinte é obrigatório')],
          dados: null,
        );
      }

      if (parcelaParaEmitir < 202001 || parcelaParaEmitir > 209912) {
        return EmitirDasResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Parcela para emitir deve estar no formato AAAAMM (ex: 202306)')],
          dados: null,
        );
      }

      final request = BaseRequest(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(
          idSistema: 'PERTMEI',
          idServico: 'GERARDAS221',
          versaoSistema: '1.0',
          dados: jsonEncode({'parcelaParaEmitir': parcelaParaEmitir}),
        ),
      );

      final response = await _apiClient.post('/Emitir', request);
      return EmitirDasResponse.fromJson(response);
    } catch (e) {
      return EmitirDasResponse(
        status: '500',
        mensagens: [Mensagem(codigo: '[Erro-PERTMEI-INTERNAL]', texto: 'Erro interno: $e')],
        dados: null,
      );
    }
  }
}
