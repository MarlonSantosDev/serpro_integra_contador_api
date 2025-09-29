/// Modelo para resposta da autenticação de procurador
class TermoAutorizacaoResponse {
  final int status;
  final List<MensagemNegocio> mensagens;
  final String? dados;
  final String? autenticarProcuradorToken;
  final DateTime? dataExpiracao;
  final bool isCacheValido;

  TermoAutorizacaoResponse({
    required this.status,
    required this.mensagens,
    this.dados,
    this.autenticarProcuradorToken,
    this.dataExpiracao,
    this.isCacheValido = false,
  });

  /// Indica se a autenticação foi bem-sucedida
  bool get sucesso => status == 200 || status == 304;

  /// Indica se o token está em cache (status 304)
  bool get isTokenEmCache => status == 304;

  /// Indica se o token expirou
  bool get isTokenExpirado {
    if (dataExpiracao == null) return false;
    return DateTime.now().isAfter(dataExpiracao!);
  }

  /// Indica se deve renovar o token
  bool get deveRenovarToken => isTokenExpirado || !sucesso;

  /// Obtém a mensagem principal da resposta
  String get mensagemPrincipal {
    if (mensagens.isEmpty) return 'Sem mensagens';
    return mensagens.first.texto;
  }

  /// Obtém o código da mensagem principal
  String get codigoMensagem {
    if (mensagens.isEmpty) return 'SEM_CODIGO';
    return mensagens.first.codigo;
  }

  factory TermoAutorizacaoResponse.fromJson(Map<String, dynamic> json) {
    final mensagens = <MensagemNegocio>[];

    if (json['mensagens'] != null) {
      if (json['mensagens'] is List) {
        for (final msg in json['mensagens']) {
          mensagens.add(MensagemNegocio.fromJson(msg));
        }
      } else if (json['mensagens'] is String) {
        // Caso especial quando mensagens vem como string
        mensagens.add(MensagemNegocio(codigo: 'INFO', texto: json['mensagens'].toString()));
      }
    }

    return TermoAutorizacaoResponse(
      status: int.parse(json['status'].toString()),
      mensagens: mensagens,
      dados: json['dados']?.toString(),
      autenticarProcuradorToken: json['autenticar_procurador_token']?.toString(),
      dataExpiracao: json['data_expiracao'] != null ? DateTime.tryParse(json['data_expiracao'].toString()) : null,
    );
  }

  /// Cria resposta a partir de headers HTTP (para cache)
  factory TermoAutorizacaoResponse.fromHeaders(Map<String, String> headers) {
    final status = int.tryParse(headers['status'] ?? '304') ?? 304;
    final etag = headers['etag'] ?? '';
    final expires = headers['expires'];

    String? token;
    DateTime? dataExpiracao;

    // Extrair token do ETag
    if (etag.contains('autenticar_procurador_token:')) {
      final startIndex = etag.indexOf('autenticar_procurador_token:') + 28;
      final endIndex = etag.indexOf('"', startIndex);
      if (endIndex > startIndex) {
        token = etag.substring(startIndex, endIndex);
      }
    }

    // Parsear data de expiração
    if (expires != null) {
      try {
        dataExpiracao = DateTime.parse(expires);
      } catch (e) {
        // Ignorar erro de parsing
      }
    }

    return TermoAutorizacaoResponse(
      status: status,
      mensagens: [MensagemNegocio(codigo: 'CACHE', texto: 'Token em cache válido')],
      autenticarProcuradorToken: token,
      dataExpiracao: dataExpiracao,
      isCacheValido: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((m) => m.toJson()).toList(),
      'dados': dados,
      'autenticar_procurador_token': autenticarProcuradorToken,
      'data_expiracao': dataExpiracao?.toIso8601String(),
      'is_cache_valido': isCacheValido,
    };
  }

  @override
  String toString() {
    return 'TermoAutorizacaoResponse(status: $status, sucesso: $sucesso, '
        'token: ${autenticarProcuradorToken != null ? "presente" : "ausente"}, '
        'expirado: $isTokenExpirado, mensagem: $mensagemPrincipal)';
  }
}

/// Modelo para mensagens de negócio
class MensagemNegocio {
  final String codigo;
  final String texto;

  MensagemNegocio({required this.codigo, required this.texto});

  factory MensagemNegocio.fromJson(Map<String, dynamic> json) {
    return MensagemNegocio(codigo: json['codigo']?.toString() ?? 'UNKNOWN', texto: json['texto']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  @override
  String toString() {
    return 'MensagemNegocio(codigo: $codigo, texto: $texto)';
  }
}

/// Modelo para dados de cache do token
class CacheToken {
  final String token;
  final DateTime dataExpiracao;
  final DateTime dataCriacao;

  CacheToken({required this.token, required this.dataExpiracao, required this.dataCriacao});

  /// Verifica se o token ainda é válido
  bool get isValido => DateTime.now().isBefore(dataExpiracao);

  /// Tempo restante até expiração
  Duration get tempoRestante => dataExpiracao.difference(DateTime.now());

  /// Indica se o token expira em menos de 1 hora
  bool get expiraEmBreve => tempoRestante.inHours < 1;

  factory CacheToken.fromJson(Map<String, dynamic> json) {
    return CacheToken(
      token: json['token'].toString(),
      dataExpiracao: DateTime.parse(json['data_expiracao'].toString()),
      dataCriacao: DateTime.parse(json['data_criacao'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'data_expiracao': dataExpiracao.toIso8601String(), 'data_criacao': dataCriacao.toIso8601String()};
  }

  @override
  String toString() {
    return 'CacheToken(token: ${token.substring(0, 8)}..., '
        'valido: $isValido, expira: $dataExpiracao)';
  }
}
