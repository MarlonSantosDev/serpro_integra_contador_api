import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('DctfWebService Tests', () {
    late DctfWebService dctfWebService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      dctfWebService = DctfWebService(apiClient);
    });

    group('gerarDocumentoArrecadacao', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(
          () => dctfWebService.gerarDocumentoArrecadacao(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

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
          () => dctfWebService.gerarDocumentoArrecadacao(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          returnsNormally,
        );
      });

      test('deve aceitar parâmetros opcionais', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';
        const diaPA = '15';
        const cnoAfericao = 12345;
        const numeroReciboEntrega = 987654321;
        const numProcReclamatoria = '12345678901234567890';
        const dataAcolhimentoProposta = 20240115;
        final idsSistemaOrigem = [SistemaOrigem.esocial];

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
          () => dctfWebService.gerarDocumentoArrecadacao(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            mesPA: mesPA,
            diaPA: diaPA,
            cnoAfericao: cnoAfericao,
            numeroReciboEntrega: numeroReciboEntrega,
            numProcReclamatoria: numProcReclamatoria,
            dataAcolhimentoProposta: dataAcolhimentoProposta,
            idsSistemaOrigem: idsSistemaOrigem,
          ),
          returnsNormally,
        );
      });
    });

    group('consultarReciboTransmissao', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(
          () => dctfWebService.consultarReciboTransmissao(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

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
          () => dctfWebService.consultarReciboTransmissao(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          returnsNormally,
        );
      });
    });

    group('consultarDeclaracaoCompleta', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(
          () => dctfWebService.consultarDeclaracaoCompleta(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

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
          () => dctfWebService.consultarDeclaracaoCompleta(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          returnsNormally,
        );
      });
    });

    group('consultarXmlDeclaracao', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(
          () => dctfWebService.consultarXmlDeclaracao(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

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
          () => dctfWebService.consultarXmlDeclaracao(contribuinteNumero: contribuinteNumero, categoria: categoria, anoPA: anoPA, mesPA: mesPA),
          returnsNormally,
        );
      });
    });

    group('transmitirDeclaracao', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const xmlAssinadoBase64 = 'PD94bWwgdmVyc2lvbj0iMS4wIj8+';

        // Act & Assert
        expect(
          () => dctfWebService.transmitirDeclaracao(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            xmlAssinadoBase64: xmlAssinadoBase64,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deve lançar exceção quando XML Base64 é inválido', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const xmlAssinadoBase64 = 'xml-invalido';

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
          () => dctfWebService.transmitirDeclaracao(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            xmlAssinadoBase64: xmlAssinadoBase64,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deve aceitar XML Base64 válido', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const xmlAssinadoBase64 =
            'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPENvbnRldWRvRGVjbGFyYWNhbz4KICA8Y2F0ZWdvcmlhRENURj40MDwvY2F0ZWdvcmlhRENURj4KICA8cGVyQXB1cmFjYW8+MjAyNDAxPC9wZXJBcHVyYWNhbz4KICA8aW5zY0NvbnRyaWI+MTEyMjIzMzMwMDAxODE8L2luc2NDb250cmliPgo8L0NvbnRldWRvRGVjbGFyYWNhbz4=';

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
          () => dctfWebService.transmitirDeclaracao(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            mesPA: '01',
            xmlAssinadoBase64: xmlAssinadoBase64,
          ),
          returnsNormally,
        );
      });
    });

    group('gerarDocumentoArrecadacaoAndamento', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(
          () => dctfWebService.gerarDocumentoArrecadacaoAndamento(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            mesPA: mesPA,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        const mesPA = '01';

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
          () => dctfWebService.gerarDocumentoArrecadacaoAndamento(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            mesPA: mesPA,
          ),
          returnsNormally,
        );
      });
    });

    group('Métodos de conveniência', () {
      setUp(() async {
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );
      });

      test('gerarDarfGeralMensal deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(() => dctfWebService.gerarDarfGeralMensal(contribuinteNumero: contribuinteNumero, anoPA: anoPA, mesPA: mesPA), returnsNormally);
      });

      test('gerarDarfPfMensal deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        const anoPA = '2024';
        const mesPA = '01';

        // Act & Assert
        expect(() => dctfWebService.gerarDarfPfMensal(contribuinteNumero: contribuinteNumero, anoPA: anoPA, mesPA: mesPA), returnsNormally);
      });

      test('gerarDarf13Salario deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const anoPA = '2024';

        // Act & Assert
        expect(() => dctfWebService.gerarDarf13Salario(contribuinteNumero: contribuinteNumero, anoPA: anoPA), returnsNormally);
      });

      test('gerarDarf13Salario para pessoa física deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        const anoPA = '2024';

        // Act & Assert
        expect(() => dctfWebService.gerarDarf13Salario(contribuinteNumero: contribuinteNumero, anoPA: anoPA, isPessoaFisica: true), returnsNormally);
      });
    });

    group('consultarXmlETransmitir', () {
      setUp(() async {
        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );
      });

      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        Future<String> assinadorXml(String xmlBase64) async => xmlBase64;

        // Criar novo cliente não autenticado
        final newApiClient = TestHelper.createMockApiClient();
        final newDctfWebService = DctfWebService(newApiClient);

        // Act & Assert
        expect(
          () => newDctfWebService.consultarXmlETransmitir(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            mesPA: '01',
            assinadorXml: assinadorXml,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        const categoria = CategoriaDctf.geralMensal;
        const anoPA = '2024';
        Future<String> assinadorXml(String xmlBase64) async => xmlBase64;

        // Act & Assert
        expect(
          () => dctfWebService.consultarXmlETransmitir(
            contribuinteNumero: contribuinteNumero,
            categoria: categoria,
            anoPA: anoPA,
            mesPA: '01',
            assinadorXml: assinadorXml,
          ),
          returnsNormally,
        );
      });
    });
  });
}
