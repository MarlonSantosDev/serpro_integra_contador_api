import 'dart:convert';
import '../../core/api_client.dart';
import '../../base/base_request.dart';
import 'model/termo_autorizacao_request.dart';
import 'model/termo_autorizacao_response.dart';
import 'exceptions/autenticaprocurador_exceptions.dart';
import 'xml_signer.dart';

/// **Serviço:** AUTENTICA PROCURADOR
///
/// Permite que um **Procurador** autorize uma **Empresa Contratante** a fazer
/// requisições em nome de um **Contribuinte**.
///
/// ## Fluxo de Autenticação
///
/// ```
/// ┌─────────────────┐    assina termo    ┌─────────────────┐
/// │   PROCURADOR    │ ─────────────────► │   CONTRATANTE   │
/// │ (certificado 2) │   autoriza usar    │ (certificado 1) │
/// └─────────────────┘                    └─────────────────┘
///         │                                      │
///         │ em nome de                           │ faz requisições
///         ▼                                      ▼
/// ┌─────────────────┐                    ┌─────────────────┐
/// │  CONTRIBUINTE   │ ◄───────────────── │   API SERPRO    │
/// │   (Empresa B)   │   dados obtidos    │                 │
/// └─────────────────┘                    └─────────────────┘
/// ```
///
/// ## Plataformas Suportadas
///
/// | Plataforma | Certificado Path | Certificado Base64 |
/// |------------|------------------|-------------------|
/// | Windows    | ✅               | ✅                |
/// | Android    | ✅               | ✅                |
/// | iOS        | ✅               | ✅                |
/// | Web        | ❌               | ✅                |
///
/// ## Exemplo Completo
///
/// ```dart
/// // 1. Autenticar Empresa A (Contratante) com seu certificado
/// await apiClient.authenticate(
///   consumerKey: 'xxx',
///   consumerSecret: 'xxx',
///   contratanteNumero: '11111111000111',  // CNPJ Empresa A
///   autorPedidoDadosNumero: '12345678901', // CPF do Procurador
///   certificadoDigitalPath: 'empresa_a.pfx',
///   senhaCertificado: 'senha123',
///   ambiente: 'producao',
/// );
///
/// // 2. Procurador assina termo para autorizar requisições em nome de Empresa B
/// final autenticaService = AutenticaProcuradorService(apiClient);
/// final resultado = await autenticaService.autenticarProcurador(
///   contratanteNome: 'Empresa A Contabilidade Ltda',
///   autorNome: 'João Silva',
///   contribuinteNumero: '22222222000222', // CNPJ Empresa B
///   certificadoPath: 'procurador.pfx',
///   certificadoPassword: 'senha_procurador',
/// );
/// ```
class AutenticaProcuradorService {
  final ApiClient _apiClient;
  final String _endpoint = '/Apoiar';

  /// Cache local do último token obtido (para responder a 304 Not Modified)
  static TermoAutorizacaoResponse? _ultimoTokenCache;

  AutenticaProcuradorService(this._apiClient);

  /// Limpa o cache local do token
  static void limparCache() {
    _ultimoTokenCache = null;
  }

  /// Obtém o token em cache (se houver e estiver válido)
  static TermoAutorizacaoResponse? get tokenEmCache => _ultimoTokenCache;

  /// Autentica procurador enviando XML assinado com Termo de Autorização
  ///
  /// ## Parâmetros Obrigatórios
  /// - [contratanteNome]: Razão social da empresa contratante (quem faz requisições)
  /// - [autorNome]: Nome do procurador (quem assina o termo)
  ///
  /// ## Parâmetros do Contribuinte (obrigatório se diferente do contratante)
  /// - [contribuinteNumero]: CPF/CNPJ do contribuinte (em nome de quem serão feitas as requisições)
  ///
  /// ## Certificado de Assinatura (obrigatório se diferente do authenticate)
  /// O certificado usado para **assinar o termo** pode ser diferente do usado na autenticação OAuth2.
  ///
  /// **Desktop/Mobile:**
  /// - [certificadoPath]: Caminho do certificado PFX/PEM do procurador
  /// - [certificadoPassword]: Senha do certificado do procurador
  ///
  /// **Web (ou todas as plataformas):**
  /// - [certificadoBase64]: Certificado PFX em Base64 (conteúdo do arquivo convertido)
  /// - [certificadoPassword]: Senha do certificado do procurador
  ///
  /// ## Parâmetros Opcionais (obtidos do ApiClient)
  /// - [contratanteNumero]: CNPJ do contratante (padrão: do authenticate)
  /// - [autorNumero]: CPF/CNPJ do procurador (padrão: do authenticate)
  ///
  /// ## Retorno
  /// [TermoAutorizacaoResponse] contendo:
  /// - `sucesso`: se a autenticação foi bem-sucedida
  /// - `autenticarProcuradorToken`: token para usar em requisições subsequentes
  /// - `dataExpiracao`: quando o token expira
  /// - `isCacheValido`: se está usando resposta em cache
  ///
  /// ## Erros Possíveis
  /// - [ExcecaoAssinaturaCertificado]: Problema com o certificado digital
  /// - [ExcecaoAssinaturaXml]: Problema na assinatura do XML
  /// - [ExcecaoErroSerpro]: Erro retornado pela API SERPRO
  Future<TermoAutorizacaoResponse> autenticarProcurador({
    // Obrigatórios: nomes
    required String contratanteNome,
    required String autorNome,
    // Contribuinte: obrigatório se diferente do contratante
    String? contribuinteNumero,
    // Certificado de assinatura: pode ser diferente do OAuth2
    String? certificadoPath,
    String? certificadoBase64,
    String? certificadoPassword,
    // Opcionais: obtidos do ApiClient se não fornecidos
    String? contratanteNumero,
    String? autorNumero,
  }) async {
    try {
      // Verificar se ApiClient está autenticado
      if (!_apiClient.isAutenticado) {
        throw ExcecaoAutenticaProcurador(
          'ApiClient não está autenticado. Chame authenticate() primeiro.',
          codigo: 'NAO_AUTENTICADO',
          statusHttp: 401,
        );
      }

      // Obter dados do ApiClient (se não fornecidos)
      final finalContratanteNumero =
          contratanteNumero ?? _apiClient.contratanteNumero!;
      final finalAutorNumero =
          autorNumero ?? _apiClient.autorPedidoDadosNumero!;
      final finalContribuinteNumero =
          contribuinteNumero ?? finalContratanteNumero;

      // Certificado de assinatura: pode ser diferente do OAuth2
      // Prioridade: certificadoBase64 > certificadoPath > certificado do authenticate
      String? finalCertificadoPath;
      String? finalCertificadoBase64;
      String? finalCertificadoPassword;

      if (certificadoBase64 != null && certificadoBase64.isNotEmpty) {
        // Usar Base64 fornecido (funciona em todas as plataformas)
        finalCertificadoBase64 = certificadoBase64;
        finalCertificadoPassword = certificadoPassword;
      } else if (certificadoPath != null && certificadoPath.isNotEmpty) {
        // Usar path fornecido (Desktop/Mobile)
        finalCertificadoPath = certificadoPath;
        finalCertificadoPassword = certificadoPassword;
      } else if (_apiClient.certificadoPath != null) {
        // Usar certificado do authenticate
        finalCertificadoPath = _apiClient.certificadoPath;
        finalCertificadoPassword = _apiClient.certificadoSenha;
      } else {
        throw ExcecaoAssinaturaCertificado(
          'Nenhum certificado fornecido para assinatura.\n'
          'Forneça certificadoPath (Desktop/Mobile) ou certificadoBase64 (Web/todas).',
        );
      }

      if (finalCertificadoPassword == null ||
          finalCertificadoPassword.isEmpty) {
        throw ExcecaoAssinaturaCertificado(
          'Senha do certificado não fornecida.',
        );
      }

      // 1. Criar termo de autorização
      final termo = TermoAutorizacaoRequest.comDataAtual(
        contratanteNumero: finalContratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: finalAutorNumero,
        autorPedidoDadosNome: autorNome,
        certificadoPath: finalCertificadoPath,
        certificadoPassword: finalCertificadoPassword,
      );

      // 2. Validar dados (transparente)
      final errosValidacao = termo.validarDados();
      if (errosValidacao.isNotEmpty) {
        throw ExcecaoAutenticaProcurador(
          'Dados do termo de autorização inválidos:\n${errosValidacao.join('\n')}',
          codigo: 'DADOS_INVALIDOS',
          statusHttp: 400,
        );
      }

      // 3. Criar XML do termo
      final xml = termo.criarXmlTermo();

      // 4. Assinar digitalmente com certificado real
      final xmlAssinado = await _assinarXmlReal(
        xml,
        certificadoPath: finalCertificadoPath,
        certificadoBase64: finalCertificadoBase64,
        certificadoPassword: finalCertificadoPassword,
      );

      // 5. Enviar para API e obter token
      return await _enviarParaAPI(
        xmlAssinado,
        finalContratanteNumero,
        finalAutorNumero,
        finalContribuinteNumero,
      );
    } on ExcecaoAutenticaProcurador {
      rethrow;
    } catch (e) {
      throw ExcecaoAutenticaProcurador(
        'Erro na autenticação de procurador: $e',
        codigo: 'ERRO_INESPERADO',
        statusHttp: 500,
      );
    }
  }

  /// Assina XML com certificado digital real (ICP-Brasil)
  ///
  /// Usa assinatura criptográfica real com certificado PFX ou PEM.
  /// Funciona em todas as plataformas (Windows, Android, iOS, Web).
  Future<String> _assinarXmlReal(
    String xml, {
    String? certificadoPath,
    String? certificadoBase64,
    required String certificadoPassword,
  }) async {
    try {
      final assinador = AssinadorDigitalXml(
        caminhoCertificado: certificadoPath,
        certificadoBase64: certificadoBase64,
        senhaCertificado: certificadoPassword,
      );

      // Carregar e validar certificado
      await assinador.carregarCertificado();
      //final infoCert = await assinador.obterInformacoesCertificado();
      //
      //print('✅ Certificado carregado: ${infoCert.nomeExibicao}');
      //print('   Válido até: ${infoCert.validoAte}');
      //print('   Dias restantes: ${infoCert.diasRestantes}');

      // Assinar o XML
      final xmlAssinado = await assinador.assinarXml(xml);

      // Limpar recursos
      assinador.dispose();

      return xmlAssinado;
    } on ExcecaoAutenticaProcurador {
      rethrow;
    } catch (e) {
      throw ExcecaoAssinaturaCertificado('Erro na assinatura digital: $e');
    }
  }

  /// Envia XML assinado para a API
  Future<TermoAutorizacaoResponse> _enviarParaAPI(
    String xmlAssinado,
    String contratanteNumero,
    String autorPedidoDadosNumero,
    String contribuinteNumero,
  ) async {
    try {
      //print('xmlAssinado: $xmlAssinado');
      // Converter XML para Base64
      final xmlBase64 = base64.encode(utf8.encode(xmlAssinado));

      // Criar dados do pedido - apenas o XML em Base64
      final dadosPedido = jsonEncode({'xml': xmlBase64});

      // Criar BaseRequest com estrutura correta
      final request = BaseRequest(
        contribuinteNumero: contribuinteNumero,
        pedidoDados: PedidoDados(
          idSistema: 'AUTENTICAPROCURADOR',
          idServico: 'ENVIOXMLASSINADO81',
          versaoSistema: '1.0',
          dados: dadosPedido,
        ),
      );

      // Fazer requisição HTTP
      final response = await _apiClient.post(
        _endpoint,
        request,
        contratanteNumero: contratanteNumero,
        autorPedidoDadosNumero: autorPedidoDadosNumero,
      );

      // Processar resposta
      final resultado = TermoAutorizacaoResponse.fromJson(response);

      // Se recebeu resposta de cache (304) e temos cache local, usar cache
      if (resultado.isCacheValido && _ultimoTokenCache != null) {
        //print('📦 Usando token do cache local (API retornou 304)');
        return TermoAutorizacaoResponse(
          status: 304,
          mensagens: resultado.mensagens,
          dados: _ultimoTokenCache!.dados,
          autenticarProcuradorToken:
              _ultimoTokenCache!.autenticarProcuradorToken,
          dataExpiracao: _ultimoTokenCache!.dataExpiracao,
          isCacheValido: true,
        );
      }

      // Se recebeu token novo, salvar em cache e no authModel
      if (resultado.sucesso && resultado.autenticarProcuradorToken != null) {
        _ultimoTokenCache = resultado;
        _apiClient.updateProcuradorToken(resultado.autenticarProcuradorToken!);
        //print('💾 Token salvo em cache local e authModel');
      }

      // Verificar erros específicos da API
      if (!resultado.sucesso) {
        final codigo = resultado.codigoMensagem;
        if (codigo.startsWith('AcessoNegado-') ||
            codigo.startsWith('EntradaIncorreta-') ||
            codigo.startsWith('Erro-')) {
          throw ExcecaoErroSerpro.doCodigo(codigo);
        }
      }

      return resultado;
    } on ExcecaoAutenticaProcurador {
      rethrow;
    } catch (e) {
      // Tentar parsear erro da API
      final errorStr = e.toString();
      if (errorStr.contains('AcessoNegado-') ||
          errorStr.contains('EntradaIncorreta-') ||
          errorStr.contains('Erro-')) {
        // Extrair código de erro
        final match = RegExp(
          r'(AcessoNegado|EntradaIncorreta|Erro)-AUTENTICAPROCURADOR-\d+',
        ).firstMatch(errorStr);
        if (match != null) {
          throw ExcecaoErroSerpro.doCodigo(match.group(0)!);
        }
      }

      throw ExcecaoAutenticaProcurador(
        'Erro ao enviar para API: $e',
        codigo: 'ERRO_API',
        statusHttp: 500,
      );
    }
  }
}
