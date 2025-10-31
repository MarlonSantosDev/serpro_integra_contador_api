import 'dart:convert';
import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/caixa_postal/model/lista_mensagens_response.dart';
import 'package:serpro_integra_contador_api/src/services/caixa_postal/model/detalhes_mensagem_response.dart';
import 'package:serpro_integra_contador_api/src/services/caixa_postal/model/indicador_mensagens_response.dart';

/// **Serviço:** CAIXA POSTAL (Caixa Postal do Simples Nacional)
///
/// A Caixa Postal é um sistema de comunicação entre a Receita Federal e os contribuintes do Simples Nacional.
///
/// **Este serviço disponibiliza APENAS os 3 serviços oficiais da API SERPRO:**
/// - **MSGCONTRIBUINTE61**: Obter Lista de Mensagens por Contribuintes
/// - **MSGDETALHAMENTO62**: Obter Detalhes de uma Mensagem Específica
/// - **INNOVAMSG63**: Obter Indicador de Novas Mensagens
///
/// **Documentação oficial:** `.cursor/rules/caixapostal.mdc`
///
/// **Observação sobre variáveis:**
/// O campo `assuntoModelo` pode conter `++VARIAVEL++` que é substituído pelo valor de `valorParametroAssunto`.
/// O campo `corpoModelo` pode conter `++1++`, `++2++`, etc. que são substituídos pelos valores do array `variaveis`.
/// Exemplo: "[IRPF] Declaração do exercício ++VARIAVEL++ processada" com valorParametroAssunto="2023"
/// resulta em: "[IRPF] Declaração do exercício 2023 processada"
///
/// **Exemplo de uso:**
/// ```dart
/// final caixaPostalService = CaixaPostalService(apiClient);
///
/// // 1. Obter lista de mensagens
/// final mensagens = await caixaPostalService.obterListaMensagensPorContribuinte(
///   '12345678000190',
///   statusLeitura: 2, // 0=Todas, 1=Lida, 2=Não lida
///   indicadorFavorito: null, // 0=Não favorita, 1=Favorita, null=Sem filtro
/// );
///
/// // 2. Obter detalhes de uma mensagem
/// final detalhes = await caixaPostalService.obterDetalhesMensagemEspecifica(
///   '12345678000190',
///   '0001626772', // ISN da mensagem
/// );
///
/// // 3. Obter indicador de novas mensagens
/// final indicador = await caixaPostalService.obterIndicadorNovasMensagens('12345678000190');
/// ```
class CaixaPostalService {
  final ApiClient _apiClient;

  CaixaPostalService(this._apiClient);

  /// Obtém a lista de mensagens da Caixa Postal de um contribuinte
  ///
  /// **Serviço API:** MSGCONTRIBUINTE61
  /// **Endpoint:** /Consultar
  ///
  /// [contribuinte] - Número do CPF/CNPJ do contribuinte
  /// [cnpjReferencia] - Número do CNPJ para filtro (apenas para PJ)
  /// [statusLeitura] - Status da mensagem: 0=Todas (não se aplica), 1=Lida, 2=Não Lida
  /// [indicadorFavorito] - Filtro por favorita: 0=Não favorita, 1=Favorita, null=Sem filtro
  /// [indicadorPagina] - Página: 0=Inicial (mais recentes), 1=Não-inicial
  /// [ponteiroPagina] - Ponteiro para página (necessário se indicadorPagina=1)
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<ListaMensagensResponse> obterListaMensagensPorContribuinte(
    String contribuinte, {
    String? cnpjReferencia,
    int statusLeitura = 0,
    int? indicadorFavorito,
    int indicadorPagina = 0,
    String? ponteiroPagina,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
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

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ListaMensagensResponse.fromJson(response);
  }

  /// Obtém os detalhes de uma mensagem específica
  ///
  /// **Serviço API:** MSGDETALHAMENTO62
  /// **Endpoint:** /Consultar
  ///
  /// [contribuinte] - Número do CPF/CNPJ do contribuinte
  /// [isn] - Identificador único da mensagem (campo 'isn' retornado na lista de mensagens)
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  Future<DetalhesMensagemResponse> obterDetalhesMensagemEspecifica(
    String contribuinte,
    String isn, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = BaseRequest(
      contribuinteNumero: contribuinte,
      pedidoDados: PedidoDados(idSistema: 'CAIXAPOSTAL', idServico: 'MSGDETALHAMENTO62', versaoSistema: '1.0', dados: jsonEncode({'isn': isn})),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return DetalhesMensagemResponse.fromJson(response);
  }

  /// Obtém o indicador de mensagens novas para um contribuinte
  ///
  /// **Serviço API:** INNOVAMSG63
  /// **Endpoint:** /Monitorar
  ///
  /// [contribuinte] - Número do CPF/CNPJ do contribuinte
  /// [contratanteNumero] - CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// **Retorna:**
  /// - indicadorMensagensNovas: 0=Sem mensagens novas, 1=Uma mensagem nova, 2=Múltiplas mensagens novas
  Future<IndicadorMensagensResponse> obterIndicadorNovasMensagens(
    String contribuinte, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = BaseRequest(
      contribuinteNumero: contribuinte,
      pedidoDados: PedidoDados(idSistema: 'CAIXAPOSTAL', idServico: 'INNOVAMSG63', versaoSistema: '1.0', dados: ''),
    );
    final response = await _apiClient.post(
      '/Monitorar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return IndicadorMensagensResponse.fromJson(response);
  }
}
