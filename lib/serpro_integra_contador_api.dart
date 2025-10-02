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
export 'src/models/base/mensagem_negocio.dart';
export 'src/models/base/mensagem.dart';
export 'src/models/base/tipo_documento.dart';

// Utilities
export 'src/util/document_utils.dart';
export 'src/util/formatter_utils.dart';
export 'src/util/dctfweb_utils.dart';
export 'src/util/assinatura_digital_utils.dart';
export 'src/util/cache_utils.dart';
export 'src/util/xml_utils.dart';
export 'src/util/eventos_atualizacao_utils.dart';

// Base Models
export 'src/models/base/base_request.dart';
// CCMEI Models
export 'src/models/ccmei/mensagem_ccmei.dart';
export 'src/models/ccmei/emitir_ccmei_response.dart';
export 'src/models/ccmei/consultar_dados_ccmei_response.dart';
export 'src/models/ccmei/consultar_situacao_cadastral_ccmei_response.dart';

// PGDASD Models
export 'src/models/pgdasd/declarar_response.dart';
export 'src/models/pgdasd/entregar_declaracao_request.dart' hide Atividade, Estabelecimento, Declaracao;
export 'src/models/pgdasd/entregar_declaracao_response.dart' hide Mensagem, ValorDevido;
export 'src/models/pgdasd/gerar_das_request.dart';
export 'src/models/pgdasd/gerar_das_response.dart' hide Mensagem, DetalhamentoDas, Das;
export 'src/models/pgdasd/consultar_declaracoes_request.dart';
export 'src/models/pgdasd/consultar_declaracoes_response.dart' hide Mensagem;
export 'src/models/pgdasd/consultar_ultima_declaracao_request.dart';
export 'src/models/pgdasd/consultar_ultima_declaracao_response.dart' hide Mensagem;
export 'src/models/pgdasd/consultar_declaracao_numero_request.dart';
export 'src/models/pgdasd/consultar_declaracao_numero_response.dart' hide Mensagem, DeclaracaoCompleta, ArquivoRecibo, ArquivoDeclaracao, ArquivoMaed;
export 'src/models/pgdasd/consultar_extrato_das_request.dart';
export 'src/models/pgdasd/consultar_extrato_das_response.dart' hide Mensagem;
export 'src/models/pgdasd/gerar_das_avulso_request.dart';
export 'src/models/pgdasd/gerar_das_avulso_response.dart' hide Mensagem;
export 'src/models/pgdasd/gerar_das_cobranca_request.dart';
export 'src/models/pgdasd/gerar_das_cobranca_response.dart' hide Mensagem;
export 'src/models/pgdasd/gerar_das_processo_request.dart';
export 'src/models/pgdasd/gerar_das_processo_response.dart' hide Mensagem;

// PGMEI Models
export 'src/models/pgmei/gerar_das_response.dart' hide GerarDasResponse;

// DCTFWeb Models
export 'src/models/dctfweb/dctfweb_response.dart';
export 'src/models/dctfweb/dctfweb_request.dart';
export 'src/models/dctfweb/dctfweb_common.dart';
export 'src/models/dctfweb/consultar_xml_response.dart';
export 'src/models/dctfweb/gerar_guia_response.dart';
export 'src/models/dctfweb/transmitir_declaracao_response.dart';
export 'src/models/dctfweb/consultar_relatorio_response.dart';

// Procurações Models
export 'src/models/procuracoes/obter_procuracao_request.dart';
export 'src/models/procuracoes/obter_procuracao_response.dart';
export 'src/models/procuracoes/mensagem_negocio.dart';
export 'src/models/procuracoes/procuracoes_enums.dart';

// Autenticação de Procurador Models
export 'src/models/autenticaprocurador/termo_autorizacao_request.dart';
export 'src/models/autenticaprocurador/termo_autorizacao_response.dart';
export 'src/models/autenticaprocurador/assinatura_digital_model.dart';
export 'src/models/autenticaprocurador/cache_model.dart';

// Caixa Postal Models
export 'src/models/caixa_postal/mensagem_negocio.dart';
export 'src/models/caixa_postal/lista_mensagens_response.dart';
export 'src/models/caixa_postal/detalhes_mensagem_response.dart';
export 'src/models/caixa_postal/indicador_mensagens_response.dart';

// DTE Models
export 'src/models/dte/dte_response.dart';

// SITFIS Models
export 'src/models/sitfis/solicitar_protocolo_request.dart';
export 'src/models/sitfis/solicitar_protocolo_response.dart';
export 'src/models/sitfis/emitir_relatorio_request.dart';
export 'src/models/sitfis/emitir_relatorio_response.dart';
export 'src/models/sitfis/sitfis_mensagens.dart';
export 'src/models/sitfis/sitfis_cache.dart';

// PARCSN Models
export 'src/models/parcsn/parcsn_response.dart';
export 'src/models/parcsn/mensagem.dart';
export 'src/models/parcsn/consultar_pedidos_response.dart';
export 'src/models/parcsn/consultar_parcelamento_response.dart';
export 'src/models/parcsn/consultar_detalhes_pagamento_response.dart';
export 'src/models/parcsn/consultar_parcelas_response.dart';
export 'src/models/parcsn/emitir_das_response.dart';
export 'src/models/parcsn/parcsn_validations.dart';
export 'src/models/parcsn/parcsn_errors.dart';

// PARCSN ESPECIAL Models
export 'src/models/parcsn_especial/parcsn_especial_response.dart';
export 'src/models/parcsn_especial/mensagem.dart';
export 'src/models/parcsn_especial/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/parcsn_especial/consultar_parcelamento_response.dart'
    hide ConsultarParcelamentoResponse, ParcelamentoDetalhado, ConsolidacaoOriginal, DetalhesConsolidacao, AlteracaoDivida, DemonstrativoPagamento;
export 'src/models/parcsn_especial/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/parcsn_especial/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/parcsn_especial/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/parcsn_especial/parcsn_especial_validations.dart';
export 'src/models/parcsn_especial/parcsn_especial_errors.dart';

// PERTSN Models
export 'src/models/pertsn/pertsn_response.dart';
export 'src/models/pertsn/mensagem.dart';
export 'src/models/pertsn/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/pertsn/consultar_parcelamento_response.dart'
    hide
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        AlteracaoDivida,
        DetalhesAlteracaoDivida,
        DemonstrativoPagamento;
export 'src/models/pertsn/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/pertsn/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/pertsn/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/pertsn/pertsn_validations.dart' hide PertsnValidations;
export 'src/models/pertsn/pertsn_errors.dart' hide PertsnErrors, PertsnErrorInfo, PertsnErrorAnalysis;

// RELPSN Models
export 'src/models/relpsn/mensagem.dart' hide Mensagem;
export 'src/models/relpsn/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/relpsn/consultar_parcelamento_response.dart'
    hide ConsultarParcelamentoResponse, ParcelamentoDetalhado, ConsolidacaoOriginal, DetalhesConsolidacao, AlteracaoDivida, DemonstrativoPagamento;
export 'src/models/relpsn/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/relpsn/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/relpsn/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/relpsn/relpsn_validations.dart';
export 'src/models/relpsn/relpsn_errors.dart';

// PARCMEI Models
export 'src/models/parcmei/parcmei_response.dart';
export 'src/models/parcmei/mensagem.dart';
export 'src/models/parcmei/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/parcmei/consultar_parcelamento_response.dart'
    hide
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        AlteracaoDivida,
        DetalhesAlteracaoDivida,
        DemonstrativoPagamento;
export 'src/models/parcmei/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/parcmei/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/parcmei/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/parcmei/parcmei_validations.dart';
export 'src/models/parcmei/parcmei_errors.dart';

// PARCMEI ESPECIAL Models
export 'src/models/parcmei_especial/parcmei_especial_response.dart';
export 'src/models/parcmei_especial/mensagem.dart';
export 'src/models/parcmei_especial/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/parcmei_especial/consultar_parcelamento_response.dart'
    hide
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        AlteracaoDivida,
        DetalhesAlteracaoDivida,
        DemonstrativoPagamento;
export 'src/models/parcmei_especial/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/parcmei_especial/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/parcmei_especial/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/parcmei_especial/parcmei_especial_validations.dart';
export 'src/models/parcmei_especial/parcmei_especial_errors.dart';

// PERTMEI Models
export 'src/models/pertmei/pertmei_response.dart'
    hide
        Mensagem,
        ConsultarPedidosResponse,
        Parcelamento,
        ConsultarParcelamentoResponse,
        ParcelamentoDetalhado,
        ConsolidacaoOriginal,
        DetalhesConsolidacao,
        DemonstrativoPagamento,
        ConsultarParcelasResponse,
        Parcela,
        ConsultarDetalhesPagamentoResponse,
        PagamentoDebito,
        DiscriminacaoDebito,
        EmitirDasResponse;

// RELPMEI Models
export 'src/models/relpmei/relpmei_base_request.dart';
export 'src/models/relpmei/relpmei_request.dart';
export 'src/models/relpmei/relpmei_response.dart'
    hide ConsultarPedidosResponse, ConsultarParcelamentoResponse, ConsultarDetalhesPagamentoResponse, EmitirDasResponse, Parcelamento, Parcela;

// PAGTOWEB Models
export 'src/models/pagtoweb/pagtoweb_request.dart';
export 'src/models/pagtoweb/pagtoweb_response.dart';

// DEFIS Models
export 'src/models/defis/transmitir_declaracao_request.dart' hide NaoOptante;
export 'src/models/defis/transmitir_declaracao_response.dart';
export 'src/models/defis/consultar_declaracoes_response.dart' hide ConsultarDeclaracoesResponse;
export 'src/models/defis/consultar_ultima_declaracao_request.dart' hide ConsultarUltimaDeclaracaoRequest;
export 'src/models/defis/consultar_ultima_declaracao_response.dart' hide ConsultarUltimaDeclaracaoResponse;
export 'src/models/defis/consultar_declaracao_especifica_request.dart';
export 'src/models/defis/consultar_declaracao_especifica_response.dart';
export 'src/models/defis/defis_enums.dart';
export 'src/models/defis/defis_response.dart';

// MIT Models
export 'src/models/mit/mit_enums.dart';
export 'src/models/mit/mit_request.dart';
export 'src/models/mit/mit_response.dart';

// Eventos Atualização Models
export 'src/models/eventos_atualizacao/eventos_atualizacao_common.dart';
export 'src/models/eventos_atualizacao/mensagem_eventos_atualizacao.dart';
export 'src/models/eventos_atualizacao/solicitar_eventos_pf_request.dart';
export 'src/models/eventos_atualizacao/solicitar_eventos_pf_response.dart';
export 'src/models/eventos_atualizacao/obter_eventos_pf_request.dart';
export 'src/models/eventos_atualizacao/obter_eventos_pf_response.dart';
export 'src/models/eventos_atualizacao/solicitar_eventos_pj_request.dart';
export 'src/models/eventos_atualizacao/solicitar_eventos_pj_response.dart';
export 'src/models/eventos_atualizacao/obter_eventos_pj_request.dart';
export 'src/models/eventos_atualizacao/obter_eventos_pj_response.dart';

// Regime de Apuração Models
export 'src/models/regime_apuracao/regime_apuracao_enums.dart';
export 'src/models/regime_apuracao/efetuar_opcao_request.dart';
export 'src/models/regime_apuracao/efetuar_opcao_response.dart' hide MensagemNegocio;
export 'src/models/regime_apuracao/consultar_anos_request.dart';
export 'src/models/regime_apuracao/consultar_anos_response.dart' hide MensagemNegocio;
export 'src/models/regime_apuracao/consultar_opcao_request.dart';
export 'src/models/regime_apuracao/consultar_opcao_response.dart' hide RegimeApuracao, MensagemNegocio;
export 'src/models/regime_apuracao/consultar_resolucao_request.dart';
export 'src/models/regime_apuracao/consultar_resolucao_response.dart' hide MensagemNegocio;

// Services
export 'src/services/ccmei_service.dart';
export 'src/services/pgdasd_service.dart';
export 'src/services/pgmei_service.dart';
export 'src/services/dctfweb_service.dart';
export 'src/services/procuracoes_service.dart';
export 'src/services/caixa_postal_service.dart';
export 'src/services/dte_service.dart';
export 'src/services/parcsn_service.dart';
export 'src/services/parcsn_especial_service.dart';
export 'src/services/pertsn_service.dart';
export 'src/services/relpsn_service.dart';
export 'src/services/parcmei_service.dart';
export 'src/services/parcmei_especial_service.dart';
export 'src/services/pertmei_service.dart';
export 'src/services/relpmei_service.dart';
export 'src/services/pagtoweb_service.dart';
export 'src/services/sitfis_service.dart';
export 'src/services/defis_service.dart';
export 'src/services/mit_service.dart';
export 'src/services/eventos_atualizacao_service.dart';
export 'src/services/autenticaprocurador_service.dart';
export 'src/services/regime_apuracao_service.dart';
