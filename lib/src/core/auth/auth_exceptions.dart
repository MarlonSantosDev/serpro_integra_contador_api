/// Exceções relacionadas à autenticação na API SERPRO Integra Contador
library;

/// Exceção base para todos os erros de autenticação
abstract class AuthException implements Exception {
  /// Mensagem de erro descritiva.
  final String message;

  /// Erro original que originou esta exceção, se houver.
  final dynamic originalError;

  /// Cria uma exceção de autenticação com [message] e opcional [originalError].
  AuthException(this.message, {this.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// Lançada quando a requisição de autenticação falha
class AuthenticationFailedException extends AuthException {
  /// Código HTTP retornado pela API.
  final int statusCode;

  /// Corpo da resposta HTTP, se disponível.
  final String? responseBody;

  /// Cria exceção com [message], [statusCode] e opcional [responseBody].
  AuthenticationFailedException(super.message, {required this.statusCode, this.responseBody, super.originalError});

  @override
  String toString() => 'AuthenticationFailedException: $message (Status: $statusCode)';
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

  /// Plataforma não suporta mTLS nativamente (ex: Web)
  platformNotSupported,
}

/// Lançada quando há problemas com o certificado digital
class CertificateException extends AuthException {
  /// Caminho do arquivo de certificado, quando aplicável.
  final String? certificatePath;

  /// Motivo específico do erro de certificado.
  final CertificateErrorReason reason;

  /// Cria exceção com [message], [reason] e opcional [certificatePath].
  CertificateException(super.message, {this.certificatePath, required this.reason});

  @override
  String toString() {
    final path = certificatePath != null ? ' (Path: $certificatePath)' : '';
    return 'CertificateException: $message$path [Reason: ${reason.name}]';
  }
}

/// Lançada quando o token de autenticação expira
class TokenExpiredException extends AuthException {
  /// Data/hora em que o token expirou.
  final DateTime expiredAt;

  /// Cria exceção indicando expiração em [expiredAt].
  TokenExpiredException(this.expiredAt) : super('Token expirado em ${expiredAt.toIso8601String()}');

  @override
  String toString() => 'TokenExpiredException: $message';
}

/// Lançada quando a renovação de token falha
class TokenRefreshException extends AuthException {
  /// Cria exceção com [message] e opcional [originalError].
  TokenRefreshException(super.message, {super.originalError});

  @override
  String toString() => 'TokenRefreshException: $message';
}

/// Lançada quando as credenciais fornecidas são inválidas
class InvalidCredentialsException extends AuthException {
  /// Nome do campo que falhou na validação.
  final String field;

  /// Cria exceção com [message] e [field] inválido.
  InvalidCredentialsException(super.message, {required this.field});

  @override
  String toString() => 'InvalidCredentialsException: $message (Campo: $field)';
}

/// Lançada quando ocorrem erros de rede durante a autenticação
class NetworkAuthException extends AuthException {
  /// Cria exceção com [message] e opcional [originalError].
  NetworkAuthException(super.message, {super.originalError});

  @override
  String toString() => 'NetworkAuthException: $message';
}

/// Lançada quando mTLS não é suportado na plataforma atual
class MtlsNotSupportedException extends AuthException {
  /// Nome da plataforma que não suporta mTLS.
  final String platform;

  /// Cria exceção para a [platform] não suportada.
  MtlsNotSupportedException(this.platform) : super('mTLS não suportado na plataforma: $platform');

  @override
  String toString() => 'MtlsNotSupportedException: $message';
}
