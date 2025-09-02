import 'package:test/test.dart';
import '../lib/integra_contador_api.dart';

void main() {
  group('Integra Contador API - PGMEI (Ambiente de Demonstração)', () {
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

    test('Consulta de DAS do MEI', () async {
      final pedido = PedidoDados(
        identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
        servico: 'PGMEI.CONSULTAR_DAS',
        parametros: {
          'periodo_apuracao': '202401',
        },
      );

      final result = await service.consultar(pedido);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Geração de DAS do MEI', () async {
      final pedido = PedidoDados(
        identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
        servico: 'PGMEI.GERAR_DAS',
        parametros: {
          'periodo_apuracao': '202401',
        },
      );

      final result = await service.emitir(pedido);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta de extrato do DAS do MEI', () async {
      final pedido = PedidoDados(
        identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
        servico: 'PGMEI.CONSULTAR_EXTRATO',
        parametros: {
          'periodo_apuracao': '202401',
        },
      );

      final result = await service.consultar(pedido);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });
  });
}

