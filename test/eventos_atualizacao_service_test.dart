import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';
import 'test_helper.dart';

void main() {
  group('EventosAtualizacaoService Tests', () {
    late EventosAtualizacaoService eventosService;
    late ApiClient apiClient;

    setUp(() {
      apiClient = TestHelper.createMockApiClient();
      eventosService = EventosAtualizacaoService(apiClient);
    });

    group('solicitarEventosPF', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        final cpfs = [contribuinteNumero];
        const evento = TipoEvento.dctfWeb;

        // Act & Assert
        expect(() => eventosService.solicitarEventosPF(cpfs: cpfs, evento: evento), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        final cpfs = [contribuinteNumero];
        const evento = TipoEvento.dctfWeb;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => eventosService.solicitarEventosPF(cpfs: cpfs, evento: evento), returnsNormally);
      });
    });

    group('obterEventosPF', () {
      test('deve lançar exceção quando protocolo é inválido', () async {
        // Arrange
        const protocoloInvalido = '123';
        const evento = TipoEvento.dctfWeb;

        // Act & Assert
        expect(() => eventosService.obterEventosPF(protocolo: protocoloInvalido, evento: evento), throwsA(isA<ArgumentError>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const protocolo = '550e8400-e29b-41d4-a716-446655440000';
        const evento = TipoEvento.dctfWeb;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => eventosService.obterEventosPF(protocolo: protocolo, evento: evento), returnsNormally);
      });
    });

    group('solicitarEventosPJ', () {
      test('deve lançar exceção quando cliente não está autenticado', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        final cnpjs = [contribuinteNumero];
        const evento = TipoEvento.dctfWeb;

        // Act & Assert
        expect(() => eventosService.solicitarEventosPJ(cnpjs: cnpjs, evento: evento), throwsA(isA<Exception>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        final cnpjs = [contribuinteNumero];
        const evento = TipoEvento.dctfWeb;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => eventosService.solicitarEventosPJ(cnpjs: cnpjs, evento: evento), returnsNormally);
      });
    });

    group('obterEventosPJ', () {
      test('deve lançar exceção quando protocolo é inválido', () async {
        // Arrange
        const protocoloInvalido = '123';
        const evento = TipoEvento.dctfWeb;

        // Act & Assert
        expect(() => eventosService.obterEventosPJ(protocolo: protocoloInvalido, evento: evento), throwsA(isA<ArgumentError>()));
      });

      test('deve aceitar parâmetros válidos', () async {
        // Arrange
        const protocolo = '550e8400-e29b-41d4-a716-446655440000';
        const evento = TipoEvento.dctfWeb;

        await apiClient.authenticate(
          consumerKey: TestHelper.validConsumerKey,
          consumerSecret: TestHelper.validConsumerSecret,
          certPath: TestHelper.validCertPath,
          certPassword: TestHelper.validCertPassword,
          contratanteNumero: TestHelper.validCnpj,
          autorPedidoDadosNumero: TestHelper.validCnpj,
        );

        // Act & Assert
        expect(() => eventosService.obterEventosPJ(protocolo: protocolo, evento: evento), returnsNormally);
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

      test('solicitarEObterEventosPF deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCpf;
        final cpfs = [contribuinteNumero];
        const evento = TipoEvento.dctfWeb;

        // Act & Assert
        expect(
          () => eventosService.solicitarEObterEventosPF(cpfs: cpfs, evento: evento, tempoEsperaCustomizado: Duration(milliseconds: 100)),
          returnsNormally,
        );
      });

      test('solicitarEObterEventosPJ deve funcionar', () async {
        // Arrange
        const contribuinteNumero = TestHelper.validCnpj;
        final cnpjs = [contribuinteNumero];
        const evento = TipoEvento.dctfWeb;

        // Act & Assert
        expect(
          () => eventosService.solicitarEObterEventosPJ(cnpjs: cnpjs, evento: evento, tempoEsperaCustomizado: Duration(milliseconds: 100)),
          returnsNormally,
        );
      });
    });

    group('Validações de entrada', () {
      test('deve validar data corretamente', () {
        // Arrange
        const dataValida = '20240101';
        const dataInvalida = '2024013';

        // Act & Assert
        expect(() => EventosAtualizacaoUtils.validarData(dataValida), returnsNormally);
        expect(() => EventosAtualizacaoUtils.validarData(dataInvalida), throwsA(isA<Exception>()));
      });

      test('deve validar período corretamente', () {
        // Arrange
        const dataInicial = '20240101';
        const dataFinal = '20240131';
        const dataFinalInvalida = '20231201';

        // Act & Assert
        expect(() => EventosAtualizacaoUtils.validarPeriodo(dataInicial, dataFinal), returnsNormally);
        expect(() => EventosAtualizacaoUtils.validarPeriodo(dataInicial, dataFinalInvalida), throwsA(isA<Exception>()));
      });

      test('deve validar protocolo corretamente', () {
        // Arrange
        const protocoloValido = '550e8400-e29b-41d4-a716-446655440000';
        const protocoloInvalido = '123';

        // Act & Assert
        expect(() => EventosAtualizacaoUtils.validarProtocolo(protocoloValido), returnsNormally);
        expect(() => EventosAtualizacaoUtils.validarProtocolo(protocoloInvalido), throwsA(isA<Exception>()));
      });

      test('deve validar tipos de evento', () {
        // Arrange
        const tiposValidos = [TipoEvento.dctfWeb, TipoEvento.caixaPostal, TipoEvento.pagamentoWeb];

        // Act & Assert
        for (final tipo in tiposValidos) {
          expect(tipo.toString(), isNotEmpty);
        }
      });

      test('deve validar tipos de contribuinte', () {
        // Arrange
        const tiposValidos = [TipoContribuinte.pessoaFisica, TipoContribuinte.pessoaJuridica];

        // Act & Assert
        for (final tipo in tiposValidos) {
          expect(tipo.toString(), isNotEmpty);
        }
      });
    });
  });
}
