/// Modelo de requisição para gerar código de barras de DARF calculado (GERARDARFCODBARRA53)
class GerarCodigoBarrasRequest {
  final int numeroDocumento;

  GerarCodigoBarrasRequest({required this.numeroDocumento});

  /// Converte para JSON string para ser usado no campo 'dados' do PedidoDados
  String toDadosJson() {
    final Map<String, dynamic> dados = {
      'numeroDocumento': numeroDocumento.toString(),
    };

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

    if (numeroDocumento <= 0) {
      erros.add('Número do documento deve ser maior que zero');
    }

    return erros;
  }

  /// Cria uma cópia com novos valores
  GerarCodigoBarrasRequest copyWith({int? numeroDocumento}) {
    return GerarCodigoBarrasRequest(
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
    );
  }

  @override
  String toString() {
    return 'GerarCodigoBarrasRequest(numeroDocumento: $numeroDocumento)';
  }
}
