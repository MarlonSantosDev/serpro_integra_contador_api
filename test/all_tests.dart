import 'package:test/test.dart';

// Importar todos os arquivos de teste
import 'test_helper.dart';
import 'ccmei_service_test.dart';
import 'pgdasd_service_test.dart';
import 'pgmei_service_test.dart';
import 'dctfweb_service_test.dart';
import 'services_consolidated_test.dart';
import 'parcelamento_services_test.dart';
import 'sicalc_service_test.dart';
import 'eventos_atualizacao_service_test.dart';
import 'autenticaprocurador_service_test.dart';

void main() {
  group('SERPRO Integra Contador API - All Tests', () {
    test('Test Helper deve estar disponível', () {
      expect(TestHelper.validCnpj, isNotEmpty);
      expect(TestHelper.validCpf, isNotEmpty);
      expect(TestHelper.validConsumerKey, isNotEmpty);
      expect(TestHelper.validConsumerSecret, isNotEmpty);
      expect(TestHelper.validCertPath, isNotEmpty);
      expect(TestHelper.validCertPassword, isNotEmpty);
    });

    test('Test Helper deve criar cliente API válido', () {
      final apiClient = TestHelper.createMockApiClient();
      expect(apiClient, isNotNull);
      expect(apiClient.isAuthenticated, isFalse);
    });

    test('Test Helper deve criar dados de autenticação válidos', () {
      final authData = TestHelper.createValidAuthData();
      expect(authData['consumerKey'], equals(TestHelper.validConsumerKey));
      expect(authData['consumerSecret'], equals(TestHelper.validConsumerSecret));
      expect(authData['certPath'], equals(TestHelper.validCertPath));
      expect(authData['certPassword'], equals(TestHelper.validCertPassword));
      expect(authData['contratanteNumero'], equals(TestHelper.validCnpj));
      expect(authData['autorPedidoDadosNumero'], equals(TestHelper.validCnpj));
    });

    test('Test Helper deve validar respostas corretamente', () {
      expect(TestHelper.isValidResponse({'status': 'success'}), isTrue);
      expect(TestHelper.isValidResponse(null), isFalse);
      expect(TestHelper.isValidErrorMessage('Erro de teste'), isTrue);
      expect(TestHelper.isValidErrorMessage(''), isFalse);
    });
  });
}
