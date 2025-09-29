import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('CcmeiService Tests', () {
    late CcmeiService ccmeiService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      ccmeiService = CcmeiService(apiClient);
    });

    group('emitirCcmei', () {
      test('deve lançar exceção quando CNPJ é inválido', () async {
        // Arrange
        const invalidCnpj = '12345678901234';

        // Act & Assert
        expect(() => ccmeiService.emitirCcmei(invalidCnpj), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando CNPJ está vazio', () async {
        // Arrange
        const emptyCnpj = '';

        // Act & Assert
        expect(() => ccmeiService.emitirCcmei(emptyCnpj), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;

        // Act & Assert
        expect(() => ccmeiService.emitirCcmei(validCnpj), throwsA(isA<Exception>()));
      });

      test('deve aceitar CNPJ válido', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => ccmeiService.emitirCcmei(validCnpj), returnsNormally);
      });

      test('deve aceitar parâmetros opcionais de contratante e autor', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
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
        expect(() => ccmeiService.emitirCcmei(validCnpj, contratanteNumero: customContratante, autorPedidoDadosNumero: customAutor), returnsNormally);
      });
    });

    group('consultarDadosCcmei', () {
      test('deve lançar exceção quando CNPJ é inválido', () async {
        // Arrange
        const invalidCnpj = '12345678901234';

        // Act & Assert
        expect(() => ccmeiService.consultarDadosCcmei(invalidCnpj), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;

        // Act & Assert
        expect(() => ccmeiService.consultarDadosCcmei(validCnpj), throwsA(isA<Exception>()));
      });

      test('deve aceitar CNPJ válido', () async {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => ccmeiService.consultarDadosCcmei(validCnpj), returnsNormally);
      });
    });

    group('consultarSituacaoCadastral', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const validCpf = TestHelper.validCpf;

        // Act & Assert
        expect(() => ccmeiService.consultarSituacaoCadastral(validCpf), throwsA(isA<Exception>()));
      });

      test('deve aceitar CPF válido', () async {
        // Arrange
        const validCpf = TestHelper.validCpf;
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => ccmeiService.consultarSituacaoCadastral(validCpf), returnsNormally);
      });

      test('deve aceitar parâmetros opcionais de contratante e autor', () async {
        // Arrange
        const validCpf = TestHelper.validCpf;
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
          () => ccmeiService.consultarSituacaoCadastral(validCpf, contratanteNumero: customContratante, autorPedidoDadosNumero: customAutor),
          returnsNormally,
        );
      });
    });

    group('Validações de entrada', () {
      test('deve validar formato de CNPJ corretamente', () {
        // Arrange
        const validCnpj = TestHelper.validCnpj;
        const invalidCnpj = '12345678901234';

        // Act & Assert
        expect(() => ValidationUtils.validateCNPJ(validCnpj), returnsNormally);
        expect(() => ValidationUtils.validateCNPJ(invalidCnpj), throwsA(isA<Exception>()));
      });
    });
  });
}
