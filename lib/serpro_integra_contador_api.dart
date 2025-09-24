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

// Base Models
export 'src/models/base/base_request.dart';

// CCMEI Models
export 'src/models/ccmei/emitir_ccmei_response.dart';
export 'src/models/ccmei/consultar_dados_ccmei_response.dart';

// PGDASD Models
export 'src/models/pgdasd/declarar_response.dart';

// PGMEI Models
export 'src/models/pgmei/gerar_das_response.dart';

// DCTFWeb Models
export 'src/models/dctfweb/dctfweb_response.dart';

// Procurações Models
export 'src/models/procuracoes/procuracoes_response.dart';

// Caixa Postal Models
export 'src/models/caixa_postal/caixa_postal_response.dart';

// DTE Models
export 'src/models/dte/dte_response.dart';

// PagamentoWEB Models
export 'src/models/pagamentoweb/pagamentoweb_response.dart';

// PARCSN Models
export 'src/models/parcsn/parcsn_response.dart';

// PARCSN ESPECIAL Models
export 'src/models/parcsn_especial/parcsn_especial_response.dart';

// PERTSN Models
export 'src/models/pertsn/pertsn_response.dart';

// RELPSN Models
export 'src/models/relpsn/relpsn_response.dart';

// PARCMEI Models
export 'src/models/parcmei/parcmei_response.dart';

// PARCMEI ESPECIAL Models
export 'src/models/parcmei_especial/parcmei_especial_response.dart';

// PERTMEI Models
export 'src/models/pertmei/pertmei_response.dart';

// RELPMEI Models
export 'src/models/relpmei/relpmei_response.dart';

// Sicalc Models
export 'src/models/sicalc/sicalc_response.dart';

// PAGTOWEB Models
export 'src/models/pagtoweb/pagtoweb_response.dart';

// SITFIS Models
export 'src/models/sitfis/sitfis_response.dart';

// DEFIS Models
export 'src/models/defis/transmitir_declaracao_request.dart';
export 'src/models/defis/transmitir_declaracao_response.dart';
export 'src/models/defis/defis_response.dart';

// Services
export 'src/services/ccmei_service.dart';
export 'src/services/pgdasd_service.dart';
export 'src/services/pgmei_service.dart';
export 'src/services/dctfweb_service.dart';
export 'src/services/procuracoes_service.dart';
export 'src/services/caixa_postal_service.dart';
export 'src/services/dte_service.dart';
export 'src/services/pagamentoweb_service.dart';
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
