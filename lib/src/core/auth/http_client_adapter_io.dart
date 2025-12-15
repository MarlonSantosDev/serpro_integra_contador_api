import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'auth_exceptions.dart';

/// Adaptador HTTP com suporte a mTLS (Mutual TLS) usando certificados cliente
///
/// Esta classe gerencia a configuração de certificados digitais e
/// execução de requisições HTTP com autenticação mútua (mTLS).
///
/// Implementação multiplataforma usando API nativa do Dart (SecurityContext).
///
/// ## Modos de operação:
/// - **Com certificado via bytes**: Carrega certificado diretamente dos bytes (Base64 decodificado)
/// - **Com certificado via arquivo**: Carrega certificado de arquivo P12/PFX
/// - **Sem certificado (trial)**: Modo de teste sem mTLS
class HttpClientAdapter {
  SecurityContext? _securityContext;
  bool _isMtlsEnabled = false;
  HttpClient? _httpClient;

  /// Configura mTLS com certificado a partir de bytes (Base64 decodificado)
  ///
  /// Este método é preferível pois não depende de arquivos no sistema de arquivos,
  /// tornando-o mais portátil e seguro (certificado fica apenas na memória).
  ///
  /// [certBytes] Bytes do certificado P12/PFX (resultado de base64.decode)
  /// [certPassword] Senha do certificado
  ///
  /// Exemplo:
  /// ```dart
  /// final certBytes = base64.decode(certificadoBase64);
  /// await adapter.configureMtlsFromBytes(certBytes, 'senha123');
  /// ```
  Future<void> configureMtlsFromBytes(Uint8List certBytes, String certPassword) async {
    try {
      _securityContext = SecurityContext()
        ..useCertificateChainBytes(certBytes, password: certPassword)
        ..usePrivateKeyBytes(certBytes, password: certPassword);

      _isMtlsEnabled = true;

      // Criar HTTP client com configuração de certificado
      _httpClient = HttpClient(context: _securityContext);

      // Aceitar todos os certificados do servidor (focando apenas em client auth)
      _httpClient!.badCertificateCallback = (cert, host, port) => true;
    } on TlsException catch (e) {
      throw CertificateException('Erro SSL/TLS ao carregar certificado: ${e.message}', reason: CertificateErrorReason.invalidFormat);
    } catch (e) {
      if (e is CertificateException) rethrow;
      throw CertificateException('Erro ao configurar mTLS com bytes: $e', reason: CertificateErrorReason.invalidFormat);
    }
  }

  /// Configura mTLS com certificado se fornecido
  ///
  /// [certPath] Caminho para o arquivo de certificado P12/PFX
  /// [certPassword] Senha do certificado
  /// [isProduction] Se está em ambiente de produção
  ///
  /// Em produção com certificado: Carrega certificado no SecurityContext
  /// Em trial: Não usa certificado, aceita certificados auto-assinados
  Future<void> configureMtls(String? certPath, String? certPassword, bool isProduction) async {
    try {
      // Para produção com certificado
      if (isProduction && certPath != null && certPassword != null) {
        await _loadCertificateFromFile(certPath, certPassword);
        _isMtlsEnabled = true;
      } else {
        // Modo trial - sem certificado necessário
        _securityContext = null;
        _isMtlsEnabled = false;
      }

      // Criar HTTP client com configuração apropriada
      _httpClient = HttpClient(context: _securityContext);

      // Aceitar todos os certificados do servidor (focando apenas em client auth)
      // O servidor SERPRO tem certificado válido, mas não precisamos validá-lo aqui
      _httpClient!.badCertificateCallback = (cert, host, port) => true;
    } catch (e) {
      if (e is CertificateException) rethrow;
      throw CertificateException('Erro ao configurar mTLS: $e', certificatePath: certPath, reason: CertificateErrorReason.invalidFormat);
    }
  }

  /// Configura mTLS com certificado via Base64 ou arquivo
  ///
  /// Este método unificado aceita tanto Base64 quanto caminho de arquivo.
  /// Prioriza Base64 se ambos forem fornecidos.
  ///
  /// [certBase64] Certificado P12/PFX em Base64
  /// [certPath] Caminho para o arquivo de certificado P12/PFX
  /// [certPassword] Senha do certificado
  /// [isProduction] Se está em ambiente de produção
  Future<void> configureMtlsUnified({String? certBase64, String? certPath, String? certPassword, required bool isProduction}) async {
    try {
      if (!isProduction) {
        // Modo trial - sem certificado necessário
        _securityContext = null;
        _isMtlsEnabled = false;
        _httpClient = HttpClient(context: _securityContext);
        _httpClient!.badCertificateCallback = (cert, host, port) => true;
        return;
      }

      // Em produção, precisa de certificado
      if (certPassword == null) {
        throw CertificateException('Senha do certificado é obrigatória em produção', reason: CertificateErrorReason.invalidPassword);
      }

      // Priorizar Base64 se fornecido
      if (certBase64 != null && certBase64.trim().isNotEmpty) {
        final certBytes = base64.decode(certBase64);
        await configureMtlsFromBytes(Uint8List.fromList(certBytes), certPassword);
        return;
      }

      // Usar arquivo se Base64 não fornecido
      if (certPath != null && certPath.trim().isNotEmpty) {
        await _loadCertificateFromFile(certPath, certPassword);
        _isMtlsEnabled = true;
        _httpClient = HttpClient(context: _securityContext);
        _httpClient!.badCertificateCallback = (cert, host, port) => true;
        return;
      }

      throw CertificateException(
        'Certificado digital obrigatório em produção. Forneça certBase64 ou certPath.',
        reason: CertificateErrorReason.notFound,
      );
    } catch (e) {
      if (e is CertificateException) rethrow;
      throw CertificateException('Erro ao configurar mTLS: $e', reason: CertificateErrorReason.invalidFormat);
    }
  }

  /// Carrega certificado P12/PFX de arquivo no SecurityContext usando API nativa do Dart
  ///
  /// Esta implementação usa a API nativa do Dart (SecurityContext) que suporta
  /// PKCS12/PFX nativamente em todas as plataformas (Android, iOS, Desktop, Windows).
  Future<void> _loadCertificateFromFile(String certPath, String certPassword) async {
    try {
      // Resolver caminho absoluto se necessário
      final certFile = File(certPath);
      final absolutePath = certFile.isAbsolute ? certPath : certFile.absolute.path;
      final resolvedFile = File(absolutePath);

      // Verificar se arquivo existe
      if (!await resolvedFile.exists()) {
        throw CertificateException(
          'Certificado não encontrado: $absolutePath',
          certificatePath: absolutePath,
          reason: CertificateErrorReason.notFound,
        );
      }

      // Ler arquivo PKCS12/PFX
      final pkcs12Bytes = await resolvedFile.readAsBytes();

      // Usar API nativa do Dart para carregar PKCS12
      // SecurityContext suporta PKCS12 diretamente em todas as plataformas
      // incluindo certificados com algoritmos legados como RC2-40-CBC
      _securityContext = SecurityContext()
        ..useCertificateChainBytes(pkcs12Bytes, password: certPassword)
        ..usePrivateKeyBytes(pkcs12Bytes, password: certPassword);
    } on FileSystemException catch (e) {
      throw CertificateException('Erro ao ler certificado: ${e.message}', certificatePath: certPath, reason: CertificateErrorReason.notFound);
    } on TlsException catch (e) {
      throw CertificateException('Erro SSL/TLS: ${e.message}', certificatePath: certPath, reason: CertificateErrorReason.invalidFormat);
    } catch (e) {
      if (e is CertificateException) rethrow;
      throw CertificateException('Erro ao carregar certificado: $e', certificatePath: certPath, reason: CertificateErrorReason.invalidFormat);
    }
  }

  /// Executa uma requisição POST
  ///
  /// [uri] URL completa do endpoint
  /// [headers] Headers HTTP da requisição
  /// [body] Corpo da requisição (String)
  ///
  /// Retorna o corpo da resposta parseado como JSON
  /// Lança exceções específicas em caso de erro
  Future<Map<String, dynamic>> post(Uri uri, Map<String, String> headers, String body) async {
    if (_httpClient == null) {
      throw StateError('HttpClient não configurado. Chame configureMtls ou configureMtlsFromBytes primeiro.');
    }

    HttpClientRequest? request;
    HttpClientResponse? response;

    try {
      // Criar requisição POST
      request = await _httpClient!.postUrl(uri);

      // Adicionar headers
      headers.forEach((key, value) {
        request!.headers.add(key, value);
      });

      // Adicionar body
      request.write(body);

      // Obter resposta
      response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Verificar status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final res = jsonDecode(responseBody);
        throw AuthenticationFailedException('Requisição falhou..', statusCode: res['status'], responseBody: res['message']);
      }

      // Parsear JSON
      try {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } catch (e) {
        throw AuthenticationFailedException('Resposta não é um JSON válido: $e', statusCode: response.statusCode, responseBody: responseBody);
      }
    } on SocketException catch (e) {
      throw NetworkAuthException('Erro de rede ao autenticar: ${e.message}', originalError: e);
    } on TlsException catch (e) {
      throw CertificateException('Erro SSL/TLS durante autenticação: ${e.message}', reason: CertificateErrorReason.invalidFormat);
    } on HttpException catch (e) {
      throw NetworkAuthException('Erro HTTP: ${e.message}', originalError: e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkAuthException('Erro ao fazer requisição: $e', originalError: e);
    }
  }

  /// Libera recursos alocados
  void dispose() {
    _httpClient?.close();
    _httpClient = null;
    _securityContext = null;
  }

  /// Retorna true se mTLS está habilitado
  bool get isMtlsEnabled => _isMtlsEnabled;
}
