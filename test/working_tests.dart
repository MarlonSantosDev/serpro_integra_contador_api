import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('SERPRO Integra Contador API - Working Tests', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
    });

    group('Test Helper Tests', () {
      test('deve criar cliente API válido', () {
        final client = TestHelper.createMockApiClient();
        expect(client, isNotNull);
        expect(client.isAuthenticated, isFalse);
      });

      test('deve criar dados de autenticação válidos', () {
        final authData = TestHelper.createValidAuthData();
        expect(authData['consumerKey'], equals(TestHelper.validConsumerKey));
        expect(authData['consumerSecret'], equals(TestHelper.validConsumerSecret));
        expect(authData['certPath'], equals(TestHelper.validCertPath));
        expect(authData['certPassword'], equals(TestHelper.validCertPassword));
        expect(authData['contratanteNumero'], equals(TestHelper.validCnpj));
        expect(authData['autorPedidoDadosNumero'], equals(TestHelper.validCnpj));
      });

      test('deve validar respostas corretamente', () {
        expect(TestHelper.isValidResponse({'status': 'success'}), isTrue);
        expect(TestHelper.isValidResponse(null), isFalse);
        expect(TestHelper.isValidErrorMessage('Erro de teste'), isTrue);
        expect(TestHelper.isValidErrorMessage(''), isFalse);
      });
    });

    group('CcmeiService Tests', () {
      late CcmeiService ccmeiService;

      setUp(() {
        ccmeiService = CcmeiService(apiClient);
      });

      test('deve lançar exceção quando CNPJ é inválido', () async {
        const invalidCnpj = '12345678901234';

        expect(() => ccmeiService.emitirCcmei(invalidCnpj), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        const validCnpj = TestHelper.validCnpj;

        expect(() => ccmeiService.emitirCcmei(validCnpj), throwsA(isA<Exception>()));
      });

      test('deve aceitar CNPJ válido após autenticação', () async {
        const validCnpj = TestHelper.validCnpj;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        expect(() => ccmeiService.emitirCcmei(validCnpj), returnsNormally);
      });
    });

    group('PgmeiService Tests', () {
      late PgmeiService pgmeiService;

      setUp(() {
        pgmeiService = PgmeiService(apiClient);
      });

      test('deve lançar exceção quando CNPJ é inválido', () async {
        const invalidCnpj = '12345678901234';
        const periodoApuracao = '202401';

        expect(() => pgmeiService.gerarDas(invalidCnpj, periodoApuracao), throwsA(isA<Exception>()));
      });

      test('deve lançar exceção quando período é inválido', () async {
        const validCnpj = TestHelper.validCnpj;
        const invalidPeriodo = '202413';

        expect(() => pgmeiService.gerarDas(validCnpj, invalidPeriodo), throwsA(isA<ArgumentError>()));
      });

      test('deve aceitar parâmetros válidos após autenticação', () async {
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

        expect(() => pgmeiService.gerarDas(validCnpj, periodoApuracao), returnsNormally);
      });
    });

    group('ProcuracoesService Tests', () {
      late ProcuracoesService procuracoesService;

      setUp(() {
        procuracoesService = ProcuracoesService(apiClient);
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        const outorgante = TestHelper.validCnpj;
        const outorgado = TestHelper.validCpf;

        expect(() => procuracoesService.obterProcuracao(outorgante, outorgado), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos após autenticação', () async {
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

        expect(() => procuracoesService.obterProcuracao(outorgante, outorgado), returnsNormally);
      });

      test('deve validar CPF corretamente', () {
        expect(procuracoesService.isCpfValido('12345678901'), isTrue);
        expect(procuracoesService.isCpfValido('123456789'), isFalse);
      });

      test('deve validar CNPJ corretamente', () {
        expect(procuracoesService.isCnpjValido('12345678000100'), isTrue);
        expect(procuracoesService.isCnpjValido('123456780001'), isFalse);
      });

      test('deve detectar tipo de documento corretamente', () {
        expect(procuracoesService.detectarTipoDocumento('12345678901'), equals('1'));
        expect(procuracoesService.detectarTipoDocumento('12345678000100'), equals('2'));
      });

      test('deve formatar CPF corretamente', () {
        expect(procuracoesService.formatarCpf('12345678901'), equals('123.456.789-01'));
      });

      test('deve formatar CNPJ corretamente', () {
        expect(procuracoesService.formatarCnpj('12345678000100'), equals('12.345.678/0001-00'));
      });
    });

    group('CaixaPostalService Tests', () {
      late CaixaPostalService caixaPostalService;

      setUp(() {
        caixaPostalService = CaixaPostalService(apiClient);
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        const contribuinte = TestHelper.validCnpj;

        expect(() => caixaPostalService.obterListaMensagensPorContribuinte(contribuinte), throwsA(isA<Exception>()));
      });

      test('deve aceitar contribuinte válido após autenticação', () async {
        const contribuinte = TestHelper.validCnpj;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        expect(() => caixaPostalService.obterListaMensagensPorContribuinte(contribuinte), returnsNormally);
      });

      test('deve aceitar métodos de conveniência', () async {
        const contribuinte = TestHelper.validCnpj;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        expect(() => caixaPostalService.listarTodasMensagens(contribuinte), returnsNormally);

        expect(() => caixaPostalService.listarMensagensNaoLidas(contribuinte), returnsNormally);

        expect(() => caixaPostalService.listarMensagensLidas(contribuinte), returnsNormally);

        expect(() => caixaPostalService.listarMensagensFavoritas(contribuinte), returnsNormally);
      });
    });

    group('ApiClient Tests', () {
      test('deve autenticar corretamente', () async {
        expect(apiClient.isAuthenticated, isFalse);

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        expect(apiClient.isAuthenticated, isTrue);
      });

      test('deve gerenciar cache de procurador', () {
        const tokenProcurador = 'token-teste-123456789';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        expect(apiClient.hasProcuradorToken, isFalse);
        expect(apiClient.procuradorToken, isNull);

        apiClient.setProcuradorToken(tokenProcurador, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

        expect(apiClient.hasProcuradorToken, isTrue);
        expect(apiClient.procuradorToken, equals(tokenProcurador));

        apiClient.clearProcuradorCache();

        expect(apiClient.hasProcuradorToken, isFalse);
        expect(apiClient.procuradorToken, isNull);
      });

      test('deve obter informações do cache de procurador', () {
        const tokenProcurador = 'token-teste-123456789';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        apiClient.setProcuradorToken(tokenProcurador, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

        final cacheInfo = apiClient.procuradorCacheInfo;

        expect(cacheInfo, isNotNull);
        expect(cacheInfo!['token'], contains('token-te'));
        expect(cacheInfo['is_valido'], isTrue);
        expect(cacheInfo['contratante_numero'], equals(contratanteNumero));
        expect(cacheInfo['autor_pedido_dados_numero'], equals(autorPedidoDadosNumero));
      });
    });

    group('ValidationUtils Tests', () {
      test('deve validar CNPJ corretamente', () {
        expect(() => ValidationUtils.validateCNPJ(TestHelper.validCnpj), returnsNormally);
        expect(() => ValidationUtils.validateCNPJ('12345678901234'), throwsA(isA<Exception>()));
      });

      test('deve validar período corretamente', () {
        expect(() => ValidationUtils.validatePeriodo('202401'), returnsNormally);
        expect(() => ValidationUtils.validatePeriodo('202413'), throwsA(isA<ArgumentError>()));
      });

      test('deve validar ano corretamente', () {
        expect(() => ValidationUtils.validateAno('2024'), returnsNormally);
        expect(() => ValidationUtils.validateAno('20'), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
