import 'package:test/test.dart';
import '../lib/integra_contador_api.dart';

void main() {
  group('Integra Contador API - REGIMEAPURACAO (Ambiente de Demonstração)', () {
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

    test('Consulta do regime de apuração atual', () async {
      final pedido = PedidoDados(
        identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
        servico: 'REGIMEAPURACAO.CONSULTAR',
        parametros: {
          'periodo_apuracao': '202401',
        },
      );

      final result = await service.consultar(pedido);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });

    test('Consulta do histórico de regimes de apuração', () async {
      final pedido = PedidoDados(
        identificacao: IntegraContadorHelper.criarIdentificacao('00000000000000'),
        servico: 'REGIMEAPURACAO.CONSULTAR_HISTORICO',
        parametros: {
          'ano_calendario': '2024',
        },
      );

      final result = await service.consultar(pedido);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data?.dados, isNotNull);
    });
  });
}

