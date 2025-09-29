import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Classe auxiliar para testes com dados mockados
class TestHelper {
  /// Cria um cliente API mockado para testes
  static ApiClient createMockApiClient() {
    return ApiClient();
  }

  /// Dados de teste válidos
  static const String validCnpj = '11222333000181';
  static const String validCpf = '11144477735';
  static const String validConsumerKey = 'test_consumer_key';
  static const String validConsumerSecret = 'test_consumer_secret';
  static const String validCertPath = 'test_cert.p12';
  static const String validCertPassword = 'test_password';

  /// Cria dados de autenticação válidos para testes
  static Map<String, String> createValidAuthData() {
    return {
      'consumerKey': validConsumerKey,
      'consumerSecret': validConsumerSecret,
      'certPath': validCertPath,
      'certPassword': validCertPassword,
      'contratanteNumero': validCnpj,
      'autorPedidoDadosNumero': validCnpj,
    };
  }

  /// Valida se uma resposta contém dados válidos
  static bool isValidResponse(dynamic response) {
    return response != null;
  }

  /// Valida se uma mensagem de erro é válida
  static bool isValidErrorMessage(dynamic error) {
    return error != null && error.toString().isNotEmpty;
  }
}
