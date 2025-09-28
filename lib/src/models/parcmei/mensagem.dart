class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(codigo: json['codigo']?.toString() ?? '', texto: json['texto']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se é uma mensagem de sucesso
  bool get isSucesso => codigo.contains('Sucesso') || codigo.contains('SUCESSO');

  /// Verifica se é uma mensagem de erro
  bool get isErro => codigo.contains('ERRO') || codigo.contains('Erro');

  /// Verifica se é uma mensagem de aviso
  bool get isAviso => codigo.contains('AVISO') || codigo.contains('Aviso');

  /// Verifica se é uma mensagem específica do PARCMEI
  bool get isParcmei => codigo.contains('PARCMEI');

  @override
  String toString() {
    return '$codigo: $texto';
  }
}
