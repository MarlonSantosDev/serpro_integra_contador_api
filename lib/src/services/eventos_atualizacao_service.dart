import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/eventos_atualizacao_common.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/solicitar_eventos_pf_request.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/solicitar_eventos_pf_response.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/obter_eventos_pf_request.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/obter_eventos_pf_response.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/solicitar_eventos_pj_request.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/solicitar_eventos_pj_response.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/obter_eventos_pj_request.dart';
import 'package:serpro_integra_contador_api/src/models/eventos_atualizacao/obter_eventos_pj_response.dart';

/// Serviço para consultar eventos de última atualização
///
/// Este serviço permite monitorar atualizações em sistemas de negócio
/// como DCTFWeb, CaixaPostal e PagamentoWeb para contribuintes específicos.
///
/// O processo é assíncrono: primeiro solicita os eventos, depois obtém os resultados
/// usando o protocolo retornado.
class EventosAtualizacaoService {
  final ApiClient _apiClient;

  EventosAtualizacaoService(this._apiClient);

  /// Solicita eventos de atualização para Pessoa Física
  ///
  /// [cpfs] Lista de CPFs (máximo 1000)
  /// [evento] Tipo de evento a ser monitorado
  ///
  /// Retorna um protocolo que deve ser usado posteriormente para obter os resultados
  Future<SolicitarEventosPFResponse> solicitarEventosPF({required List<String> cpfs, required TipoEvento evento}) async {
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

    final response = await _apiClient.post('/Monitorar', baseRequest);
    return SolicitarEventosPFResponse.fromJson(response);
  }

  /// Obtém os eventos de atualização de Pessoa Física usando o protocolo
  ///
  /// [protocolo] Protocolo retornado pela solicitação anterior
  /// [evento] Tipo de evento consultado
  ///
  /// Retorna a lista de eventos com as datas de última atualização
  Future<ObterEventosPFResponse> obterEventosPF({required String protocolo, required TipoEvento evento}) async {
    final request = ObterEventosPFRequest(protocolo: protocolo, evento: evento);

    final baseRequest = BaseRequest(
      contribuinteNumero: '', // Vazio para obter eventos
      pedidoDados: PedidoDados(
        idSistema: EventosAtualizacaoCommon.idSistema,
        idServico: EventosAtualizacaoCommon.obterEventosPF,
        versaoSistema: EventosAtualizacaoCommon.versaoSistema,
        dados: request.dadosJson,
      ),
    );

    final response = await _apiClient.post('/Monitorar', baseRequest);
    return ObterEventosPFResponse.fromJson(response);
  }

  /// Solicita eventos de atualização para Pessoa Jurídica
  ///
  /// [cnpjs] Lista de CNPJs (máximo 1000)
  /// [evento] Tipo de evento a ser monitorado
  ///
  /// Retorna um protocolo que deve ser usado posteriormente para obter os resultados
  Future<SolicitarEventosPJResponse> solicitarEventosPJ({required List<String> cnpjs, required TipoEvento evento}) async {
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

    final response = await _apiClient.post('/Monitorar', baseRequest);
    return SolicitarEventosPJResponse.fromJson(response);
  }

  /// Obtém os eventos de atualização de Pessoa Jurídica usando o protocolo
  ///
  /// [protocolo] Protocolo retornado pela solicitação anterior
  /// [evento] Tipo de evento consultado
  ///
  /// Retorna a lista de eventos com as datas de última atualização
  Future<ObterEventosPJResponse> obterEventosPJ({required String protocolo, required TipoEvento evento}) async {
    final request = ObterEventosPJRequest(protocolo: protocolo, evento: evento);

    final baseRequest = BaseRequest(
      contribuinteNumero: '', // Vazio para obter eventos
      pedidoDados: PedidoDados(
        idSistema: EventosAtualizacaoCommon.idSistema,
        idServico: EventosAtualizacaoCommon.obterEventosPJ,
        versaoSistema: EventosAtualizacaoCommon.versaoSistema,
        dados: request.dadosJson,
      ),
    );

    final response = await _apiClient.post('/Monitorar', baseRequest);
    return ObterEventosPJResponse.fromJson(response);
  }

  /// Método de conveniência para solicitar e obter eventos PF em uma única operação
  ///
  /// Aguarda o tempo estimado e retorna os resultados automaticamente
  Future<ObterEventosPFResponse> solicitarEObterEventosPF({
    required List<String> cpfs,
    required TipoEvento evento,
    Duration? tempoEsperaCustomizado,
  }) async {
    // Solicitar eventos
    final solicitacao = await solicitarEventosPF(cpfs: cpfs, evento: evento);

    // Aguardar o tempo estimado (ou customizado)
    final tempoEspera = tempoEsperaCustomizado ?? Duration(milliseconds: solicitacao.dados.tempoEsperaMedioEmMs);
    await Future.delayed(tempoEspera);

    // Obter resultados
    return obterEventosPF(protocolo: solicitacao.dados.protocolo, evento: evento);
  }

  /// Método de conveniência para solicitar e obter eventos PJ em uma única operação
  ///
  /// Aguarda o tempo estimado e retorna os resultados automaticamente
  Future<ObterEventosPJResponse> solicitarEObterEventosPJ({
    required List<String> cnpjs,
    required TipoEvento evento,
    Duration? tempoEsperaCustomizado,
  }) async {
    // Solicitar eventos
    final solicitacao = await solicitarEventosPJ(cnpjs: cnpjs, evento: evento);

    // Aguardar o tempo estimado (ou customizado)
    final tempoEspera = tempoEsperaCustomizado ?? Duration(milliseconds: solicitacao.dados.tempoEsperaMedioEmMs);
    await Future.delayed(tempoEspera);

    // Obter resultados
    return obterEventosPJ(protocolo: solicitacao.dados.protocolo, evento: evento);
  }
}
