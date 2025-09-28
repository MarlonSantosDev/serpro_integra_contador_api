import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/mit/mit_request.dart';
import 'package:serpro_integra_contador_api/src/models/mit/mit_response.dart';
import 'package:serpro_integra_contador_api/src/models/mit/mit_enums.dart';

/// Serviço para integração com MIT (Módulo de Inclusão de Tributos)
///
/// Implementa todos os serviços disponíveis do Integra MIT:
/// - Encerrar Apuração (ENCAPURACAO314)
/// - Consultar Situação Encerramento (SITUACAOENC315)
/// - Consultar Apuração (CONSAPURACAO316)
/// - Listar Apurações (LISTAAPURACOES317)
class MitService {
  final ApiClient _apiClient;

  MitService(this._apiClient);

  /// Encerra uma apuração MIT
  ///
  /// Este serviço inicia o processo de encerramento de uma apuração do Módulo
  /// de Inclusão de Tributos do sistema DCTFWeb.
  ///
  /// A apuração NÃO será enviada à DCTFWEB no momento da requisição.
  /// O envio será feito automaticamente em momento posterior.
  ///
  /// Utilize o serviço [consultarSituacaoEncerramento] gratuitamente passando
  /// o protocoloEncerramento devolvido neste serviço para consultar o status do envio.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte (apenas PJ é aceito)
  /// [periodoApuracao] Período da apuração (mês e ano)
  /// [dadosIniciais] Dados iniciais da apuração
  /// [debitos] Débitos da apuração (obrigatório se não for sem movimento)
  /// [listaEventosEspeciais] Lista de eventos especiais (máximo 5)
  /// [transmissaoImediata] Indicador de transmissão imediata (apenas para sem movimento)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<EncerrarApuracaoResponse> encerrarApuracao({
    required String contribuinteNumero,
    required PeriodoApuracao periodoApuracao,
    required DadosIniciais dadosIniciais,
    Debitos? debitos,
    List<EventoEspecial>? listaEventosEspeciais,
    bool? transmissaoImediata,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EncerrarApuracaoRequest(
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      debitos: debitos,
      listaEventosEspeciais: listaEventosEspeciais,
      transmissaoImediata: transmissaoImediata,
    );

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'MIT', idServico: 'ENCAPURACAO314', versaoSistema: '1.0', dados: request.toDadosJson()),
    );

    final endpoint = _obterEndpoint('ENCAPURACAO314');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return EncerrarApuracaoResponse.fromJson(response);
  }

  /// Consulta a situação de encerramento de uma apuração MIT
  ///
  /// Este serviço oferece uma solução para a consulta assíncrona do encerramento
  /// de uma apuração no Módulo de Inclusão de Tributos do sistema DCTFWeb.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [protocoloEncerramento] Protocolo retornado pelo serviço de encerramento
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ConsultarSituacaoEncerramentoResponse> consultarSituacaoEncerramento({
    required String contribuinteNumero,
    required String protocoloEncerramento,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ConsultarSituacaoEncerramentoRequest(protocoloEncerramento: protocoloEncerramento);

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'MIT', idServico: 'SITUACAOENC315', versaoSistema: '1.0', dados: request.toDadosJson()),
    );

    final endpoint = _obterEndpoint('SITUACAOENC315');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarSituacaoEncerramentoResponse.fromJson(response);
  }

  /// Consulta os dados de uma apuração MIT
  ///
  /// O serviço permite consultar as apurações registradas no sistema,
  /// proporcionando acesso rápido e seguro às informações detalhadas.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [idApuracao] ID da apuração obtido no serviço de encerramento
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ConsultarApuracaoResponse> consultarApuracao({
    required String contribuinteNumero,
    required int idApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ConsultarApuracaoRequest(idApuracao: idApuracao);

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'MIT', idServico: 'CONSAPURACAO316', versaoSistema: '1.0', dados: request.toDadosJson()),
    );

    final endpoint = _obterEndpoint('CONSAPURACAO316');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarApuracaoResponse.fromJson(response);
  }

  /// Lista todas as apurações MIT por ano ou mês
  ///
  /// O serviço permite listar todas as apurações MIT por ano ou mês.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoApuracao] Ano da apuração (obrigatório)
  /// [mesApuracao] Mês da apuração (opcional)
  /// [situacaoApuracao] Situação da apuração (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ListarApuracaoesResponse> listarApuracaoes({
    required String contribuinteNumero,
    required int anoApuracao,
    int? mesApuracao,
    int? situacaoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = ListarApuracaoesRequest(anoApuracao: anoApuracao, mesApuracao: mesApuracao, situacaoApuracao: situacaoApuracao);

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(idSistema: 'MIT', idServico: 'LISTAAPURACOES317', versaoSistema: '1.0', dados: request.toDadosJson()),
    );

    final endpoint = _obterEndpoint('LISTAAPURACOES317');
    final response = await _apiClient.post(
      endpoint,
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ListarApuracaoesResponse.fromJson(response);
  }

  // MÉTODOS DE CONVENIÊNCIA

  /// Cria uma apuração sem movimento (para DCTFWeb sem movimento)
  ///
  /// Método de conveniência para criar uma apuração sem movimento,
  /// que será transmitida automaticamente para a DCTFWeb.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período da apuração
  /// [responsavelApuracao] Dados do responsável pela apuração
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<EncerrarApuracaoResponse> criarApuracaoSemMovimento({
    required String contribuinteNumero,
    required PeriodoApuracao periodoApuracao,
    required ResponsavelApuracao responsavelApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dadosIniciais = DadosIniciais(semMovimento: true, qualificacaoPj: QualificacaoPj.pjEmGeral, responsavelApuracao: responsavelApuracao);

    return encerrarApuracao(
      contribuinteNumero: contribuinteNumero,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      transmissaoImediata: true,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Cria uma apuração com movimento básica
  ///
  /// Método de conveniência para criar uma apuração com movimento
  /// com configurações básicas.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [periodoApuracao] Período da apuração
  /// [responsavelApuracao] Dados do responsável pela apuração
  /// [debitos] Débitos da apuração
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<EncerrarApuracaoResponse> criarApuracaoComMovimento({
    required String contribuinteNumero,
    required PeriodoApuracao periodoApuracao,
    required ResponsavelApuracao responsavelApuracao,
    required Debitos debitos,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final dadosIniciais = DadosIniciais(
      semMovimento: false,
      qualificacaoPj: QualificacaoPj.pjEmGeral,
      tributacaoLucro: TributacaoLucro.realAnual,
      variacoesMonetarias: VariacoesMonetarias.regimeCaixa,
      regimePisCofins: RegimePisCofins.naoCumulativa,
      responsavelApuracao: responsavelApuracao,
    );

    return encerrarApuracao(
      contribuinteNumero: contribuinteNumero,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      debitos: debitos,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta apurações por período específico
  ///
  /// Método de conveniência para consultar apurações de um mês específico.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoApuracao] Ano da apuração
  /// [mesApuracao] Mês da apuração
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ListarApuracaoesResponse> consultarApuracaoesPorMes({
    required String contribuinteNumero,
    required int anoApuracao,
    required int mesApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return listarApuracaoes(
      contribuinteNumero: contribuinteNumero,
      anoApuracao: anoApuracao,
      mesApuracao: mesApuracao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta apurações encerradas
  ///
  /// Método de conveniência para consultar apenas apurações encerradas.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoApuracao] Ano da apuração
  /// [mesApuracao] Mês da apuração (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ListarApuracaoesResponse> consultarApuracaoesEncerradas({
    required String contribuinteNumero,
    required int anoApuracao,
    int? mesApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return listarApuracaoes(
      contribuinteNumero: contribuinteNumero,
      anoApuracao: anoApuracao,
      mesApuracao: mesApuracao,
      situacaoApuracao: SituacaoApuracao.encerrada.codigo,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Aguarda o encerramento de uma apuração
  ///
  /// Método utilitário que consulta periodicamente o status de encerramento
  /// até que a apuração seja encerrada ou ocorra timeout.
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [protocoloEncerramento] Protocolo retornado pelo serviço de encerramento
  /// [intervaloConsulta] Intervalo entre consultas em segundos (padrão: 30)
  /// [timeoutSegundos] Timeout máximo em segundos (padrão: 300)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ConsultarSituacaoEncerramentoResponse> aguardarEncerramento({
    required String contribuinteNumero,
    required String protocoloEncerramento,
    int intervaloConsulta = 30,
    int timeoutSegundos = 300,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final inicio = DateTime.now();

    while (DateTime.now().difference(inicio).inSeconds < timeoutSegundos) {
      final response = await consultarSituacaoEncerramento(
        contribuinteNumero: contribuinteNumero,
        protocoloEncerramento: protocoloEncerramento,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Se a apuração foi encerrada ou houve erro, retorna
      if (response.situacaoEnum == SituacaoApuracao.encerrada ||
          response.situacaoEnum == SituacaoApuracao.emEdicaoComPendencias ||
          !response.sucesso) {
        return response;
      }

      // Aguarda antes da próxima consulta
      await Future.delayed(Duration(seconds: intervaloConsulta));
    }

    // Timeout - retorna a última resposta
    return await consultarSituacaoEncerramento(
      contribuinteNumero: contribuinteNumero,
      protocoloEncerramento: protocoloEncerramento,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Obtém o endpoint para o serviço MIT
  String _obterEndpoint(String idServico) {
    // URLs base dos serviços MIT
    const endpoints = {
      'ENCAPURACAO314': 'https://apigateway.serpro.gov.br/integra-contador-dctfweb-trial/v1/mit/encerrar-apuracao',
      'SITUACAOENC315': 'https://apigateway.serpro.gov.br/integra-contador-dctfweb-trial/v1/mit/consultar-situacao-encerramento',
      'CONSAPURACAO316': 'https://apigateway.serpro.gov.br/integra-contador-dctfweb-trial/v1/mit/consultar-apuracao',
      'LISTAAPURACOES317': 'https://apigateway.serpro.gov.br/integra-contador-dctfweb-trial/v1/mit/listar-apuracoes',
    };

    return endpoints[idServico] ?? 'https://apigateway.serpro.gov.br/integra-contador-dctfweb-trial/v1/mit/$idServico';
  }
}
