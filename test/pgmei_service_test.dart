import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('PgmeiService Tests', () {
    late PgmeiService pgmeiService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      pgmeiService = PgmeiService(apiClient);
    });

    group('gerarDas', () {
      test('deve lançar exceção quando CNPJ é inválido', () async {
        // Arrange
        const invalidCnpj = '12345678901234';
        const periodoApuracao = '202401';

        // Act & Assert
        expect(() => pgmeiService.gerarDas(invalidCnpj, periodoApuracao), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando período é inválido', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const invalidPeriodo = '202413'; // Mês inválido

        // Act & Assert
        expect(() => pgmeiService.gerarDas(validCnpj, invalidPeriodo), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';

        // Act & Assert
        expect(() => pgmeiService.gerarDas(validCnpj, periodoApuracao), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => pgmeiService.gerarDas(validCnpj, periodoApuracao), returnsNormally);
      });

      test('deve aceitar parâmetros opcionais', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';
        const customContratante = '98765432000100';
        const customAutor = '11122233344';

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(
          () => pgmeiService.gerarDas(validCnpj, periodoApuracao, contratanteNumero: customContratante, autorPedidoDadosNumero: customAutor),
          returnsNormally,
        );
      });
    });

    group('gerarDasCodigoDeBarras', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';

        // Act & Assert
        expect(() => pgmeiService.gerarDasCodigoDeBarras(validCnpj, periodoApuracao), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => pgmeiService.gerarDasCodigoDeBarras(validCnpj, periodoApuracao), returnsNormally);
      });
    });

    group('atualizarBeneficio', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';

        // Act & Assert
        expect(() => pgmeiService.atualizarBeneficio(validCnpj, periodoApuracao), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const periodoApuracao = '202401';

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => pgmeiService.atualizarBeneficio(validCnpj, periodoApuracao), returnsNormally);
      });
    });

    group('consultarDividaAtiva', () {
      test('deve lançar exceção quando CNPJ é inválido', () async {
        // Arrange
        const invalidCnpj = '12345678901234';
        const ano = '2024';

        // Act & Assert
        expect(() => pgmeiService.consultarDividaAtiva(invalidCnpj, ano), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando ano é inválido', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const invalidAno = '20'; // Ano inválido

        // Act & Assert
        expect(() => pgmeiService.consultarDividaAtiva(validCnpj, invalidAno), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const ano = '2024';

        // Act & Assert
        expect(() => pgmeiService.consultarDividaAtiva(validCnpj, ano), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const ano = '2024';

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => pgmeiService.consultarDividaAtiva(validCnpj, ano), returnsNormally);
      });

      test('deve aceitar parâmetros opcionais', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const ano = '2024';
        const customContratante = '98765432000100';
        const customAutor = '11122233344';

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(
          () => pgmeiService.consultarDividaAtiva(validCnpj, ano, contratanteNumero: customContratante, autorPedidoDadosNumero: customAutor),
          returnsNormally,
        );
      });
    });
  });
}
