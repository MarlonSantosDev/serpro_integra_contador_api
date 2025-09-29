/// Enums para tipos de procuração
enum TipoProcuracao {
  /// Procuração geral
  geral('geral'),

  /// Procuração específica
  especifica('especifica'),

  /// Procuração de representação
  representacao('representacao');

  const TipoProcuracao(this.value);

  final String value;

  @override
  String toString() => value;
}
