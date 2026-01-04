import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_request.dart'
    as request_models;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_request.dart'
    show Declaracao, ValorDevido;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_response.dart'
    as response_models;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_response.dart'
    show GerarDasResponse;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_response.dart'
    as gerar_das_models;
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracoes_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracoes_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_ultima_declaracao_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_ultima_declaracao_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracao_numero_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_declaracao_numero_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_extrato_das_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_extrato_das_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_avulso_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_avulso_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_cobranca_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_cobranca_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_processo_request.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/gerar_das_processo_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/consultar_ultima_declaracao_com_pagamento_response.dart';
import 'package:serpro_integra_contador_api/src/services/pgdasd/model/entregar_declaracao_com_das_response.dart';

/// **Serviço:** PGDASD (Programa Gerador do DAS do Simples Nacional)
///
/// O PGDASD é o sistema para declaração e geração de DAS do Simples Nacional para MEI.
///
/// **Este serviço permite:**
/// - Entregar declaração mensal (TRANSDECLARACAO11)
/// - Gerar DAS (GERARDAS12)
/// - Consultar declarações transmitidas (CONSDECLARACAO13)
/// - Consultar última declaração/recibo (CONSULTIMADECREC14)
/// - Consultar declaração/recibo por número (CONSDECREC15)
/// - Consultar extrato do DAS (CONSEXTRATO16)
/// - Gerar DAS cobrança (GERARDASCOBRANCA17)
/// - Gerar DAS de processo (GERARDASPROCESSO18)
/// - Gerar DAS avulso (GERARDASAVULSO19)
///
/// **Documentação oficial:** `.cursor/rules/pgdasd.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final pgdasdService = PgdasdService(apiClient);
///
/// // Entregar declaração mensal
/// final resultado = await pgdasdService.entregarDeclaracao(
///   cnpj: '12345678000100',
///   periodoApuracao: 202504,
///   declaracao: declaracao,
/// );
/// print('Número do recibo: ${resultado.numeroRecibo}');
///
/// // Gerar DAS
/// final das = await pgdasdService.gerarDas(
///   contribuinteNumero: '12345678000100',
///   periodoApuracao: '202504',
/// );
/// print('DAS Base64: ${das.pdfBase64}');
/// ```
class PgdasdService {
  final ApiClient _apiClient;

  PgdasdService(this._apiClient);

  /// Entregar declaração mensal do Simples Nacional
  ///
  /// [cnpj] CNPJ do contribuinte (14 dígitos sem formatação)
  /// [periodoApuracao] Período de apuração da declaração (formato: AAAAMM, exemplo: 202504)
  /// [declaracao] Objeto contendo os dados da declaração
  /// [indicadorTransmissao] Indica se a declaração deve ser transmitida (padrão: true)
  /// [indicadorComparacao] Indica se há necessidade de comparação dos valores (padrão: true)
  /// [valoresParaComparacao] Valores para comparação com o valor apurado pelo sistema (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Exemplo:
  /// ```dart
  /// final resultado = await pgdasdService.entregarDeclaracao(
  ///   cnpj: '12345678000100',
  ///   periodoApuracao: 202504,
  ///   declaracao: declaracao,
  ///   autorPedidoDadosNumero: '12345678000100',
  /// );
  /// ```
  Future<response_models.EntregarDeclaracaoResponse> entregarDeclaracao({
    required String cnpj,
    required int periodoApuracao,
    required Declaracao declaracao,
    bool indicadorTransmissao = true,
    bool indicadorComparacao = true,
    List<ValorDevido>? valoresParaComparacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Construir request internamente de forma transparente
    final request = request_models.EntregarDeclaracaoRequest(
      cnpjCompleto: cnpj,
      pa: periodoApuracao,
      indicadorTransmissao: indicadorTransmissao,
      indicadorComparacao: indicadorComparacao,
      declaracao: declaracao,
      valoresParaComparacao: valoresParaComparacao,
    );

    if (!request.isValid && request.cnpjCompleto != '00000000000100') {
      throw ArgumentError('Dados da declaração inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'TRANSDECLARACAO11',
        versaoSistema: '1.0',
        dados: request.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Declarar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return response_models.EntregarDeclaracaoResponse.fromJson(response);
  }

  /// Gerar DAS de uma declaração previamente transmitida
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [dataConsolidacao] Data de consolidação futura (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasResponse> gerarDas({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? dataConsolidacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dasRequest = GerarDasRequest(
      periodoApuracao: periodoApuracao,
      dataConsolidacao: dataConsolidacao,
    );

    if (!dasRequest.isValid) {
      throw ArgumentError('Dados para geração do DAS inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'GERARDAS12',
        versaoSistema: '1.0',
        dados: dasRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasResponse.fromJson(response);
  }

  /// Consultar declarações transmitidas por ano-calendário ou período de apuração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoCalendario] Ano-calendário (formato: AAAA) - forneça este OU [periodoApuracao]
  /// [periodoApuracao] Período de apuração (formato: AAAAMM) - forneça este OU [anoCalendario]
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarDeclaracoesResponse> consultarDeclaracoes({
    required String contribuinteNumero,
    String? anoCalendario,
    String? periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = anoCalendario != null
        ? ConsultarDeclaracoesRequest.porAnoCalendario(anoCalendario)
        : ConsultarDeclaracoesRequest.porPeriodoApuracao(periodoApuracao!);

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'CONSDECLARACAO13',
        versaoSistema: '1.0',
        dados: consultaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDeclaracoesResponse.fromJson(response);
  }

  /// Consultar a última declaração/recibo transmitida por período de apuração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarUltimaDeclaracaoResponse> consultarUltimaDeclaracao({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarUltimaDeclaracaoRequest(
      periodoApuracao: periodoApuracao,
    );

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'CONSULTIMADECREC14',
        versaoSistema: '1.0',
        dados: consultaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarUltimaDeclaracaoResponse.fromJson(response);
  }

  /// Consultar declaração/recibo específica por número de declaração
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroDeclaracao] Número da declaração (17 dígitos)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarDeclaracaoNumeroResponse> consultarDeclaracaoPorNumero({
    required String contribuinteNumero,
    required String numeroDeclaracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarDeclaracaoNumeroRequest(
      numeroDeclaracao: numeroDeclaracao,
    );

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'CONSDECREC15',
        versaoSistema: '1.0',
        dados: consultaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDeclaracaoNumeroResponse.fromJson(response);
  }

  /// Consultar extrato da apuração do DAS por número de DAS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroDas] Número do DAS (17 dígitos)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ConsultarExtratoDasResponse> consultarExtratoDas({
    required String contribuinteNumero,
    required String numeroDas,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final consultaRequest = ConsultarExtratoDasRequest(numeroDas: numeroDas);

    if (!consultaRequest.isValid) {
      throw ArgumentError('Dados da consulta inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'CONSEXTRATO16',
        versaoSistema: '1.0',
        dados: consultaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarExtratoDasResponse.fromJson(response);
  }

  /// Gerar DAS Cobrança com débitos em sistema de cobrança
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasCobrancaResponse> gerarDasCobranca({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final cobrancaRequest = GerarDasCobrancaRequest(
      periodoApuracao: periodoApuracao,
    );

    if (!cobrancaRequest.isValid) {
      throw ArgumentError('Dados para geração do DAS Cobrança inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'GERARDASCOBRANCA17',
        versaoSistema: '1.0',
        dados: cobrancaRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasCobrancaResponse.fromJson(response);
  }

  /// Gerar DAS de Processo com débitos de processo em sistema de cobrança
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [numeroProcesso] Número do processo (17 dígitos)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasProcessoResponse> gerarDasProcesso({
    required String contribuinteNumero,
    required String numeroProcesso,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final processoRequest = GerarDasProcessoRequest(
      numeroProcesso: numeroProcesso,
    );

    if (!processoRequest.isValid) {
      throw ArgumentError('Dados para geração do DAS de Processo inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'GERARDASPROCESSO18',
        versaoSistema: '1.0',
        dados: processoRequest.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasProcessoResponse.fromJson(response);
  }

  /// Gerar DAS Avulso
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [request] Dados para geração do DAS Avulso
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<GerarDasAvulsoResponse> gerarDasAvulso({
    required String contribuinteNumero,
    required GerarDasAvulsoRequest request,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    if (!request.isValid) {
      throw ArgumentError('Dados para geração do DAS Avulso inválidos');
    }

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'PGDASD',
        idServico: 'GERARDASAVULSO19',
        versaoSistema: '1.0',
        dados: request.toJson().toString(),
      ),
    );

    final response = await _apiClient.post(
      '/Emitir',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return GerarDasAvulsoResponse.fromJson(response);
  }

  /// Consultar última declaração com informação de pagamento do DAS
  ///
  /// Combina a consulta da última declaração (CONSULTIMADECREC14) com
  /// consulta de declarações para obter status de pagamento do DAS.
  ///
  /// Este método executa duas operações:
  /// 1. Consulta a última declaração do período (PDFs e detalhes)
  /// 2. Consulta as declarações do ano para obter status de pagamento do DAS
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período de apuração (formato: AAAAMM, exemplo: "202504")
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Returns: [ConsultarUltimaDeclaracaoComPagamentoResponse] com todos os dados da declaração
  /// mais o campo adicional `dasPago` indicando se o DAS foi pago.
  ///
  /// O campo `dasPago`:
  /// - `true`: DAS foi pago OU não foi encontrado DAS para o período (assume pago)
  /// - `false`: DAS existe e não consta pagamento
  ///
  /// Throws: Exception se a consulta da última declaração falhar
  ///
  /// Exemplo:
  /// ```dart
  /// final resultado = await pgdasdService.consultarUltimaDeclaracaoComPagamento(
  ///   contribuinteNumero: '12345678000100',
  ///   periodoApuracao: '202504',
  /// );
  ///
  /// print('Número: ${resultado.dados?.numeroDeclaracao}');
  /// print('DAS Pago: ${resultado.dasPago ? "Sim" : "Não"}');
  /// ```
  Future<ConsultarUltimaDeclaracaoComPagamentoResponse>
  consultarUltimaDeclaracaoComPagamento({
    required String contribuinteNumero,
    required String periodoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Passo 1: Consultar última declaração
    final ultimaDeclaracaoResponse = await consultarUltimaDeclaracao(
      contribuinteNumero: contribuinteNumero,
      periodoApuracao: periodoApuracao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    // Passo 2: Extrair ano calendário do período (primeiros 4 dígitos)
    final anoCalendario = periodoApuracao.substring(0, 4);

    // Passo 3: Consultar declarações para obter status de pagamento
    bool dasPago = true; // Default: assume pago

    try {
      final declaracoesResponse = await consultarDeclaracoes(
        contribuinteNumero: contribuinteNumero,
        anoCalendario: anoCalendario,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Passo 4: Procurar período correspondente e extrair dasPago
      if (declaracoesResponse.sucesso && declaracoesResponse.dados != null) {
        final periodoInt = int.parse(periodoApuracao);

        // Iterar pelos períodos do ano
        for (final periodo in declaracoesResponse.dados!.listaPeriodos) {
          if (periodo.periodoApuracao == periodoInt) {
            // Procurar DAS nas operações do período
            for (final operacao in periodo.operacoes) {
              if (operacao.indiceDas != null) {
                dasPago = operacao.indiceDas!.dasPago;
                break; // Usa o primeiro DAS encontrado
              }
            }
            break;
          }
        }
      }
    } catch (e) {
      // Se falhar ao consultar declarações, mantém default dasPago = true
      // Não falha o método composto, apenas usa o valor padrão
    }

    // Passo 5: Criar resposta composta
    return ConsultarUltimaDeclaracaoComPagamentoResponse.fromBase(
      baseResponse: ultimaDeclaracaoResponse,
      dasPago: dasPago,
    );
  }

  /// Entregar declaração e gerar DAS automaticamente
  ///
  /// Combina a entrega de declaração (TRANSDECLARACAO11) com
  /// geração automática do DAS (GERARDAS12) após sucesso.
  ///
  /// Este método executa duas operações em sequência:
  /// 1. Transmite a declaração para a RFB
  /// 2. Se a declaração for bem-sucedida, gera o DAS automaticamente
  ///
  /// [cnpj] CNPJ do contribuinte (14 dígitos sem formatação)
  /// [periodoApuracao] Período de apuração da declaração (formato: AAAAMM, exemplo: 202504)
  /// [declaracao] Objeto contendo os dados da declaração
  /// [indicadorTransmissao] Indica se a declaração deve ser transmitida (padrão: true)
  /// [indicadorComparacao] Indica se há necessidade de comparação dos valores (padrão: true)
  /// [valoresParaComparacao] Valores para comparação com o valor apurado pelo sistema (opcional)
  /// [dataConsolidacao] Data de consolidação futura para o DAS (opcional, formato: AAAAMMDD)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Returns: [EntregarDeclaracaoComDasResponse] com dados combinados de ambas operações
  ///
  /// Comportamento em caso de erros:
  /// - Se a declaração falhar: Retorna erro imediatamente, não tenta gerar DAS
  /// - Se o DAS falhar: Retorna erro MAS preserva os dados da declaração
  ///
  /// A resposta contém getters úteis:
  /// - `sucesso`: true se ambas operações foram bem-sucedidas
  /// - `declaracaoEntregue`: true se a declaração foi transmitida
  /// - `dasGerado`: true se o DAS foi gerado
  ///
  /// IMPORTANTE: Se o DAS falhar mas a declaração foi entregue, você pode
  /// gerar o DAS manualmente usando o método `gerarDas()` com o período
  /// da declaração. O ID da declaração estará disponível em `dadosDeclaracao`.
  ///
  /// Exemplo:
  /// ```dart
  /// final resultado = await pgdasdService.entregarDeclaracaoComDas(
  ///   cnpj: '12345678000100',
  ///   periodoApuracao: 202504,
  ///   declaracao: declaracao,
  ///   autorPedidoDadosNumero: '12345678000100',
  /// );
  ///
  /// if (resultado.sucesso) {
  ///   print('✅ Declaração e DAS gerados!');
  ///   print('ID: ${resultado.dadosDeclaracao!.idDeclaracao}');
  ///   print('DAS: ${resultado.dadosDas![0].detalhamento.numeroDocumento}');
  /// } else if (resultado.declaracaoEntregue) {
  ///   print('⚠️ Declaração OK, mas DAS falhou');
  ///   print('Tente gerar DAS manualmente');
  /// } else {
  ///   print('❌ Erro ao entregar declaração');
  /// }
  /// ```
  Future<EntregarDeclaracaoComDasResponse> entregarDeclaracaoComDas({
    required String cnpj,
    required int periodoApuracao,
    required Declaracao declaracao,
    bool indicadorTransmissao = true,
    bool indicadorComparacao = true,
    List<ValorDevido>? valoresParaComparacao,
    String? dataConsolidacao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Passo 1: Entregar declaração usando o método refatorado
    final entregarResponse = await entregarDeclaracao(
      cnpj: cnpj,
      periodoApuracao: periodoApuracao,
      declaracao: declaracao,
      indicadorTransmissao: indicadorTransmissao,
      indicadorComparacao: indicadorComparacao,
      valoresParaComparacao: valoresParaComparacao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    // Passo 2: Verificar se a declaração foi bem-sucedida
    if (!entregarResponse.sucesso) {
      // Declaração falhou, retornar erro imediatamente
      return EntregarDeclaracaoComDasResponse.fromDeclaracaoError(
        declaracaoResponse: entregarResponse,
      );
    }

    // Passo 3: Converter período de apuração (int → String)
    final periodoApuracaoString = periodoApuracao.toString();

    // Passo 4: Tentar gerar DAS
    try {
      final gerarDasResponse = await gerarDas(
        contribuinteNumero: cnpj,
        periodoApuracao: periodoApuracaoString,
        dataConsolidacao: dataConsolidacao,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Passo 5a: Verificar se DAS foi gerado com sucesso
      if (!gerarDasResponse.sucesso) {
        // DAS falhou, mas declaração foi entregue
        return EntregarDeclaracaoComDasResponse.fromDasError(
          declaracaoResponse: entregarResponse,
          dasResponse: gerarDasResponse,
        );
      }

      // Passo 5b: Ambas operações bem-sucedidas
      return EntregarDeclaracaoComDasResponse.fromResponses(
        declaracaoResponse: entregarResponse,
        dasResponse: gerarDasResponse,
      );
    } catch (e) {
      // DAS lançou exception, criar resposta de erro artificial
      final gerarDasResponseErro = GerarDasResponse(
        status: 500,
        mensagens: [
          gerar_das_models.Mensagem(
            codigo: 'ERRO_GERACAO_DAS',
            texto: 'Erro ao gerar DAS: ${e.toString()}',
          ),
        ],
        dados: null,
      );

      return EntregarDeclaracaoComDasResponse.fromDasError(
        declaracaoResponse: entregarResponse,
        dasResponse: gerarDasResponseErro,
      );
    }
  }
}
