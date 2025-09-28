class Mensagem {
  final String codigo;
  final String texto;

  Mensagem({required this.codigo, required this.texto});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      codigo: json['codigo'].toString(),
      texto: json['texto'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }

  /// Verifica se é uma mensagem de sucesso
  bool get isSucesso => codigo.contains('[Sucesso-PARCSN-ESP]');

  /// Verifica se é uma mensagem de aviso
  bool get isAviso => codigo.contains('[Aviso-PARCSN-ESP]');

  /// Verifica se é uma mensagem de erro
  bool get isErro => codigo.contains('[Erro-PARCSN-ESP]');

  /// Verifica se é uma mensagem de entrada incorreta
  bool get isEntradaIncorreta =>
      codigo.contains('[EntradaIncorreta-PARCSN-ESP]');

  @override
  String toString() {
    return 'Mensagem(codigo: $codigo, texto: $texto)';
  }
}
