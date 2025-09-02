import 'package:test/test.dart';
import '../lib/integra_contador_api.dart';

void main() {
  group('Integra Contador API - DEFIS (Ambiente de Demonstração)', () {
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

    test('Consulta de declarações DEFIS', () async {
      final result = await service.consultarDeclaracoesDEFIS(
        documento: '00000000000000',
        anoCalendario: '2018',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta da última declaração DEFIS', () async {
      final result = await service.consultarUltimaDeclaracaoDEFIS(
        documento: '00000000000000',
        anoCalendario: '2018',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta de declaração DEFIS específica', () async {
      final result = await service.consultarDeclaracaoReciboDEFIS(
        documento: '00000000000000',
        numeroDeclaracao: '00000000201801',
      );
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });
  });
}

