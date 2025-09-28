/// Modelo de requisição para consultar código de receita SICALC (CONSULTAAPOIORECEITAS52)
class ConsultarReceitaRequest {
  final int codigoReceita;

  ConsultarReceitaRequest({required this.codigoReceita});

  /// Converte para JSON string para ser usado no campo 'dados' do PedidoDados
  String toDadosJson() {
    final Map<String, dynamic> dados = {'codigoReceita': codigoReceita.toString()};

    return _mapToJsonString(dados);
  }

  /// Converte Map para JSON string
  String _mapToJsonString(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    buffer.write('{');

    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('"${entry.key}":');
      buffer.write('"${entry.value}"');

      if (i < entries.length - 1) {
        buffer.write(',');
      }
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Valida os dados da requisição
  List<String> validar() {
    final List<String> erros = [];

    if (codigoReceita <= 0) {
      erros.add('Código da receita deve ser maior que zero');
    }

    return erros;
  }

  /// Cria uma cópia com novos valores
  ConsultarReceitaRequest copyWith({int? codigoReceita}) {
    return ConsultarReceitaRequest(codigoReceita: codigoReceita ?? this.codigoReceita);
  }

  @override
  String toString() {
    return 'ConsultarReceitaRequest(codigoReceita: $codigoReceita)';
  }
}
