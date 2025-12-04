import 'authentication_model.dart';

/// Cache inteligente para tokens de autenticação principal
///
/// Gerencia o ciclo de vida dos tokens OAuth2, incluindo
/// validação de expiração e detecção de necessidade de renovação.
class AuthTokenCache {
  AuthenticationModel? _currentToken;

  /// Salva um token no cache
  void saveToken(AuthenticationModel token) {
    _currentToken = token;
  }

  /// Obtém o token atual do cache se ainda for válido
  ///
  /// Retorna null se não houver token ou se estiver expirado
  AuthenticationModel? getToken() {
    if (_currentToken == null) return null;
    if (_currentToken!.isExpired) {
      invalidate();
      return null;
    }
    return _currentToken;
  }

  /// Verifica se há um token válido em cache
  bool isTokenValid() {
    if (_currentToken == null) return false;
    return !_currentToken!.isExpired;
  }

  /// Verifica se o token deve ser renovado em breve
  ///
  /// Retorna true se não houver token ou se estiver próximo da expiração
  bool shouldRefresh() {
    if (_currentToken == null) return true;
    return _currentToken!.shouldRefresh;
  }

  /// Retorna o tempo até a expiração do token
  Duration timeUntilExpiration() {
    if (_currentToken == null) return Duration.zero;
    return _currentToken!.timeUntilExpiration;
  }

  /// Invalida o cache, removendo o token atual
  void invalidate() {
    _currentToken = null;
  }

  /// Retorna estatísticas sobre o cache
  ///
  /// Útil para debugging e monitoramento
  Map<String, dynamic> get stats {
    if (_currentToken == null) {
      return {'has_token': false};
    }

    return {
      'has_token': true,
      'is_valid': isTokenValid(),
      'should_refresh': shouldRefresh(),
      'expires_in_seconds': timeUntilExpiration().inSeconds,
      'expires_in_minutes': timeUntilExpiration().inMinutes,
      'token_type': _currentToken!.tokenType,
      'created_at': _currentToken!.tokenCreatedAt.toIso8601String(),
      'expires_at': _currentToken!.expirationTime.toIso8601String(),
    };
  }

  /// Verifica se o cache tem um token (mesmo que expirado)
  bool get hasToken => _currentToken != null;

  /// Retorna o token atual (mesmo que expirado) para inspeção
  ///
  /// Use [getToken] para obter apenas tokens válidos
  AuthenticationModel? get currentToken => _currentToken;
}
