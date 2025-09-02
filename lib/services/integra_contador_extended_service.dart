import 'dart:async';
import 'dart:typed_data';

import '../models/identificacao.dart';
import '../models/dados_saida.dart';
import '../models/dados_entrada.dart';
import '../models/pedido_dados.dart';
import '../exceptions/api_exception.dart';
import 'integra_contador_service.dart';
import 'integra_contador_helper.dart';

/// Serviço estendido com métodos específicos para as 84 funcionalidades da API
class IntegraContadorExtendedService {
  final IntegraContadorService _baseService;

  IntegraContadorExtendedService(this._baseService);

  /// Método para testar a conectividade com a API
  Future<ApiResult<bool>> testarConectividade() async {
    try {
      final url = Uri.parse('${_baseService.config.baseUrl}/health');
      final response = await _baseService.httpClient.get(url, headers: _baseService.defaultHeaders).timeout(const Duration(seconds: 10));

      return ApiResult.success(response.statusCode == 200);
    } catch (e) {
      return ApiResult.failure(ExceptionFactory.network('Erro ao testar conectividade: $e'));
    }
  }
  
  /// Método para consultar dados
  Future<ApiResult<DadosSaida>> consultar(PedidoDados pedido) {
    return _baseService.consultar(pedido);
  }
  
  /// Método para emitir documentos
  Future<ApiResult<DadosSaida>> emitir(PedidoDados pedido) {
    return _baseService.emitir(pedido);
  }
  
  /// Método para declarar dados
  Future<ApiResult<DadosSaida>> declarar(PedidoDados pedido) {
    return _baseService.declarar(pedido);
  }
  
  /// Método para apoiar operações
  Future<ApiResult<DadosSaida>> apoiar(PedidoDados pedido) {
    // Converter PedidoDados para DadosEntrada
    final dadosEntrada = DadosEntrada(
      identificacao: pedido.servico,
      tipoOperacao: pedido.servico,
      versao: '1.0',
      timestamp: DateTime.now(),
      dados: {
        ...pedido.parametros ?? {},
        'identificacao': pedido.identificacao?.toJson(),
        'periodo_apuracao': pedido.periodoApuracao,
        'ano_base': pedido.anoBase,
      },
    );
    
    return _baseService.apoiar(dadosEntrada);
  }

  // ========================================
  // INTEGRA-SN (Simples Nacional)
  // ========================================

  /// 001 - Entregar declaração mensal do Simples Nacional
  Future<ApiResult<DadosSaida>> entregarDeclaracaoMensalSN({
    required String documento,
    required Map<String, dynamic> dadosDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.TRANSDECLARACAO11',
      parametros: dadosDeclaracao,
    );
    return _baseService.declarar(pedido);
  }

  /// 002 - Gerar DAS do Simples Nacional
  Future<ApiResult<DadosSaida>> gerarDASSN({
    required String documento,
    required String periodoApuracao,
    String? valorReceita,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.GERARDAS12',
      parametros: {
        'periodo_apuracao': periodoApuracao,
        if (valorReceita != null) 'valor_receita': valorReceita,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 003 - Consultar Declarações transmitidas do SN
  Future<ApiResult<DadosSaida>> consultarDeclaracoesSN({
    required String documento,
    String? anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.CONSDECLARACAO13',
      parametros: {
        if (anoCalendario != null) 'ano_calendario': anoCalendario,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 004 - Consultar a Última Declaração/Recibo transmitida do SN
  Future<ApiResult<DadosSaida>> consultarUltimaDeclaracaoSN({
    required String documento,
    required String anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.CONSULTIMADECREC14',
      parametros: {
        'ano_calendario': anoCalendario,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 005 - Consultar Declaração/Recibo específico do SN
  Future<ApiResult<DadosSaida>> consultarDeclaracaoReciboSN({
    required String documento,
    required String numeroDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.CONSDECREC15',
      parametros: {
        'numero_declaracao': numeroDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 006 - Consultar Extrato do DAS
  Future<ApiResult<DadosSaida>> consultarExtratoDAS({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.CONSEXTRATO16',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 007 - Gerar DAS referente a período no sistema de Cobrança
  Future<ApiResult<DadosSaida>> gerarDASCobranca({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.GERARDASCOBRANCA17',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 008 - Gerar DAS referente a processo no sistema de Cobrança
  Future<ApiResult<DadosSaida>> gerarDASProcesso({
    required String documento,
    required String numeroProcesso,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.GERARDASPROCESSO18',
      parametros: {
        'numero_processo': numeroProcesso,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 009 - Gerar DAS Avulso
  Future<ApiResult<DadosSaida>> gerarDASAvulso({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGDASD.GERARDASAVULSO19',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.emitir(pedido);
  }

  // ========================================
  // REGIME DE APURAÇÃO
  // ========================================

  /// 010 - Efetuar opção pelo Regime de Apuração de Receitas
  Future<ApiResult<DadosSaida>> efetuarOpcaoRegimeApuracao({
    required String documento,
    required String tipoRegime,
    required String anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'REGIMEAPURACAO.EFETUAROPCAOREGIME101',
      parametros: {
        'tipo_regime': tipoRegime,
        'ano_calendario': anoCalendario,
      },
    );
    return _baseService.declarar(pedido);
  }

  /// 011 - Consultar todas as opções de Regime de Apuração
  Future<ApiResult<DadosSaida>> consultarAnosCalendariosRegime({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'REGIMEAPURACAO.CONSULTARANOSCALENDARIOS102',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 012 - Consultar opção pelo Regime de Apuração
  Future<ApiResult<DadosSaida>> consultarOpcaoRegimeApuracao({
    required String documento,
    required String anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'REGIMEAPURACAO.CONSULTAROPCAOREGIME103',
      parametros: {
        'ano_calendario': anoCalendario,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 013 - Consultar resolução para o Regime de Caixa
  Future<ApiResult<DadosSaida>> consultarResolucaoRegimeCaixa({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'REGIMEAPURACAO.CONSULTARRESOLUCAO104',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // DEFIS
  // ========================================

  /// 014 - Transmitir declaração DEFIS
  Future<ApiResult<DadosSaida>> transmitirDeclaracaoDEFIS({
    required String documento,
    required Map<String, dynamic> dadosDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DEFIS.TRANSDECLARACAO141',
      parametros: dadosDeclaracao,
    );
    return _baseService.declarar(pedido);
  }

  /// 015 - Consultar declarações DEFIS transmitidas
  Future<ApiResult<DadosSaida>> consultarDeclaracoesDEFIS({
    required String documento,
    String? anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DEFIS.CONSDECLARACAO142',
      parametros: {
        if (anoCalendario != null) 'ano_calendario': anoCalendario,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 016 - Consultar última declaração DEFIS
  Future<ApiResult<DadosSaida>> consultarUltimaDeclaracaoDEFIS({
    required String documento,
    required String anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DEFIS.CONSULTIMADECREC143',
      parametros: {
        'ano_calendario': anoCalendario,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 017 - Consultar declaração DEFIS específica
  Future<ApiResult<DadosSaida>> consultarDeclaracaoReciboDEFIS({
    required String documento,
    required String numeroDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DEFIS.CONSDECREC144',
      parametros: {
        'numero_declaracao': numeroDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // INTEGRA-MEI
  // ========================================

  /// 018 - Gerar DAS MEI em PDF
  Future<ApiResult<DadosSaida>> gerarDASMEIPDF({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGMEI.GERARDASPDF21',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 019 - Gerar DAS MEI em código de barras
  Future<ApiResult<DadosSaida>> gerarDASMEICodigoBarras({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGMEI.GERARDASCODBARRA22',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 020 - Atualizar Benefício MEI
  Future<ApiResult<DadosSaida>> atualizarBeneficioMEI({
    required String documento,
    required Map<String, dynamic> dadosBeneficio,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGMEI.ATUBENEFICIO23',
      parametros: dadosBeneficio,
    );
    return _baseService.emitir(pedido);
  }

  /// 021 - Consultar Dívida Ativa MEI
  Future<ApiResult<DadosSaida>> consultarDividaAtivaMEI({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PGMEI.DIVIDAATIVA24',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 022 - Emitir Certificado de Condição MEI
  Future<ApiResult<DadosSaida>> emitirCertificadoCondicaoMEI({
    required String cpf,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cpf(cpf),
      servico: 'CCMEI.EMITIRCCMEI121',
      parametros: {},
    );
    return _baseService.emitir(pedido);
  }

  /// 023 - Consultar dados do Certificado de Condição MEI
  Future<ApiResult<DadosSaida>> consultarDadosCertificadoMEI({
    required String cpf,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cpf(cpf),
      servico: 'CCMEI.DADOSCCMEI122',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 024 - Consultar situação cadastral MEI
  Future<ApiResult<DadosSaida>> consultarSituacaoCadastralMEI({
    required String cpf,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cpf(cpf),
      servico: 'CCMEI.CCMEISITCADASTRAL123',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 025 - Transmitir declaração anual MEI (DASN-SIMEI)
  Future<ApiResult<DadosSaida>> transmitirDeclaracaoAnualMEI({
    required String documento,
    required Map<String, dynamic> dadosDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DASNSIMEI.TRANSDECLARACAO151',
      parametros: dadosDeclaracao,
    );
    return _baseService.declarar(pedido);
  }

  /// 026 - Consultar última declaração anual MEI
  Future<ApiResult<DadosSaida>> consultarUltimaDeclaracaoMEI({
    required String documento,
    required String anoCalendario,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DASNSIMEI.CONSULTIMADECREC152',
      parametros: {
        'ano_calendario': anoCalendario,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 027 - Atualizar DAS de excesso de receitas MEI
  Future<ApiResult<DadosSaida>> atualizarDASExcessoMEI({
    required String documento,
    required String periodoApuracao,
    required String valorExcesso,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DASNSIMEI.ATUALIZADASEXCESSO153',
      parametros: {
        'periodo_apuracao': periodoApuracao,
        'valor_excesso': valorExcesso,
      },
    );
    return _baseService.emitir(pedido);
  }

  // ========================================
  // INTEGRA-DCTFWEB
  // ========================================

  /// 028 - Gerar Guia Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> gerarGuiaDeclaracaoDCTF({
    required String documento,
    required String periodoApuracao,
    Map<String, dynamic>? parametrosAdicionais,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.GERARGUIA201',
      parametros: {
        'periodo_apuracao': periodoApuracao,
        if (parametrosAdicionais != null) ...parametrosAdicionais,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 029 - Consultar Declaração Completa DCTFWeb
  Future<ApiResult<DadosSaida>> consultarDeclaracaoCompletaDCTF({
    required String documento,
    required String periodoApuracao,
    Map<String, dynamic>? parametrosAdicionais,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSDECLARACAO202',
      parametros: {
        'periodo_apuracao': periodoApuracao,
        if (parametrosAdicionais != null) ...parametrosAdicionais,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 030 - Consultar Lista de Declarações DCTFWeb
  Future<ApiResult<DadosSaida>> consultarListaDeclaracoesDCTF({
    required String documento,
    required String dataInicio,
    required String dataFim,
    Map<String, dynamic>? parametrosAdicionais,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSLISTADECLARACAO203',
      parametros: {
        'data_inicio': dataInicio,
        'data_fim': dataFim,
        if (parametrosAdicionais != null) ...parametrosAdicionais,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 031 - Transmitir Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> transmitirDeclaracaoDCTF({
    required String documento,
    required Map<String, dynamic> dadosDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.TRANSDECLARACAO204',
      parametros: dadosDeclaracao,
    );
    return _baseService.declarar(pedido);
  }

  /// 032 - Consultar Lista de Vínculos da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarListaVinculosDCTF({
    required String documento,
    required String idDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSLISTAVINCULOS205',
      parametros: {
        'id_declaracao': idDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 033 - Consultar Detalhe do Vínculo da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarDetalheVinculoDCTF({
    required String documento,
    required String idDeclaracao,
    required String idVinculo,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSDETALHEVINCULO206',
      parametros: {
        'id_declaracao': idDeclaracao,
        'id_vinculo': idVinculo,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 034 - Consultar Lista de Créditos da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarListaCreditosDCTF({
    required String documento,
    required String idDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSLISTACREDITOS207',
      parametros: {
        'id_declaracao': idDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 035 - Consultar Detalhe do Crédito da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarDetalheCreditoDCTF({
    required String documento,
    required String idDeclaracao,
    required String idCredito,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSDETALHECREDITO208',
      parametros: {
        'id_declaracao': idDeclaracao,
        'id_credito': idCredito,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 036 - Consultar Lista de Débitos da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarListaDebitosDCTF({
    required String documento,
    required String idDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSLISTADEBITOS209',
      parametros: {
        'id_declaracao': idDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 037 - Consultar Detalhe do Débito da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarDetalheDebitoDCTF({
    required String documento,
    required String idDeclaracao,
    required String idDebito,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSDETALHEDEBITO210',
      parametros: {
        'id_declaracao': idDeclaracao,
        'id_debito': idDebito,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 038 - Consultar Resumo da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarResumoDeclaracaoDCTF({
    required String documento,
    required String idDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSRESUMO211',
      parametros: {
        'id_declaracao': idDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 039 - Consultar Recibo da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarReciboDeclaracaoDCTF({
    required String documento,
    required String idDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSRECIBO212',
      parametros: {
        'id_declaracao': idDeclaracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 040 - Consultar Tabela de Códigos e Descrições da DCTFWeb
  Future<ApiResult<DadosSaida>> consultarTabelaCodigosDCTF({
    required String documento,
    required String nomeTabela,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSTABELA213',
      parametros: {
        'nome_tabela': nomeTabela,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 041 - Retificar Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> retificarDeclaracaoDCTF({
    required String documento,
    required String idDeclaracao,
    required Map<String, dynamic> dadosRetificacao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.RETIFICARDECLARACAO214',
      parametros: {
        'id_declaracao': idDeclaracao,
        ...dadosRetificacao,
      },
    );
    return _baseService.declarar(pedido);
  }

  /// 042 - Excluir Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> excluirDeclaracaoDCTF({
    required String documento,
    required String idDeclaracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.EXCLUIRDECLARACAO215',
      parametros: {
        'id_declaracao': idDeclaracao,
      },
    );
    return _baseService.declarar(pedido);
  }

  /// 043 - Consultar Limite de Dispensa da DCTFWeb
  Future<ApiResult<DadosSaida>> consultarLimiteDispensaDCTF({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSLIMITEDISPENSA216',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 044 - Consultar Situação da Declaração DCTFWeb
  Future<ApiResult<DadosSaida>> consultarSituacaoDeclaracaoDCTF({
    required String documento,
    required String periodoApuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'DCTFWEB.CONSSITUACAODECLARACAO217',
      parametros: {
        'periodo_apuracao': periodoApuracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // INTEGRA-PROCURACOES
  // ========================================

  /// 045 - Obter Procuração
  Future<ApiResult<DadosSaida>> obterProcuracao({
    required String documento,
    required String tipoProcuracao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PROCURACOESRFB.OBTERPROCURACAO301',
      parametros: {
        'tipo_procuracao': tipoProcuracao,
      },
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // INTEGRA-SICALC
  // ========================================

  /// 046 - Consolidar e Gerar DARF em PDF
  Future<ApiResult<DadosSaida>> consolidarGerarDARFPDF({
    required String documento,
    required Map<String, dynamic> dadosCalculo,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'SICALC.CONSOLIDARGERARDARFPDF401',
      parametros: dadosCalculo,
    );
    return _baseService.emitir(pedido);
  }

  /// 047 - Gerar DARF com código de barras em PDF
  Future<ApiResult<DadosSaida>> gerarDARFCodigoBarrasPDF({
    required String documento,
    required Map<String, dynamic> dadosCalculo,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'SICALC.GERARDARFCODIGOBARRASPDF402',
      parametros: dadosCalculo,
    );
    return _baseService.emitir(pedido);
  }

  /// 048 - Consultar dados de um DARF
  Future<ApiResult<DadosSaida>> consultarDadosDARF({
    required String documento,
    required String numeroReferencia,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'SICALC.CONSULTARDADOSDARF403',
      parametros: {
        'numero_referencia': numeroReferencia,
      },
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // INTEGRA-CAIXAPOSTAL
  // ========================================

  /// 049 - Consultar Mensagens do Contribuinte
  Future<ApiResult<DadosSaida>> consultarMensagensContribuinte({
    required String documento,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CAIXAPOSTALRFB.CONSULTARMSGCONTRIBUINTE501',
      parametros: {
        if (dataInicio != null) 'data_inicio': IntegraContadorHelper.formatarDataParaAPI(dataInicio),
        if (dataFim != null) 'data_fim': IntegraContadorHelper.formatarDataParaAPI(dataFim),
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 050 - Marcar Mensagem como Lida
  Future<ApiResult<DadosSaida>> marcarMensagemLida({
    required String documento,
    required String idMensagem,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CAIXAPOSTALRFB.MARCARMSGLIDA502',
      parametros: {
        'id_mensagem': idMensagem,
      },
    );
    return _baseService.declarar(pedido);
  }

  /// 051 - Marcar Mensagem como Não Lida
  Future<ApiResult<DadosSaida>> marcarMensagemNaoLida({
    required String documento,
    required String idMensagem,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CAIXAPOSTALRFB.MARCARMSGNLIDA503',
      parametros: {
        'id_mensagem': idMensagem,
      },
    );
    return _baseService.declarar(pedido);
  }

  /// 052 - Excluir Mensagem
  Future<ApiResult<DadosSaida>> excluirMensagem({
    required String documento,
    required String idMensagem,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CAIXAPOSTALRFB.EXCLUIRMSG504',
      parametros: {
        'id_mensagem': idMensagem,
      },
    );
    return _baseService.declarar(pedido);
  }

  // ========================================
  // INTEGRA-PAGAMENTO
  // ========================================

  /// 053 - Consultar Pagamentos
  Future<ApiResult<DadosSaida>> consultarPagamentos({
    required String documento,
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PAGAMENTOSRFB.CONSULTARPAGAMENTOS601',
      parametros: {
        if (dataInicio != null) 'data_inicio': IntegraContadorHelper.formatarDataParaAPI(dataInicio),
        if (dataFim != null) 'data_fim': IntegraContadorHelper.formatarDataParaAPI(dataFim),
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 054 - Consultar Detalhes de um Pagamento
  Future<ApiResult<DadosSaida>> consultarDetalhesPagamento({
    required String documento,
    required String idPagamento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PAGAMENTOSRFB.CONSULTARDETALHESPAGAMENTO602',
      parametros: {
        'id_pagamento': idPagamento,
      },
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // INTEGRA-GERENCIADOR
  // ========================================

  /// 055 - Consultar Protocolo
  Future<ApiResult<DadosSaida>> consultarProtocolo({
    required String documento,
    required String numeroProtocolo,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'GERENCIADORPROTOCOLO.CONSULTARPROTOCOLO701',
      parametros: {
        'numero_protocolo': numeroProtocolo,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 056 - Cancelar Protocolo
  Future<ApiResult<DadosSaida>> cancelarProtocolo({
    required String documento,
    required String numeroProtocolo,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'GERENCIADORPROTOCOLO.CANCELARPROTOCOLO702',
      parametros: {
        'numero_protocolo': numeroProtocolo,
      },
    );
    return _baseService.declarar(pedido);
  }

  // ========================================
  // INTEGRA-SITFIS
  // ========================================

  /// 057 - Consultar Situação Fiscal
  Future<ApiResult<DadosSaida>> consultarSituacaoFiscalSITFIS({
    required String documento,
    String? anoBase,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'SITFIS.CONSULTARSITUACAOFISCAL801',
      anoBase: anoBase,
    );
    return _baseService.consultar(pedido);
  }

  /// 058 - Consultar Débitos
  Future<ApiResult<DadosSaida>> consultarDebitos({
    required String documento,
    String? situacao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'SITFIS.CONSULTARDEBITOS802',
      parametros: {
        if (situacao != null) 'situacao': situacao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 059 - Consultar Divergências GFIP x GPS
  Future<ApiResult<DadosSaida>> consultarDivergenciasGFIPxGPS({
    required String documento,
    String? periodo,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'SITFIS.CONSULTARDIVERGENCIASGFIPGPS803',
      parametros: {
        if (periodo != null) 'periodo': periodo,
      },
    );
    return _baseService.consultar(pedido);
  }

  // ========================================
  // INTEGRA-PARCELAMENTOS
  // ========================================

  /// 060 - Consultar Parcelamentos
  Future<ApiResult<DadosSaida>> consultarParcelamentos({
    required String documento,
    String? situacao,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PARCELAMENTOSRFB.CONSULTARPARCELAMENTOS901',
      parametros: {
        if (situacao != null) 'situacao': situacao,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 061 - Consultar Detalhes de um Parcelamento
  Future<ApiResult<DadosSaida>> consultarDetalhesParcelamento({
    required String documento,
    required String idParcelamento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PARCELAMENTOSRFB.CONSULTARDETALHESPARCELAMENTO902',
      parametros: {
        'id_parcelamento': idParcelamento,
      },
    );
    return _baseService.consultar(pedido);
  }

  /// 062 - Emitir Extrato de um Parcelamento
  Future<ApiResult<DadosSaida>> emitirExtratoParcelamento({
    required String documento,
    required String idParcelamento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PARCELAMENTOSRFB.EMITIREXTRATOPARCELAMENTO903',
      parametros: {
        'id_parcelamento': idParcelamento,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 063 - Emitir Recibo de uma Parcela
  Future<ApiResult<DadosSaida>> emitirReciboParcela({
    required String documento,
    required String idParcelamento,
    required String idParcela,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PARCELAMENTOSRFB.EMITIRRECIBOPARCELA904',
      parametros: {
        'id_parcelamento': idParcelamento,
        'id_parcela': idParcela,
      },
    );
    return _baseService.emitir(pedido);
  }

  /// 064 - Desistir de um Parcelamento
  Future<ApiResult<DadosSaida>> desistirParcelamento({
    required String documento,
    required String idParcelamento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'PARCELAMENTOSRFB.DESISTIRPARCELAMENTO905',
      parametros: {
        'id_parcelamento': idParcelamento,
      },
    );
    return _baseService.declarar(pedido);
  }

  // ========================================
  // OUTROS SISTEMAS
  // ========================================

  /// 065 - Consultar Dados Cadastrais PF
  Future<ApiResult<DadosSaida>> consultarDadosCadastraisPF({
    required String cpf,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cpf(cpf),
      servico: 'CADASTROPF.CONSULTARDADOSCADASTRAIS1001',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 066 - Consultar Dados Cadastrais PJ
  Future<ApiResult<DadosSaida>> consultarDadosCadastraisPJ({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROPJ.CONSULTARDADOSCADASTRAIS1101',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 067 - Consultar Situação do CNPJ
  Future<ApiResult<DadosSaida>> consultarSituacaoCNPJ({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROPJ.CONSULTARSITUACAOCNPJ1102',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 068 - Consultar Quadro de Sócios e Administradores (QSA)
  Future<ApiResult<DadosSaida>> consultarQSA({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROPJ.CONSULTARQSA1103',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 069 - Consultar Comprovante de Inscrição e Situação Cadastral
  Future<ApiResult<DadosSaida>> consultarComprovanteInscricao({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROPJ.CONSULTARCOMPROVANTEINSCRICAO1104',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 070 - Consultar Optantes pelo Simples Nacional
  Future<ApiResult<DadosSaida>> consultarOptantesSimplesNacional({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROPJ.CONSULTAROPTANTESSIMPLESNACIONAL1105',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 071 - Consultar Inscrições Vinculadas
  Future<ApiResult<DadosSaida>> consultarInscricoesVinculadas({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARINSCRICOESVINCULADAS1201',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 072 - Consultar Atividades Econômicas
  Future<ApiResult<DadosSaida>> consultarAtividadesEconomicas({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROUNIFICADO.CONSULTARATIVIDADESECONOMICAS1202',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 073 - Consultar Endereços
  Future<ApiResult<DadosSaida>> consultarEnderecos({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARENDERECOS1203',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 074 - Consultar Telefones
  Future<ApiResult<DadosSaida>> consultarTelefones({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARTELEFONES1204',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 075 - Consultar Emails
  Future<ApiResult<DadosSaida>> consultarEmails({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTAREMAILS1205',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 076 - Consultar Relações
  Future<ApiResult<DadosSaida>> consultarRelacoes({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARRELACOES1206',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 077 - Consultar Histórico de Nomes
  Future<ApiResult<DadosSaida>> consultarHistoricoNomes({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICONOMES1207',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 078 - Consultar Histórico de Situações
  Future<ApiResult<DadosSaida>> consultarHistoricoSituacoes({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICOSITUACOES1208',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 079 - Consultar Histórico de Endereços
  Future<ApiResult<DadosSaida>> consultarHistoricoEnderecos({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICOENDERECOS1209',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 080 - Consultar Histórico de Atividades
  Future<ApiResult<DadosSaida>> consultarHistoricoAtividades({
    required String cnpj,
  }) async {
    final pedido = PedidoDados(
      identificacao: Identificacao.cnpj(cnpj),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICOATIVIDADES1210',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 081 - Consultar Histórico de Relações
  Future<ApiResult<DadosSaida>> consultarHistoricoRelacoes({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICORELACOES1211',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 082 - Consultar Histórico de Telefones
  Future<ApiResult<DadosSaida>> consultarHistoricoTelefones({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICOTELEFONES1212',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 083 - Consultar Histórico de Emails
  Future<ApiResult<DadosSaida>> consultarHistoricoEmails({
    required String documento,
  }) async {
    final pedido = PedidoDados(
      identificacao: IntegraContadorHelper.criarIdentificacao(documento),
      servico: 'CADASTROUNIFICADO.CONSULTARHISTORICOEMAILS1213',
      parametros: {},
    );
    return _baseService.consultar(pedido);
  }

  /// 084 - Validar Certificado Digital
  Future<ApiResult<DadosSaida>> validarCertificadoDigital({
    required Uint8List certificado,
    required String senha,
    bool validarCadeia = true,
  }) async {
    final dadosEntrada = IntegraContadorHelper.criarDadosValidacaoCertificado(
      certificado: certificado,
      senha: senha,
      validarCadeia: validarCadeia,
    );
    return _baseService.apoiar(dadosEntrada);
  }

  // ========================================
  // MÉTODOS DE CONVENIÊNCIA
  // ========================================

  /// Consulta múltiplas informações em paralelo para um CNPJ
  Future<Map<String, ApiResult<DadosSaida>>> consultarInformacoesCompletas({
    required String documento,
    required String anoBase,
  }) async {
    final futures = {
      'situacaoFiscal': consultarSituacaoFiscalSITFIS(documento: documento, anoBase: anoBase),
      'debitos': consultarDebitos(documento: documento),
      'parcelamentos': consultarParcelamentos(documento: documento),
      'declaracoesSN': consultarDeclaracoesSN(documento: documento, anoCalendario: anoBase),
      'declaracoesDEFIS': consultarDeclaracoesDEFIS(documento: documento, anoCalendario: anoBase),
      'dadosCadastrais': consultarDadosCadastraisPJ(cnpj: documento),
      'qsa': consultarQSA(cnpj: documento),
    };

    final results = await Future.wait(futures.values);
    return Map.fromIterables(futures.keys, results);
  }

  /// Gera todos os tipos de DAS disponíveis para um documento e período
  Future<Map<String, ApiResult<DadosSaida>>> gerarTodosDAS({
    required String documento,
    required String periodoApuracao,
  }) async {
    final futures = {
      'dasSN': gerarDASSN(documento: documento, periodoApuracao: periodoApuracao),
      'dasMEI': gerarDASMEIPDF(documento: documento, periodoApuracao: periodoApuracao),
      'dasCobranca': gerarDASCobranca(documento: documento, periodoApuracao: periodoApuracao),
    };

    final results = await Future.wait(futures.values);
    return Map.fromIterables(futures.keys, results);
  }

  /// Consulta todas as declarações disponíveis para um documento e ano
  Future<Map<String, ApiResult<DadosSaida>>> consultarTodasDeclaracoes({
    required String documento,
    required String anoCalendario,
  }) async {
    final futures = {
      'declaracoesSN': consultarDeclaracoesSN(documento: documento, anoCalendario: anoCalendario),
      'declaracoesDEFIS': consultarDeclaracoesDEFIS(documento: documento, anoCalendario: anoCalendario),
      'declaracaoAnualMEI': consultarUltimaDeclaracaoMEI(documento: documento, anoCalendario: anoCalendario),
    };

    final results = await Future.wait(futures.values);
    return Map.fromIterables(futures.keys, results);
  }

  void dispose() {
    _baseService.dispose();
  }
}


