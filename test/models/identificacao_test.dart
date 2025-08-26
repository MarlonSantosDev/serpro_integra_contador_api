import 'package:test/test.dart';
import '../../lib/models/identificacao.dart';

void main() {
  group('Identificacao', () {
    group('CPF', () {
      test('deve criar identificação com CPF válido', () {
        final identificacao = Identificacao.cpf('12345678909');

        expect(identificacao.cpf, equals('12345678909'));
        expect(identificacao.tipo, equals('CPF'));
        expect(identificacao.numeroFormatado, equals('123.456.789-09'));
      });

      test('deve remover formatação do CPF', () {
        final identificacao = Identificacao.cpf('123.456.789-09');

        expect(identificacao.cpf, equals('12345678909'));
      });

      test('deve validar CPF correto', () {
        final identificacao = Identificacao.cpf('11144477735');

        expect(identificacao.isValid, isTrue);
      });

      test('deve invalidar CPF incorreto', () {
        final identificacao = Identificacao.cpf('12345678901');

        expect(identificacao.isValid, isFalse);
      });

      test('deve invalidar CPF com todos os dígitos iguais', () {
        final identificacao = Identificacao.cpf('11111111111');

        expect(identificacao.isValid, isFalse);
      });

      test('deve invalidar CPF com tamanho incorreto', () {
        final identificacao = Identificacao.cpf('123456789');

        expect(identificacao.isValid, isFalse);
      });
    });

    group('CNPJ', () {
      test('deve criar identificação com CNPJ válido', () {
        final identificacao = Identificacao.cnpj('11222333000181');

        expect(identificacao.cnpj, equals('11222333000181'));
        expect(identificacao.tipo, equals('CNPJ'));
        expect(identificacao.numeroFormatado, equals('11.222.333/0001-81'));
      });

      test('deve remover formatação do CNPJ', () {
        final identificacao = Identificacao.cnpj('11.222.333/0001-81');

        expect(identificacao.cnpj, equals('11222333000181'));
      });

      test('deve validar CNPJ correto', () {
        final identificacao = Identificacao.cnpj('11222333000181');

        expect(identificacao.isValid, isTrue);
      });

      test('deve invalidar CNPJ incorreto', () {
        final identificacao = Identificacao.cnpj('11222333000180');

        expect(identificacao.isValid, isFalse);
      });

      test('deve invalidar CNPJ com todos os dígitos iguais', () {
        final identificacao = Identificacao.cnpj('11111111111111');

        expect(identificacao.isValid, isFalse);
      });

      test('deve invalidar CNPJ com tamanho incorreto', () {
        final identificacao = Identificacao.cnpj('1122233300018');

        expect(identificacao.isValid, isFalse);
      });
    });

    group('JSON', () {
      test('deve serializar para JSON', () {
        final identificacao = Identificacao.cpf('12345678909');
        final json = identificacao.toJson();

        expect(json['cpf'], equals('12345678909'));
        expect(json['tipoNi'], isNotNull);
      });

      test('deve deserializar de JSON', () {
        final json = {
          'cpf': '12345678909',
          'tipoNi': {'codigo': '1', 'descricao': 'CPF'},
        };

        final identificacao = Identificacao.fromJson(json);

        expect(identificacao.cpf, equals('12345678909'));
        expect(identificacao.tipoNi?.codigo, equals('1'));
      });
    });

    group('Equality', () {
      test('deve ser igual quando todos os campos são iguais', () {
        final id1 = Identificacao.cpf('12345678909');
        final id2 = Identificacao.cpf('12345678909');

        expect(id1, equals(id2));
        expect(id1.hashCode, equals(id2.hashCode));
      });

      test('deve ser diferente quando os campos são diferentes', () {
        final id1 = Identificacao.cpf('12345678909');
        final id2 = Identificacao.cpf('98765432100');

        expect(id1, isNot(equals(id2)));
      });
    });

    group('toString', () {
      test('deve retornar string formatada para CPF', () {
        final identificacao = Identificacao.cpf('12345678909');

        expect(identificacao.toString(), contains('CPF'));
        expect(identificacao.toString(), contains('123.456.789-09'));
      });

      test('deve retornar string formatada para CNPJ', () {
        final identificacao = Identificacao.cnpj('11222333000181');

        expect(identificacao.toString(), contains('CNPJ'));
        expect(identificacao.toString(), contains('11.222.333/0001-81'));
      });
    });
  });
}
