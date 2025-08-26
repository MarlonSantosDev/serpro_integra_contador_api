import 'package:json_annotation/json_annotation.dart';

part 'problem_details.g.dart';

/// Modelo para detalhes de problemas/erros da API (RFC 7807)
@JsonSerializable()
class ProblemDetails {
  /// URI que identifica o tipo do problema
  final String? type;
  
  /// Título resumido do problema
  final String? title;
  
  /// Código de status HTTP
  final int? status;
  
  /// Explicação detalhada do problema
  final String? detail;
  
  /// URI que identifica a instância específica do problema
  final String? instance;
  
  /// Campos adicionais específicos do problema
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic>? extensions;

  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.extensions,
  });

  /// Cria uma instância a partir de JSON
  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    final problemDetails = _$ProblemDetailsFromJson(json);
    
    // Captura campos adicionais não mapeados
    final extensions = <String, dynamic>{};
    const knownFields = {'type', 'title', 'status', 'detail', 'instance'};
    
    for (final entry in json.entries) {
      if (!knownFields.contains(entry.key)) {
        extensions[entry.key] = entry.value;
      }
    }
    
    return ProblemDetails(
      type: problemDetails.type,
      title: problemDetails.title,
      status: problemDetails.status,
      detail: problemDetails.detail,
      instance: problemDetails.instance,
      extensions: extensions.isNotEmpty ? extensions : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    final json = _$ProblemDetailsToJson(this);
    
    // Adiciona campos de extensão
    if (extensions != null) {
      json.addAll(extensions!);
    }
    
    return json;
  }

  /// Cria um problema de validação
  factory ProblemDetails.validation({
    required String detail,
    String? instance,
    Map<String, dynamic>? extensions,
  }) {
    return ProblemDetails(
      type: 'https://tools.ietf.org/html/rfc7231#section-6.5.1',
      title: 'Erro de Validação',
      status: 400,
      detail: detail,
      instance: instance,
      extensions: extensions,
    );
  }

  /// Cria um problema de autenticação
  factory ProblemDetails.authentication({
    String? detail,
    String? instance,
  }) {
    return ProblemDetails(
      type: 'https://tools.ietf.org/html/rfc7235#section-3.1',
      title: 'Erro de Autenticação',
      status: 401,
      detail: detail ?? 'Token de autenticação inválido ou expirado',
      instance: instance,
    );
  }

  /// Cria um problema de autorização
  factory ProblemDetails.authorization({
    String? detail,
    String? instance,
  }) {
    return ProblemDetails(
      type: 'https://tools.ietf.org/html/rfc7231#section-6.5.3',
      title: 'Erro de Autorização',
      status: 403,
      detail: detail ?? 'Acesso negado para esta operação',
      instance: instance,
    );
  }

  /// Cria um problema de recurso não encontrado
  factory ProblemDetails.notFound({
    String? detail,
    String? instance,
  }) {
    return ProblemDetails(
      type: 'https://tools.ietf.org/html/rfc7231#section-6.5.4',
      title: 'Recurso Não Encontrado',
      status: 404,
      detail: detail ?? 'O recurso solicitado não foi encontrado',
      instance: instance,
    );
  }

  /// Cria um problema de erro interno do servidor
  factory ProblemDetails.internalServerError({
    String? detail,
    String? instance,
  }) {
    return ProblemDetails(
      type: 'https://tools.ietf.org/html/rfc7231#section-6.6.1',
      title: 'Erro Interno do Servidor',
      status: 500,
      detail: detail ?? 'Ocorreu um erro interno no servidor',
      instance: instance,
    );
  }

  /// Cria um problema de erro de cliente
  factory ProblemDetails.clientError({
    required String detail,
    String? instance,
  }) {
    return ProblemDetails(
      type: 'client_error',
      title: 'Erro de Cliente',
      status: 0,
      detail: detail,
      instance: instance,
    );
  }

  /// Verifica se é um erro de validação
  bool get isValidationError => status == 400;

  /// Verifica se é um erro de autenticação
  bool get isAuthenticationError => status == 401;

  /// Verifica se é um erro de autorização
  bool get isAuthorizationError => status == 403;

  /// Verifica se é um erro de recurso não encontrado
  bool get isNotFoundError => status == 404;

  /// Verifica se é um erro interno do servidor
  bool get isServerError => status != null && status! >= 500;

  /// Verifica se é um erro de cliente
  bool get isClientError => status != null && status! >= 400 && status! < 500;

  /// Obtém uma mensagem de erro amigável
  String get friendlyMessage {
    switch (status) {
      case 400:
        return 'Os dados enviados são inválidos. Verifique as informações e tente novamente.';
      case 401:
        return 'Sua sessão expirou. Faça login novamente.';
      case 403:
        return 'Você não tem permissão para realizar esta operação.';
      case 404:
        return 'O recurso solicitado não foi encontrado.';
      case 429:
        return 'Muitas requisições. Aguarde um momento e tente novamente.';
      case 500:
        return 'Erro interno do servidor. Tente novamente mais tarde.';
      case 502:
        return 'Serviço temporariamente indisponível. Tente novamente mais tarde.';
      case 503:
        return 'Serviço em manutenção. Tente novamente mais tarde.';
      default:
        return detail ?? title ?? 'Ocorreu um erro inesperado.';
    }
  }

  /// Obtém sugestão de ação para o usuário
  String? get actionSuggestion {
    switch (status) {
      case 400:
        return 'Verifique os dados enviados e corrija os erros indicados.';
      case 401:
        return 'Faça login novamente para continuar.';
      case 403:
        return 'Entre em contato com o administrador se precisar de acesso.';
      case 429:
        return 'Aguarde alguns minutos antes de tentar novamente.';
      case 500:
      case 502:
      case 503:
        return 'Se o problema persistir, entre em contato com o suporte.';
      default:
        return null;
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('ProblemDetails(');
    buffer.write('status: $status');
    if (title != null) buffer.write(', title: $title');
    if (detail != null) buffer.write(', detail: $detail');
    buffer.write(')');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProblemDetails &&
        other.type == type &&
        other.title == title &&
        other.status == status &&
        other.detail == detail &&
        other.instance == instance;
  }

  @override
  int get hashCode {
    return Object.hash(type, title, status, detail, instance);
  }
}

