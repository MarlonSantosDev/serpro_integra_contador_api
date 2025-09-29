import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('SicalcService Tests', () {
    late SicalcService sicalcService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      sicalcService = SicalcService(apiClient);
    });

    group('Testes básicos de autenticação', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        const codigoReceita = 190;

        // Act & Assert
        expect(
          () => sicalcService.consultarCodigoReceita(contribuinteNumero: contribuinteNumero, codigoReceita: codigoReceita),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos após autenticação', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        const codigoReceita = 190;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => sicalcService.consultarCodigoReceita(contribuinteNumero: contribuinteNumero, codigoReceita: codigoReceita), returnsNormally);
      });
    });

    group('gerarCodigoBarrasDarf', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        const numeroDocumento = 123456789012345;

        // Act & Assert
        expect(
          () => sicalcService.gerarCodigoBarrasDarf(contribuinteNumero: contribuinteNumero, numeroDocumento: numeroDocumento),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos após autenticação', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        const numeroDocumento = 123456789012345;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => sicalcService.gerarCodigoBarrasDarf(contribuinteNumero: contribuinteNumero, numeroDocumento: numeroDocumento), returnsNormally);
      });
    });

    group('Validações básicas', () {
      test('deve validar UF corretamente', () {
        // Arrange
        const ufValida = 'SP';
        const ufInvalida = 'XX';

        // Act & Assert
        expect(SicalcUtils.isValidUF(ufValida), isTrue);
        expect(SicalcUtils.isValidUF(ufInvalida), isFalse);
      });

      test('deve validar código de receita', () {
        // Arrange
        const codigoValido = 190;
        const codigoInvalido = 0;

        // Act & Assert
        expect(SicalcUtils.isValidCodigoReceita(codigoValido), isTrue);
        expect(SicalcUtils.isValidCodigoReceita(codigoInvalido), isFalse);
      });

      test('deve validar período de apuração mensal', () {
        // Arrange
        const dataPAValida = '01/2024';
        const dataPAInvalida = '13/2024';

        // Act & Assert
        expect(SicalcUtils.isValidDataPA(dataPAValida, 'ME'), isTrue);
        expect(SicalcUtils.isValidDataPA(dataPAInvalida, 'ME'), isFalse);
      });

      test('deve validar período de apuração anual', () {
        // Arrange
        const dataPAValida = '2024';
        const dataPAInvalida = '20';

        // Act & Assert
        expect(SicalcUtils.isValidDataPA(dataPAValida, 'AN'), isTrue);
        expect(SicalcUtils.isValidDataPA(dataPAInvalida, 'AN'), isFalse);
      });
    });
  });
}
