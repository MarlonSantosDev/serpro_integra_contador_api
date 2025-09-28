class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo']?.toString() ?? '',
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se é uma mensagem de sucesso
  bool get isSucesso => codigo.contains('Sucesso');

  /// Verifica se é uma mensagem de erro
  bool get isErro => codigo.contains('Erro') || codigo.contains('Falha');

  /// Verifica se é uma mensagem de aviso
  bool get isAviso => codigo.contains('Aviso') || codigo.contains('Atenção');

  /// Verifica se é uma mensagem de informação
  bool get isInformacao =>
      codigo.contains('Info') || codigo.contains('Informação');

  @override
  String toString() {
    return 'Mensagem(codigo: $codigo, texto: $texto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mensagem && other.codigo == codigo && other.texto == texto;
  }

  @override
  int get hashCode => codigo.hashCode ^ texto.hashCode;
}
