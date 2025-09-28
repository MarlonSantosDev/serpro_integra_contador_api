import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/dte/dte_response.dart';
import 'package:serpro_integra_contador_api/src/util/document_utils.dart';

/// Serviço para consultas do DTE - Domicílio Tributário Eletrônico
class DteService {
  final ApiClient _apiClient;

  DteService(this._apiClient);

  /// Obtém informação que indica se há adesão ao DTE de um contribuinte
  ///
  /// Obtém informação que indica se há adesão ao DTE - Domicílio Tributário Eletrônico,
  /// no Caixa Postal do Simples Nacional e no e-CAC de um contribuinte.
  ///
  /// [cnpj] CNPJ do contribuinte (apenas Pessoa Jurídica - tipo 2)
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
  Future<DteResponse> obterIndicadorDte(String cnpj) async {
    // Validações
    final validacao = _validarCnpj(cnpj);
    if (validacao != null) {
      throw ArgumentError(validacao);
    }

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
      final response = await _apiClient.post('/', request);
      final dteResponse = DteResponse.fromJson(response);

      // Validação adicional da resposta
      _validarResposta(dteResponse);

      return dteResponse;
    } catch (e) {
      // Tratamento de erros específicos do DTE
      if (e is ArgumentError) {
        rethrow;
      }

      // Erro de conexão ou sistema
      throw Exception('Erro ao consultar indicador DTE: ${e.toString()}');
    }
  }

  /// Valida se o CNPJ é válido e se é do tipo correto (Pessoa Jurídica)
  String? _validarCnpj(String cnpj) {
    if (cnpj.isEmpty) {
      return 'CNPJ não pode estar vazio';
    }

    final cnpjLimpo = DocumentUtils.cleanDocumentNumber(cnpj);

    if (!DocumentUtils.isValidCnpj(cnpjLimpo)) {
      return 'CNPJ inválido. Deve ter 14 dígitos e ser válido';
    }

    // Verifica se tem 14 dígitos (CNPJ)
    if (cnpjLimpo.length != 14) {
      return 'CNPJ deve ter exatamente 14 dígitos';
    }

    return null;
  }

  /// Valida a resposta recebida do serviço
  void _validarResposta(DteResponse response) {
    if (response.status != 200) {
      throw Exception('Erro HTTP ${response.status}: ${response.mensagemPrincipal}');
    }

    // Verifica se há mensagens de erro específicas do DTE
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
    final cnpjLimpo = DocumentUtils.cleanDocumentNumber(cnpj);
    if (cnpjLimpo.length == 14) {
      return '${cnpjLimpo.substring(0, 2)}.${cnpjLimpo.substring(2, 5)}.${cnpjLimpo.substring(5, 8)}/${cnpjLimpo.substring(8, 12)}-${cnpjLimpo.substring(12)}';
    }
    return cnpj;
  }

  /// Limpa CNPJ removendo formatação
  String limparCnpj(String cnpj) {
    return DocumentUtils.cleanDocumentNumber(cnpj);
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
      'indicador': response.dadosParsed?.indicadorEnquadramento,
      'status_enquadramento': response.statusEnquadramentoDescricao,
      'is_optante_dte': response.isOptanteDte,
      'is_optante_simples': response.isOptanteSimples,
      'is_optante_dte_e_simples': response.isOptanteDteESimples,
      'is_nao_optante': response.isNaoOptante,
      'is_ni_invalido': response.isNiInvalido,
    };
  }
}
