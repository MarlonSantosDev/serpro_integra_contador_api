class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(codigo: json['codigo'].toString(), texto: json['texto'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se a mensagem indica sucesso
  bool get isSucesso => codigo.contains('Sucesso') || codigo.contains('SUCESSO');

  /// Verifica se a mensagem indica erro
  bool get isErro => codigo.contains('Erro') || codigo.contains('ERRO');

  /// Verifica se a mensagem indica aviso
  bool get isAviso => codigo.contains('Aviso') || codigo.contains('AVISO');

  @override
  String toString() {
    return 'Mensagem(codigo: $codigo, texto: $texto)';
  }
}
