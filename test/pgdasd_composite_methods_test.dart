import 'package:test/test.dart';
import 'package:serpro_integra_contador_api/serpro_integra_contador_api.dart';

/// Teste de validação de tipos e assinaturas dos métodos compostos
void main() {
  group('PGDASD Composite Methods - Type Validation', () {
    test('ConsultarUltimaDeclaracaoComPagamentoResponse deve estender a classe base', () {
      // Arrange
      final baseResponse = ConsultarUltimaDeclaracaoResponse(status: 200, mensagens: [], dados: null);

      // Act
      final compositeResponse = ConsultarUltimaDeclaracaoComPagamentoResponse.fromBase(baseResponse: baseResponse, dasPago: true);

      // Assert
      expect(compositeResponse, isA<ConsultarUltimaDeclaracaoResponse>());
      expect(compositeResponse.dasPago, isTrue);
      expect(compositeResponse.status, equals(200));
      expect(compositeResponse.sucesso, isTrue);
    });

    test('ConsultarUltimaDeclaracaoComPagamentoResponse.toJson deve incluir dasPago', () {
      // Arrange
      final response = ConsultarUltimaDeclaracaoComPagamentoResponse(status: 200, mensagens: [], dados: null, dasPago: false);

      // Act
      final json = response.toJson();

      // Assert
      expect(json, containsPair('dasPago', false));
      expect(json, containsPair('status', 200));
    });

    test('EntregarDeclaracaoComDasResponse deve ter getters corretos - sucesso', () {
      // Arrange
      final response = EntregarDeclaracaoComDasResponse(status: 200, mensagens: [], dadosDeclaracao: null, dadosDas: null);

      // Assert
      expect(response.sucesso, isTrue);
      expect(response.declaracaoEntregue, isFalse);
      expect(response.dasGerado, isFalse);
    });

    test('EntregarDeclaracaoComDasResponse deve ter getters corretos - erro', () {
      // Arrange
      final response = EntregarDeclaracaoComDasResponse(status: 500, mensagens: [], dadosDeclaracao: null, dadosDas: null);

      // Assert
      expect(response.sucesso, isFalse);
      expect(response.declaracaoEntregue, isFalse);
      expect(response.dasGerado, isFalse);
    });

    test('EntregarDeclaracaoComDasResponse.toJson deve incluir todos os campos', () {
      // Arrange
      final response = EntregarDeclaracaoComDasResponse(status: 200, mensagens: [], dadosDeclaracao: null, dadosDas: null);

      // Act
      final json = response.toJson();

      // Assert
      expect(json, containsPair('status', 200));
      expect(json, containsPair('sucesso', true));
      expect(json, containsPair('declaracaoEntregue', false));
      expect(json, containsPair('dasGerado', false));
      expect(json.containsKey('mensagens'), isTrue);
    });

    test('PgdasdService deve ter método consultarUltimaDeclaracaoComPagamento', () {
      // Arrange
      final apiClient = ApiClient();
      final service = PgdasdService(apiClient);

      // Assert - verificar que o método existe
      expect(service.consultarUltimaDeclaracaoComPagamento, isA<Function>());
    });

    test('PgdasdService deve ter método entregarDeclaracaoComDas', () {
      // Arrange
      final apiClient = ApiClient();
      final service = PgdasdService(apiClient);

      // Assert - verificar que o método existe
      expect(service.entregarDeclaracaoComDas, isA<Function>());
    });
  });
}
