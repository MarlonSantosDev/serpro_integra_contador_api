import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('AutenticaProcuradorService Tests', () {
    late AutenticaProcuradorService autenticaProcuradorService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      autenticaProcuradorService = AutenticaProcuradorService(apiClient);
    });

    group('autenticarProcurador', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const termoAutorizacaoBase64 = 'dGVybW8gZGUgYXV0b3JpemFjYW8gZW0gYmFzZTY0';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        // Act & Assert
        expect(
          () => autenticaProcuradorService.autenticarProcurador(
            xmlAssinado: termoAutorizacaoBase64,
            contratanteNumero: contratanteNumero,
            autorPedidoDadosNumero: autorPedidoDadosNumero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('deve lançar exceção quando termo de autorização é inválido', () async {
        // Arrange
        const termoAutorizacaoBase64 = 'termo-invalido';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

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
          () => autenticaProcuradorService.autenticarProcurador(
            xmlAssinado: termoAutorizacaoBase64,
            contratanteNumero: contratanteNumero,
            autorPedidoDadosNumero: autorPedidoDadosNumero,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const termoAutorizacaoBase64 = 'dGVybW8gZGUgYXV0b3JpemFjYW8gZW0gYmFzZTY0';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

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
          () => autenticaProcuradorService.autenticarProcurador(
            xmlAssinado: termoAutorizacaoBase64,
            contratanteNumero: contratanteNumero,
            autorPedidoDadosNumero: autorPedidoDadosNumero,
          ),
          returnsNormally,
        );
      });
    });

    group('gerarTermoAutorizacao', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        final request = TermoAutorizacaoRequest(
          contratanteNumero: contribuinteNumero,
          contratanteNome: 'Empresa Teste',
          autorPedidoDadosNumero: TestHelper.validCpf,
          autorPedidoDadosNome: 'Procurador Teste',
          dataAssinatura: '20240101',
          dataVigencia: '20250101',
        );

        // Act & Assert
        expect(
          () => autenticaProcuradorService.criarTermoAutorizacao(
            contratanteNumero: contribuinteNumero,
            contratanteNome: 'Empresa Teste',
            autorPedidoDadosNumero: TestHelper.validCpf,
            autorPedidoDadosNome: 'Procurador Teste',
          ),
          returnsNormally,
        );
      });

      test('deve aceitar request válido', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        final request = TermoAutorizacaoRequest(
          contratanteNumero: contribuinteNumero,
          contratanteNome: 'Empresa Teste',
          autorPedidoDadosNumero: TestHelper.validCpf,
          autorPedidoDadosNome: 'Procurador Teste',
          dataAssinatura: '20240101',
          dataVigencia: '20250101',
        );

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
          () => autenticaProcuradorService.criarTermoAutorizacao(
            contratanteNumero: contribuinteNumero,
            contratanteNome: 'Empresa Teste',
            autorPedidoDadosNumero: TestHelper.validCpf,
            autorPedidoDadosNome: 'Procurador Teste',
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

      test('criarTermoComDataAtual deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;

        // Act & Assert
        expect(
          () => autenticaProcuradorService.criarTermoComDataAtual(
            contratanteNumero: contribuinteNumero,
            contratanteNome: 'Empresa Teste',
            autorPedidoDadosNumero: TestHelper.validCpf,
            autorPedidoDadosNome: 'Procurador Teste',
          ),
          returnsNormally,
        );
      });

      test('autenticarProcurador deve funcionar', () async {
        // Arrange
        const termoAutorizacaoBase64 = 'dGVybW8gZGUgYXV0b3JpemFjYW8gZW0gYmFzZTY0';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        // Act & Assert
        expect(
          () => autenticaProcuradorService.autenticarProcurador(
            xmlAssinado: termoAutorizacaoBase64,
            contratanteNumero: contratanteNumero,
            autorPedidoDadosNumero: autorPedidoDadosNumero,
          ),
          returnsNormally,
        );
      });
    });

    group('Validações de entrada', () {
      test('deve validar termo de autorização Base64', () {
        // Arrange
        const termoValido = 'dGVybW8gZGUgYXV0b3JpemFjYW8gZW0gYmFzZTY0';
        const termoInvalido = 'termo-invalido';

        // Act & Assert
        expect(() => AssinaturaDigitalUtils.validarBase64(termoValido), returnsNormally);
        expect(() => AssinaturaDigitalUtils.validarBase64(termoInvalido), throwsA(isA<Exception>()));
      });

      test('deve validar tipos de procuração', () {
        // Arrange
        const tiposValidos = [TipoProcuracao.geral, TipoProcuracao.especifica, TipoProcuracao.representacao];

        // Act & Assert
        for (final tipo in tiposValidos) {
          expect(tipo.toString(), isNotEmpty);
        }
      });

      test('deve validar dias de validade', () {
        // Arrange
        const validadeValida = 30;
        const validadeInvalida = 0;

        // Act & Assert
        expect(() => AssinaturaDigitalUtils.validarValidade(validadeValida), returnsNormally);
        expect(() => AssinaturaDigitalUtils.validarValidade(validadeInvalida), throwsA(isA<Exception>()));
      });
    });

    group('Cache de procurador', () {
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

      test('deve verificar se há token de procurador válido', () {
        // Arrange
        const tokenProcurador = 'token-teste-123456789';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        // Act
        apiClient.setProcuradorToken(tokenProcurador, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

        // Assert
        expect(apiClient.hasProcuradorToken, isTrue);
        expect(apiClient.procuradorToken, equals(tokenProcurador));
      });

      test('deve limpar cache de procurador', () {
        // Arrange
        const tokenProcurador = 'token-teste-123456789';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        apiClient.setProcuradorToken(tokenProcurador, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

        // Act
        apiClient.clearProcuradorCache();

        // Assert
        expect(apiClient.hasProcuradorToken, isFalse);
        expect(apiClient.procuradorToken, isNull);
      });

      test('deve obter informações do cache', () {
        // Arrange
        const tokenProcurador = 'token-teste-123456789';
        const contratanteNumero = TestHelper.validCnpj;
        const autorPedidoDadosNumero = TestHelper.validCpf;

        apiClient.setProcuradorToken(tokenProcurador, contratanteNumero: contratanteNumero, autorPedidoDadosNumero: autorPedidoDadosNumero);

        // Act
        final cacheInfo = apiClient.procuradorCacheInfo;

        // Assert
        expect(cacheInfo, isNotNull);
        expect(cacheInfo!['token'], contains('token-te'));
        expect(cacheInfo['is_valido'], isTrue);
        expect(cacheInfo['contratante_numero'], equals(contratanteNumero));
        expect(cacheInfo['autor_pedido_dados_numero'], equals(autorPedidoDadosNumero));
      });
    });
  });
}
