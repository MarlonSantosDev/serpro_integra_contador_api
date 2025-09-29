import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('Parcelamento Services Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
    });

    group('ParcsnService Tests', () {
      late ParcsnService parcsnService;

      setUp(() {
        parcsnService = ParcsnService(apiClient);
      });

      test('consultarPedidos deve lançar exceção quando cliente não está autenticado', () async {
        // Act & Assert
        expect(() => parcsnService.consultarPedidos(), throwsA(isA<Exception>()));
      });

      test('consultarPedidos deve aceitar chamada válida após autenticação', () async {
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => parcsnService.consultarPedidos(), returnsNormally);
      });
    });

    group('ParcmeiService Tests', () {
      late ParcmeiService parcmeiService;

      setUp(() {
        parcmeiService = ParcmeiService(apiClient);
      });

      test('consultarPedidos deve lançar exceção quando cliente não está autenticado', () async {
        // Act & Assert
        expect(() => parcmeiService.consultarPedidos(), throwsA(isA<Exception>()));
      });

      test('consultarPedidos deve aceitar chamada válida após autenticação', () async {
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => parcmeiService.consultarPedidos(), returnsNormally);
      });
    });

    group('PertsnService Tests', () {
      late PertsnService pertsnService;

      setUp(() {
        pertsnService = PertsnService(apiClient);
      });

      test('consultarPedidos deve lançar exceção quando cliente não está autenticado', () async {
        // Act & Assert
        expect(() => pertsnService.consultarPedidos(), throwsA(isA<Exception>()));
      });

      test('consultarPedidos deve aceitar chamada válida após autenticação', () async {
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => pertsnService.consultarPedidos(), returnsNormally);
      });
    });

    group('PertmeiService Tests', () {
      late PertmeiService pertmeiService;

      setUp(() {
        pertmeiService = PertmeiService(apiClient);
      });

      test('consultarPedidos deve retornar resposta quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;

        // Act & Assert
        expect(() => pertmeiService.consultarPedidos(contribuinteNumero), returnsNormally);
      });

      test('consultarPedidos deve aceitar CNPJ válido após autenticação', () async {
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

        // Act & Assert
        expect(() => pertmeiService.consultarPedidos(contribuinteNumero), returnsNormally);
      });
    });

    group('RelpsnService Tests', () {
      late RelpsnService relpsnService;

      setUp(() {
        relpsnService = RelpsnService(apiClient);
      });

      test('consultarPedidos deve lançar exceção quando cliente não está autenticado', () async {
        // Act & Assert
        expect(() => relpsnService.consultarPedidos(), throwsA(isA<Exception>()));
      });

      test('consultarPedidos deve aceitar chamada válida após autenticação', () async {
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => relpsnService.consultarPedidos(), returnsNormally);
      });
    });

    group('Validações básicas', () {
      test('deve validar CNPJ', () {
        const cnpjValido = TestHelper.validCnpj;
        const cnpjInvalido = '123';
        expect(() => ValidationUtils.validateCNPJ(cnpjValido), returnsNormally);
        expect(() => ValidationUtils.validateCNPJ(cnpjInvalido), throwsA(isA<ArgumentError>()));
      });

      test('deve validar período de apuração', () {
        const periodoValido = '202401';
        const periodoInvalido = '202413';
        expect(() => ValidationUtils.validatePeriodo(periodoValido), returnsNormally);
        expect(() => ValidationUtils.validatePeriodo(periodoInvalido), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
