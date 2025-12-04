/// Exceções relacionadas à autenticação na API SERPRO Integra Contador
library;

/// Exceção base para todos os erros de autenticação
abstract class AuthException implements Exception {
  final String message;
  final dynamic originalError;

  AuthException(this.message, {this.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// Lançada quando a requisição de autenticação falha
class AuthenticationFailedException extends AuthException {
  final int statusCode;
  final String? responseBody;

  AuthenticationFailedException(
    super.message, {
    required this.statusCode,
    this.responseBody,
    super.originalError,
  });

  @override
  String toString() =>
      'AuthenticationFailedException: $message (Status: $statusCode)';
}

/// Razões específicas para falhas de certificado
enum CertificateErrorReason {
  /// Arquivo de certificado não encontrado
  notFound,

  /// Senha do certificado inválida
  invalidPassword,

  /// Certificado expirado
  expired,

  /// Formato de certificado inválido
  invalidFormat,

  /// Certificado obrigatório em produção mas não fornecido
  requiredForProduction,
}

/// Lançada quando há problemas com o certificado digital
class CertificateException extends AuthException {
  final String? certificatePath;
  final CertificateErrorReason reason;

  CertificateException(
    super.message, {
    this.certificatePath,
    required this.reason,
  });

  @override
  String toString() {
    final path = certificatePath != null ? ' (Path: $certificatePath)' : '';
    return 'CertificateException: $message$path [Reason: ${reason.name}]';
  }
}

/// Lançada quando o token de autenticação expira
class TokenExpiredException extends AuthException {
  final DateTime expiredAt;

  TokenExpiredException(this.expiredAt)
      : super('Token expirado em ${expiredAt.toIso8601String()}');

  @override
  String toString() => 'TokenExpiredException: $message';
}

/// Lançada quando a renovação de token falha
class TokenRefreshException extends AuthException {
  TokenRefreshException(super.message, {super.originalError});

  @override
  String toString() => 'TokenRefreshException: $message';
}

/// Lançada quando as credenciais fornecidas são inválidas
class InvalidCredentialsException extends AuthException {
  final String field;

  InvalidCredentialsException(super.message, {required this.field});

  @override
  String toString() => 'InvalidCredentialsException: $message (Campo: $field)';
}

/// Lançada quando ocorrem erros de rede durante a autenticação
class NetworkAuthException extends AuthException {
  NetworkAuthException(super.message, {super.originalError});

  @override
  String toString() => 'NetworkAuthException: $message';
}

/// Lançada quando mTLS não é suportado na plataforma atual
class MtlsNotSupportedException extends AuthException {
  final String platform;

  MtlsNotSupportedException(this.platform)
      : super('mTLS não suportado na plataforma: $platform');

  @override
  String toString() => 'MtlsNotSupportedException: $message';
}
