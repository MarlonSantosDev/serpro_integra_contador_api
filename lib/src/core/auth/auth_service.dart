import 'dart:convert';
import 'authentication_model.dart';
import 'auth_credentials.dart';
import 'http_client_adapter.dart';
import 'auth_exceptions.dart';

/// Serviço de autenticação OAuth2 para API SERPRO Integra Contador
///
/// Gerencia a autenticação usando OAuth2 client credentials flow
/// conforme especificação da API SERPRO.
class AuthService {
  final HttpClientAdapter _httpAdapter;
  final String _environment;

  /// URL de autenticação para ambiente Trial
  static const String _authUrlTrial =
      'https://autenticacao.sapi.serpro.gov.br/authenticate';

  /// URL de autenticação para ambiente de Produção
  static const String _authUrlProd =
      'https://autenticacao.sapi.serpro.gov.br/authenticate';

  /// Cria o serviço com [HttpClientAdapter] e ambiente (_environment).
  AuthService(this._httpAdapter, this._environment);

  /// Retorna a URL de autenticação apropriada para o ambiente
  String get _authUrl =>
      _environment == 'producao' ? _authUrlProd : _authUrlTrial;

  /// Autentica usando OAuth2 client credentials flow
  ///
  /// [credentials] Credenciais de autenticação validadas
  ///
  /// Retorna [AuthenticationModel] com tokens de acesso
  ///
  /// Lança exceções específicas em caso de erro:
  /// - [AuthenticationFailedException] - Falha na autenticação
  /// - [NetworkAuthException] - Erro de rede
  Future<AuthenticationModel> authenticate(AuthCredentials credentials) async {
    try {
      // Trial (sem certificado)
      if (credentials.ambiente == 'trial') {
        return AuthenticationModel(
          expiresIn: 2008,
          scope: "default",
          tokenType: "Bearer",
          accessToken: "06aef429-a981-3ec5-a1f8-71d38d86481e",
          jwtToken: "06aef429-a981-3ec5-a1f8-71d38d86481e",
          contratanteNumero: credentials.contratanteNumero,
          autorPedidoDadosNumero: credentials.autorPedidoDadosNumero,
          tokenCreatedAt: DateTime.now(),
        );
      }
      // Construir Basic Auth header
      final basicAuth = base64.encode(
        utf8.encode('${credentials.consumerKey}:${credentials.consumerSecret}'),
      );

      // Preparar headers conforme documentação SERPRO
      final headers = {
        'Authorization': 'Basic $basicAuth',
        'role-type': 'TERCEIROS',
        'content-type': 'application/x-www-form-urlencoded',
      };

      // Fazer requisição de autenticação
      final response = await _httpAdapter.post(
        Uri.parse(_authUrl),
        headers,
        'grant_type=client_credentials',
      );

      // Criar modelo de autenticação
      return AuthenticationModel(
        expiresIn: int.parse(response['expires_in'].toString()),
        scope: response['scope'],
        tokenType: response['token_type'],
        accessToken: response['access_token'],
        jwtToken: response['jwt_token'],
        contratanteNumero: credentials.contratanteNumero,
        autorPedidoDadosNumero: credentials.autorPedidoDadosNumero,
        tokenCreatedAt: DateTime.now(),
      );
    } on AuthenticationFailedException catch (e) {
      throw AuthenticationFailedException(
        e.toString(),
        statusCode: e.statusCode,
        responseBody: e.responseBody,
      );
    } catch (e) {
      throw AuthenticationFailedException(
        e.toString(),
        statusCode: 0,
        responseBody: e.toString(),
      );
    }
  }

  /// Verifica se o token deve ser renovado
  ///
  /// SERPRO não fornece endpoint de refresh, então este método
  /// apenas verifica se está próximo da expiração (< 5 minutos)
  bool shouldRefreshToken(AuthenticationModel auth) {
    return auth.shouldRefresh;
  }

  /// Tenta renovar o token
  ///
  /// NOTA: SERPRO não suporta refresh_token.
  /// É necessário re-autenticar completamente usando [authenticate].
  ///
  /// Este método sempre lança [TokenRefreshException].
  Future<AuthenticationModel> refreshToken(
    AuthenticationModel currentAuth,
  ) async {
    throw TokenRefreshException(
      'SERPRO não suporta refresh de token. '
      'Re-autentique usando o método authenticate().',
    );
  }
}
