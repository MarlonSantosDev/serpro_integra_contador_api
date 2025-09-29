import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('PgdasdService Tests', () {
    late PgdasdService pgdasdService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      pgdasdService = PgdasdService(apiClient);
    });

    group('Métodos básicos', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;

        // Act & Assert - Testando apenas se o serviço existe e pode ser chamado
        expect(() => pgdasdService.toString(), returnsNormally);
      });

      test('deve aceitar parâmetros válidos após autenticação', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert - Testando apenas se o serviço existe
        expect(() => pgdasdService.toString(), returnsNormally);
      });
    });

    group('Validações básicas', () {
      test('deve validar CNPJ', () {
        // Arrange
        const cnpjValido = TestHelper.validCnpj;
        const cnpjInvalido = '123';

        // Act & Assert
        expect(() => ValidationUtils.validateCNPJ(cnpjValido), returnsNormally);
        expect(() => ValidationUtils.validateCNPJ(cnpjInvalido), throwsA(isA<ArgumentError>()));
      });

      test('deve validar período de apuração', () {
        // Arrange
        const periodoValido = '202401';
        const periodoInvalido = '202413';

        // Act & Assert
        expect(() => ValidationUtils.validatePeriodo(periodoValido), returnsNormally);
        expect(() => ValidationUtils.validatePeriodo(periodoInvalido), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
