import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/eventos_atualizacao_common.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/solicitar_eventos_pf_request.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/solicitar_eventos_pf_response.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/obter_eventos_pf_request.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/obter_eventos_pf_response.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/solicitar_eventos_pj_request.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/solicitar_eventos_pj_response.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/obter_eventos_pj_request.dart';
import 'package:serpro_integra_contador_api/src/services/eventos_atualizacao/model/obter_eventos_pj_response.dart';

/// **Serviço:** EVENTOS DE ATUALIZAÇÃO
///
/// O serviço de eventos de atualização permite monitorar mudanças em sistemas de negócio
/// como DCTFWeb, Caixa Postal e PagamentoWeb para contribuintes específicos.
///
/// **Este serviço permite:**
/// - Solicitar eventos para Pessoa Física (SOLICITAREVENTOS-PF291)
/// - Obter eventos solicitados para PF (OBTEREVENTOS-PF292)
/// - Solicitar eventos para Pessoa Jurídica (SOLICITAREVENTOS-PJ293)
/// - Obter eventos solicitados para PJ (OBTEREVENTOS-PJ294)
///
/// **Documentação oficial:** `.cursor/rules/eventos_atualizacao.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final eventosService = EventosAtualizacaoService(apiClient);
///
/// // Solicitar eventos para PJ
/// final solicitacao = await eventosService.solicitarEventosPJ(
///   cnpjs: ['12345678000190'],
///   evento: TipoEvento.dctfWeb,
/// );
/// print('Protocolo: ${solicitacao.protocolo}');
///
/// // Obter eventos após processamento (aguardar alguns segundos)
/// final eventos = await eventosService.obterEventosPJ(
///   protocolo: solicitacao.protocolo,
/// );
/// print('Eventos: ${eventos.eventos.length}');
/// ```
class EventosAtualizacaoService {
  final ApiClient _apiClient;

  EventosAtualizacaoService(this._apiClient);

  /// Solicita eventos de atualização para Pessoa Física
  ///
  /// [cpfs] Lista de CPFs (máximo 1000)
  /// [evento] Tipo de evento a ser monitorado
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna um protocolo que deve ser usado posteriormente para obter os resultados
  Future<SolicitarEventosPFResponse> solicitarEventosPF({
    required List<String> cpfs,
    required TipoEvento evento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = SolicitarEventosPFRequest(cpfs: cpfs, evento: evento);
    final baseRequest = BaseRequest(
      contribuinteNumero: request.cpfsString,
      pedidoDados: PedidoDados(
        idSistema: EventosAtualizacaoCommon.idSistema,
        idServico: EventosAtualizacaoCommon.solicitarEventosPF,
        versaoSistema: EventosAtualizacaoCommon.versaoSistema,
        dados: request.dadosJson,
      ),
    );

    final response = await _apiClient.post(
      '/Monitorar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return SolicitarEventosPFResponse.fromJson(response);
  }

  /// Obtém os eventos de atualização de Pessoa Física usando o protocolo
  ///
  /// [protocolo] Protocolo retornado pela solicitação anterior
  /// [evento] Tipo de evento consultado
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna a lista de eventos com as datas de última atualização
  Future<ObterEventosPFResponse> obterEventosPF({
    required String protocolo,
    required TipoEvento evento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ObterEventosPFRequest(protocolo: protocolo, evento: evento);

    final baseRequest = BaseRequest(
      contribuinteNumero: '00000000000', // Placeholder para obter eventos
      pedidoDados: PedidoDados(
        idSistema: EventosAtualizacaoCommon.idSistema,
        idServico: EventosAtualizacaoCommon.obterEventosPF,
        versaoSistema: EventosAtualizacaoCommon.versaoSistema,
        dados: request.dadosJson,
      ),
    );

    final response = await _apiClient.post(
      '/Monitorar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ObterEventosPFResponse.fromJson(response);
  }

  /// Solicita eventos de atualização para Pessoa Jurídica
  ///
  /// [cnpjs] Lista de CNPJs (máximo 1000)
  /// [evento] Tipo de evento a ser monitorado
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna um protocolo que deve ser usado posteriormente para obter os resultados
  Future<SolicitarEventosPJResponse> solicitarEventosPJ({
    required List<String> cnpjs,
    required TipoEvento evento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = SolicitarEventosPJRequest(cnpjs: cnpjs, evento: evento);

    final baseRequest = BaseRequest(
      contribuinteNumero: request.cnpjsString,
      pedidoDados: PedidoDados(
        idSistema: EventosAtualizacaoCommon.idSistema,
        idServico: EventosAtualizacaoCommon.solicitarEventosPJ,
        versaoSistema: EventosAtualizacaoCommon.versaoSistema,
        dados: request.dadosJson,
      ),
    );

    final response = await _apiClient.post(
      '/Monitorar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return SolicitarEventosPJResponse.fromJson(response);
  }

  /// Obtém os eventos de atualização de Pessoa Jurídica usando o protocolo
  ///
  /// [protocolo] Protocolo retornado pela solicitação anterior
  /// [evento] Tipo de evento consultado
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna a lista de eventos com as datas de última atualização
  Future<ObterEventosPJResponse> obterEventosPJ({
    required String protocolo,
    required TipoEvento evento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ObterEventosPJRequest(protocolo: protocolo, evento: evento);

    final baseRequest = BaseRequest(
      contribuinteNumero: '00000000000000', // Placeholder para obter eventos
      pedidoDados: PedidoDados(
        idSistema: EventosAtualizacaoCommon.idSistema,
        idServico: EventosAtualizacaoCommon.obterEventosPJ,
        versaoSistema: EventosAtualizacaoCommon.versaoSistema,
        dados: request.dadosJson,
      ),
    );

    final response = await _apiClient.post(
      '/Monitorar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ObterEventosPJResponse.fromJson(response);
  }

  /// Método de conveniência para solicitar e obter eventos PF em uma única operação
  ///
  /// Aguarda o tempo estimado e retorna os resultados automaticamente
  Future<ObterEventosPFResponse> solicitarEObterEventosPF({
    required List<String> cpfs,
    required TipoEvento evento,
    Duration? tempoEsperaCustomizado,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Solicitar eventos
    final solicitacao = await solicitarEventosPF(
      cpfs: cpfs,
      evento: evento,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    // Aguardar o tempo estimado (ou customizado)
    final tempoEspera =
        tempoEsperaCustomizado ??
        Duration(milliseconds: solicitacao.dados.tempoEsperaMedioEmMs);
    await Future.delayed(tempoEspera);

    // Obter resultados
    return obterEventosPF(
      protocolo: solicitacao.dados.protocolo,
      evento: evento,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }
}
