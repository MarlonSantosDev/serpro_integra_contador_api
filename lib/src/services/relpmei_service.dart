import '../core/api_client.dart';
import '../models/relpmei/relpmei_request.dart';
import '../models/relpmei/relpmei_response.dart';

/// Serviço para integração com RELPMEI (Receita Federal)
///
/// Este serviço implementa todos os métodos disponíveis para:
/// - Consultar pedidos de parcelamento
/// - Consultar parcelamentos existentes
/// - Consultar parcelas para impressão
/// - Consultar detalhes de pagamento
/// - Emitir DAS (Documento de Arrecadação Simplificada)
class RelpmeiService {
  final ApiClient _apiClient;

  RelpmeiService(this._apiClient);

  /// Consulta pedidos de parcelamento RELPMEI
  ///
  /// [request] - Dados da consulta incluindo CPF/CNPJ obrigatório
  ///
  /// Retorna lista de pedidos encontrados ou erro detalhado
  Future<ConsultarPedidosResponse> consultarPedidos(ConsultarPedidosRequest request) async {
    try {
      // Validação dos dados obrigatórios
      if (request.cpfCnpj?.isEmpty ?? true) {
        return ConsultarPedidosResponse(
          sucesso: false,
          mensagem: 'CPF/CNPJ é obrigatório',
          codigoErro: 'VALIDATION_ERROR',
          detalhesErro: 'Campo cpfCnpj não pode estar vazio',
        );
      }

      // Fazer requisição para o endpoint RELPMEI
      final response = await _apiClient.post('/relpmei/pedidos', request);

      if (response['status'] == 200) {
        return ConsultarPedidosResponse.fromJson(response);
      } else {
        return ConsultarPedidosResponse(
          sucesso: false,
          mensagem: 'Erro na consulta de pedidos',
          codigoErro: 'HTTP_ERROR',
          detalhesErro: 'Status: ${response['status']} - ${response['body']}',
        );
      }
    } catch (e) {
      return ConsultarPedidosResponse(
        sucesso: false,
        mensagem: 'Erro interno na consulta de pedidos',
        codigoErro: 'INTERNAL_ERROR',
        detalhesErro: e.toString(),
      );
    }
  }

  /// Consulta parcelamentos existentes RELPMEI
  ///
  /// [request] - Dados da consulta incluindo CPF/CNPJ obrigatório
  ///
  /// Retorna lista de parcelamentos encontrados ou erro detalhado
  Future<ConsultarParcelamentoResponse> consultarParcelamento(ConsultarParcelamentoRequest request) async {
    try {
      // Validação dos dados obrigatórios
      if (request.cpfCnpj?.isEmpty ?? true) {
        return ConsultarParcelamentoResponse(
          sucesso: false,
          mensagem: 'CPF/CNPJ é obrigatório',
          codigoErro: 'VALIDATION_ERROR',
          detalhesErro: 'Campo cpfCnpj não pode estar vazio',
        );
      }

      // Fazer requisição para o endpoint RELPMEI
      final response = await _apiClient.post('/relpmei/parcelamentos', request);

      if (response['status'] == 200) {
        return ConsultarParcelamentoResponse.fromJson(response);
      } else {
        return ConsultarParcelamentoResponse(
          sucesso: false,
          mensagem: 'Erro na consulta de parcelamentos',
          codigoErro: 'HTTP_ERROR',
          detalhesErro: 'Status: ${response['status']} - ${response['body']}',
        );
      }
    } catch (e) {
      return ConsultarParcelamentoResponse(
        sucesso: false,
        mensagem: 'Erro interno na consulta de parcelamentos',
        codigoErro: 'INTERNAL_ERROR',
        detalhesErro: e.toString(),
      );
    }
  }

  /// Consulta parcelas para impressão RELPMEI
  ///
  /// [request] - Dados da consulta incluindo CPF/CNPJ obrigatório
  ///
  /// Retorna lista de parcelas para impressão ou erro detalhado
  Future<ConsultarParcelasImpressaoResponse> consultarParcelasImpressao(ConsultarParcelasImpressaoRequest request) async {
    try {
      // Validação dos dados obrigatórios
      if (request.cpfCnpj?.isEmpty ?? true) {
        return ConsultarParcelasImpressaoResponse(
          sucesso: false,
          mensagem: 'CPF/CNPJ é obrigatório',
          codigoErro: 'VALIDATION_ERROR',
          detalhesErro: 'Campo cpfCnpj não pode estar vazio',
        );
      }

      // Fazer requisição para o endpoint RELPMEI
      final response = await _apiClient.post('/relpmei/parcelas-impressao', request);

      if (response['status'] == 200) {
        return ConsultarParcelasImpressaoResponse.fromJson(response);
      } else {
        return ConsultarParcelasImpressaoResponse(
          sucesso: false,
          mensagem: 'Erro na consulta de parcelas para impressão',
          codigoErro: 'HTTP_ERROR',
          detalhesErro: 'Status: ${response['status']} - ${response['body']}',
        );
      }
    } catch (e) {
      return ConsultarParcelasImpressaoResponse(
        sucesso: false,
        mensagem: 'Erro interno na consulta de parcelas para impressão',
        codigoErro: 'INTERNAL_ERROR',
        detalhesErro: e.toString(),
      );
    }
  }

  /// Consulta detalhes de pagamento RELPMEI
  ///
  /// [request] - Dados da consulta incluindo CPF/CNPJ obrigatório
  ///
  /// Retorna lista de detalhes de pagamento ou erro detalhado
  Future<ConsultarDetalhesPagamentoResponse> consultarDetalhesPagamento(ConsultarDetalhesPagamentoRequest request) async {
    try {
      // Validação dos dados obrigatórios
      if (request.cpfCnpj?.isEmpty ?? true) {
        return ConsultarDetalhesPagamentoResponse(
          sucesso: false,
          mensagem: 'CPF/CNPJ é obrigatório',
          codigoErro: 'VALIDATION_ERROR',
          detalhesErro: 'Campo cpfCnpj não pode estar vazio',
        );
      }

      // Fazer requisição para o endpoint RELPMEI
      final response = await _apiClient.post('/relpmei/detalhes-pagamento', request);

      if (response['status'] == 200) {
        return ConsultarDetalhesPagamentoResponse.fromJson(response);
      } else {
        return ConsultarDetalhesPagamentoResponse(
          sucesso: false,
          mensagem: 'Erro na consulta de detalhes de pagamento',
          codigoErro: 'HTTP_ERROR',
          detalhesErro: 'Status: ${response['status']} - ${response['body']}',
        );
      }
    } catch (e) {
      return ConsultarDetalhesPagamentoResponse(
        sucesso: false,
        mensagem: 'Erro interno na consulta de detalhes de pagamento',
        codigoErro: 'INTERNAL_ERROR',
        detalhesErro: e.toString(),
      );
    }
  }

  /// Emite DAS (Documento de Arrecadação Simplificada) RELPMEI
  ///
  /// [request] - Dados para emissão incluindo CPF/CNPJ obrigatório
  ///
  /// Retorna DAS emitido ou erro detalhado
  Future<EmitirDasResponse> emitirDas(EmitirDasRequest request) async {
    try {
      // Validação dos dados obrigatórios
      if (request.cpfCnpj?.isEmpty ?? true) {
        return EmitirDasResponse(
          sucesso: false,
          mensagem: 'CPF/CNPJ é obrigatório',
          codigoErro: 'VALIDATION_ERROR',
          detalhesErro: 'Campo cpfCnpj não pode estar vazio',
        );
      }

      // Fazer requisição para o endpoint RELPMEI
      final response = await _apiClient.post('/relpmei/emitir-das', request);

      if (response['status'] == 200) {
        return EmitirDasResponse.fromJson(response);
      } else {
        return EmitirDasResponse(
          sucesso: false,
          mensagem: 'Erro na emissão de DAS',
          codigoErro: 'HTTP_ERROR',
          detalhesErro: 'Status: ${response['status']} - ${response['body']}',
        );
      }
    } catch (e) {
      return EmitirDasResponse(sucesso: false, mensagem: 'Erro interno na emissão de DAS', codigoErro: 'INTERNAL_ERROR', detalhesErro: e.toString());
    }
  }
}
