import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/ccmei/model/consultar_dados_ccmei_response.dart';
import 'package:serpro_integra_contador_api/src/services/ccmei/model/consultar_situacao_cadastral_ccmei_response.dart';
import 'package:serpro_integra_contador_api/src/services/ccmei/model/emitir_ccmei_response.dart';
import 'package:serpro_integra_contador_api/src/util/validacoes_utils.dart';

/// Serviço para operações relacionadas ao CCMEI (Cadastro Centralizado de Microempreendedor Individual)
///
/// O CCMEI é um documento que comprova a situação cadastral do MEI junto à Receita Federal.
/// Este serviço permite:
/// - Emitir CCMEI em PDF
/// - Consultar dados completos do MEI
/// - Consultar situação cadastral por CPF
class CcmeiService {
  /// Cliente da API para comunicação com o SERPRO
  final ApiClient _apiClient;

  /// Construtor que recebe o cliente da API
  CcmeiService(this._apiClient);

  /// Emite o CCMEI (Cadastro Centralizado de MEI) em formato PDF
  ///
  /// [cnpj]: CNPJ do MEI (deve ser válido)
  /// [contratanteNumero]: CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna: EmitirCcmeiResponse com o PDF e informações do documento
  /// Lança exceção se o CNPJ for inválido ou houver erro na API
  Future<EmitirCcmeiResponse> emitirCcmei(String cnpj, {String? contratanteNumero, String? autorPedidoDadosNumero}) async {
    // Validar formato do CNPJ antes de fazer a requisição
    ValidacoesUtils.validateCNPJ(cnpj);

    // Criar requisição com dados específicos do serviço CCMEI
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'CCMEI',
        idServico: 'EMITIRCCMEI121', // ID específico para emissão de CCMEI
        versaoSistema: '1.0',
        dados: '',
      ),
    );

    // Executar requisição para o endpoint de emissão
    final response = await _apiClient.post('/Emitir', request, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);
    return EmitirCcmeiResponse.fromJson(response);
  }

  /// Consulta dados completos do MEI através do CNPJ
  ///
  /// [cnpj]: CNPJ do MEI (deve ser válido)
  /// [contratanteNumero]: CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna: ConsultarDadosCcmeiResponse com informações completas do MEI incluindo:
  /// - Dados empresariais (nome, endereço, capital social)
  /// - Dados do empresário (nome, CPF)
  /// - Situação cadastral e enquadramento
  /// - Atividades econômicas (CNAE principal e secundárias)
  /// - Períodos de enquadramento como MEI
  /// Lança exceção se o CNPJ for inválido ou houver erro na API
  Future<ConsultarDadosCcmeiResponse> consultarDadosCcmei(String cnpj, {String? contratanteNumero, String? autorPedidoDadosNumero}) async {
    // Validar formato do CNPJ antes de fazer a requisição
    ValidacoesUtils.validateCNPJ(cnpj);

    // Criar requisição para consulta de dados completos
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'CCMEI',
        idServico: 'DADOSCCMEI122', // ID específico para consulta de dados
        versaoSistema: '1.0',
        dados: '',
      ),
    );

    // Executar requisição para o endpoint de consulta
    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarDadosCcmeiResponse.fromJson(response);
  }

  /// Consulta situação cadastral do MEI através do CPF do empresário
  ///
  /// [cpf]: CPF do empresário MEI (deve ser válido)
  /// [contratanteNumero]: CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna: ConsultarSituacaoCadastralCcmeiResponse com lista de CNPJs vinculados ao CPF
  /// Útil para encontrar todos os CNPJs de um empresário MEI
  /// Lança exceção se o CPF for inválido ou houver erro na API
  Future<ConsultarSituacaoCadastralCcmeiResponse> consultarSituacaoCadastral(
    String cpf, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    // Validar formato do CPF antes de fazer a requisição

    // Criar requisição para consulta de situação cadastral
    final request = BaseRequest(
      contribuinteNumero: cpf,
      pedidoDados: PedidoDados(
        idSistema: 'CCMEI',
        idServico: 'CCMEISITCADASTRAL123', // ID específico para consulta de situação
        versaoSistema: '1.0',
        dados: '',
      ),
    );

    // Executar requisição para o endpoint de consulta
    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ConsultarSituacaoCadastralCcmeiResponse.fromJson(response);
  }
}
