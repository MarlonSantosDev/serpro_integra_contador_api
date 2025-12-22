import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serpro_integra_contador_api/src/base/base_request.dart';
import 'package:serpro_integra_contador_api/src/core/auth/authentication_model.dart';
import 'package:serpro_integra_contador_api/src/util/validacoes_utils.dart';
import 'package:serpro_integra_contador_api/src/util/formatador_utils.dart';
import 'package:serpro_integra_contador_api/src/util/request_tag_generator.dart';
import 'package:serpro_integra_contador_api/src/services/autenticaprocurador/autenticaprocurador_service.dart';
import 'auth/auth_service.dart';
import 'auth/auth_credentials.dart';
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
  static const String _baseUrlDemo =
      'https://gateway.apiserpro.serpro.gov.br/integra-contador-trial/v1';

  /// URL base para ambiente de produção
  static const String _baseUrlProd =
      'https://gateway.apiserpro.serpro.gov.br/integra-contador/v1';

  /// Ambiente atual ('trial' ou 'producao')
  String _ambiente = 'trial';

  /// Modelo de autenticação contendo tokens e dados do contratante/autor
  AuthenticationModel? _authModel;

  /// Serviços de autenticação
  AuthService? _authService;
  HttpClientAdapter? _httpAdapter;
  AuthCredentials? _storedCredentials;

  /// Construtor padrão
  ApiClient();

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS PARA DADOS DE AUTENTICAÇÃO (usados pelos serviços)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Número do contratante (CNPJ) configurado na autenticação
  String? get contratanteNumero => _authModel?.contratanteNumero;

  /// Número do autor do pedido (CPF/CNPJ) configurado na autenticação
  String? get autorPedidoDadosNumero => _authModel?.autorPedidoDadosNumero;

  /// Caminho do certificado digital (se configurado)
  String? get certificadoPath => _storedCredentials?.certPath;

  /// Senha do certificado digital (se configurado)
  String? get certificadoSenha => _storedCredentials?.certPassword;

  /// Verifica se está autenticado
  bool get isAutenticado => _authModel != null;

  /// Configura URLs dos servidores Firebase Cloud Functions
  ///
  /// [urlAutenticacao]: URL base para autenticação OAuth2 normal
  /// [urlAutenticacaoProcurado]: URL base para autenticação de procurador
  /// [urlProxy]: URL base para proxy das requisições POST (evita CORS na web)
  ///
  /// ## Exemplo
  /// ```dart
  /// final apiClient = ApiClient();
  /// apiClient.setServidores(
  ///   urlAutenticacaoProcurado: 'https://servidor.com.app',
  ///   urlAutenticacao: 'https://servidor.com.app',
  ///   urlProxy: 'https://servidor.com.app',
  /// );
  /// ```
  void setServidores({
    String? urlAutenticacao,
    String? urlAutenticacaoProcurado,
    String? urlProxy,
  }) {
    if (urlAutenticacao != null) _urlAutenticacao = urlAutenticacao;
    if (urlAutenticacaoProcurado != null)
      _urlAutenticacaoProcurado = urlAutenticacaoProcurado;
    if (urlProxy != null) _urlProxy = urlProxy;
  }

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

  /// URL para autenticação OAuth2 normal (Firebase Cloud Functions)
  String? _urlAutenticacao;

  /// URL para autenticação de procurador (Firebase Cloud Functions)
  String? _urlAutenticacaoProcurado;

  /// URL para proxy das requisições POST (Firebase Cloud Functions)
  String? _urlProxy;

  /// Certificado usado na autenticação via Cloud Function (para uso no proxy)
  String? _cloudFunctionCertBase64;
  String? _cloudFunctionCertPassword;

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
      // Usar autenticação via Cloud Function se URL estiver configurada
      if (_urlAutenticacao != null && _urlAutenticacao!.isNotEmpty) {
        // Armazenar certificado para uso no proxy
        _cloudFunctionCertBase64 = certificadoDigitalBase64;
        _cloudFunctionCertPassword = senhaCertificado;

        await _authenticateViaCloudFunction(
          consumerKey: consumerKey,
          consumerSecret: consumerSecret,
          contratanteNumero: contratanteNumero,
          autorPedidoDadosNumero: autorPedidoDadosNumero,
          ambiente: ambiente,
        );
        return;
      }

      // 0. Verificar se é uma nova autenticação com dados diferentes
      final novoContratante = contratanteNumero.trim();
      final novoAutor = autorPedidoDadosNumero.trim();

      if (_storedCredentials != null &&
          (_storedCredentials!.contratanteNumero != novoContratante ||
              _storedCredentials!.autorPedidoDadosNumero != novoAutor)) {
        // Limpar dados da autenticação anterior para evitar conflitos
        clearAuthentication();
      }

      // 1. Validar ambiente
      if (ambiente != 'trial' && ambiente != 'producao') {
        throw _buildErrorResponse(
          mensagem: 'Ambiente inválido',
          status: 400,
          resposta:
              'Ambiente deve ser "trial" ou "producao". Recebido: "$ambiente"',
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
          resposta:
              'Campo "autorPedidoDadosNumero" é obrigatório (CPF/CNPJ do autor)',
        );
      }

      // 3. Validar certificado em produção
      if (ambiente == 'producao') {
        final temCertificadoBase64 =
            certificadoDigitalBase64 != null &&
            certificadoDigitalBase64.trim().isNotEmpty;
        final temCertificadoPath =
            certificadoDigitalPath != null &&
            certificadoDigitalPath.trim().isNotEmpty;

        if (!temCertificadoBase64 && !temCertificadoPath) {
          throw _buildErrorResponse(
            mensagem: 'Certificado digital obrigatório em produção',
            status: 400,
            resposta:
                'Para ambiente de produção é necessário informar o certificado digital. '
                'Use "certificadoDigitalBase64" (recomendado) ou "certificadoDigitalPath".',
          );
        }

        if (senhaCertificado == null) {
          throw _buildErrorResponse(
            mensagem: 'Senha do certificado não informada',
            status: 400,
            resposta:
                'Para ambiente de produção é necessário informar a senha do certificado digital (use string vazia "" para certificados sem senha).',
          );
        }
      }

      // 4. Criar credenciais
      final credentials = AuthCredentials(
        consumerKey: consumerKey.trim(),
        consumerSecret: consumerSecret.trim(),
        certPath: certificadoDigitalPath?.trim(),
        certBase64: certificadoDigitalBase64?.trim(),
        certPassword: senhaCertificado?.trim(),
        contratanteNumero: contratanteNumero.trim(),
        autorPedidoDadosNumero: autorPedidoDadosNumero.trim(),
        ambiente: ambiente,
      );

      credentials.validate();
      _storedCredentials = credentials;

      // 5. Inicializar HTTP adapter com mTLS (aceita Base64 diretamente - sem arquivo temporário)
      _httpAdapter = HttpClientAdapter();

      await _httpAdapter!.configureMtlsUnified(
        certBase64: certificadoDigitalBase64,
        certPath: certificadoDigitalPath,
        certPassword: senhaCertificado,
        isProduction: ambiente == 'producao',
      );

      // 6. Inicializar serviço de autenticação
      _authService = AuthService(_httpAdapter!, ambiente);

      // 7. Executar autenticação
      _authModel = await _authService!.authenticate(credentials);

      // Token já está armazenado em _authModel
    } on InvalidCredentialsException catch (e) {
      throw _buildErrorResponse(
        mensagem: e.message,
        status: 400,
        resposta: 'Credenciais inválidas',
      );
    } on CertificateException catch (e) {
      throw _buildErrorResponse(
        mensagem: 'Erro no certificado digital',
        status: 400,
        resposta: e.message,
      );
    } on AuthenticationFailedException catch (e) {
      throw _buildErrorResponse(
        mensagem: 'Falha na autenticação',
        status: e.statusCode,
        resposta: e.responseBody ?? e.message,
      );
    } on NetworkAuthException catch (e) {
      throw _buildErrorResponse(
        mensagem: 'Erro de rede durante autenticação',
        status: 0,
        resposta: e.message,
      );
    } catch (e) {
      throw _buildErrorResponse(
        mensagem: 'Erro inesperado durante autenticação',
        status: 500,
        resposta: e.toString(),
      );
    }
  }

  /// **Autenticação Unificada**: OAuth2 + Procurador em um único passo
  ///
  /// Este método combina a autenticação OAuth2 básica com a autenticação do procurador
  /// em uma única chamada, facilitando o uso quando ambas são necessárias.
  ///
  /// [consumerKey]: Chave do consumidor fornecida pelo SERPRO
  /// [consumerSecret]: Segredo do consumidor forneida pelo SERPRO
  /// [contratanteNumero]: CNPJ da empresa contratante
  /// [autorPedidoDadosNumero]: CPF/CNPJ do autor do pedido
  /// [certificadoDigitalBase64]: Certificado digital em Base64 (opcional)
  /// [certificadoDigitalPath]: Caminho para o arquivo do certificado digital (opcional)
  /// [senhaCertificado]: Senha do certificado digital (opcional)
  /// [ambiente]: Ambiente de execução ('trial' ou 'producao')
  ///
  /// Parâmetros do Procurador (se fornecidos, faz autenticação completa):
  /// [contratanteNome]: Nome da empresa contratante
  /// [autorNome]: Nome do autor da procuração
  /// [contribuinteNumero]: CNPJ do contribuinte (se diferente do contratante)
  /// [autorNumero]: CPF/CNPJ do autor (se diferente do autorPedidoDadosNumero)
  /// [certificadoProcuradorPath]: Caminho do certificado do procurador
  /// [certificadoProcuradorBase64]: Certificado do procurador em Base64
  /// [certificadoProcuradorPassword]: Senha do certificado do procurador
  Future<void> authenticateWithProcurador({
    required String consumerKey,
    required String consumerSecret,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
    String? certificadoDigitalBase64,
    String? certificadoDigitalPath,
    String? senhaCertificado,
    String ambiente = 'trial',

    // Parâmetros do Procurador (se fornecidos, faz autenticação completa)
    String? contratanteNome,
    String? autorNome,
    String? contribuinteNumero,
    String? autorNumero,
    String? certificadoProcuradorPath,
    String? certificadoProcuradorBase64,
    String? certificadoProcuradorPassword,
  }) async {
    // Limpar dados da autenticação anterior para evitar conflitos
    clearAuthentication();

    // Usar autenticação procurador via Cloud Function se URL estiver configurada
    if (_urlAutenticacaoProcurado != null &&
        _urlAutenticacaoProcurado!.isNotEmpty &&
        contratanteNome != null &&
        autorNome != null) {
      // Armazenar certificado para uso no proxy
      _cloudFunctionCertBase64 =
          certificadoProcuradorBase64 ?? certificadoDigitalBase64;
      _cloudFunctionCertPassword =
          certificadoProcuradorPassword ?? senhaCertificado;

      await _authenticateWithProcuradorViaCloudFunction(
        consumerKey: consumerKey,
        consumerSecret: consumerSecret,
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorPedidoDadosNumero: autorNumero ?? autorPedidoDadosNumero,
        autorNome: autorNome,
        ambiente: ambiente,
        contribuinteNumero: contribuinteNumero ?? contratanteNumero,
        certificadoDigitalBase64: certificadoDigitalBase64,
        senhaCertificado: senhaCertificado,
        certificadoProcuradorBase64: certificadoProcuradorBase64,
        certificadoProcuradorPassword: certificadoProcuradorPassword,
      );
      return;
    }

    // Validações dos parâmetros do procurador (se fornecidos)
    if (contratanteNome != null || autorNome != null) {
      // Se forneceu um parâmetro do procurador, todos os obrigatórios devem estar presentes
      if (contratanteNome == null || contratanteNome.trim().isEmpty) {
        throw Exception('Parâmetro obrigatório ausente: contratanteNome');
      }
      if (autorNome == null || autorNome.trim().isEmpty) {
        throw Exception('Parâmetro obrigatório ausente: autorNome');
      }

      // Validar se há pelo menos um certificado disponível
      final hasCertificadoDigital =
          certificadoDigitalPath != null || certificadoDigitalBase64 != null;
      final hasCertificadoProcurador =
          certificadoProcuradorPath != null ||
          certificadoProcuradorBase64 != null;

      if (!hasCertificadoDigital && !hasCertificadoProcurador) {
        throw Exception(
          'Certificado digital necessário. Forneça certificadoDigitalPath/Base64 ou certificadoProcuradorPath/Base64',
        );
      }
    }

    // 1. Fazer autenticação OAuth2 normal
    await authenticate(
      consumerKey: consumerKey,
      consumerSecret: consumerSecret,
      contratanteNumero: contratanteNumero,
      autorPedidoDadosNumero: autorPedidoDadosNumero,
      certificadoDigitalBase64: certificadoDigitalBase64,
      certificadoDigitalPath: certificadoDigitalPath,
      senhaCertificado: senhaCertificado,
      ambiente: ambiente,
    );

    // 2. Se parâmetros do procurador foram fornecidos, fazer autenticação do procurador
    if (contratanteNome != null && autorNome != null) {
      // Validar se a autenticação OAuth2 foi bem-sucedida
      if (_authModel == null) {
        throw Exception(
          'Falha na autenticação OAuth2. Não é possível prosseguir com a autenticação do procurador.',
        );
      }
      final service = AutenticaProcuradorService(this);
      final response = await service.autenticarProcurador(
        contratanteNumero: contratanteNumero,
        contratanteNome: contratanteNome,
        autorNome: autorNome,
        contribuinteNumero: contribuinteNumero ?? contratanteNumero,
        autorNumero: autorNumero ?? autorPedidoDadosNumero,
        certificadoPath: certificadoProcuradorPath ?? certificadoDigitalPath,
        certificadoBase64: certificadoProcuradorBase64,
        certificadoPassword: certificadoProcuradorPassword ?? senhaCertificado,
      );

      if (!response.sucesso) {
        throw Exception(
          'Falha na autenticação do procurador.: ${response.mensagemPrincipal}',
        );
      }

      // Atualizar o _authModel com o token do procurador
      _updateProcuradorToken(response.autenticarProcuradorToken ?? '');
    }
  }

  /// Constrói resposta de erro padronizada em formato JSON
  Exception _buildErrorResponse({
    required String mensagem,
    required int status,
    required String resposta,
  }) {
    final errorJson = {
      'mensagem': mensagem,
      'status': status,
      'resposta': resposta,
    };
    return Exception(json.encode(errorJson));
  }

  /// Autentica via Firebase Cloud Function (para uso na Web)
  Future<void> _authenticateViaCloudFunction({
    required String consumerKey,
    required String consumerSecret,
    required String contratanteNumero,
    required String autorPedidoDadosNumero,
    required String ambiente,
    String? certSecretName,
    String? certPasswordSecretName,
    String? firebaseToken,
  }) async {
    if (_urlAutenticacao == null) {
      throw Exception(
        'urlAutenticacao não configurado. Chame setServidores() primeiro.',
      );
    }
    final url = Uri.parse('$_urlAutenticacao/autenticar_serpro');
    final body = <String, String>{
      'consumer_key': consumerKey,
      'consumer_secret': consumerSecret,
      'contratante_numero': contratanteNumero,
      'autor_pedido_dados_numero': autorPedidoDadosNumero,
      'ambiente': ambiente,
    };
    if (certSecretName != null) body['cert_secret_name'] = certSecretName;
    if (certPasswordSecretName != null)
      body['cert_password_secret_name'] = certPasswordSecretName;

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (firebaseToken != null)
      headers['Authorization'] = 'Bearer $firebaseToken';

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      _authModel = AuthenticationModel(
        expiresIn: responseBody['expires_in'] ?? 2008,
        scope: responseBody['scope'] ?? 'default',
        tokenType: responseBody['token_type'] ?? 'Bearer',
        accessToken: responseBody['access_token'],
        jwtToken: responseBody['jwt_token'],
        contratanteNumero:
            responseBody['contratante_numero'] ?? contratanteNumero,
        autorPedidoDadosNumero:
            responseBody['autor_pedido_dados_numero'] ?? autorPedidoDadosNumero,
        tokenCreatedAt: DateTime.now(),
      );
      _ambiente = ambiente;
    } else {
      throw _buildErrorResponse(
        mensagem: 'Falha servidor',
        status: response.statusCode,
        resposta: response.body,
      );
    }
  }

  /// Autentica Procurador via Firebase Cloud Function (para uso na Web)
  Future<void> _authenticateWithProcuradorViaCloudFunction({
    required String consumerKey,
    required String consumerSecret,
    required String contratanteNumero,
    required String contratanteNome,
    required String autorPedidoDadosNumero,
    required String autorNome,
    required String ambiente,
    String? contribuinteNumero,
    String? certSecretName,
    String? certPasswordSecretName,
    String? firebaseToken,
    String? certificadoDigitalBase64,
    String? senhaCertificado,
    String? certificadoProcuradorBase64,
    String? certificadoProcuradorPassword,
  }) async {
    if (_urlAutenticacaoProcurado == null) {
      throw Exception(
        'urlAutenticacaoProcurado não configurado. Chame setServidores() primeiro.',
      );
    }
    final url = Uri.parse('$_urlAutenticacaoProcurado/autenticar_procurador');
    final body = <String, String>{
      'consumer_key': consumerKey,
      'consumer_secret': consumerSecret,
      'contratante_numero': contratanteNumero,
      'contratante_nome': contratanteNome,
      'autor_pedido_dados_numero': autorPedidoDadosNumero,
      'autor_nome': autorNome,
      'ambiente': ambiente,
    };
    if (contribuinteNumero != null)
      body['contribuinte_numero'] = contribuinteNumero;
    if (certSecretName != null) body['cert_secret_name'] = certSecretName;
    if (certPasswordSecretName != null)
      body['cert_password_secret_name'] = certPasswordSecretName;
    if (certificadoDigitalBase64 != null)
      body['certificado_base64'] = certificadoDigitalBase64;
    if (senhaCertificado != null) body['certificado_senha'] = senhaCertificado;
    if (certificadoProcuradorBase64 != null)
      body['certificado_procurador_base64'] = certificadoProcuradorBase64;
    if (certificadoProcuradorPassword != null)
      body['certificado_procurador_senha'] = certificadoProcuradorPassword;

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (firebaseToken != null)
      headers['Authorization'] = 'Bearer $firebaseToken';

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseBody =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      _authModel = AuthenticationModel(
        expiresIn: responseBody['expires_in'] ?? 2008,
        scope: responseBody['scope'] ?? 'default',
        tokenType: responseBody['token_type'] ?? 'Bearer',
        accessToken: responseBody['access_token'],
        jwtToken: responseBody['jwt_token'],
        contratanteNumero:
            responseBody['contratante_numero'] ?? contratanteNumero,
        autorPedidoDadosNumero:
            responseBody['autor_pedido_dados_numero'] ?? autorPedidoDadosNumero,
        tokenCreatedAt: DateTime.now(),
        procuradorToken: responseBody['procurador_token'] ?? '',
      );
      _ambiente = ambiente;
    } else {
      throw _buildErrorResponse(
        mensagem: 'Falha procurador via Servidor',
        status: response.statusCode,
        resposta: response.body,
      );
    }
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
        } catch (e) {
          // Se falhar a re-autenticação, limpar tudo
          _authModel = null;
          throw Exception(
            'Token expirado e não foi possível renovar automaticamente. '
            'Erro: $e. Por favor, chame authenticate() novamente.',
          );
        }
      } else {
        // Não temos credenciais para re-autenticar
        _authModel = null;
        throw Exception(
          'Token expirado. Por favor, chame authenticate() novamente.',
        );
      }
    }

    // Usar dados customizados se fornecidos, senão usar os dados padrão
    final finalContratanteNumero =
        contratanteNumero ?? _authModel!.contratanteNumero;

    // Quando há token de procurador, o autorPedidoDadosNumero deve ser o contribuinteNumero
    final finalAutorPedidoDadosNumero =
        autorPedidoDadosNumero ??
        (hasProcuradorToken
            ? request.contribuinteNumero
            : _authModel!.autorPedidoDadosNumero);

    // Criar o JSON completo usando os dados de autenticação
    final requestBody = request.toJsonWithAuth(
      contratanteNumero: finalContratanteNumero,
      contratanteTipo: ValidacoesUtils.detectDocumentType(
        finalContratanteNumero,
      ),
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      autorPedidoDadosTipo: ValidacoesUtils.detectDocumentType(
        finalAutorPedidoDadosNumero,
      ),
    );

    // Preparar headers obrigatórios
    final headers = <String, String>{
      'Authorization': 'Bearer ${_authModel!.accessToken}',
      'jwt_token': _authModel!.jwtToken,
      'Content-Type': 'application/json',
    };

    // Adicionar token de procurador (sempre do authModel, parâmetro ignorado)
    if (_authModel != null && _authModel!.procuradorToken.isNotEmpty) {
      headers['autenticar_procurador_token'] = _authModel!.procuradorToken;
    }

    // Gerar e adicionar identificador de requisição
    final requestTag = RequestTagGenerator.generateRequestTag(
      autorPedidoDadosNumero: finalAutorPedidoDadosNumero,
      contribuinteNumero: request.contribuinteNumero,
      idServico: request.pedidoDados.idServico,
    );
    headers['X-Request-Tag'] = requestTag;

    // Executar requisição HTTP POST
    final response = await (() async {
      // Se urlProxy estiver configurado (Web), usar proxy
      if (_urlProxy != null && _urlProxy!.isNotEmpty) {
        final proxyUrl = Uri.parse('$_urlProxy/proxy_serpro');
        final proxyHeaders = <String, String>{
          'Content-Type': 'application/json',
        };
        final proxyBody = {
          'endpoint': endpoint,
          'body': requestBody,
          'access_token': _authModel!.accessToken,
          'jwt_token': _authModel!.jwtToken,
          'procurador_token': _authModel!.procuradorToken.isNotEmpty
              ? _authModel!.procuradorToken
              : null,
          'ambiente': _ambiente,
          'certificado_base64':
              _cloudFunctionCertBase64 ?? _storedCredentials?.certBase64,
          'certificado_senha':
              _cloudFunctionCertPassword ?? _storedCredentials?.certPassword,
        };

        //print("================================================");
        //print("Usando proxy: $proxyUrl");
        //print("Proxy body: ${json.encode(proxyBody)}");
        //print("================================================");

        return await http.post(
          proxyUrl,
          headers: proxyHeaders,
          body: json.encode(proxyBody),
        );
      } else {
        // Requisição direta (Desktop/Mobile ou quando urlProxy não está configurado)
        //print("================================================");
        //print("Endpoint direto: $_baseUrl$endpoint");
        //print("headers: ${headers}");
        //print("requestBody: ${json.encode(requestBody)}");
        //print("================================================");

        return await http.post(
          Uri.parse('$_baseUrl$endpoint'),
          headers: headers,
          body: json.encode(requestBody),
        );
      }
    })();
    // Verificar se a requisição foi bem-sucedida
    if (response.statusCode >= 200 && response.statusCode < 300) {
      Map<String, dynamic> responseBody =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

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
        "mensagens":
            "Credenciais inválidas. Certifique-se de ter fornecido as credenciais de segurança corretas",
        "body": "Credenciais inválidas",
      });
    } else if (response.statusCode == 304) {
      final autenticarProcuradorToken = response.headers['etag']
          .toString()
          .replaceAll(':', '":"');
      final expiresISO =
          FormatadorUtils.converterHttpExpiresParaISO(
            response.headers['expires'],
          ) ??
          '';
      final stringBody =
          "{$autenticarProcuradorToken, \"data_hora_expiracao\":\"$expiresISO\"}";
      final body = jsonDecode(stringBody);
      return {
        "status": response.statusCode,
        "mensagens": "Resposta em cache (304 Not Modified)",
        "dados": body,
      };
    } else {
      throw Exception(
        'Falha na requisição: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
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
      throw Exception(
        'Cliente não autenticado. Chame o método authenticate primeiro.',
      );
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
      Map<String, dynamic> responseBody =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      // Salvar token de procurador no authModel
      if (responseBody['autenticarProcuradorToken'] != null) {
        // Atualizar o _authModel com o token do procurador
        _updateProcuradorToken(responseBody['autenticarProcuradorToken']);
      }

      return responseBody;
    } else {
      throw Exception(
        'Falha na autenticação de procurador: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  /// Verifica se existe token de procurador válido no authModel
  bool get hasProcuradorToken =>
      _authModel?.procuradorToken.isNotEmpty ?? false;

  /// Obtém token de procurador do authModel
  String? get procuradorToken => _authModel?.procuradorToken;

  /// Atualiza o token de procurador no authModel (usado internamente e pelos services)
  void updateProcuradorToken(String procuradorToken) {
    _updateProcuradorToken(procuradorToken);
  }

  /// Atualiza o token de procurador no authModel (usado internamente)
  void _updateProcuradorToken(String procuradorToken) {
    if (_authModel != null) {
      _authModel = AuthenticationModel(
        accessToken: _authModel!.accessToken,
        jwtToken: _authModel!.jwtToken,
        expiresIn: _authModel!.expiresIn,
        contratanteNumero: _authModel!.contratanteNumero,
        autorPedidoDadosNumero: _authModel!.autorPedidoDadosNumero,
        tokenCreatedAt: _authModel!.tokenCreatedAt,
        tokenType: _authModel!.tokenType,
        scope: _authModel!.scope,
        fromCache: _authModel!.fromCache,
        procuradorToken: procuradorToken,
      );
    }
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
    if (_authModel == null ||
        _authService == null ||
        _storedCredentials == null) {
      throw Exception(
        'Cliente não autenticado ou credenciais não disponíveis. '
        'Chame authenticate() primeiro.',
      );
    }

    try {
      _authModel = await _authService!.authenticate(_storedCredentials!);
    } catch (e) {
      _authModel = null;
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
    _httpAdapter?.dispose();
    _httpAdapter = null;
    _authService = null;
    _storedCredentials = null;
    _cloudFunctionCertBase64 = null;
    _cloudFunctionCertPassword = null;

    // Limpar cache estático do serviço de procurador
    AutenticaProcuradorService.limparCache();
  }
}
