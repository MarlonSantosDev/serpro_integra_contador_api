import 'dart:convert';
import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/caixa_postal/lista_mensagens_response.dart';
import 'package:serpro_integra_contador_api/src/models/caixa_postal/detalhes_mensagem_response.dart';
import 'package:serpro_integra_contador_api/src/models/caixa_postal/indicador_mensagens_response.dart';

/// Serviço para operações da Caixa Postal
class CaixaPostalService {
  final ApiClient _apiClient;

  CaixaPostalService(this._apiClient);

  /// Obtém a lista de mensagens da Caixa Postal de um contribuinte
  ///
  /// [contribuinte] - Número do CPF/CNPJ do contribuinte
  /// [cnpjReferencia] - Número do CNPJ para filtro (apenas para PJ)
  /// [statusLeitura] - Status da mensagem: 0=Não se aplica, 1=Lida, 2=Não Lida
  /// [indicadorFavorito] - Filtro por favorita: 0=Não favorita, 1=Favorita
  /// [indicadorPagina] - Página: 0=Inicial (mais recentes), 1=Não-inicial
  /// [ponteiroPagina] - Ponteiro para página (necessário se indicadorPagina=1)
  Future<ListaMensagensResponse> obterListaMensagensPorContribuinte(
    String contribuinte, {
    String? cnpjReferencia,
    int statusLeitura = 0,
    int? indicadorFavorito,
    int indicadorPagina = 0,
    String? ponteiroPagina,
  }) async {
    final dadosMap = <String, dynamic>{'statusLeitura': statusLeitura.toString(), 'indicadorPagina': indicadorPagina.toString()};

    if (cnpjReferencia != null && cnpjReferencia.isNotEmpty) {
      dadosMap['cnpjReferencia'] = cnpjReferencia;
    }

    if (indicadorFavorito != null) {
      dadosMap['indicadorFavorito'] = indicadorFavorito.toString();
    }

    if (ponteiroPagina != null && ponteiroPagina.isNotEmpty) {
      dadosMap['ponteiroPagina'] = ponteiroPagina;
    } else if (indicadorPagina == 0) {
      dadosMap['ponteiroPagina'] = '00000000000000';
    }

    final request = BaseRequest(
      contribuinteNumero: contribuinte,
      pedidoDados: PedidoDados(idSistema: 'CAIXAPOSTAL', idServico: 'MSGCONTRIBUINTE61', versaoSistema: '1.0', dados: jsonEncode(dadosMap)),
    );

    final response = await _apiClient.post('/Consultar', request);
    return ListaMensagensResponse.fromJson(response);
  }

  /// Obtém os detalhes de uma mensagem específica
  ///
  /// [contribuinte] - Número do CPF/CNPJ do contribuinte
  /// [isn] - Identificador único da mensagem
  Future<DetalhesMensagemResponse> obterDetalhesMensagemEspecifica(String contribuinte, String isn) async {
    final request = BaseRequest(
      contribuinteNumero: contribuinte,
      pedidoDados: PedidoDados(idSistema: 'CAIXAPOSTAL', idServico: 'MSGDETALHAMENTO62', versaoSistema: '1.0', dados: jsonEncode({'isn': isn})),
    );

    final response = await _apiClient.post('/Consultar', request);
    return DetalhesMensagemResponse.fromJson(response);
  }

  /// Obtém o indicador de mensagens novas para um contribuinte
  ///
  /// [contribuinte] - Número do CPF/CNPJ do contribuinte
  ///
  /// Retorna:
  /// - 0: Contribuinte não possui mensagens novas
  /// - 1: Contribuinte possui uma mensagem nova
  /// - 2: Contribuinte possui mensagens novas
  Future<IndicadorMensagensResponse> obterIndicadorNovasMensagens(String contribuinte) async {
    final request = BaseRequest(
      contribuinteNumero: contribuinte,
      pedidoDados: PedidoDados(idSistema: 'CAIXAPOSTAL', idServico: 'INNOVAMSG63', versaoSistema: '1.0', dados: ''),
    );
    final response = await _apiClient.post('/Monitorar', request);
    return IndicadorMensagensResponse.fromJson(response);
  }

  // Métodos de conveniência com nomes mais simples

  /// Alias para obterListaMensagensPorContribuinte - obtém todas as mensagens
  Future<ListaMensagensResponse> listarTodasMensagens(String contribuinte) {
    return obterListaMensagensPorContribuinte(contribuinte, statusLeitura: 0);
  }

  /// Obtém apenas mensagens não lidas
  Future<ListaMensagensResponse> listarMensagensNaoLidas(String contribuinte) {
    return obterListaMensagensPorContribuinte(contribuinte, statusLeitura: 2);
  }

  /// Obtém apenas mensagens lidas
  Future<ListaMensagensResponse> listarMensagensLidas(String contribuinte) {
    return obterListaMensagensPorContribuinte(contribuinte, statusLeitura: 1);
  }

  /// Obtém apenas mensagens favoritas
  Future<ListaMensagensResponse> listarMensagensFavoritas(String contribuinte) {
    return obterListaMensagensPorContribuinte(contribuinte, indicadorFavorito: 1);
  }

  /// Obtém mensagens com paginação
  Future<ListaMensagensResponse> listarMensagensComPaginacao(
    String contribuinte, {
    required String ponteiroPagina,
    int statusLeitura = 0,
    int? indicadorFavorito,
  }) {
    return obterListaMensagensPorContribuinte(
      contribuinte,
      statusLeitura: statusLeitura,
      indicadorFavorito: indicadorFavorito,
      indicadorPagina: 1,
      ponteiroPagina: ponteiroPagina,
    );
  }

  /// Verifica se há mensagens novas (método de conveniência)
  Future<bool> temMensagensNovas(String contribuinte) async {
    final response = await obterIndicadorNovasMensagens(contribuinte);
    return response.dadosParsed?.conteudo.isNotEmpty == true && response.dadosParsed!.conteudo.first.temMensagensNovas;
  }
}
