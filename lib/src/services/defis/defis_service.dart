import 'dart:convert';

import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/transmitir_declaracao_request.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/transmitir_declaracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/consultar_declaracoes_response.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/consultar_ultima_declaracao_request.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/consultar_ultima_declaracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/consultar_declaracao_especifica_request.dart';
import 'package:serpro_integra_contador_api/src/services/defis/model/consultar_declaracao_especifica_response.dart';

/// **Serviço:** DEFIS (Declaração de Informações Socioeconômicas e Fiscais)
///
/// Serviço para transmissão e consulta da DEFIS, declaração obrigatória para
/// empresas optantes pelo Simples Nacional que encerraram atividades no ano-calendário.
///
/// **Este serviço permite:**
/// - TRANSDECLARACAO141: Transmitir Declaração Sócio Econômica
/// - CONSDECLARACAO142: Consultar Declarações Transmitidas
/// - CONSULTIMADECREC143: Consultar Última Declaração Transmitida
/// - CONSDECREC144: Consultar Declaração Específica
///
/// **Documentação oficial:** `.cursor/rules/defis.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final defisService = DefisService(apiClient);
///
/// // Transmitir declaração
/// final resultado = await defisService.transmitirDeclaracao(
///   contribuinteNumero: '12345678000190',
///   declaracaoData: TransmitirDeclaracaoRequest(...),
/// );
/// print('Recibo: ${resultado.numeroRecibo}');
/// ```
class DefisService {
  final ApiClient _apiClient;

  DefisService(this._apiClient);

  /// Transmite a Declaração Sócio Econômica - DEFIS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte (apenas Pessoa Jurídica é aceita)
  /// [declaracaoData] Dados da declaração incluindo ano, empresa, situação especial, etc.
  /// [contratanteNumero] Número do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] Número do autor do pedido de dados (opcional, usa dados da autenticação se não informado)
  Future<TransmitirDeclaracaoResponse> transmitirDeclaracao({
    required String contribuinteNumero,
    required TransmitirDeclaracaoRequest declaracaoData,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DEFIS', idServico: 'TRANSDECLARACAO141', versaoSistema: '1.0', dados: jsonEncode(declaracaoData.toJson())),
    );

    final response = await _apiClient.post(
      '/Declarar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return TransmitirDeclaracaoResponse.fromJson(response);
  }

  /// Consulta todas as declarações transmitidas na DEFIS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [contratanteNumero] Número do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] Número do autor do pedido de dados (opcional, usa dados da autenticação se não informado)
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoesTransmitidas({
    required String contribuinteNumero,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'DEFIS',
        idServico: 'CONSDECLARACAO142',
        versaoSistema: '1.0',
        dados: '', // Não é necessário passar dados para este serviço
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDeclaracoesResponse.fromJson(response);
  }

  /// Consulta a última declaração transmitida na DEFIS para um ano específico
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [ano] Ano calendário que se deseja consultar a última declaração transmitida
  /// [contratanteNumero] Número do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] Número do autor do pedido de dados (opcional, usa dados da autenticação se não informado)
  Future<ConsultarUltimaDeclaracaoResponse> consultarUltimaDeclaracao({
    required String contribuinteNumero,
    required int ano,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarUltimaDeclaracaoRequest(ano: ano);

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'DEFIS',
        idServico: 'CONSULTIMADECREC143',
        versaoSistema: '1.0',
        dados: jsonEncode(consultaRequest.toJson()),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarUltimaDeclaracaoResponse.fromJson(response);
  }

  /// Consulta uma declaração específica transmitida na DEFIS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [idDefis] ID DEFIS da declaração específica
  /// [contratanteNumero] Número do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] Número do autor do pedido de dados (opcional, usa dados da autenticação se não informado)

  Future<ConsultarDeclaracaoEspecificaResponse> consultarDeclaracaoEspecifica({
    required String contribuinteNumero,
    required String idDefis,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarDeclaracaoEspecificaRequest(idDefis: idDefis);

    final request = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'DEFIS', idServico: 'CONSDECREC144', versaoSistema: '1.0', dados: jsonEncode(consultaRequest.toJson())),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDeclaracaoEspecificaResponse.fromJson(response);
  }
}
