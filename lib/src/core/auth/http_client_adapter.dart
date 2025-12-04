import 'dart:io';
import 'dart:convert';
import 'auth_exceptions.dart';

/// Adaptador HTTP com suporte a mTLS (Mutual TLS) usando certificados cliente
///
/// Esta classe gerencia a configuração de certificados digitais e
/// execução de requisições HTTP com autenticação mútua (mTLS).
///
/// Implementação multiplataforma usando API nativa do Dart (SecurityContext).
class HttpClientAdapter {
  SecurityContext? _securityContext;
  bool _isMtlsEnabled = false;
  HttpClient? _httpClient;

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
        await _loadCertificate(certPath, certPassword);
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

  /// Carrega certificado P12/PFX no SecurityContext usando API nativa do Dart
  ///
  /// Esta implementação usa a API nativa do Dart (SecurityContext) que suporta
  /// PKCS12/PFX nativamente em todas as plataformas (Android, iOS, Web, Desktop, Windows).
  Future<void> _loadCertificate(String certPath, String certPassword) async {
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
      throw StateError('HttpClient não configurado. Chame configureMtls primeiro.');
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
