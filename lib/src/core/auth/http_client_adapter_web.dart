import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'auth_exceptions.dart';

/// Adaptador HTTP para Flutter Web
///
/// Web browsers não suportam mTLS (Mutual TLS) nativamente.
/// Para autenticação OAuth2 com mTLS, use o parâmetro urlServidor
/// no método authenticate() do ApiClient.
///
/// ## Funcionamento:
/// - **Trial mode**: Funciona normalmente sem certificado
/// - **Production mode SEM urlServidor**: Lança CertificateException
/// - **Production mode COM urlServidor**: ApiClient usa _authenticateViaCloudFunction()
///
/// Esta implementação usa `package:http` ao invés de `dart:io` pois
/// navegadores não suportam SecurityContext e HttpClient nativos.
class HttpClientAdapter {
  bool _isConfigured = false;

  /// Configura mTLS com certificado a partir de bytes
  ///
  /// Em Web, este método apenas marca o adapter como configurado.
  /// O certificado será enviado para Cloud Function via body da requisição.
  ///
  /// [certBytes] Bytes do certificado P12/PFX (não usado em Web)
  /// [certPassword] Senha do certificado (não usada em Web)
  Future<void> configureMtlsFromBytes(Uint8List certBytes, String certPassword) async {
    _isConfigured = true;
  }

  /// Configura mTLS com certificado se fornecido
  ///
  /// Em Web:
  /// - Trial mode: OK, sem certificado necessário
  /// - Production mode: Lança erro se urlServidor não for usado
  ///
  /// [certPath] Caminho para o arquivo de certificado (não usado em Web)
  /// [certPassword] Senha do certificado (não usada em Web)
  /// [isProduction] Se está em ambiente de produção
  Future<void> configureMtls(String? certPath, String? certPassword, bool isProduction) async {
    if (!isProduction) {
      // Trial mode - sem certificado necessário
      _isConfigured = true;
      return;
    }

    // Production mode na Web SEM urlServidor = erro
    throw CertificateException(
      'mTLS não é suportado nativamente em navegadores Web.\n'
      'Configure o parâmetro urlServidor no método authenticate() '
      'para usar proxy via Firebase Cloud Functions ou servidor próprio.',
      reason: CertificateErrorReason.platformNotSupported,
    );
  }

  /// Configura mTLS com certificado via Base64 ou arquivo
  ///
  /// Em Web:
  /// - Trial mode: OK, sem certificado necessário
  /// - Production mode: Lança erro se urlServidor não for usado
  ///
  /// [certBase64] Certificado P12/PFX em Base64 (não usado em Web)
  /// [certPath] Caminho para o arquivo de certificado (não usado em Web)
  /// [certPassword] Senha do certificado (não usada em Web)
  /// [isProduction] Se está em ambiente de produção
  Future<void> configureMtlsUnified({String? certBase64, String? certPath, String? certPassword, required bool isProduction}) async {
    if (!isProduction) {
      // Trial mode - sem certificado necessário
      _isConfigured = true;
      return;
    }

    // Production mode na Web SEM urlServidor = erro
    throw CertificateException(
      'mTLS não é suportado nativamente em navegadores Web.\n\n'
      'Para usar a API em produção na Web, configure o parâmetro urlServidor:\n\n'
      'await apiClient.authenticate(\n'
      '  consumerKey: "key",\n'
      '  consumerSecret: "secret",\n'
      '  ambiente: "producao",\n'
      '  urlServidor: "https://servidor.com.br",\n'
      '  certificadoDigitalBase64: certBase64,\n'
      '  senhaCertificado: senha,\n'
      ');\n\n'
      'Veja a documentação para mais informações sobre deploy do servidor mTLS.',
      reason: CertificateErrorReason.platformNotSupported,
    );
  }

  /// Executa uma requisição POST
  ///
  /// Usa `package:http` ao invés de `dart:io.HttpClient`.
  ///
  /// [uri] URL completa do endpoint
  /// [headers] Headers HTTP da requisição
  /// [body] Corpo da requisição (String)
  ///
  /// Retorna o corpo da resposta parseado como JSON
  /// Lança exceções específicas em caso de erro
  Future<Map<String, dynamic>> post(Uri uri, Map<String, String> headers, String body) async {
    if (!_isConfigured) {
      throw StateError('HttpClient não configurado. Chame configureMtls, configureMtlsFromBytes ou configureMtlsUnified primeiro.');
    }

    try {
      // Fazer requisição POST usando package:http
      final response = await http.post(uri, headers: headers, body: body);

      // Verificar status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final responseBody = utf8.decode(response.bodyBytes);

        // Tentar parsear JSON de erro
        Map<String, dynamic>? errorData;
        try {
          errorData = jsonDecode(responseBody) as Map<String, dynamic>;
        } catch (_) {
          // Não é JSON, usar body como string
        }

        throw AuthenticationFailedException(
          'Requisição falhou',
          statusCode: errorData?['status'] ?? response.statusCode,
          responseBody: errorData?['message'] ?? responseBody,
        );
      }

      // Parsear JSON
      try {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } catch (e) {
        throw AuthenticationFailedException(
          'Resposta não é um JSON válido: $e',
          statusCode: response.statusCode,
          responseBody: utf8.decode(response.bodyBytes),
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw NetworkAuthException('Erro ao fazer requisição: $e', originalError: e);
    }
  }

  /// Libera recursos alocados (no-op em Web)
  void dispose() {
    _isConfigured = false;
  }

  /// Retorna false - Web nunca tem mTLS nativo
  ///
  /// mTLS é feito via Cloud Function/servidor proxy
  bool get isMtlsEnabled => false;
}
