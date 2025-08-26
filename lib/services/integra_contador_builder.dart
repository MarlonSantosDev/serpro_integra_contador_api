import 'package:http/http.dart' as http;

import 'integra_contador_service.dart';
import 'integra_contador_extended_service.dart';

/// Builder para facilitar a criação dos serviços da API Integra Contador
class IntegraContadorBuilder {
  String? _jwtToken;
  String? _procuradorToken;
  ApiConfig? _config;
  http.Client? _httpClient;

  /// Define o token JWT
  IntegraContadorBuilder withJwtToken(String token) {
    _jwtToken = token;
    return this;
  }

  /// Define o token de procurador
  IntegraContadorBuilder withProcuradorToken(String token) {
    _procuradorToken = token;
    return this;
  }

  /// Define a configuração da API
  IntegraContadorBuilder withConfig(ApiConfig config) {
    _config = config;
    return this;
  }

  /// Define o cliente HTTP customizado
  IntegraContadorBuilder withHttpClient(http.Client client) {
    _httpClient = client;
    return this;
  }

  /// Define timeout personalizado
  IntegraContadorBuilder withTimeout(Duration timeout) {
    _config = (_config ?? const ApiConfig()).copyWith(timeout: timeout);
    return this;
  }

  /// Define número máximo de tentativas
  IntegraContadorBuilder withMaxRetries(int maxRetries) {
    _config = (_config ?? const ApiConfig()).copyWith(maxRetries: maxRetries);
    return this;
  }

  /// Define URL base personalizada
  IntegraContadorBuilder withBaseUrl(String baseUrl) {
    _config = (_config ?? const ApiConfig()).copyWith(baseUrl: baseUrl);
    return this;
  }

  /// Define headers customizados
  IntegraContadorBuilder withCustomHeaders(Map<String, String> headers) {
    _config = (_config ?? const ApiConfig()).copyWith(customHeaders: headers);
    return this;
  }

  /// Constrói o serviço base
  IntegraContadorService buildBaseService() {
    if (_jwtToken == null || _jwtToken!.isEmpty) {
      throw ArgumentError('JWT Token é obrigatório');
    }

    return IntegraContadorService(
      jwtToken: _jwtToken!,
      procuradorToken: _procuradorToken,
      config: _config,
      httpClient: _httpClient,
    );
  }

  /// Constrói o serviço estendido com todas as 84 funcionalidades
  IntegraContadorExtendedService buildExtendedService() {
    final baseService = buildBaseService();
    return IntegraContadorExtendedService(baseService);
  }

  /// Constrói o serviço estendido (alias para buildExtendedService)
  IntegraContadorExtendedService build() {
    return buildExtendedService();
  }
}

/// Factory para criar instâncias dos serviços
class IntegraContadorFactory {
  /// Cria um serviço base com configuração mínima
  static IntegraContadorService createBaseService({
    required String jwtToken,
    String? procuradorToken,
    Duration? timeout,
  }) {
    return IntegraContadorBuilder()
        .withJwtToken(jwtToken)
        .withProcuradorToken(procuradorToken ?? '')
        .withTimeout(timeout ?? const Duration(seconds: 30))
        .buildBaseService();
  }

  /// Cria um serviço estendido com configuração mínima
  static IntegraContadorExtendedService createExtendedService({
    required String jwtToken,
    String? procuradorToken,
    Duration? timeout,
  }) {
    return IntegraContadorBuilder()
        .withJwtToken(jwtToken)
        .withProcuradorToken(procuradorToken ?? '')
        .withTimeout(timeout ?? const Duration(seconds: 30))
        .buildExtendedService();
  }

  /// Cria um serviço para ambiente de desenvolvimento
  static IntegraContadorExtendedService createDevelopmentService({
    required String jwtToken,
    String? procuradorToken,
  }) {
    return IntegraContadorBuilder()
        .withJwtToken(jwtToken)
        .withProcuradorToken(procuradorToken ?? '')
        .withTimeout(const Duration(seconds: 60))
        .withMaxRetries(5)
        .withCustomHeaders({
          'X-Environment': 'development',
          'X-Debug': 'true',
        })
        .buildExtendedService();
  }

  /// Cria um serviço para ambiente de produção
  static IntegraContadorExtendedService createProductionService({
    required String jwtToken,
    String? procuradorToken,
  }) {
    return IntegraContadorBuilder()
        .withJwtToken(jwtToken)
        .withProcuradorToken(procuradorToken ?? '')
        .withTimeout(const Duration(seconds: 30))
        .withMaxRetries(3)
        .withCustomHeaders({
          'X-Environment': 'production',
        })
        .buildExtendedService();
  }

  /// Cria um serviço para testes
  static IntegraContadorExtendedService createTestService({
    required String jwtToken,
    http.Client? mockClient,
  }) {
    return IntegraContadorBuilder()
        .withJwtToken(jwtToken)
        .withTimeout(const Duration(seconds: 10))
        .withMaxRetries(1)
        .withHttpClient(mockClient ?? http.Client())
        .withCustomHeaders({
          'X-Environment': 'test',
        })
        .buildExtendedService();
  }
}

