import '../models/problem_details.dart';

/// Exceção base para erros da API Integra Contador
abstract class IntegraContadorException implements Exception {
  /// Mensagem do erro
  final String message;
  
  /// Código do erro (opcional)
  final String? code;
  
  /// Detalhes adicionais do erro
  final Map<String, dynamic>? details;

  const IntegraContadorException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'IntegraContadorException: $message';
}

/// Exceção para erros de validação
class ValidationException extends IntegraContadorException {
  /// Campos com erro de validação
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    super.code,
    super.details,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exceção para erros de autenticação
class AuthenticationException extends IntegraContadorException {
  const AuthenticationException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exceção para erros de autorização
class AuthorizationException extends IntegraContadorException {
  const AuthorizationException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'AuthorizationException: $message';
}

/// Exceção para recursos não encontrados
class NotFoundException extends IntegraContadorException {
  const NotFoundException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exceção para erros de rede/conectividade
class NetworkException extends IntegraContadorException {
  const NetworkException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exceção para erros do servidor
class ServerException extends IntegraContadorException {
  const ServerException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'ServerException: $message';
}

/// Exceção para timeout de requisições
class TimeoutException extends IntegraContadorException {
  const TimeoutException(
    super.message, {
    super.code,
    super.details,
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exceção para limite de taxa excedido
class RateLimitException extends IntegraContadorException {
  /// Tempo em segundos para tentar novamente
  final int? retryAfter;

  const RateLimitException(
    super.message, {
    super.code,
    super.details,
    this.retryAfter,
  });

  @override
  String toString() => 'RateLimitException: $message';
}

/// Factory para criar exceções a partir de ProblemDetails
class ExceptionFactory {
  /// Cria uma exceção apropriada baseada no ProblemDetails
  static IntegraContadorException fromProblemDetails(ProblemDetails problem) {
    final message = problem.detail ?? problem.title ?? 'Erro desconhecido';
    final code = problem.status?.toString();
    final details = problem.extensions;

    switch (problem.status) {
      case 400:
        return ValidationException(
          message,
          code: code,
          details: details,
        );
      case 401:
        return AuthenticationException(
          message,
          code: code,
          details: details,
        );
      case 403:
        return AuthorizationException(
          message,
          code: code,
          details: details,
        );
      case 404:
        return NotFoundException(
          message,
          code: code,
          details: details,
        );
      case 429:
        final retryAfter = details?['retry_after'] as int?;
        return RateLimitException(
          message,
          code: code,
          details: details,
          retryAfter: retryAfter,
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          message,
          code: code,
          details: details,
        );
      default:
        return _GenericException(
          message,
          code: code,
          details: details,
        );
    }
  }

  /// Cria uma exceção de rede
  static NetworkException network(String message, {Exception? cause}) {
    return NetworkException(
      message,
      details: cause != null ? {'cause': cause.toString()} : null,
    );
  }

  /// Cria uma exceção de timeout
  static TimeoutException timeout({Duration? duration}) {
    final message = duration != null
        ? 'Timeout após ${duration.inSeconds} segundos'
        : 'Timeout na requisição';
    
    return TimeoutException(
      message,
      details: duration != null ? {'duration_seconds': duration.inSeconds} : null,
    );
  }
}

/// Implementação genérica para casos não mapeados
class _GenericException extends IntegraContadorException {
  const _GenericException(
    super.message, {
    super.code,
    super.details,
  });
}

