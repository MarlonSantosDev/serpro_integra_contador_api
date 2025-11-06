import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/services/dte/model/dte_response.dart';
import 'package:serpro_integra_contador_api/src/util/validacoes_utils.dart';

/// **Serviço:** DTE (Domicílio Tributário Eletrônico)
///
/// O DTE é um canal de comunicação digital entre a Receita Federal e os contribuintes.
///
/// **Este serviço disponibiliza APENAS 1 serviço oficial da API SERPRO:**
/// - **CONSULTASITUACAODTE111**: Obter indicador de adesão ao DTE
///
/// **Documentação oficial:** `.cursor/rules/dte.mdc`
///
/// **Exemplo de uso:**
/// ```dart
/// final dteService = DteService(apiClient);
///
/// // Verificar adesão ao DTE
/// final dte = await dteService.obterIndicadorDte('12345678000190');
/// if (dte.isOptanteDte) {
///   print('Contribuinte optante pelo DTE');
///   print('Status: ${dte.statusEnquadramentoDescricao}');
/// }
/// ```
class DteService {
  final ApiClient _apiClient;

  DteService(this._apiClient);

  /// Obtém informação que indica se há adesão ao DTE de um contribuinte
  ///
  /// Obtém informação que indica se há adesão ao DTE - Domicílio Tributário Eletrônico,
  /// no Caixa Postal do Simples Nacional e no e-CAC de um contribuinte.
  ///
  /// [cnpj] CNPJ do contribuinte (apenas Pessoa Jurídica - tipo 2)
  /// [contratanteNumero] CNPJ do contratante (opcional, usa dados da autenticação se não informado)
  /// [autorPedidoDadosNumero] CPF/CNPJ do autor do pedido (opcional, usa dados da autenticação se não informado)
  ///
  /// Retorna [DteResponse] com o indicador de enquadramento e status
  ///
  /// Exemplo:
  /// ```dart
  /// final response = await dteService.obterIndicadorDte('12345678000195');
  /// if (response.sucesso) {
  ///   print('Status: ${response.statusEnquadramentoDescricao}');
  ///   print('É optante DTE: ${response.isOptanteDte}');
  /// }
  /// ```
  Future<DteResponse> obterIndicadorDte(String cnpj, {String? contratanteNumero, String? autorPedidoDadosNumero}) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(
        idSistema: 'DTE',
        idServico: 'CONSULTASITUACAODTE111',
        versaoSistema: '1.0',
        dados: '', // Campo dados deve ser enviado vazio conforme documentação
      ),
    );

    try {
      final response = await _apiClient.post(
        '/Consultar',
        request,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );
      final dteResponse = DteResponse.fromJson(response);

      _validarResposta(dteResponse);

      return dteResponse;
    } catch (e) {
      if (e is ArgumentError) {
        rethrow;
      }

      throw Exception('Erro ao consultar indicador DTE: ${e.toString()}');
    }
  }

  /// Valida se o CNPJ é válido e se é do tipo correto (Pessoa Jurídica)
  String? _validarCnpj(String cnpj) {
    if (cnpj.isEmpty) {
      return 'CNPJ não pode estar vazio';
    }

    if (!ValidacoesUtils.isValidCnpj(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }

  /// Valida a resposta recebida do serviço
  void _validarResposta(DteResponse response) {
    if (response.status != 200) {
      throw Exception('Erro HTTP ${response.status}: ${response.mensagemPrincipal}');
    }

    for (final mensagem in response.mensagens) {
      if (mensagem.isErro) {
        final erroInfo = _obterInfoErro(mensagem.codigo);
        throw Exception('${erroInfo['descricao']}: ${mensagem.texto}');
      }
    }
  }

  /// Obtém informações detalhadas sobre códigos de erro do DTE
  Map<String, String> _obterInfoErro(String codigo) {
    switch (codigo) {
      case 'Erro-DTE-04':
        return {'tipo': 'Validação', 'descricao': 'CPF inválido (9 dígitos)', 'acao': 'Verifique se o CPF tem exatamente 9 dígitos e é válido'};
      case 'Erro-DTE-05':
        return {'tipo': 'Validação', 'descricao': 'CNPJ inválido (8 dígitos)', 'acao': 'Verifique se o CNPJ tem exatamente 8 dígitos e é válido'};
      case 'Erro-DTE-991':
        return {
          'tipo': 'Sistema',
          'descricao': 'Serviço não disponibilizado pelo sistema',
          'acao': 'Verifique se o serviço CONSULTASITUACAODTE111 está disponível',
        };
      case 'Erro-DTE-992':
        return {'tipo': 'Sistema', 'descricao': 'Serviço inválido', 'acao': 'Verifique se o idServico está correto'};
      case 'Erro-DTE-993':
        return {'tipo': 'Sistema', 'descricao': 'Erro na conversão do retorno do serviço DTE', 'acao': 'Tente novamente em alguns minutos'};
      case 'Erro-DTE-994':
        return {'tipo': 'Validação', 'descricao': 'Campo informado inválido', 'acao': 'Verifique os dados enviados na requisição'};
      case 'Erro-DTE-995':
        return {'tipo': 'Conexão', 'descricao': 'Erro ao conectar com o serviço DTE', 'acao': 'Verifique sua conexão e tente novamente'};
      default:
        return {'tipo': 'Desconhecido', 'descricao': 'Erro não mapeado', 'acao': 'Entre em contato com o suporte'};
    }
  }

  /// Verifica se um código de erro é conhecido
  bool isErroConhecido(String codigo) {
    return ['Erro-DTE-04', 'Erro-DTE-05', 'Erro-DTE-991', 'Erro-DTE-992', 'Erro-DTE-993', 'Erro-DTE-994', 'Erro-DTE-995'].contains(codigo);
  }

  /// Obtém informações sobre um erro específico
  Map<String, String>? obterInfoErro(String codigo) {
    if (!isErroConhecido(codigo)) return null;
    return _obterInfoErro(codigo);
  }

  /// Valida se um CNPJ é válido para uso no DTE
  bool validarCnpjDte(String cnpj) {
    return _validarCnpj(cnpj) == null;
  }

  /// Formata CNPJ para exibição
  String formatarCnpj(String cnpj) {
    final cnpjLimpo = ValidacoesUtils.cleanDocumentNumber(cnpj);
    if (cnpjLimpo.length == 14) {
      return '${cnpjLimpo.substring(0, 2)}.${cnpjLimpo.substring(2, 5)}.${cnpjLimpo.substring(5, 8)}/${cnpjLimpo.substring(8, 12)}-${cnpjLimpo.substring(12)}';
    }
    return cnpj;
  }

  /// Limpa CNPJ removendo formatação
  String limparCnpj(String cnpj) {
    return ValidacoesUtils.cleanDocumentNumber(cnpj);
  }

  /// Obtém descrição do indicador de enquadramento
  String obterDescricaoIndicador(int indicador) {
    switch (indicador) {
      case -2:
        return 'NI inválido';
      case -1:
        return 'NI Não optante';
      case 0:
        return 'NI Optante DTE';
      case 1:
        return 'NI Optante Simples';
      case 2:
        return 'NI Optante DTE e Simples';
      default:
        return 'Indicador desconhecido ($indicador)';
    }
  }

  /// Verifica se um indicador é válido
  bool isIndicadorValido(int indicador) {
    return indicador >= -2 && indicador <= 2;
  }

  /// Analisa uma resposta DTE e retorna informações úteis
  Map<String, dynamic> analisarResposta(DteResponse response) {
    return {
      'sucesso': response.sucesso,
      'status_http': response.status,
      'codigo_mensagem': response.codigoMensagem,
      'mensagem': response.mensagemPrincipal,
      'tem_indicador': response.temIndicadorValido,
      'indicador': response.dados?.indicadorEnquadramento,
      'status_enquadramento': response.statusEnquadramentoDescricao,
      'is_optante_dte': response.isOptanteDte,
      'is_optante_simples': response.isOptanteSimples,
      'is_optante_dte_e_simples': response.isOptanteDteESimples,
      'is_nao_optante': response.isNaoOptante,
      'is_ni_invalido': response.isNiInvalido,
    };
  }
}
