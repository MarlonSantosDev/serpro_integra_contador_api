import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/core/auth/authentication_model.dart';
import 'package:serpro_integra_contador_api/src/util/validacoes_utils.dart';
import 'package:serpro_integra_contador_api/src/util/request_tag_generator.dart';
import 'package:serpro_integra_contador_api/src/services/autenticaprocurador/model/cache_model.dart';
import 'auth/auth_service.dart';
import 'auth/auth_credentials.dart';
import 'auth/auth_token_cache.dart';
import 'auth/http_client_adapter.dart';
import 'auth/auth_exceptions.dart';

/// Cliente principal para comunicação com a API do SERPRO Integra Contador
///
/// ## Uso Simples
///
/// **Modo Trial (sem certificado):**
/// ```dart
/// final apiClient = ApiClient();
/// await apiClient.authenticate(
///   consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
///   consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
///   contratanteNumero: '00000000000191',
///   autorPedidoDadosNumero: '00000000191',
///   ambiente: 'trial',
/// );
/// ```
///
/// **Modo Produção (com certificado):**
/// ```dart
/// final apiClient = ApiClient();
/// await apiClient.authenticate(
///   consumerKey: 'sua_key',
///   consumerSecret: 'seu_secret',
///   contratanteNumero: '12345678000100',
///   autorPedidoDadosNumero: '11122233344',
///   certificadoDigitalBase64: 'BASE64_DO_CERTIFICADO',
///   senhaCertificado: 'senha123',
///   ambiente: 'producao',
/// );
/// ```
///
/// ## Autenticação Automática no Construtor
///
/// ```dart
/// final apiClient = ApiClient.autenticar(
///   consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
///   consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
///   contratanteNumero: '00000000000191',
///   autorPedidoDadosNumero: '00000000191',
///   ambiente: 'trial',
/// );
/// // Pronto para usar!
/// await CaixaPostal(apiClient);
/// ```
class ApiClient {
  /// URL base para ambiente de demonstração/teste
  static const String _baseUrlDemo = 'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';

  /// URL base para ambiente de produção
  static const String _baseUrlProd = 'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1';

  /// Ambiente atual ('trial' ou 'producao')
  String _ambiente = 'trial';

  /// Modelo de autenticação contendo tokens e dados do contratante/autor
  AuthenticationModel? _authModel;

  /// Cache do token de procurador para evitar reautenticações desnecessárias
  CacheModel? _procuradorCache;

  /// Serviços de autenticação
  AuthService? _authService;
  AuthTokenCache? _tokenCache;
  HttpClientAdapter? _httpAdapter;
  AuthCredentials? _storedCredentials;

  /// Construtor padrão
  ApiClient();

  /// Construtor com autenticação automática
  ///
  /// Cria uma instância e já autentica automaticamente.
  /// Útil para simplificar o uso da API.
  ///
  /// **Exemplo Trial:**
  /// ```dart
  /// final apiClient = await ApiClient.autenticar(
  ///   consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  ///   consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  ///   contratanteNumero: '00000000000191',
  ///   autorPedidoDadosNumero: '00000000191',
  ///   ambiente: 'trial',
  /// );
  /// ```
  ///
  /// **Exemplo Produção:**
  /// ```dart
  /// final apiClient = await ApiClient.autenticar(
  ///   consumerKey: 'sua_key',
  ///   consumerSecret: 'seu_secret',
  ///   contratanteNumero: '12345678000100',
  ///   autorPedidoDadosNumero: '11122233344',
  ///   certificadoDigitalBase64: 'BASE64_DO_CERTIFICADO',
  ///   senhaCertificado: 'senha123',
  ///   ambiente: 'producao',
  /// );
  /// ```
  static Future<ApiClient> autenticar({
    required String consumerKey,
    required String consumerSecret,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
    String? certificadoDigitalBase64,
    String? certificadoDigitalPath,
    String? senhaCertificado,
    String ambiente = 'trial',
  }) async {
    final client = ApiClient();
    await client.authenticate(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      certificadoDigitalBase64: certificadoDigitalBase64,
      certificadoDigitalPath: certificadoDigitalPath,
      senhaCertificado: senhaCertificado,
      ambiente: ambiente,
    );
    return client;
  }

  /// Obtém a URL base de acordo com o ambiente configurado
  String get _baseUrl => _ambiente == 'producao' ? _baseUrlProd : _baseUrlDemo;

  /// Autentica o cliente com a API do SERPRO usando OAuth2 e mTLS
  ///
  /// ## Parâmetros
  /// - [consumerKey]: Consumer Key fornecido pelo SERPRO (obrigatório)
  /// - [consumerSecret]: Consumer Secret fornecido pelo SERPRO (obrigatório)
  /// - [contratanteNumero]: CNPJ da empresa contratante (obrigatório)
  /// - [autorPedidoDadosNumero]: CPF/CNPJ do autor da requisição (obrigatório)
  /// - [certificadoDigitalBase64]: Certificado P12/PFX em Base64 (produção)
  /// - [certificadoDigitalPath]: Caminho do arquivo P12/PFX (produção)
  /// - [senhaCertificado]: Senha do certificado (produção)
  /// - [ambiente]: 'trial' ou 'producao' (padrão: 'trial')
  ///
  /// ## Exemplos
  ///
  /// **Trial (sem certificado):**
  /// ```dart
  /// await apiClient.authenticate(
  ///   consumerKey: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  ///   consumerSecret: '06aef429-a981-3ec5-a1f8-71d38d86481e',
  ///   contratanteNumero: '00000000000191',
  ///   autorPedidoDadosNumero: '00000000191',
  ///   ambiente: 'trial',
  /// );
  /// ```
  ///
  /// **Produção (com certificado em Base64):**
  /// ```dart
  /// await apiClient.authenticate(
  ///   consumerKey: 'sua_key',
  ///   consumerSecret: 'seu_secret',
  ///   contratanteNumero: '12345678000100',
  ///   autorPedidoDadosNumero: '11122233344',
  ///   certificadoDigitalBase64: 'MIIJqQIBAzCCCW8GCSqGSIb3...',
  ///   senhaCertificado: 'senha123',
  ///   ambiente: 'producao',
  /// );
  /// ```
  ///
  /// **Produção (com certificado em arquivo):**
  /// ```dart
  /// await apiClient.authenticate(
  ///   consumerKey: 'sua_key',
  ///   consumerSecret: 'seu_secret',
  ///   contratanteNumero: '12345678000100',
  ///   autorPedidoDadosNumero: '11122233344',
  ///   certificadoDigitalPath: '/caminho/certificado.pfx',
  ///   senhaCertificado: 'senha123',
  ///   ambiente: 'producao',
  /// );
  /// ```
  ///
  /// ## Erros Retornados (formato JSON)
  /// ```json
  /// {
  ///   "mensagem": "Consumer Secret não informado ou inválido",
  ///   "status": 400,
  ///   "resposta": "Campo 'consumerSecret' é obrigatório"
  /// }
  /// ```
  Future<void> authenticate({
    required String consumerKey,
    required String consumerSecret,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
    String? certificadoDigitalBase64,
    String? certificadoDigitalPath,
    String? senhaCertificado,
    String ambiente = 'trial',
  }) async {
    try {
      // 1. Validar ambiente
      if (ambiente != 'trial' && ambiente != 'producao') {
        throw _buildErrorResponse(
          mensagem: 'Ambiente inválido',
          status: 400,
          resposta: 'Ambiente deve ser "trial" ou "producao". Recebido: "$ambiente"',
        );
      }
      _ambiente = ambiente;

      // 2. Validar credenciais obrigatórias
      if (consumerKey.trim().isEmpty) {
        throw _buildErrorResponse(
          mensagem: 'Consumer Key não informado ou inválido',
          status: 400,
          resposta: 'Campo "consumerKey" é obrigatório e não pode ser vazio',
        );
      }

      if (consumerSecret.trim().isEmpty) {
        throw _buildErrorResponse(
          mensagem: 'Consumer Secret não informado ou inválido',
          status: 400,
          resposta: 'Campo "consumerSecret" é obrigatório e não pode ser vazio',
        );
      }

      if (contratanteNumero.trim().isEmpty) {
        throw _buildErrorResponse(
          mensagem: 'Número do contratante não informado',
          status: 400,
          resposta: 'Campo "contratanteNumero" é obrigatório (CNPJ da empresa)',
        );
      }

      if (autorPedidoDadosNumero.trim().isEmpty) {
        throw _buildErrorResponse(
          mensagem: 'Número do autor não informado',
          status: 400,
          resposta: 'Campo "autorPedidoDadosNumero" é obrigatório (CPF/CNPJ do autor)',
        );
      }

      // 3. Validar certificado em produção
      if (ambiente == 'producao') {
        final temCertificadoBase64 = certificadoDigitalBase64 != null && certificadoDigitalBase64.trim().isNotEmpty;
        final temCertificadoPath = certificadoDigitalPath != null && certificadoDigitalPath.trim().isNotEmpty;

        if (!temCertificadoBase64 && !temCertificadoPath) {
          throw _buildErrorResponse(
            mensagem: 'Certificado digital obrigatório em produção',
            status: 400,
            resposta:
                'Para ambiente de produção é necessário informar o certificado digital. '
                'Use "certificadoDigitalBase64" (recomendado) ou "certificadoDigitalPath".',
          );
        }

        if (senhaCertificado == null || senhaCertificado.trim().isEmpty) {
          throw _buildErrorResponse(
            mensagem: 'Senha do certificado não informada',
            status: 400,
            resposta: 'Para ambiente de produção é necessário informar a senha do certificado digital.',
          );
        }
      }

      // 4. Se tiver certificado em Base64, converter para arquivo temporário ANTES de criar credenciais
      String? certPathToUse = certificadoDigitalPath;
      if (certificadoDigitalBase64 != null && certificadoDigitalBase64.trim().isNotEmpty) {
        certPathToUse = await _saveCertificateFromBase64(certificadoDigitalBase64);
      }

      // 5. Criar credenciais (agora com o caminho do arquivo já definido)
      final credentials = AuthCredentials(
        consumerKey: consumerKey.trim(),
        consumerSecret: consumerSecret.trim(),
        certPath: certPathToUse?.trim(),
        certPassword: senhaCertificado?.trim(),
        contratanteNumero: contratanteNumero.trim(),
        autorPedidoDadosNumero: autorPedidoDadosNumero.trim(),
        ambiente: ambiente,
      );

      credentials.validate();
      _storedCredentials = credentials;

      // 6. Inicializar HTTP adapter com mTLS
      _httpAdapter = HttpClientAdapter();

      await _httpAdapter!.configureMtls(certPathToUse, senhaCertificado, ambiente == 'producao');

      // 7. Inicializar serviço de autenticação
      _authService = AuthService(_httpAdapter!, ambiente);

      // 7. Executar autenticação
      _authModel = await _authService!.authenticate(credentials);

      // 8. Inicializar cache de tokens
      _tokenCache = AuthTokenCache();
      _tokenCache!.saveToken(_authModel!);
    } on InvalidCredentialsException catch (e) {
      throw _buildErrorResponse(mensagem: e.message, status: 400, resposta: 'Credenciais inválidas');
    } on CertificateException catch (e) {
      throw _buildErrorResponse(mensagem: 'Erro no certificado digital', status: 400, resposta: e.message);
    } on AuthenticationFailedException catch (e) {
      throw _buildErrorResponse(mensagem: 'Falha na autenticação', status: e.statusCode, resposta: e.responseBody ?? e.message);
    } on NetworkAuthException catch (e) {
      throw _buildErrorResponse(mensagem: 'Erro de rede durante autenticação', status: 0, resposta: e.message);
    } catch (e) {
      throw _buildErrorResponse(mensagem: 'Erro inesperado durante autenticação', status: 500, resposta: e.toString());
    }
  }

  /// Salva certificado em Base64 em arquivo temporário
  Future<String> _saveCertificateFromBase64(String base64String) async {
    try {
      final bytes = base64.decode(base64String);
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/serpro_cert_${DateTime.now().millisecondsSinceEpoch}.p12');
      await tempFile.writeAsBytes(bytes);
      return tempFile.path;
    } catch (e) {
      throw _buildErrorResponse(
        mensagem: 'Erro ao processar certificado Base64',
        status: 400,
        resposta: 'Não foi possível decodificar o certificado Base64. Verifique se o formato está correto.',
      );
    }
  }

  /// Constrói resposta de erro padronizada em formato JSON
  Exception _buildErrorResponse({required String mensagem, required int status, required String resposta}) {
    final errorJson = {'mensagem': mensagem, 'status': status, 'resposta': resposta};
    return Exception(json.encode(errorJson));
  }

  /// Executa uma requisição POST para a API do SERPRO
  ///
  /// [endpoint]: Caminho do endpoint (ex: '/Ccmei/Emitir')
  /// [request]: Objeto BaseRequest contendo os dados da requisição
  /// [contratanteNumero]: CNPJ do contratante (opcional, usa o padrão se não fornecido)
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor (opcional, usa o padrão se não fornecido)
  /// [procuradorToken]: Token de procurador para operações que requerem procuração
  ///
  /// Retorna: Map com a resposta da API ou lança exceção em caso de erro
  ///
  /// ## Renovação Automática de Tokens
  ///
  /// Este método verifica automaticamente se o token está próximo de expirar
  /// e renova antes de fazer a requisição. Isso é transparente para o usuário.
  Future<Map<String, dynamic>> post(
    String endpoint,
    BaseRequest request, {
    String? contratanteNumero,
    String? autorPedidoDadosNumero,
    String? procuradorToken,
  }) async {
    // Verificar se o cliente foi autenticado
    if (_authModel == null) {
      throw _buildErrorResponse(
        mensagem: 'Cliente não autenticado',
        status: 401,
        resposta: 'Primeiro faça a autenticação usando o método authenticate()',
      );
    }

    // RENOVAÇÃO AUTOMÁTICA: Verificar se token está próximo de expirar
    if (_authModel!.shouldRefresh || _authModel!.isExpired) {
      if (_storedCredentials != null && _authService != null) {
        try {
          // Re-autenticar automaticamente
          _authModel = await _authService!.authenticate(_storedCredentials!);
          _tokenCache?.saveToken(_authModel!);
        } catch (e) {
          // Se falhar a re-autenticação, limpar tudo
          _authModel = null;
          _tokenCache?.invalidate();
          throw Exception(
            'Token expirado e não foi possível renovar automaticamente. '
            'Erro: $e. Por favor, chame authenticate() novamente.',
          );
        }
      } else {
        // Não temos credenciais para re-autenticar
        _authModel = null;
        _tokenCache?.invalidate();
        throw Exception('Token expirado. Por favor, chame authenticate() novamente.');
      }
    }

    // Usar dados customizados se fornecidos, senão usar os dados padrão
    final finalContratanteNumero = contratanteNumero ?? _authModel!.contratanteNumero;
    final finalAutorPedidoDadosNumero = autorPedidoDadosNumero ?? _authModel!.autorPedidoDadosNumero;

    // Criar o JSON completo usando os dados de autenticação
    final requestBody = request.toJsonWithAuth(
      contratanteNumero: finalContratanteNumero,
      contratanteTipo: ValidacoesUtils.detectDocumentType(finalContratanteNumero),
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      autorPedidoDadosTipo: ValidacoesUtils.detectDocumentType(finalAutorPedidoDadosNumero),
    );

    // Preparar headers obrigatórios
    final headers = <String, String>{
      'Authorization': 'Bearer ${_authModel!.accessToken}',
      'jwt_token': _authModel!.jwtToken,
      'Content-Type': 'application/json',
    };

    // Adicionar token de procurador se fornecido
    if (procuradorToken != null && procuradorToken.isNotEmpty) {
      headers['autenticar_procurador_token'] = procuradorToken;
    }

    // Gerar e adicionar identificador de requisição
    final requestTag = RequestTagGenerator.generateRequestTag(
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      contribuinteNumero: request.contribuinteNumero,
      idServico: request.pedidoDados.idServico,
    );
    headers['X-Request-Tag'] = requestTag;

    // Executar requisição HTTP POST
    final response = await http.post(Uri.parse('$_baseUrl$endpoint'), headers: headers, body: json.encode(requestBody));

    // Verificar se a requisição foi bem-sucedida
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Verificar se a API retornou um erro de negócio
      if (responseBody.isNotEmpty &&
          responseBody['mensagens'] != null &&
          responseBody['mensagens'] is List &&
          (responseBody['mensagens'] as List).isNotEmpty &&
          responseBody['mensagens'][0]['codigo'] == "ERRO") {
        // Reformatar resposta de erro
        responseBody = {
          "rota": endpoint,
          "status": response.statusCode,
          "idSistema": requestBody['pedidoDados']['idSistema'],
          "idServico": requestBody['pedidoDados']['idServico'],
          "mensagens": "${responseBody['mensagens'][0]['texto']}",
          "body": json.encode(requestBody),
        };
        throw Exception(responseBody);
      }
      return responseBody;
    } else if (response.statusCode == 401) {
      throw Exception({
        "status": response.statusCode,
        "mensagens": "Credenciais inválidas. Certifique-se de ter fornecido as credenciais de segurança corretas",
        "body": "Credenciais inválidas",
      });
    } else {
      throw Exception('Falha na requisição: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Autentica procurador usando termo de autorização assinado digitalmente
  ///
  /// Este método é usado quando um procurador precisa realizar operações em nome do contribuinte.
  ///
  /// [termoAutorizacaoBase64]: Termo de autorização assinado e codificado em Base64
  /// [contratanteNumero]: CNPJ da empresa contratante
  /// [autorPedidoDadosNumero]: CPF/CNPJ do procurador
  ///
  /// Retorna: Map com token de procurador e informações de cache
  Future<Map<String, dynamic>> autenticarProcurador({
    required String termoAutorizacaoBase64,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
  }) async {
    if (_authModel == null) {
      throw Exception('Cliente não autenticado. Chame o método authenticate primeiro.');
    }

    final requestBody = {'termoAutorizacao': termoAutorizacaoBase64};

    final requestTag = RequestTagGenerator.generateRequestTag(
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      contribuinteNumero: contratanteNumero,
      idServico: 'AUTENTICARPROCURADOR',
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/AutenticarProcurador'),
      headers: {
        'Authorization': 'Bearer ${_authModel!.accessToken}',
        'jwt_token': _authModel!.jwtToken,
        'Content-Type': 'application/json',
        'X-Request-Tag': requestTag,
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Salvar token de procurador em cache
      if (responseBody['autenticar_procurador_token'] != null) {
        _procuradorCache = CacheModel.fromResponse(
          token: responseBody['autenticar_procurador_token'],
          headers: response.headers,
          contratanteNumero: contratanteNumero,
          autorPedidoDadosNumero: autorPedidoDadosNumero,
        );
      }

      return responseBody;
    } else {
      throw Exception('Falha na autenticação de procurador: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Verifica se existe token de procurador válido em cache
  bool get hasProcuradorToken => _procuradorCache?.isTokenValido ?? false;

  /// Obtém token de procurador do cache
  String? get procuradorToken => _procuradorCache?.token;

  /// Define token de procurador manualmente
  void setProcuradorToken(String token, {required String contratanteNumero, required String autorPedidoDadosNumero}) {
    _procuradorCache = CacheModel(
      token: token,
      dataCriacao: DateTime.now(),
      dataExpiracao: DateTime.now().add(const Duration(hours: 24)),
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
    );
  }

  /// Limpa cache de procurador
  void clearProcuradorCache() {
    _procuradorCache = null;
  }

  /// Obtém informações do cache de procurador
  Map<String, dynamic>? get procuradorCacheInfo {
    if (_procuradorCache == null) return null;

    return {
      'token': _procuradorCache!.token.substring(0, 8) + '...',
      'is_valido': _procuradorCache!.isTokenValido,
      'expira_em_breve': _procuradorCache!.expiraEmBreve,
      'tempo_restante_horas': _procuradorCache!.tempoRestante.inHours,
      'contratante_numero': _procuradorCache!.contratanteNumero,
      'autor_pedido_dados_numero': _procuradorCache!.autorPedidoDadosNumero,
    };
  }

  /// Verifica se o cliente está autenticado
  bool get isAuthenticated => _authModel != null;

  /// Obtém os dados de autenticação (apenas para debugging)
  AuthenticationModel? get authModel => _authModel;

  /// Obtém informações sobre o status do token de autenticação
  ///
  /// Retorna um Map com informações úteis:
  /// - `authenticated`: se está autenticado
  /// - `expires_in_seconds`: segundos até expiração
  /// - `expires_in_minutes`: minutos até expiração
  /// - `should_refresh`: se deve renovar em breve
  /// - `is_expired`: se já expirou
  /// - `token_type`: tipo do token
  /// - `ambiente`: ambiente atual
  /// - `mtls_enabled`: se mTLS está habilitado
  ///
  /// ## Exemplo
  ///
  /// ```dart
  /// final info = apiClient.authTokenInfo;
  /// print('Expira em: ${info['expires_in_minutes']} minutos');
  /// print('mTLS ativo: ${info['mtls_enabled']}');
  /// ```
  Map<String, dynamic> get authTokenInfo {
    if (_authModel == null) {
      return {'authenticated': false};
    }

    return {
      'authenticated': true,
      'expires_in_seconds': _authModel!.timeUntilExpiration.inSeconds,
      'expires_in_minutes': _authModel!.timeUntilExpiration.inMinutes,
      'should_refresh': _authModel!.shouldRefresh,
      'is_expired': _authModel!.isExpired,
      'token_type': _authModel!.tokenType,
      'ambiente': _ambiente,
      'mtls_enabled': _httpAdapter?.isMtlsEnabled ?? false,
    };
  }

  /// Força re-autenticação manual
  ///
  /// Útil quando você sabe que o token vai expirar em breve ou
  /// quando deseja garantir um token novo.
  ///
  /// Requer que `authenticate()` tenha sido chamado anteriormente.
  ///
  /// ## Exemplo
  ///
  /// ```dart
  /// try {
  ///   await apiClient.forceReauthenticate();
  ///   print('Token renovado com sucesso!');
  /// } catch (e) {
  ///   print('Erro ao renovar token: $e');
  /// }
  /// ```
  Future<void> forceReauthenticate() async {
    if (_authModel == null || _authService == null || _storedCredentials == null) {
      throw Exception(
        'Cliente não autenticado ou credenciais não disponíveis. '
        'Chame authenticate() primeiro.',
      );
    }

    try {
      _authModel = await _authService!.authenticate(_storedCredentials!);
      _tokenCache?.saveToken(_authModel!);
    } catch (e) {
      _authModel = null;
      _tokenCache?.invalidate();
      rethrow;
    }
  }

  /// Limpa toda a autenticação e libera recursos
  ///
  /// Após chamar este método, será necessário autenticar novamente
  /// antes de fazer qualquer requisição.
  ///
  /// ## Exemplo
  ///
  /// ```dart
  /// apiClient.clearAuthentication();
  /// // Agora é necessário chamar authenticate() novamente
  /// ```
  void clearAuthentication() {
    _authModel = null;
    _tokenCache?.invalidate();
    _httpAdapter?.dispose();
    _httpAdapter = null;
    _authService = null;
    _storedCredentials = null;
    clearProcuradorCache();
  }
}
