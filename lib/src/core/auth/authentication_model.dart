import 'dart:convert';
import '../../util/validacoes_utils.dart';

/// Modelo de dados de autenticação OAuth2 da API SERPRO Integra Contador
class AuthenticationModel {
  /// Token de acesso OAuth2 (Bearer token)
  final String accessToken;

  /// Token JWT adicional exigido pela API SERPRO
  final String jwtToken;

  /// Tempo de expiração do token em segundos
  final int expiresIn;

  /// Momento em que o token foi criado
  final DateTime tokenCreatedAt;

  /// Tipo do token (geralmente 'Bearer')
  final String tokenType;

  /// Escopo do token
  final String scope;

  /// Dados do contratante (empresa que contratou o serviço na Loja Serpro)
  final String contratanteNumero;

  /// Tipo do documento do contratante (1 = CPF, 2 = CNPJ).
  final int contratanteTipo;

  /// Dados do autor do pedido (quem está fazendo a requisição)
  final String autorPedidoDadosNumero;

  /// Tipo do documento do autor (1 = CPF, 2 = CNPJ).
  final int autorPedidoDadosTipo;

  /// Indica se a autenticação foi recuperada do cache
  final bool fromCache;

  /// Token do procurador, quando aplicável.
  final String procuradorToken;

  /// Constrói o modelo com tokens e dados do contratante/autor.
  AuthenticationModel({
    required this.accessToken,
    required this.jwtToken,
    required this.expiresIn,
    required this.contratanteNumero,
    required this.autorPedidoDadosNumero,
    DateTime? tokenCreatedAt,
    this.tokenType = 'Bearer',
    this.scope = '',
    this.fromCache = false,
    this.procuradorToken = '',
  }) : tokenCreatedAt = tokenCreatedAt ?? DateTime.now(),
       contratanteTipo = ValidacoesUtils.detectDocumentType(contratanteNumero),
       autorPedidoDadosTipo = ValidacoesUtils.detectDocumentType(
         autorPedidoDadosNumero,
       );

  /// Verifica se o token está expirado
  bool get isExpired {
    final expirationTime = tokenCreatedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expirationTime);
  }

  /// Verifica se o token deve ser renovado em breve (< 5 minutos)
  bool get shouldRefresh {
    final expirationTime = tokenCreatedAt.add(Duration(seconds: expiresIn));
    final timeRemaining = expirationTime.difference(DateTime.now());
    return timeRemaining.inMinutes < 5;
  }

  /// Retorna o tempo até a expiração do token
  Duration get timeUntilExpiration {
    final expirationTime = tokenCreatedAt.add(Duration(seconds: expiresIn));
    final remaining = expirationTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Retorna o momento exato de expiração do token
  DateTime get expirationTime {
    return tokenCreatedAt.add(Duration(seconds: expiresIn));
  }

  /// Cria uma instância a partir de JSON
  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      accessToken: json['access_token'] as String,
      jwtToken: json['jwt_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      scope: json['scope'] as String? ?? '',
      contratanteNumero: json['contratante_numero'] as String,
      autorPedidoDadosNumero: json['autor_pedido_dados_numero'] as String,
      tokenCreatedAt: json['token_created_at'] != null
          ? DateTime.parse(json['token_created_at'] as String)
          : DateTime.now(),
      procuradorToken: json['procurador_token'] as String? ?? '',
      fromCache:
          json['from_cache'] as bool? ??
          true, // Se veio do JSON, provavelmente é do cache
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'jwt_token': jwtToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
      'scope': scope,
      'token_created_at': tokenCreatedAt.toIso8601String(),
      'contratante_numero': contratanteNumero,
      'contratante_tipo': contratanteTipo,
      'autor_pedido_dados_numero': autorPedidoDadosNumero,
      'autor_pedido_dados_tipo': autorPedidoDadosTipo,
      'procurador_token': procuradorToken,
      'from_cache': fromCache,
    };
  }

  /// Retorna informações detalhadas da autenticação em formato JSON formatado
  ///
  /// Ideal para debug e visualização rápida de todos os dados de autenticação.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// print(authModel.info);
  /// ```
  String get info {
    return JsonEncoder.withIndent('  ').convert({
      'access_token': accessToken.length > 50
          ? '${accessToken.substring(0, 50)}...'
          : accessToken,
      'jwt_token': jwtToken.length > 50
          ? '${jwtToken.substring(0, 50)}...'
          : jwtToken,
      'token_type': tokenType,
      'scope': scope,
      'expira_em': expiresIn,
      'expira_em_formato': '${(expiresIn / 60).toStringAsFixed(1)} minutos',
      'token_criado_em': tokenCreatedAt.toIso8601String(),
      'expiração_hora': expirationTime.toIso8601String(),
      'tempo_ate_expiracao': '${timeUntilExpiration.inMinutes} minutos',
      'está_expirado': isExpired,
      'deveria_atualizar': shouldRefresh,
      'origem': fromCache ? 'cache' : 'nova autenticação',
      'contratante': {
        'numero': contratanteNumero,
        'tipo': contratanteTipo == 1 ? 'CPF' : 'CNPJ',
      },
      'autorPedidoDados': {
        'numero': autorPedidoDadosNumero,
        'tipo': autorPedidoDadosTipo == 1 ? 'CPF' : 'CNPJ',
      },
      'procurador_token': procuradorToken,
    });
  }

  @override
  String toString() {
    return 'AuthenticationModel('
        'tokenType: $tokenType, '
        'expiresIn: ${timeUntilExpiration.inMinutes}min, '
        'isExpired: $isExpired, '
        'shouldRefresh: $shouldRefresh'
        ')';
  }
}
