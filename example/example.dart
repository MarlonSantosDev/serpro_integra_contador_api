/// Example demonstrating how to use the serpro_integra_contador_api package.
///
/// This example shows basic usage of the API client and some of the available services.
///
/// ## Exemplos Disponíveis
///
/// Este pacote fornece dois exemplos completos:
///
/// ### 1. Exemplo Dart Puro
/// **Localização**: [example/dart](example/dart)
///
/// Exemplo em Dart puro que demonstra o uso de todos os serviços disponíveis.
/// Ideal para aplicações CLI, scripts e integrações backend.
///
/// **Como executar:**
/// ```bash
/// cd example/dart
/// dart run main.dart
/// ```
///
/// **Características:**
/// - Exemplos de todos os 23 serviços disponíveis
/// - Arquivos separados por serviço em `src/`
/// - Testes e exemplos adicionais em `my_test/`
/// - Suporte completo para autenticação com certificados
///
/// ### 2. Exemplo Flutter
/// **Localização**: [example/flutter](example/flutter)
///
/// Aplicação Flutter completa com interface gráfica para testar todos os serviços.
/// Ideal para desenvolvimento mobile, web e desktop.
///
/// **Como executar:**
/// ```bash
/// cd example/flutter
/// flutter run
/// ```
///
/// **Características:**
/// - Interface gráfica intuitiva
/// - Suporte para todos os 23 serviços
/// - Configuração de autenticação (Trial e Produção)
/// - Campos de entrada dinâmicos por serviço
/// - Exibição formatada de resultados
/// - Suporte multiplataforma (Web, Android, iOS, Desktop)
///
/// Para mais detalhes, consulte:
/// - [README do exemplo Dart](example/dart/README.md)
/// - [README do exemplo Flutter](example/flutter/README.md)
library example;

import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Main entry point for the example.
void main() async {
  // Initialize the API client
  final apiClient = ApiClient();

  // Authenticate with certificates
  await apiClient.authenticate(
    consumerKey: 'your_consumer_key',
    consumerSecret: 'your_consumer_secret',
    certificadoDigitalPath: 'path/to/certificate.pfx',
    senhaCertificado: 'certificate_password',
    contratanteNumero: '12345678000100',
    autorPedidoDadosNumero: '12345678000100',
  );

  // Example: Use CCMEI service
  final ccmeiService = CcmeiService(apiClient);
  try {
    await ccmeiService.emitirCcmei('12345678000100');
    print('CCMEI emitted successfully');
  } catch (e) {
    print('Error: $e');
  }

  // Example: Use PGMEI service
  final pgmeiService = PgmeiService(apiClient);
  try {
    await pgmeiService.gerarDas(cnpj: '12345678000100', periodoApuracao: '202401');
    print('DAS generated successfully');
  } catch (e) {
    print('Error: $e');
  }
}
