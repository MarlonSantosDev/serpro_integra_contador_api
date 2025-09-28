/// Package para acessar a API do SERPRO Integra Contador
///
/// Este package fornece uma interface Dart para interagir com todos os serviços
/// disponíveis na API do SERPRO Integra Contador, incluindo DEFIS, PGDASD,
/// PGMEI, CCMEI e outros.
library serpro_integra_contador_api;

// Core
export 'src/core/api_client.dart';
export 'src/core/auth/authentication_model.dart';

// Utilities
export 'src/util/document_utils.dart';
export 'src/util/message_utils.dart';
export 'src/util/dctfweb_utils.dart';
export 'src/util/sicalc_utils.dart';

// Base Models
export 'src/models/base/base_request.dart';
// CCMEI Models
export 'src/models/ccmei/mensagem_ccmei.dart';
export 'src/models/ccmei/emitir_ccmei_response.dart';
export 'src/models/ccmei/consultar_dados_ccmei_response.dart';
export 'src/models/ccmei/consultar_situacao_cadastral_ccmei_response.dart';

// PGDASD Models
export 'src/models/pgdasd/declarar_response.dart';

// PGMEI Models
export 'src/models/pgmei/gerar_das_response.dart';

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

// Caixa Postal Models
export 'src/models/caixa_postal/mensagem_negocio.dart' hide MensagemNegocio;
export 'src/models/caixa_postal/lista_mensagens_response.dart';
export 'src/models/caixa_postal/detalhes_mensagem_response.dart';
export 'src/models/caixa_postal/indicador_mensagens_response.dart';

// DTE Models
export 'src/models/dte/dte_response.dart' hide MensagemNegocio;

// SITFIS Models
export 'src/models/sitfis/solicitar_protocolo_request.dart';
export 'src/models/sitfis/solicitar_protocolo_response.dart';
export 'src/models/sitfis/emitir_relatorio_request.dart';
export 'src/models/sitfis/emitir_relatorio_response.dart';
export 'src/models/sitfis/sitfis_mensagens.dart';
export 'src/models/sitfis/sitfis_cache.dart';

// PARCSN Models
export 'src/models/parcsn/parcsn_response.dart';
export 'src/models/parcsn/mensagem.dart' hide Mensagem;
export 'src/models/parcsn/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/parcsn/consultar_parcelamento_response.dart'
    hide ConsultarParcelamentoResponse, ParcelamentoDetalhado, ConsolidacaoOriginal, DetalhesConsolidacao, AlteracaoDivida, DemonstrativoPagamento;
export 'src/models/parcsn/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/parcsn/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/parcsn/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/parcsn/parcsn_validations.dart';
export 'src/models/parcsn/parcsn_errors.dart' hide PertsnErrors, PertsnErrorInfo, PertsnErrorAnalysis;

// PARCSN ESPECIAL Models
export 'src/models/parcsn_especial/parcsn_especial_response.dart';
export 'src/models/parcsn_especial/mensagem.dart' hide Mensagem;
export 'src/models/parcsn_especial/consultar_pedidos_response.dart' hide ConsultarPedidosResponse, ParcelamentosData, Parcelamento;
export 'src/models/parcsn_especial/consultar_parcelamento_response.dart'
    hide ConsultarParcelamentoResponse, ParcelamentoDetalhado, ConsolidacaoOriginal, DetalhesConsolidacao, AlteracaoDivida, DemonstrativoPagamento;
export 'src/models/parcsn_especial/consultar_detalhes_pagamento_response.dart'
    hide ConsultarDetalhesPagamentoResponse, DetalhesPagamentoData, PagamentoDebito, DiscriminacaoDebito;
export 'src/models/parcsn_especial/consultar_parcelas_response.dart' hide ConsultarParcelasResponse, ListaParcelasData, Parcela;
export 'src/models/parcsn_especial/emitir_das_response.dart' hide EmitirDasResponse, DasData;
export 'src/models/parcsn_especial/parcsn_especial_validations.dart';
export 'src/models/parcsn_especial/parcsn_especial_errors.dart' hide ParcsnEspecialErrors, ParcsnEspecialErrorInfo, ParcsnEspecialErrorAnalysis;

// PERTSN Models
export 'src/models/pertsn/pertsn_response.dart';
export 'src/models/pertsn/mensagem.dart' hide Mensagem;
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
export 'src/models/pertsn/pertsn_errors.dart';

// RELPSN Models
export 'src/models/relpsn/mensagem.dart';
export 'src/models/relpsn/consultar_pedidos_response.dart';
export 'src/models/relpsn/consultar_parcelamento_response.dart';
export 'src/models/relpsn/consultar_parcelas_response.dart';
export 'src/models/relpsn/consultar_detalhes_pagamento_response.dart';
export 'src/models/relpsn/emitir_das_response.dart';
export 'src/models/relpsn/relpsn_validations.dart';
export 'src/models/relpsn/relpsn_errors.dart';

// PARCMEI Models
export 'src/models/parcmei/parcmei_response.dart';
export 'src/models/parcmei/mensagem.dart' hide Mensagem;
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
export 'src/models/parcmei_especial/mensagem.dart' hide Mensagem;
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

// Sicalc Models
export 'src/models/sicalc/sicalc_response.dart';
export 'src/models/sicalc/consolidar_darf_request.dart';
export 'src/models/sicalc/consolidar_darf_response.dart';
export 'src/models/sicalc/consultar_receita_request.dart';
export 'src/models/sicalc/consultar_receita_response.dart';
export 'src/models/sicalc/gerar_codigo_barras_request.dart';
export 'src/models/sicalc/gerar_codigo_barras_response.dart';

// PAGTOWEB Models
export 'src/models/pagtoweb/pagtoweb_request.dart';
export 'src/models/pagtoweb/pagtoweb_response.dart' hide MensagemNegocio;

// DEFIS Models
export 'src/models/defis/transmitir_declaracao_request.dart';
export 'src/models/defis/transmitir_declaracao_response.dart';
export 'src/models/defis/defis_response.dart';

// MIT Models
export 'src/models/mit/mit_enums.dart' hide TipoDocumento;
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
export 'src/services/sicalc_service.dart';
export 'src/services/pagtoweb_service.dart';
export 'src/services/sitfis_service.dart';
export 'src/services/defis_service.dart';
export 'src/services/mit_service.dart';
export 'src/services/eventos_atualizacao_service.dart';
