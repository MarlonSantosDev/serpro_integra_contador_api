import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/mit/model/mit_request.dart';
import 'package:serpro_integra_contador_api/src/services/mit/model/mit_response.dart';
import 'package:serpro_integra_contador_api/src/services/mit/model/mit_enums.dart';

/// **Serviço:** MIT (Módulo de Inclusão de Tributos)
///
/// O MIT é um módulo para apuração de tributos no sistema DCTFWeb.
///
/// **Este serviço permite:**
/// - Encerrar apuração (ENCAPURACAO314)
/// - Consultar situação do encerramento (SITUACAOENC315)
/// - Consultar apuração específica (CONSAPURACAO316)
/// - Listar todas as apurações (LISTAAPURACOES317)
///
/// **Documentação oficial:** `.cursor/rules/mit.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final mitService = MitService(apiClient);
///
/// // Encerrar apuração
/// final resultado = await mitService.encerrarApuracao(
///   contribuinteNumero: '12345678000190',
///   anoMes: 202401,
/// );
/// print('Protocolo: ${resultado.protocoloEncerramento}');
///
/// // Consultar situação do encerramento
/// final situacao = await mitService.consultarSituacaoEncerramento(
///   contribuinteNumero: '12345678000190',
///   protocoloEncerramento: resultado.protocoloEncerramento,
/// );
/// print('Situação: ${situacao.situacao}');
/// ```
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
  /// [creditos] Créditos da apuração (opcional)
  /// [listaEventosEspeciais] Lista de eventos especiais (máximo 5)
  /// [transmissaoImediata] Indicador de transmissão imediata (apenas para sem movimento)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<EncerrarApuracaoResponse> encerrarApuracao({
    required String contribuinteNumero,
    required PeriodoApuracao periodoApuracao,
    required DadosIniciais dadosIniciais,
    Debitos? debitos,
    Creditos? creditos,
    List<EventoEspecial>? listaEventosEspeciais,
    bool? transmissaoImediata,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final request = EncerrarApuracaoRequest(
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      debitos: debitos,
      creditos: creditos,
      listaEventosEspeciais: listaEventosEspeciais,
      transmissaoImediata: transmissaoImediata,
    );

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'MIT',
        idServico: 'ENCAPURACAO314',
        versaoSistema: '1.0',
        dados: request.toDadosJson(),
      ),
    );

    final response = await _apiClient.post(
      '/Declarar',
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
    final request = ConsultarSituacaoEncerramentoRequest(
      protocoloEncerramento: protocoloEncerramento,
    );

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'MIT',
        idServico: 'SITUACAOENC315',
        versaoSistema: '1.0',
        dados: request.toDadosJson(),
      ),
    );

    final response = await _apiClient.post(
      '/Apoiar',
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
      pedidoDados: PedidoDados(
        idSistema: 'MIT',
        idServico: 'CONSAPURACAO316',
        versaoSistema: '1.0',
        dados: request.toDadosJson(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ConsultarApuracaoResponse.fromJson(response);
  }

  /// Lista todas as apurações MIT por ano ou mês
  ///
  /// Este serviço permite listar todas as apurações MIT por ano ou mês,
  /// proporcionando uma visão geral das apurações do contribuinte.
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
    final request = ListarApuracaoesRequest(
      anoApuracao: anoApuracao,
      mesApuracao: mesApuracao,
      situacaoApuracao: situacaoApuracao,
    );

    final baseRequest = BaseRequest(
      contribuinteNumero: contribuinteNumero,
      pedidoDados: PedidoDados(
        idSistema: 'MIT',
        idServico: 'LISTAAPURACOES317',
        versaoSistema: '1.0',
        dados: request.toDadosJson(),
      ),
    );

    final response = await _apiClient.post(
      '/Consultar',
      baseRequest,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );

    return ListarApuracaoesResponse.fromJson(response);
  }

  // ========== MÉTODOS AUXILIARES E CONVENIÊNCIA ==========

  /// Cria uma apuração sem movimento de forma simplificada
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [mesApuracao] Mês da apuração (1-12)
  /// [anoApuracao] Ano da apuração
  /// [qualificacaoPj] Qualificação da PJ (padrão: PJ em geral)
  /// [cpfResponsavel] CPF do responsável pela apuração
  /// [emailResponsavel] E-mail do responsável (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<EncerrarApuracaoResponse> criarApuracaoSemMovimento({
    required String contribuinteNumero,
    required int mesApuracao,
    required int anoApuracao,
    QualificacaoPj qualificacaoPj = QualificacaoPj.pjEmGeral,
    required String cpfResponsavel,
    String? emailResponsavel,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final periodoApuracao = PeriodoApuracao(
      mesApuracao: mesApuracao,
      anoApuracao: anoApuracao,
    );

    final responsavelApuracao = ResponsavelApuracao(
      cpfResponsavel: cpfResponsavel,
      emailResponsavel: emailResponsavel,
    );

    final dadosIniciais = DadosIniciais(
      semMovimento: true,
      qualificacaoPj: qualificacaoPj,
      responsavelApuracao: responsavelApuracao,
    );

    return await encerrarApuracao(
      contribuinteNumero: contribuinteNumero,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      transmissaoImediata: true,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Cria uma apuração com movimento de forma simplificada
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [mesApuracao] Mês da apuração (1-12)
  /// [anoApuracao] Ano da apuração
  /// [qualificacaoPj] Qualificação da PJ (padrão: PJ em geral)
  /// [tributacaoLucro] Tributação do lucro (padrão: Real Anual)
  /// [variacoesMonetarias] Variações monetárias (padrão: Regime de Caixa)
  /// [regimePisCofins] Regime PIS/COFINS (padrão: Não-cumulativa)
  /// [debitos] Débitos da apuração
  /// [cpfResponsavel] CPF do responsável pela apuração
  /// [emailResponsavel] E-mail do responsável (opcional)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<EncerrarApuracaoResponse> criarApuracaoComMovimento({
    required String contribuinteNumero,
    required int mesApuracao,
    required int anoApuracao,
    QualificacaoPj qualificacaoPj = QualificacaoPj.pjEmGeral,
    TributacaoLucro tributacaoLucro = TributacaoLucro.realAnual,
    VariacoesMonetarias variacoesMonetarias = VariacoesMonetarias.regimeCaixa,
    RegimePisCofins regimePisCofins = RegimePisCofins.naoCumulativa,
    required Debitos debitos,
    required String cpfResponsavel,
    String? emailResponsavel,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final periodoApuracao = PeriodoApuracao(
      mesApuracao: mesApuracao,
      anoApuracao: anoApuracao,
    );

    final responsavelApuracao = ResponsavelApuracao(
      cpfResponsavel: cpfResponsavel,
      emailResponsavel: emailResponsavel,
    );

    final dadosIniciais = DadosIniciais(
      semMovimento: false,
      qualificacaoPj: qualificacaoPj,
      tributacaoLucro: tributacaoLucro,
      variacoesMonetarias: variacoesMonetarias,
      regimePisCofins: regimePisCofins,
      responsavelApuracao: responsavelApuracao,
    );

    return await encerrarApuracao(
      contribuinteNumero: contribuinteNumero,
      periodoApuracao: periodoApuracao,
      dadosIniciais: dadosIniciais,
      debitos: debitos,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta apurações por mês específico
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoApuracao] Ano da apuração
  /// [mesApuracao] Mês da apuração (1-12)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ListarApuracaoesResponse> consultarApuracaoesPorMes({
    required String contribuinteNumero,
    required int anoApuracao,
    required int mesApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return await listarApuracaoes(
      contribuinteNumero: contribuinteNumero,
      anoApuracao: anoApuracao,
      mesApuracao: mesApuracao,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Consulta apurações encerradas por ano
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [anoApuracao] Ano da apuração
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ListarApuracaoesResponse> consultarApuracaoesEncerradas({
    required String contribuinteNumero,
    required int anoApuracao,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return await listarApuracaoes(
      contribuinteNumero: contribuinteNumero,
      anoApuracao: anoApuracao,
      situacaoApuracao: SituacaoApuracao.encerrada.codigo,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Aguarda o encerramento de uma apuração com polling
  ///
  /// [contribuinteNumero] CNPJ do contribuinte
  /// [protocoloEncerramento] Protocolo de encerramento
  /// [timeoutSegundos] Timeout em segundos (padrão: 300)
  /// [intervaloConsulta] Intervalo entre consultas em segundos (padrão: 10)
  /// [contratanteNumero] CNPJ do contratante (opcional)
  /// [autorPedidoDadosNumero] CNPJ do autor do pedido (opcional)
  Future<ConsultarSituacaoEncerramentoResponse> aguardarEncerramento({
    required String contribuinteNumero,
    required String protocoloEncerramento,
    int timeoutSegundos = 300,
    int intervaloConsulta = 10,
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final inicio = DateTime.now();
    final timeout = Duration(seconds: timeoutSegundos);

    while (DateTime.now().difference(inicio) < timeout) {
      final response = await consultarSituacaoEncerramento(
        contribuinteNumero: contribuinteNumero,
        protocoloEncerramento: protocoloEncerramento,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Se o encerramento foi concluído (sucesso ou erro)
      if (response.encerramentoConcluido || response.sucesso) {
        return response;
      }

      // Aguardar antes da próxima consulta
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

  // ========== MÉTODOS DE VALIDAÇÃO ==========

  /// Valida se um código de débito é válido para o tributo
  ///
  /// [codigoDebito] Código do débito
  /// [tributo] Grupo do tributo
  bool validarCodigoDebito(String codigoDebito, GrupoTributo tributo) {
    return ValidacoesMit.validarCodigoDebito(codigoDebito, tributo);
  }

  /// Valida se a qualificação PJ permite o tributo
  ///
  /// [tributo] Grupo do tributo
  /// [qualificacao] Qualificação da PJ
  bool validarTributoParaQualificacao(
    GrupoTributo tributo,
    QualificacaoPj qualificacao,
  ) {
    return ValidacoesMit.validarTributoParaQualificacao(tributo, qualificacao);
  }

  /// Valida se a tributação do lucro permite o tributo
  ///
  /// [tributo] Grupo do tributo
  /// [tributacao] Tributação do lucro
  bool validarTributoParaTributacao(
    GrupoTributo tributo,
    TributacaoLucro tributacao,
  ) {
    return ValidacoesMit.validarTributoParaTributacao(tributo, tributacao);
  }

  // ========== MÉTODOS DE UTILIDADE ==========

  /// Obtém códigos de receita válidos para um tributo
  ///
  /// [tributo] Grupo do tributo
  List<String> obterCodigosReceita(GrupoTributo tributo) {
    return CodigosReceitaMit.obterCodigosPorTributo(tributo);
  }

  /// Cria um débito de forma simplificada
  ///
  /// [idDebito] ID do débito
  /// [codigoDebito] Código do débito
  /// [valorDebito] Valor do débito
  /// [cnpjScp] CNPJ SCP (opcional)
  /// [estabelecimento] Estabelecimento (opcional)
  /// [municipioEstabelecimento] Município do estabelecimento (opcional)
  Debito criarDebito({
    required int idDebito,
    required String codigoDebito,
    required double valorDebito,
    String? cnpjScp,
    String? estabelecimento,
    String? municipioEstabelecimento,
  }) {
    return Debito(
      idDebito: idDebito,
      codigoDebito: codigoDebito,
      valorDebito: valorDebito,
      cnpjScp: cnpjScp,
      estabelecimento: estabelecimento,
      municipioEstabelecimento: municipioEstabelecimento,
    );
  }

  /// Cria um crédito de forma simplificada
  ///
  /// [idCredito] ID do crédito
  /// [codigoCredito] Código do crédito
  /// [valorCredito] Valor do crédito
  /// [cnpjScp] CNPJ SCP (opcional)
  /// [estabelecimento] Estabelecimento (opcional)
  /// [municipioEstabelecimento] Município do estabelecimento (opcional)
  Credito criarCredito({
    required int idCredito,
    required String codigoCredito,
    required double valorCredito,
    String? cnpjScp,
    String? estabelecimento,
    String? municipioEstabelecimento,
  }) {
    return Credito(
      idCredito: idCredito,
      codigoCredito: codigoCredito,
      valorCredito: valorCredito,
      cnpjScp: cnpjScp,
      estabelecimento: estabelecimento,
      municipioEstabelecimento: municipioEstabelecimento,
    );
  }
}
