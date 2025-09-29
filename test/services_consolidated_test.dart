import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('Services Consolidated Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
    });

    group('ProcuracoesService Tests', () {
      late ProcuracoesService procuracoesService;

      setUp(() {
        procuracoesService = ProcuracoesService(apiClient);
      });

      test('obterProcuracao deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const outorgante = TestHelper.validCnpj;
        const outorgado = TestHelper.validCpf;

        // Act & Assert
        expect(() => procuracoesService.obterProcuracao(outorgante, outorgado), throwsA(isA<Exception>()));
      });

      test('obterProcuracao deve aceitar parâmetros válidos', () async {
        // Arrange
        const outorgante = TestHelper.validCnpj;
        const outorgado = TestHelper.validCpf;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => procuracoesService.obterProcuracao(outorgante, outorgado), returnsNormally);
      });
    });

    group('CaixaPostalService Tests', () {
      late CaixaPostalService caixaPostalService;

      setUp(() {
        caixaPostalService = CaixaPostalService(apiClient);
      });

      test('listarTodasMensagens deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;

        // Act & Assert
        expect(() => caixaPostalService.listarTodasMensagens(contribuinteNumero), throwsA(isA<Exception>()));
      });

      test('listarTodasMensagens deve aceitar contribuinte válido', () async {
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
        expect(() => caixaPostalService.listarTodasMensagens(contribuinteNumero), returnsNormally);
      });

      test('temMensagensNovas deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;

        // Act & Assert
        expect(() => caixaPostalService.temMensagensNovas(contribuinteNumero), throwsA(isA<Exception>()));
      });

      test('temMensagensNovas deve aceitar parâmetros válidos', () async {
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
        expect(() => caixaPostalService.temMensagensNovas(contribuinteNumero), returnsNormally);
      });
    });

    group('DteService Tests', () {
      late DteService dteService;

      setUp(() {
        dteService = DteService(apiClient);
      });

      test('obterIndicadorDte deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const cnpj = TestHelper.validCnpj;

        // Act & Assert
        expect(() => dteService.obterIndicadorDte(cnpj), throwsA(isA<Exception>()));
      });

      test('obterIndicadorDte deve aceitar CNPJ válido', () async {
        // Arrange
        const cnpj = TestHelper.validCnpj;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => dteService.obterIndicadorDte(cnpj), returnsNormally);
      });
    });

    group('Validações básicas', () {
      test('deve validar CNPJ', () {
        const cnpjValido = TestHelper.validCnpj;
        const cnpjInvalido = '123';
        expect(() => ValidationUtils.validateCNPJ(cnpjValido), returnsNormally);
        expect(() => ValidationUtils.validateCNPJ(cnpjInvalido), throwsA(isA<ArgumentError>()));
      });

      test('deve validar CPF', () {
        const cpfValido = TestHelper.validCpf;
        const cpfInvalido = '123';
        expect(() => ValidationUtils.validateCPF(cpfValido), returnsNormally);
        expect(() => ValidationUtils.validateCPF(cpfInvalido), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
