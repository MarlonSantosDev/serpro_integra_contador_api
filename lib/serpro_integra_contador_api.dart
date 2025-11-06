/// Package Dart para integração com a API do SERPRO Integra Contador
///
/// Este package fornece uma interface completa e type-safe para interagir com todos os serviços
/// disponíveis na API do SERPRO Integra Contador, incluindo:
///
/// ## Serviços Disponíveis:
/// - **CCMEI**: Cadastro Centralizado de Microempreendedor Individual
/// - **PGDASD**: Pagamento de DAS por Débito Direto Autorizado
/// - **PGMEI**: Pagamento de DAS do MEI
/// - **DCTFWeb**: Declaração de Débitos e Créditos Tributários Federais
/// - **DEFIS**: Declaração de Informações Socioeconômicas e Fiscais
/// - **Parcelamentos**: PARCMEI, PARCSN, PERTMEI, PERTSN, RELPMEI, RELPSN
/// - **SITFIS**: Sistema de Informações Tributárias Fiscais
/// - **SICALC**: Sistema de Cálculo de Impostos
/// - **MIT**: Manifesto de Importação de Trânsito
/// - **Eventos de Atualização**: Consulta de eventos de atualização
/// - **Procurações**: Gestão de procurações eletrônicas
/// - **Caixa Postal**: Consulta de mensagens da Receita Federal
/// - **Regime de Apuração**: Gestão de opções pelo regime de apuração do Simples Nacional
///
/// ## Características Principais:
/// - Autenticação automática com certificados cliente (mTLS)
/// - Cache inteligente de tokens de procurador
/// - Validação automática de documentos (CPF/CNPJ)
/// - Tratamento de erros padronizado
/// - Suporte completo a procurações eletrônicas
/// - Modelos de dados type-safe para todas as operações
/// - **Flexibilidade de contratante e autor do pedido**: Todos os serviços suportam
///   parâmetros opcionais `contratanteNumero` e `autorPedidoDadosNumero` para
///   permitir diferentes contextos de uso em uma única requisição
///
/// ## Exemplo de Uso:
/// ```dart
/// import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
///
/// void main() async {
///   // Inicializar cliente da API
///   final apiClient = ApiClient();
///
///   // Autenticar com certificados
///   await apiClient.authenticate(
///     consumerKey: 'seu_consumer_key',
///     consumerSecret: 'seu_consumer_secret',
///     certPath: 'caminho/para/certificado.p12',
///     certPassword: 'senha_do_certificado',
///     contratanteNumero: '12345678000100',
///     autorPedidoDadosNumero: '12345678000100',
///   );
///
///   // Usar serviços com valores padrão da autenticação
///   final ccmeiService = CcmeiService(apiClient);
///   final response = await ccmeiService.emitirCcmei('12345678000100');
///   print('CCMEI emitido: ${response.dados.pdf.isNotEmpty}');
///
///   // Usar serviços com valores específicos para esta requisição
///   final sicalcService = SicalcService(apiClient);
///   final darfResponse = await sicalcService.consolidarEGerarDarf(
///     contribuinteNumero: '12345678000100',
///     contratanteNumero: '98765432000100', // Valor específico
///     autorPedidoDadosNumero: '11122233344', // Valor específico
///     // ... outros parâmetros
///   );
/// }
/// ```
library serpro_integra_contador_api;

// Core
export 'src/core/api_client.dart';
export 'src/core/auth/authentication_model.dart';

// Common Models (Classes base consolidadas)
export 'src/base/mensagem_negocio.dart';
export 'src/base/mensagem.dart';
export 'src/base/tipo_documento.dart';

// Utilities
export 'src/util/validacoes_utils.dart';
export 'src/util/formatador_utils.dart';
export 'src/services/pgmei/model/pgmei_validations.dart';
export 'src/util/arquivo_utils.dart';

// Base Models
export 'src/base/base_request.dart';
// CCMEI Models
export 'src/services/ccmei/model/mensagem_ccmei.dart';
export 'src/services/ccmei/model/emitir_ccmei_response.dart';
export 'src/services/ccmei/model/consultar_dados_ccmei_response.dart';
export 'src/services/ccmei/model/consultar_situacao_cadastral_ccmei_response.dart';

// PGDASD Models
export 'src/services/pgdasd/model/declarar_response.dart';
export 'src/services/pgdasd/model/entregar_declaracao_request.dart' hide Atividade, Estabelecimento, Declaracao;
export 'src/services/pgdasd/model/entregar_declaracao_response.dart' hide Mensagem, ValorDevido;
export 'src/services/pgdasd/model/gerar_das_request.dart';
export 'src/services/pgdasd/model/gerar_das_response.dart' hide Mensagem, DetalhamentoDas, Das;
export 'src/services/pgdasd/model/consultar_declaracoes_request.dart';
export 'src/services/pgdasd/model/consultar_declaracoes_response.dart' hide Mensagem;
export 'src/services/pgdasd/model/consultar_ultima_declaracao_request.dart';
export 'src/services/pgdasd/model/consultar_ultima_declaracao_response.dart' hide Mensagem;
export 'src/services/pgdasd/model/consultar_declaracao_numero_request.dart';
export 'src/services/pgdasd/model/consultar_declaracao_numero_response.dart'
    hide Mensagem, DeclaracaoCompleta, ArquivoRecibo, ArquivoDeclaracao, ArquivoMaed;
export 'src/services/pgdasd/model/consultar_extrato_das_request.dart';
export 'src/services/pgdasd/model/consultar_extrato_das_response.dart' hide Mensagem;
export 'src/services/pgdasd/model/gerar_das_avulso_request.dart';
export 'src/services/pgdasd/model/gerar_das_avulso_response.dart' hide Mensagem;
export 'src/services/pgdasd/model/gerar_das_cobranca_request.dart';
export 'src/services/pgdasd/model/gerar_das_cobranca_response.dart' hide Mensagem;
export 'src/services/pgdasd/model/gerar_das_processo_request.dart';
export 'src/services/pgdasd/model/gerar_das_processo_response.dart' hide Mensagem;

// PGMEI Models
export 'src/services/pgmei/model/base_response.dart' hide Mensagem;
export 'src/services/pgmei/model/gerar_das_response.dart' hide GerarDasResponse, ValoresDas, Das, ComposicaoDas;
export 'src/services/pgmei/model/gerar_das_codigo_barras_response.dart';
export 'src/services/pgmei/model/atualizar_beneficio_response.dart';
export 'src/services/pgmei/model/consultar_divida_ativa_response.dart' hide Debito;
export 'src/services/pgmei/model/pgmei_requests.dart' hide GerarDasRequest;

// DCTFWeb Models
export 'src/services/dctfweb/model/dctfweb_response.dart';
export 'src/services/dctfweb/model/dctfweb_request.dart';
export 'src/services/dctfweb/model/dctfweb_common.dart';
export 'src/services/dctfweb/model/consultar_xml_response.dart';
export 'src/services/dctfweb/model/gerar_guia_response.dart';
export 'src/services/dctfweb/model/transmitir_declaracao_response.dart';
export 'src/services/dctfweb/model/consultar_relatorio_response.dart';

// Procurações Models
export 'src/services/procuracoes/model/obter_procuracao_request.dart';
export 'src/services/procuracoes/model/obter_procuracao_response.dart';
export 'src/services/procuracoes/model/mensagem_negocio.dart';
export 'src/services/procuracoes/model/procuracoes_enums.dart';

// Autenticação de Procurador Models
export 'src/services/autenticaprocurador/model/termo_autorizacao_request.dart';
export 'src/services/autenticaprocurador/model/termo_autorizacao_response.dart';
export 'src/services/autenticaprocurador/model/assinatura_digital_model.dart';
export 'src/services/autenticaprocurador/model/cache_model.dart';

// Caixa Postal Models
export 'src/services/caixa_postal/model/mensagem_negocio.dart';
export 'src/services/caixa_postal/model/lista_mensagens_response.dart';
export 'src/services/caixa_postal/model/detalhes_mensagem_response.dart';
export 'src/services/caixa_postal/model/indicador_mensagens_response.dart';

// DTE Models
export 'src/services/dte/model/dte_response.dart';

// SITFIS Models
export 'src/services/sitfis/model/solicitar_protocolo_request.dart';
export 'src/services/sitfis/model/solicitar_protocolo_response.dart';
export 'src/services/sitfis/model/emitir_relatorio_request.dart';
export 'src/services/sitfis/model/emitir_relatorio_response.dart';
export 'src/services/sitfis/model/sitfis_mensagens.dart';
export 'src/services/sitfis/model/sitfis_cache.dart';

// PARCSN Models
export 'src/services/parcsn/model/parcsn_response.dart';
export 'src/services/parcsn/model/mensagem.dart';
export 'src/services/parcsn/model/consultar_pedidos_response.dart';
export 'src/services/parcsn/model/consultar_parcelamento_response.dart';
export 'src/services/parcsn/model/consultar_detalhes_pagamento_response.dart';
export 'src/services/parcsn/model/consultar_parcelas_response.dart';
export 'src/services/parcsn/model/emitir_das_response.dart';
export 'src/services/parcsn/model/parcsn_validations.dart';
export 'src/services/parcsn/model/parcsn_errors.dart';

// PARCSN ESPECIAL Models
export 'src/services/parcsn_especial/model/parcsn_especial_response.dart';
export 'src/services/parcsn_especial/model/mensagem.dart';
export 'src/services/parcsn_especial/model/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/services/parcsn_especial/model/consultar_parcelamento_response.dart'
    hide ConsultarParcelamentoResponse, ParcelamentoDetalhado, ConsolidacaoOriginal, DetalhesConsolidacao, AlteracaoDivida, DemonstrativoPagamento;
export 'src/services/parcsn_especial/model/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/services/parcsn_especial/model/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/services/parcsn_especial/model/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/services/parcsn_especial/model/parcsn_especial_validations.dart';
export 'src/services/parcsn_especial/model/parcsn_especial_errors.dart';

// PERTSN Models
export 'src/services/pertsn/model/pertsn_response.dart';
export 'src/services/pertsn/model/mensagem.dart';
export 'src/services/pertsn/model/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/services/pertsn/model/consultar_parcelamento_response.dart'
    hide
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        AlteracaoDivida,
        DetalhesAlteracaoDivida,
        DemonstrativoPagamento;
export 'src/services/pertsn/model/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/services/pertsn/model/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/services/pertsn/model/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/services/pertsn/model/pertsn_validations.dart' hide PertsnValidations;
export 'src/services/pertsn/model/pertsn_errors.dart' hide PertsnErrors, PertsnErrorInfo, PertsnErrorAnalysis;

// RELPSN Models
export 'src/services/relpsn/model/mensagem.dart' hide Mensagem;
export 'src/services/relpsn/model/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/services/relpsn/model/consultar_parcelamento_response.dart'
    hide ConsultarParcelamentoResponse, ParcelamentoDetalhado, ConsolidacaoOriginal, DetalhesConsolidacao, AlteracaoDivida, DemonstrativoPagamento;
export 'src/services/relpsn/model/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/services/relpsn/model/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/services/relpsn/model/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/services/relpsn/model/relpsn_validations.dart';
export 'src/services/relpsn/model/relpsn_errors.dart';

// PARCMEI Models
export 'src/services/parcmei/model/parcmei_response.dart';
export 'src/services/parcmei/model/mensagem.dart';
export 'src/services/parcmei/model/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/services/parcmei/model/consultar_parcelamento_response.dart'
    hide
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        AlteracaoDivida,
        DetalhesAlteracaoDivida,
        DemonstrativoPagamento;
export 'src/services/parcmei/model/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/services/parcmei/model/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/services/parcmei/model/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/services/parcmei/model/parcmei_validations.dart';
export 'src/services/parcmei/model/parcmei_errors.dart';

// PARCMEI ESPECIAL Models
export 'src/services/parcmei_especial/model/parcmei_especial_response.dart';
export 'src/services/parcmei_especial/model/mensagem.dart';
export 'src/services/parcmei_especial/model/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/services/parcmei_especial/model/consultar_parcelamento_response.dart'
    hide
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        AlteracaoDivida,
        DetalhesAlteracaoDivida,
        DemonstrativoPagamento;
export 'src/services/parcmei_especial/model/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/services/parcmei_especial/model/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/services/parcmei_especial/model/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/services/parcmei_especial/model/parcmei_especial_validations.dart';
export 'src/services/parcmei_especial/model/parcmei_especial_errors.dart';

// PERTMEI Models
export 'src/services/pertmei/model/pertmei_response.dart'
    hide
        Mensagem,
        ConsultarPedidosResponse,
        Parcelamento,
        ParcelamentosData,
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        DemonstrativoPagamento,
        ConsultarParcelasResponse,
        ListaParcelasData,
        Parcela,
        ConsultarDetalhesPagamentoResponse,
        DetalhesPagamentoData,
        PagamentoDebito,
        DiscriminacaoDebito,
        EmitirDasResponse,
        DasData;

// RELPMEI Models - Padrão dos outros serviços
export 'src/services/relpmei/model/relpmei_requests.dart';
export 'src/services/relpmei/model/relpmei_base_response.dart';
export 'src/services/relpmei/model/relpmei_responses.dart';

// PAGTOWEB Models
export 'src/services/pagtoweb/model/pagtoweb_request.dart';
export 'src/services/pagtoweb/model/pagtoweb_response.dart';

// DEFIS Models
export 'src/services/defis/model/transmitir_declaracao_request.dart' hide NaoOptante;
export 'src/services/defis/model/transmitir_declaracao_response.dart';
export 'src/services/defis/model/consultar_declaracoes_response.dart' hide ConsultarDeclaracoesResponse;
export 'src/services/defis/model/consultar_ultima_declaracao_request.dart' hide ConsultarUltimaDeclaracaoRequest;
export 'src/services/defis/model/consultar_ultima_declaracao_response.dart' hide ConsultarUltimaDeclaracaoResponse;
export 'src/services/defis/model/consultar_declaracao_especifica_request.dart';
export 'src/services/defis/model/consultar_declaracao_especifica_response.dart';
export 'src/services/defis/model/defis_enums.dart';
export 'src/services/defis/model/defis_response.dart';

// MIT Models
export 'src/services/mit/model/mit_enums.dart';
export 'src/services/mit/model/mit_request.dart';
export 'src/services/mit/model/mit_response.dart';

// Eventos Atualização Models
export 'src/services/eventos_atualizacao/model/eventos_atualizacao_common.dart';
export 'src/services/eventos_atualizacao/model/mensagem_eventos_atualizacao.dart';
export 'src/services/eventos_atualizacao/model/solicitar_eventos_pf_request.dart';
export 'src/services/eventos_atualizacao/model/solicitar_eventos_pf_response.dart';
export 'src/services/eventos_atualizacao/model/obter_eventos_pf_request.dart';
export 'src/services/eventos_atualizacao/model/obter_eventos_pf_response.dart';
export 'src/services/eventos_atualizacao/model/solicitar_eventos_pj_request.dart';
export 'src/services/eventos_atualizacao/model/solicitar_eventos_pj_response.dart';
export 'src/services/eventos_atualizacao/model/obter_eventos_pj_request.dart';
export 'src/services/eventos_atualizacao/model/obter_eventos_pj_response.dart';

// Regime de Apuração Models
export 'src/services/regime_apuracao/model/regime_apuracao_enums.dart';
export 'src/services/regime_apuracao/model/efetuar_opcao_request.dart';
export 'src/services/regime_apuracao/model/efetuar_opcao_response.dart';
export 'src/services/regime_apuracao/model/consultar_anos_request.dart';
export 'src/services/regime_apuracao/model/consultar_anos_response.dart';
export 'src/services/regime_apuracao/model/consultar_opcao_request.dart';
export 'src/services/regime_apuracao/model/consultar_opcao_response.dart' hide RegimeApuracao;
export 'src/services/regime_apuracao/model/consultar_resolucao_request.dart';
export 'src/services/regime_apuracao/model/consultar_resolucao_response.dart';

// SICALC Models
export 'src/services/sicalc/model/sicalc_enums.dart' hide TipoContribuinte;
export 'src/services/sicalc/model/sicalc_request.dart';
export 'src/services/sicalc/model/sicalc_response.dart';

// Services
export 'src/services/ccmei/ccmei_service.dart';
export 'src/services/pgdasd/pgdasd_service.dart';
export 'src/services/pgmei/pgmei_service.dart';
export 'src/services/dctfweb/dctfweb_service.dart';
export 'src/services/procuracoes/procuracoes_service.dart';
export 'src/services/caixa_postal/caixa_postal_service.dart';
export 'src/services/dte/dte_service.dart';
export 'src/services/parcsn/parcsn_service.dart';
export 'src/services/parcsn_especial/parcsn_especial_service.dart';
export 'src/services/pertsn/pertsn_service.dart';
export 'src/services/relpsn/relpsn_service.dart';
export 'src/services/parcmei/parcmei_service.dart';
export 'src/services/parcmei_especial/parcmei_especial_service.dart';
export 'src/services/pertmei/pertmei_service.dart';
export 'src/services/relpmei/relpmei_service.dart';
export 'src/services/pagtoweb/pagtoweb_service.dart';
export 'src/services/sitfis/sitfis_service.dart';
export 'src/services/defis/defis_service.dart';
export 'src/services/mit/mit_service.dart';
export 'src/services/eventos_atualizacao/eventos_atualizacao_service.dart';
export 'src/services/autenticaprocurador/autenticaprocurador_service.dart';
export 'src/services/regime_apuracao/regime_apuracao_service.dart';
export 'src/services/sicalc/sicalc_service.dart';
