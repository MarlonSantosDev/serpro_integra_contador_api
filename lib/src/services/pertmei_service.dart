import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/pertmei/pertmei_response.dart';

/// Serviço para integração com PERTMEI (Parcelamento Especial de Regularização Tributária para MEI)
///
/// Este serviço implementa todos os métodos disponíveis para:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos existentes
/// - Consultar parcelas para impressão
/// - Consultar detalhes de pagamento
/// - Emitir DAS (Documento de Arrecadação Simplificada)
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
          dados: '',
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
        dados: '',
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
          dados: '',
        );
      }

      if (numeroParcelamento <= 0) {
        return ConsultarParcelamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Número do parcelamento deve ser maior que zero')],
          dados: '',
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
        dados: '',
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
          dados: '',
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
        dados: '',
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
          dados: '',
        );
      }

      if (numeroParcelamento <= 0) {
        return ConsultarDetalhesPagamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Número do parcelamento deve ser maior que zero')],
          dados: '',
        );
      }

      if (anoMesParcela < 202001 || anoMesParcela > 209912) {
        return ConsultarDetalhesPagamentoResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Ano/mês da parcela deve estar no formato AAAAMM (ex: 202306)')],
          dados: '',
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
        dados: '',
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
          dados: '',
        );
      }

      if (parcelaParaEmitir < 202001 || parcelaParaEmitir > 209912) {
        return EmitirDasResponse(
          status: '400',
          mensagens: [Mensagem(codigo: '[Erro-PERTMEI-VALIDATION]', texto: 'Parcela para emitir deve estar no formato AAAAMM (ex: 202306)')],
          dados: '',
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
        dados: '',
      );
    }
  }
}
