import 'package:test/test.dart';
import '../lib/integra_contador_api.dart';

void main() {
  group('Integra Contador API - Ambiente de Demonstração', () {
    late IntegraContadorExtendedService service;

    setUp(() {
      service = IntegraContadorFactory.createTrialService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Teste de conectividade', () async {
      final result = await service.testarConectividade();
      expect(result.isSuccess, isTrue);
    });

    test('Consulta de declarações PGDASD', () async {
      final result = await service.consultarDeclaracoesSN(
        documento: '00000000000000',
        anoCalendario: '2018',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Geração de DAS do Simples Nacional', () async {
      final result = await service.gerarDASSN(
        documento: '00000000000100',
        periodoApuracao: '201801',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta da última declaração/recibo', () async {
      final result = await service.consultarUltimaDeclaracaoSN(
        documento: '00000000000000',
        anoCalendario: '2018',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta de declaração/recibo específico', () async {
      final result = await service.consultarDeclaracaoReciboSN(
        documento: '00000000000000',
        numeroDeclaracao: '00000000201801001',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta de extrato do DAS', () async {
      final result = await service.consultarExtratoDAS(
        documento: '00000000000000',
        periodoApuracao: '201801',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });
  });
}

