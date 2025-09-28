import 'package:serpro_integra_contador_api/src/core/api_client.dart';
import 'package:serpro_integra_contador_api/src/models/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/models/procuracoes/obter_procuracao_request.dart';
import 'package:serpro_integra_contador_api/src/models/procuracoes/obter_procuracao_response.dart';
import 'package:serpro_integra_contador_api/src/models/procuracoes/procuracoes_response.dart';

/// Serviço para operações de Procurações Eletrônicas
class ProcuracoesService {
  final ApiClient _apiClient;

  ProcuracoesService(this._apiClient);

  /// Obtém procurações eletrônicas entre um outorgante e seu procurador
  ///
  /// [outorgante] - CPF/CNPJ do outorgante (quem emite a procuração)
  /// [outorgado] - CPF/CNPJ do procurador (quem recebe a procuração)
  /// [contratanteNumero] - CPF/CNPJ do contratante (opcional, usa do ApiClient se não informado)
  /// [autorPedidoDadosNumero] - CPF/CNPJ do autor do pedido (opcional, usa do ApiClient se não informado)
  Future<ObterProcuracaoResponse> obterProcuracao(
    String outorgante,
    String outorgado, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final requestData = ObterProcuracaoRequest.fromDocuments(outorgante: outorgante, outorgado: outorgado);

    // Validar dados antes de enviar
    final erros = requestData.validate();
    if (erros.isNotEmpty) {
      throw ArgumentError('Dados inválidos: ${erros.join(', ')}');
    }

    final request = BaseRequest(
      contribuinteNumero: outorgante,
      pedidoDados: PedidoDados(idSistema: 'PROCURACOES', idServico: 'OBTERPROCURACAO41', versaoSistema: '1', dados: requestData.toJsonString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ObterProcuracaoResponse.fromJson(response);
  }

  /// Obtém procurações com dados específicos de tipos de documento
  ///
  /// [outorgante] - CPF/CNPJ do outorgante
  /// [tipoOutorgante] - Tipo do outorgante (1=CPF, 2=CNPJ)
  /// [outorgado] - CPF/CNPJ do procurador
  /// [tipoOutorgado] - Tipo do procurador (1=CPF, 2=CNPJ)
  Future<ObterProcuracaoResponse> obterProcuracaoComTipos(
    String outorgante,
    String tipoOutorgante,
    String outorgado,
    String tipoOutorgado, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    final requestData = ObterProcuracaoRequest(
      outorgante: outorgante,
      tipoOutorgante: tipoOutorgante,
      outorgado: outorgado,
      tipoOutorgado: tipoOutorgado,
    );

    // Validar dados antes de enviar
    final erros = requestData.validate();
    if (erros.isNotEmpty) {
      throw ArgumentError('Dados inválidos: ${erros.join(', ')}');
    }

    final request = BaseRequest(
      contribuinteNumero: outorgante,
      pedidoDados: PedidoDados(idSistema: 'PROCURACOES', idServico: 'OBTERPROCURACAO41', versaoSistema: '1', dados: requestData.toJsonString()),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ObterProcuracaoResponse.fromJson(response);
  }

  /// Método de conveniência para obter procurações de pessoa física
  Future<ObterProcuracaoResponse> obterProcuracaoPf(
    String cpfOutorgante,
    String cpfProcurador, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return obterProcuracaoComTipos(
      cpfOutorgante,
      '1', // CPF
      cpfProcurador,
      '1', // CPF
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Método de conveniência para obter procurações de pessoa jurídica
  Future<ObterProcuracaoResponse> obterProcuracaoPj(
    String cnpjOutorgante,
    String cnpjProcurador, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return obterProcuracaoComTipos(
      cnpjOutorgante,
      '2', // CNPJ
      cnpjProcurador,
      '2', // CNPJ
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Método de conveniência para obter procurações mistas (PF para PJ ou vice-versa)
  Future<ObterProcuracaoResponse> obterProcuracaoMista(
    String documentoOutorgante,
    String documentoProcurador,
    bool outorganteIsPj,
    bool procuradorIsPj, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
  }) async {
    return obterProcuracaoComTipos(
      documentoOutorgante,
      outorganteIsPj ? '2' : '1',
      documentoProcurador,
      procuradorIsPj ? '2' : '1',
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Valida se um documento é um CPF válido
  bool isCpfValido(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 11;
  }

  /// Valida se um documento é um CNPJ válido
  bool isCnpjValido(String cnpj) {
    final cleaned = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 14;
  }

  /// Detecta o tipo de documento (1=CPF, 2=CNPJ)
  String detectarTipoDocumento(String documento) {
    final cleaned = documento.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.length == 11 ? '1' : '2';
  }

  /// Limpa um documento removendo caracteres não numéricos
  String limparDocumento(String documento) {
    return documento.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Formata um CPF (xxx.xxx.xxx-xx)
  String formatarCpf(String cpf) {
    final cleaned = limparDocumento(cpf);
    if (cleaned.length != 11) return cpf;
    return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
  }

  /// Formata um CNPJ (xx.xxx.xxx/xxxx-xx)
  String formatarCnpj(String cnpj) {
    final cleaned = limparDocumento(cnpj);
    if (cleaned.length != 14) return cnpj;
    return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
  }

  /// Método legado mantido para compatibilidade
  @Deprecated('Use obterProcuracao() ao invés de obterProcuracaoLegado()')
  Future<ProcuracoesResponse> obterProcuracaoLegado(String cnpj, {String? contratanteNumero, String? autorPedidoDadosNumero}) async {
    final request = BaseRequest(
      contribuinteNumero: cnpj,
      pedidoDados: PedidoDados(idSistema: 'PROCURACOES', idServico: 'OBTERPROCURACAO41', dados: ''),
    );

    final response = await _apiClient.post(
      '/Consultar',
      request,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
    return ProcuracoesResponse.fromJson(response);
  }
}
