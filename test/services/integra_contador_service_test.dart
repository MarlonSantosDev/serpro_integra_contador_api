import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/services/integra_contador_service.dart';
import '../../lib/models/identificacao.dart';
import '../../lib/models/pedido_dados.dart';
import '../../lib/models/dados_saida.dart';
import '../../lib/exceptions/api_exception.dart';

import 'integra_contador_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('IntegraContadorService', () {
    late MockClient mockClient;
    late IntegraContadorService service;

    setUp(() {
      mockClient = MockClient();
      service = IntegraContadorService(
        jwtToken: 'test_token',
        httpClient: mockClient,
      );
    });

    group('Consultar', () {
      test('deve retornar sucesso para consulta válida', () async {
        // Arrange
        final responseBody = {
          'resultado': 'sucesso',
          'status': 'ok',
          'dados': {
            'situacao_fiscal': 'regular',
            'debitos_pendentes': false,
          },
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(responseBody),
              200,
            ));

        final pedido = PedidoDados.consultaSituacaoFiscal(
          identificacao: Identificacao.cpf('11144477735'),
          anoBase: '2024',
        );

        // Act
        final result = await service.consultar(pedido);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.situacaoFiscal, equals('regular'));
        expect(result.data?.debitosPendentes, isFalse);
      });

      test('deve retornar erro para resposta 400', () async {
        // Arrange
        final errorBody = {
          'type': 'validation_error',
          'title': 'Erro de Validação',
          'status': 400,
          'detail': 'CPF inválido',
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(errorBody),
              400,
            ));

        final pedido = PedidoDados.consultaSituacaoFiscal(
          identificacao: Identificacao.cpf('12345678901'),
          anoBase: '2024',
        );

        // Act
        final result = await service.consultar(pedido);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error, isA<ValidationException>());
        expect(result.error?.message, equals('CPF inválido'));
      });

      test('deve fazer retry para erro 500', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode({
                'type': 'server_error',
                'title': 'Erro Interno do Servidor',
                'status': 500,
                'detail': 'Internal Server Error',
              }),
              500,
            ));

        final pedido = PedidoDados.consultaSituacaoFiscal(
          identificacao: Identificacao.cpf('11144477735'),
          anoBase: '2024',
        );

        // Act
        final result = await service.consultar(pedido);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.error, isA<ServerException>());
        
        // Verifica se fez 3 tentativas (maxRetries padrão)
        verify(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(3);
      });
    });

    group('Métodos de conveniência', () {
      test('consultarSituacaoFiscal deve funcionar com CPF', () async {
        // Arrange
        final responseBody = {
          'resultado': 'sucesso',
          'status': 'ok',
          'dados': {'situacao_fiscal': 'regular'},
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(responseBody),
              200,
            ));

        // Act
        final result = await service.consultarSituacaoFiscal(
          documento: '11144477735',
          anoBase: '2024',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.situacaoFiscal, equals('regular'));
      });

      test('consultarSituacaoFiscal deve funcionar com CNPJ', () async {
        // Arrange
        final responseBody = {
          'resultado': 'sucesso',
          'status': 'ok',
          'dados': {'situacao_fiscal': 'regular'},
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(responseBody),
              200,
            ));

        // Act
        final result = await service.consultarSituacaoFiscal(
          documento: '11222333000181',
          anoBase: '2024',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.situacaoFiscal, equals('regular'));
      });

      test('emitirDARF deve funcionar corretamente', () async {
        // Arrange
        final responseBody = {
          'resultado': 'sucesso',
          'status': 'ok',
          'dados': {
            'codigo_barras': '12345678901234567890123456789012345678901234',
            'linha_digitavel': '12345.67890 12345.678901 23456.789012 3 45678901234567890',
            'valor_total': '1600.50',
          },
        };

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(responseBody),
              200,
            ));

        // Act
        final result = await service.emitirDARF(
          documento: '11222333000181',
          codigoReceita: '0220',
          periodoApuracao: '012024',
          valorPrincipal: '1500.00',
          valorMulta: '75.00',
          valorJuros: '25.50',
          dataVencimento: DateTime(2024, 2, 20),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data?.codigoBarras, isNotNull);
        expect(result.data?.linhaDigitavel, isNotNull);
        expect(result.data?.valorTotal, equals('1600.50'));
      });
    });

    group('ApiResult', () {
      test('map deve transformar dados em caso de sucesso', () {
        final result = ApiResult.success(DadosSaida(status: 'ok'));
        
        final mapped = result.map((data) => data.status?.toUpperCase());
        
        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, equals('OK'));
      });

      test('map deve manter erro em caso de falha', () {
        final error = ValidationException('Erro de teste');
        final result = ApiResult<DadosSaida>.failure(error);
        
        final mapped = result.map((data) => data.status?.toUpperCase());
        
        expect(mapped.isFailure, isTrue);
        expect(mapped.error, equals(error));
      });

      test('mapAsync deve funcionar corretamente', () async {
        final result = ApiResult.success(DadosSaida(status: 'ok'));
        
        final mapped = await result.mapAsync((data) async {
          await Future.delayed(Duration(milliseconds: 10));
          return data.status?.toUpperCase();
        });
        
        expect(mapped.isSuccess, isTrue);
        expect(mapped.data, equals('OK'));
      });
    });

    group('IntegraContadorServiceBuilder', () {
      test('deve construir serviço com configurações básicas', () {
        final service = IntegraContadorServiceBuilder()
            .withJwtToken('test_token')
            .build();
        
        expect(service, isNotNull);
      });

      test('deve construir serviço com todas as configurações', () {
        final config = ApiConfig(
          timeout: Duration(seconds: 60),
          maxRetries: 5,
        );
        
        final service = IntegraContadorServiceBuilder()
            .withJwtToken('test_token')
            .withProcuradorToken('procurador_token')
            .withConfig(config)
            .withHttpClient(mockClient)
            .build();
        
        expect(service, isNotNull);
      });

      test('deve lançar erro se JWT token não for fornecido', () {
        expect(
          () => IntegraContadorServiceBuilder().build(),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deve configurar timeout usando método de conveniência', () {
        final service = IntegraContadorServiceBuilder()
            .withJwtToken('test_token')
            .withTimeout(Duration(seconds: 45))
            .build();
        
        expect(service, isNotNull);
      });

      test('deve configurar maxRetries usando método de conveniência', () {
        final service = IntegraContadorServiceBuilder()
            .withJwtToken('test_token')
            .withMaxRetries(5)
            .build();
        
        expect(service, isNotNull);
      });
    });
  });
}

